//
//  PREDCrashManager.m
//  PreDemObjc
//
//  Created by WangSiyu on 21/02/2017.
//  Copyright © 2017 pre-engineering. All rights reserved.
//

#import <SystemConfiguration/SystemConfiguration.h>
#import "PREDemObjc.h"
#import "PREDPrivate.h"
#import "PREDHelper.h"
#import "PREDNetworkClient.h"
#import "PREDCrashManager.h"
#import "PREDCrashReportTextFormatter.h"
#import "PREDCrashCXXExceptionHandler.h"
#include <sys/sysctl.h>
#import "QiniuSDK.h"

#define CrashReportUploadRetryInterval        100
#define CrashReportUploadMaxTimes             5

// internal keys

static NSString *const kPREDAppWentIntoBackgroundSafely = @"PREDAppWentIntoBackgroundSafely";
static NSString *const kPREDAppDidReceiveLowMemoryNotification = @"PREDAppDidReceiveLowMemoryNotification";
static NSString *const kPREDFakeCrashReport = @"PREDFakeCrashAppString";
static NSString *const kPREDCrashKillSignal = @"SIGKILL";

// Temporary class until PLCR catches up
// We trick PLCR with an Objective-C exception.
//
// This code provides us access to the C++ exception message, including a correct stack trace.
//
@interface PREDCrashCXXExceptionWrapperException : NSException

- (instancetype)initWithCXXExceptionInfo:(const PREDCrashUncaughtCXXExceptionInfo *)info;

@end

@implementation PREDCrashCXXExceptionWrapperException {
    const PREDCrashUncaughtCXXExceptionInfo *_info;
}

- (instancetype)initWithCXXExceptionInfo:(const PREDCrashUncaughtCXXExceptionInfo *)info {
    extern char* __cxa_demangle(const char* mangled_name, char* output_buffer, size_t* length, int* status);
    char *demangled_name = &__cxa_demangle ? __cxa_demangle(info->exception_type_name ?: "", NULL, NULL, NULL) : NULL;
    
    if ((self = [super
                 initWithName:[NSString stringWithUTF8String:demangled_name ?: info->exception_type_name ?: ""]
                 reason:[NSString stringWithUTF8String:info->exception_message ?: ""]
                 userInfo:nil])) {
        _info = info;
    }
    return self;
}

- (NSArray *)callStackReturnAddresses {
    NSMutableArray *cxxFrames = [NSMutableArray arrayWithCapacity:_info->exception_frames_count];
    
    for (uint32_t i = 0; i < _info->exception_frames_count; ++i) {
        [cxxFrames addObject:[NSNumber numberWithUnsignedLongLong:_info->exception_frames[i]]];
    }
    return cxxFrames;
}

@end


// C++ Exception Handler
static void uncaught_cxx_exception_handler(const PREDCrashUncaughtCXXExceptionInfo *info) {
    // This relies on a LOT of sneaky internal knowledge of how PLCR works and should not be considered a long-term solution.
    NSGetUncaughtExceptionHandler()([[PREDCrashCXXExceptionWrapperException alloc] initWithCXXExceptionInfo:info]);
    abort();
}


@implementation PREDCrashManager {
    NSMutableArray *_crashFiles;
    NSFileManager  *_fileManager;
    QNUploadManager *_uploadManager;
    
    BOOL _sendingInProgress;
    BOOL _isSetup;
    
    BOOL _didLogLowMemoryWarning;
    
    id _appDidBecomeActiveObserver;
    id _appWillTerminateObserver;
    id _appDidEnterBackgroundObserver;
    id _appWillEnterForegroundObserver;
    id _appDidReceiveLowMemoryWarningObserver;
}

- (instancetype)initWithNetworkClient:(PREDNetworkClient *)networkClient {
    if ((self = [super init])) {
        _isSetup = NO;
        _networkClient = networkClient;
        _plCrashReporter = nil;
        _exceptionHandler = nil;
        _didCrashInLastSession = NO;
        _didLogLowMemoryWarning = NO;
        _fileManager = [[NSFileManager alloc] init];
        _crashFiles = [[NSMutableArray alloc] init];
        _crashesDir = PREDHelper.settingsDir;
        _uploadManager = [[QNUploadManager alloc] init];
    }
    return self;
}

- (void) dealloc {
    [self unregisterObservers];
}

#pragma mark - Public

/**
 *	 Main startup sequence initializing PLCrashReporter if it wasn't disabled
 */
- (void)startManager {
    [self registerObservers];
    
    if (!_isSetup) {
        static dispatch_once_t plcrPredicate;
        dispatch_once(&plcrPredicate, ^{
            /* Configure our reporter */
            
            PLCrashReporterSignalHandlerType signalHandlerType = PLCrashReporterSignalHandlerTypeBSD;
            
            PLCrashReporterSymbolicationStrategy symbolicationStrategy = PLCrashReporterSymbolicationStrategyNone;
            if (self.isOnDeviceSymbolicationEnabled) {
                symbolicationStrategy = PLCrashReporterSymbolicationStrategyAll;
            }
            
            PREPLCrashReporterConfig *config = [[PREPLCrashReporterConfig alloc] initWithSignalHandlerType: signalHandlerType
                                                                                     symbolicationStrategy: symbolicationStrategy];
            self.plCrashReporter = [[PREPLCrashReporter alloc] initWithConfiguration: config];
            
            // Check if we previously crashed
            if ([self.plCrashReporter hasPendingCrashReport]) {
                _didCrashInLastSession = YES;
                [self handleCrashReport];
            }
            
            
            if (PREDHelper.isDebuggerAttached) {
                PREDLogWarning(@"Detecting crashes is NOT enabled due to running the app with a debugger attached.");
            } else {
                // Multiple exception handlers can be set, but we can only query the top level error handler (uncaught exception handler).
                //
                // To check if PLCrashReporter's error handler is successfully added, we compare the top
                // level one that is set before and the one after PLCrashReporter sets up its own.
                //
                // With delayed processing we can then check if another error handler was set up afterwards
                // and can show a debug warning log message, that the dev has to make sure the "newer" error handler
                // doesn't exit the process itself, because then all subsequent handlers would never be invoked.
                //
                // Note: ANY error handler setup BEFORE PreDemObjc initialization will not be processed!
                
                // get the current top level error handler
                NSUncaughtExceptionHandler *initialHandler = NSGetUncaughtExceptionHandler();
                
                // PLCrashReporter may only be initialized once. So make sure the developer
                // can't break this
                NSError *error = NULL;
                
                // Enable the Crash Reporter
                if (![self.plCrashReporter enableCrashReporterAndReturnError: &error]) {
                    PREDLogError(@"Could not enable crash reporter: %@", [error localizedDescription]);
                }
                
                // get the new current top level error handler, which should now be the one from PLCrashReporter
                NSUncaughtExceptionHandler *currentHandler = NSGetUncaughtExceptionHandler();
                
                // do we have a new top level error handler? then we were successful
                if (currentHandler && currentHandler != initialHandler) {
                    self.exceptionHandler = currentHandler;
                    
                    PREDLogDebug(@"Exception handler successfully initialized.");
                } else {
                    // this should never happen, theoretically only if NSSetUncaugtExceptionHandler() has some internal issues
                    PREDLogError(@"Exception handler could not be set. Make sure there is no other exception handler set up!");
                }
                
                // Add the C++ uncaught exception handler, which is currently not handled by PLCrashReporter internally
                [PREDCrashUncaughtCXXExceptionHandlerManager addCXXExceptionHandler:uncaught_cxx_exception_handler];
            }
            _isSetup = YES;
        });
    }
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:kPREDAppDidReceiveLowMemoryNotification])
        _didReceiveMemoryWarningInLastSession = [[NSUserDefaults standardUserDefaults] boolForKey:kPREDAppDidReceiveLowMemoryNotification];
    
    if (!_didCrashInLastSession && self.isAppNotTerminatingCleanlyDetectionEnabled) {
        BOOL didAppSwitchToBackgroundSafely = YES;
        
        if ([[NSUserDefaults standardUserDefaults] valueForKey:kPREDAppWentIntoBackgroundSafely])
            didAppSwitchToBackgroundSafely = [[NSUserDefaults standardUserDefaults] boolForKey:kPREDAppWentIntoBackgroundSafely];
        
        if (!didAppSwitchToBackgroundSafely) {
            PREDLogVerbose(@"App kill detected, creating crash report.");
            [self createCrashReportForAppKill];
            _didCrashInLastSession = YES;
        }
    }
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
        [self appEnteredForeground];
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kPREDAppDidReceiveLowMemoryNotification];
    
    if(PREDHelper.isPreiOS8Environment) {
        // calling synchronize in pre-iOS 8 takes longer to sync than in iOS 8+, calling synchronize explicitly.
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [self triggerDelayedProcessing];
    PREDLogVerbose(@"CrashManager startManager has finished.");
}

- (void)stopManager {
    [self unregisterObservers];
}

#pragma mark - Private


/**
 * Remove a cached crash report
 *
 *  @param filename The base filename of the crash report
 */
- (void)cleanCrashReportWithFilename:(NSString *)filename {
    if (!filename) return;
    
    NSError *error = NULL;
    
    [_fileManager removeItemAtPath:filename error:&error];
    [_crashFiles removeObject:filename];
}

- (void) registerObservers {
    __weak typeof(self) weakSelf = self;
    
    if(nil == _appDidBecomeActiveObserver) {
        _appDidBecomeActiveObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification
                                                                                        object:nil
                                                                                         queue:NSOperationQueue.mainQueue
                                                                                    usingBlock:^(NSNotification *note) {
                                                                                        typeof(self) strongSelf = weakSelf;
                                                                                        [strongSelf triggerDelayedProcessing];
                                                                                    }];
    }
    
    if (nil ==  _appWillTerminateObserver) {
        _appWillTerminateObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillTerminateNotification
                                                                                      object:nil
                                                                                       queue:NSOperationQueue.mainQueue
                                                                                  usingBlock:^(NSNotification *note) {
                                                                                      typeof(self) strongSelf = weakSelf;
                                                                                      [strongSelf leavingAppSafely];
                                                                                  }];
    }
    
    if (nil ==  _appDidEnterBackgroundObserver) {
        _appDidEnterBackgroundObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification
                                                                                           object:nil
                                                                                            queue:NSOperationQueue.mainQueue
                                                                                       usingBlock:^(NSNotification *note) {
                                                                                           typeof(self) strongSelf = weakSelf;
                                                                                           [strongSelf leavingAppSafely];
                                                                                       }];
    }
    
    if (nil == _appWillEnterForegroundObserver) {
        _appWillEnterForegroundObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification
                                                                                            object:nil
                                                                                             queue:NSOperationQueue.mainQueue
                                                                                        usingBlock:^(NSNotification *note) {
                                                                                            typeof(self) strongSelf = weakSelf;
                                                                                            [strongSelf appEnteredForeground];
                                                                                        }];
    }
    
    if (nil == _appDidReceiveLowMemoryWarningObserver) {
        _appDidReceiveLowMemoryWarningObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification
                                                                                                   object:nil
                                                                                                    queue:NSOperationQueue.mainQueue
                                                                                               usingBlock:^(NSNotification *note) {
                                                                                                   // we only need to log this once
                                                                                                   if (!_didLogLowMemoryWarning) {
                                                                                                       [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kPREDAppDidReceiveLowMemoryNotification];
                                                                                                       _didLogLowMemoryWarning = YES;
                                                                                                       if(PREDHelper.isPreiOS8Environment) {
                                                                                                           // calling synchronize in pre-iOS 8 takes longer to sync than in iOS 8+, calling synchronize explicitly.
                                                                                                           [[NSUserDefaults standardUserDefaults] synchronize];
                                                                                                       }
                                                                                                   }
                                                                                               }];
    }
}

- (void) unregisterObservers {
    [self unregisterObserver:_appDidBecomeActiveObserver];
    [self unregisterObserver:_appWillTerminateObserver];
    [self unregisterObserver:_appDidEnterBackgroundObserver];
    [self unregisterObserver:_appWillEnterForegroundObserver];
    [self unregisterObserver:_appDidReceiveLowMemoryWarningObserver];
}

- (void) unregisterObserver:(id)observer {
    if (observer) {
        [[NSNotificationCenter defaultCenter] removeObserver:observer];
        observer = nil;
    }
}

- (void)leavingAppSafely {
    if (self.isAppNotTerminatingCleanlyDetectionEnabled) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kPREDAppWentIntoBackgroundSafely];
        if(PREDHelper.isPreiOS8Environment) {
            // calling synchronize in pre-iOS 8 takes longer to sync than in iOS 8+, calling synchronize explicitly.
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

- (void)appEnteredForeground {
    // we disable kill detection while the debugger is running, since we'd get only false positives if the app is terminated by the user using the debugger
    if (PREDHelper.isDebuggerAttached) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kPREDAppWentIntoBackgroundSafely];
    } else if (self.isAppNotTerminatingCleanlyDetectionEnabled) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kPREDAppWentIntoBackgroundSafely];
        
        static dispatch_once_t predAppData;
        
        dispatch_once(&predAppData, ^{
            if(PREDHelper.isPreiOS8Environment) {
                // calling synchronize in pre-iOS 8 takes longer to sync than in iOS 8+, calling synchronize explicitly.
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        });
    }
}

#pragma mark - PLCrashReporter

/**
 *	 Process new crash reports provided by PLCrashReporter
 *
 */
- (void) handleCrashReport {
    PREDLogVerbose(@"VERBOSE: Handling crash report");
    NSError *error = NULL;
    
    if (!self.plCrashReporter) return;
    
    // Try loading the crash report
    NSData *crashData = [[NSData alloc] initWithData:[self.plCrashReporter loadPendingCrashReportDataAndReturnError: &error]];
    
    if (crashData == nil) {
        PREDLogError(@"Could not load crash report: %@", error);
    } else {
        NSString *cacheFilename = [NSString stringWithFormat: @"%.0f", [NSDate timeIntervalSinceReferenceDate]];
        [crashData writeToFile:[_crashesDir stringByAppendingPathComponent: cacheFilename] atomically:YES];
    }
    [self.plCrashReporter purgePendingCrashReport];
}

/**
 *	Check if there are any new crash reports that are not yet processed
 *
 *	@return	`YES` if there is at least one new crash report found, `NO` otherwise
 */
- (BOOL)hasPendingCrashReport {
    if ([self.fileManager fileExistsAtPath:_crashesDir]) {
        NSError *error = NULL;
        
        NSArray *dirArray = [self.fileManager contentsOfDirectoryAtPath:_crashesDir error:&error];
        
        for (NSString *file in dirArray) {
            NSString *filePath = [_crashesDir stringByAppendingPathComponent:file];
            
            NSDictionary *fileAttributes = [self.fileManager attributesOfItemAtPath:filePath error:&error];
            if ([[fileAttributes objectForKey:NSFileType] isEqualToString:NSFileTypeRegular] &&
                [[fileAttributes objectForKey:NSFileSize] intValue] > 0 &&
                ![file hasSuffix:@".DS_Store"] &&
                ![file hasSuffix:@".plist"]) {
                [_crashFiles addObject:filePath];
            }
        }
    }
    
    if ([_crashFiles count] > 0) {
        PREDLogDebug(@"%lu pending crash reports found.", (unsigned long)[_crashFiles count]);
        return YES;
    } else {
        if (_didCrashInLastSession) {
            _didCrashInLastSession = NO;
        }
        
        return NO;
    }
}


#pragma mark - Crash Report Processing

- (void)triggerDelayedProcessing {
    PREDLogVerbose(@"VERBOSE: Triggering delayed crash processing.");
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(invokeDelayedProcessing) object:nil];
    [self performSelector:@selector(invokeDelayedProcessing) withObject:nil afterDelay:0.5];
}

/**
 * Delayed startup processing for everything that does not to be done in the app startup runloop
 *
 * - Checks if there is another exception handler installed that may block ours
 * - Present UI if the user has to approve new crash reports
 * - Send pending approved crash reports
 */
- (void)invokeDelayedProcessing {
    if (!PREDHelper.isRunningInAppExtension &&
        [[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) {
        return;
    }
    
    PREDLogDebug(@"Start delayed CrashManager processing");
    
    // was our own exception handler successfully added?
    if (self.exceptionHandler) {
        // get the current top level error handler
        NSUncaughtExceptionHandler *currentHandler = NSGetUncaughtExceptionHandler();
        
        // If the top level error handler differs from our own, then at least another one was added.
        // This could cause exception crashes not to be reported to PreDem. See log message for details.
        if (self.exceptionHandler != currentHandler) {
            PREDLogWarning(@"Another exception handler was added. If this invokes any kind exit() after processing the exception, which causes any subsequent error handler not to be invoked, these crashes will NOT be reported to PreDem!");
        }
    }
    
    if (!_sendingInProgress && [self hasPendingCrashReport]) {
        _sendingInProgress = YES;
        [self sendNextCrashReport];
    }
}
/**
 *  Creates a fake crash report because the app was killed while being in foreground
 */
- (void)createCrashReportForAppKill {
    NSString *fakeReportUUID = PREDHelper.UUID ?: @"???";
    NSString *fakeReporterKey = PREDHelper.UUID ?: @"???";
    
    NSString *fakeReportAppBundleIdentifier = PREDHelper.appBundleId;
    NSString *fakeReportDeviceModel = PREDHelper.deviceModel ?: @"Unknown";
    
    NSString *fakeSignalName = kPREDCrashKillSignal;
    
    NSMutableString *fakeReportString = [NSMutableString string];
    
    [fakeReportString appendFormat:@"Incident Identifier: %@\n", fakeReportUUID];
    [fakeReportString appendFormat:@"CrashReporter Key:   %@\n", fakeReporterKey];
    [fakeReportString appendFormat:@"Hardware Model:      %@\n", fakeReportDeviceModel];
    [fakeReportString appendFormat:@"Identifier:      %@\n", fakeReportAppBundleIdentifier];
    
    NSString *fakeReportAppVersionString = [NSString stringWithFormat:@"%@ (%@)", PREDHelper.appVersion, PREDHelper.appBuild];
    
    [fakeReportString appendFormat:@"Version:         %@\n", fakeReportAppVersionString];
    [fakeReportString appendString:@"Code Type:       ARM\n"];
    [fakeReportString appendString:@"\n"];
    
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    NSDateFormatter *rfc3339Formatter = [[NSDateFormatter alloc] init];
    [rfc3339Formatter setLocale:enUSPOSIXLocale];
    [rfc3339Formatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
    [rfc3339Formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSString *fakeCrashTimestamp = [rfc3339Formatter stringFromDate:[NSDate date]];
    
    // we use the current date, since we don't know when the kill actually happened
    [fakeReportString appendFormat:@"Date/Time:       %@\n", fakeCrashTimestamp];
    [fakeReportString appendFormat:@"OS Version:      %@\n", PREDHelper.osVersion];
    [fakeReportString appendString:@"Report Version:  104\n"];
    [fakeReportString appendString:@"\n"];
    [fakeReportString appendFormat:@"Exception Type:  %@\n", fakeSignalName];
    [fakeReportString appendString:@"Exception Codes: 00000020 at 0x8badf00d\n"];
    [fakeReportString appendString:@"\n"];
    [fakeReportString appendString:@"Application Specific Information:\n"];
    [fakeReportString appendString:@"The application did not terminate cleanly but no crash occured."];
    if (self.didReceiveMemoryWarningInLastSession) {
        [fakeReportString appendString:@" The app received at least one Low Memory Warning."];
    }
    [fakeReportString appendString:@"\n\n"];
    
    NSString *fakeReportFilename = [NSString stringWithFormat: @"%.0f", [NSDate timeIntervalSinceReferenceDate]];
    
    NSError *error = nil;
    
    if (![[fakeReportString dataUsingEncoding:NSUTF8StringEncoding] writeToFile:[_crashesDir stringByAppendingPathComponent:[fakeReportFilename stringByAppendingPathExtension:@"fake"]] options:NSDataWritingAtomic error:&error]) {
        PREDLogError(@"Writing fake crash report error: %@", error ?: @"unknown");
    }
}

/**
 *
 * Gathers all collected data and constructs the XML structure and starts the sending process
 */
- (void)sendNextCrashReport {
    NSError *error = NULL;
    
    if ([_crashFiles count] == 0)
        return;
    
    // we start sending always with the oldest pending one
    NSString *filename = [_crashFiles objectAtIndex:0];
    NSString *cacheFilename = [filename lastPathComponent];
    NSData *crashData = [NSData dataWithContentsOfFile:filename];
    NSDateFormatter *rfc3339Formatter = [[NSDateFormatter alloc] init];
    [rfc3339Formatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
    [rfc3339Formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSString *startTime = [rfc3339Formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:0]];
    NSString *crashTime = [rfc3339Formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:0]];
    if ([crashData length] > 0) {
        PREPLCrashReport *report = nil;
        NSString *crashLogString = nil;
        NSString *reportUUID = PREDHelper.UUID;
        
        if ([[cacheFilename pathExtension] isEqualToString:@"fake"]) {
            crashLogString = [[NSString alloc] initWithData:crashData encoding:NSUTF8StringEncoding];
        } else {
            report = [[PREPLCrashReport alloc] initWithData:crashData error:&error];
            if (report.uuidRef != NULL) {
                reportUUID = (NSString *) CFBridgingRelease(CFUUIDCreateString(NULL, report.uuidRef));
            }
            crashLogString = [PREDCrashReportTextFormatter stringValueForCrashReport:report crashReporterKey:PREDHelper.UUID];
            crashTime = [rfc3339Formatter stringFromDate:report.systemInfo.timestamp];
            if ([report.processInfo respondsToSelector:@selector(processStartTime)]) {
                if (report.systemInfo.timestamp && report.processInfo.processStartTime) {
                    startTime = [rfc3339Formatter stringFromDate:report.processInfo.processStartTime];
                }
            }
        }
        
        if (report == nil && crashLogString == nil) {
            PREDLogWarning(@"WARNING: Could not parse crash report");
            // we cannot do anything with this report, so delete it
            [self cleanCrashReportWithFilename:filename];
            // we don't continue with the next report here, even if there are to prevent calling sendCrashReports from itself again
            // the next crash will be automatically send on the next app start/becoming active event
            return;
        }
        NSString *md5 = [PREDHelper MD5:crashLogString];
        NSDictionary *param = @{@"md5": md5};
        __weak typeof(self) wSelf = self;
        [_networkClient getPath:@"crash-report-token/i" parameters:param completion:^(PREDHTTPOperation *operation, NSData *data, NSError *error) {
            __strong typeof(wSelf) strongSelf = wSelf;
            if (!error) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                if (!error && operation.response.statusCode < 400 && dic && [dic respondsToSelector:@selector(valueForKey:)] && [dic valueForKey:@"key"] && [dic valueForKey:@"token"]) {
                    NSString *key = [dic valueForKey:@"key"];
                    NSString *token = [dic valueForKey:@"token"];
                    NSDictionary *crashDic = @{
                                               @"app_bundle_id": PREDHelper.appBundleId,
                                               @"app_name": PREDHelper.appName,
                                               @"app_version": PREDHelper.appVersion,
                                               @"device_model": PREDHelper.deviceModel,
                                               @"os_platform": PREDHelper.osPlatform,
                                               @"os_version": PREDHelper.osVersion,
                                               @"os_build": PREDHelper.osBuild,
                                               @"sdk_version": PREDHelper.sdkVersion,
                                               @"sdk_id": PREDHelper.UUID,
                                               @"device_id": @"",
                                               @"report_uuid": reportUUID,
                                               @"crash_log_key": key,
                                               @"manufacturer": @"Apple",
                                               @"start_time": startTime,
                                               @"crash_time": crashTime,
                                               };
                    [strongSelf uploadCrashLog:crashLogString WithKey:key token:token crashDic:crashDic retryTimes:0];
                } else {
                    PREDLogError(@"get upload token fail: %@, drop report", error);
                    return;
                }
            } else {
                PREDLogError(@"get upload token fail: %@, drop report", error);
                return;
            }
        }];
        
    } else {
        // we cannot do anything with this report, so delete it
        [self cleanCrashReportWithFilename:filename];
    }
}

- (void)uploadCrashLog:(NSString *)crashLog WithKey:(NSString *)key token:(NSString *)token crashDic:(NSDictionary *)crashDic retryTimes:(NSInteger)retryTimes {
    __weak typeof(self) wSelf = self;
    [_uploadManager
     putData:[crashLog dataUsingEncoding:NSUTF8StringEncoding]
     key:key
     token: token
     complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
         __strong typeof(wSelf) strongSelf = wSelf;
         if (resp) {
             PREDLogDebug(@"Sending crash reports");
             [strongSelf->_networkClient postPath:@"crashes/i" parameters:crashDic completion:^(PREDHTTPOperation *operation, NSData *data, NSError *error) {
                 __strong typeof (wSelf) strongSelf = wSelf;
                 [strongSelf processUploadResultWithFilename:[strongSelf->_crashFiles objectAtIndex:0] responseData:data statusCode:operation.response.statusCode error:error];
             }];
         } else if (retryTimes < CrashReportUploadMaxTimes) {
             PREDLogWarning(@"upload log fail: %@, retry after: %d seconds", info.error, CrashReportUploadMaxTimes);
             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(CrashReportUploadRetryInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                 [strongSelf uploadCrashLog:crashLog WithKey:key token:token crashDic:crashDic retryTimes:retryTimes + 1];
                 return;
             });
         } else {
             PREDLogError(@"upload log fail: %@, drop report", info.error);
             return;
         }
     }
     option:nil];
}

// process upload response
- (void)processUploadResultWithFilename:(NSString *)filename responseData:(NSData *)responseData statusCode:(NSInteger)statusCode error:(NSError *)error {
    _sendingInProgress = NO;
    if (!error) {
        if (statusCode >= 200 && statusCode < 400) {
            [self cleanCrashReportWithFilename:filename];
            // only if sending the crash report went successfully, continue with the next one (if there are more)
            [self sendNextCrashReport];
        } else {
            error = [NSError errorWithDomain:kPREDCrashErrorDomain
                                        code:PREDCrashAPIErrorWithStatusCode
                                    userInfo:@{
                                               NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Sending failed with status code: %li", (long)statusCode]
                                               }];

        }
    }
    if (error) {
        PREDLogError(@"%@", error);
    }
}

@end
