//
//  PREDManager.h
//  PreDemObjc
//
//  Created by WangSiyu on 21/02/2017.
//  Copyright © 2017 pre-engineering. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PREDNullability.h"
#import "PREDEnums.h"

NS_ASSUME_NONNULL_BEGIN

@interface PREDManager: NSObject

#pragma mark - Public Methods

///-----------------------------------------------------------------------------
/// @name Initialization
///-----------------------------------------------------------------------------


/**
 Initialize the manager with a PreDem app identifier.
 
 @param appKey The app key that should be used.
 @param serviceDomain The service domain that data will be reported to or requested from.
 */
+ (void)startWithAppKey:(nonnull NSString *)appKey
          serviceDomain:(nonnull NSString *)serviceDomain;

/**
 *  diagnose current network environment
 *
 *  @param host     the end point you want this diagnose action perform with
 *  @param complete diagnose result can be retrieved from the block
 */
+ (void)diagnose:(nonnull NSString *)host
        complete:(nonnull PREDNetDiagCompleteHandler)complete;

+ (void)trackEventWithName:(nonnull NSString *)eventName
                     event:(nonnull NSDictionary *)event;

+ (void)trackEventsWithName:(nonnull NSString *)eventName
                     events:(nonnull NSArray<NSDictionary *>*)events;


///-----------------------------------------------------------------------------
/// @name SDK meta data
///-----------------------------------------------------------------------------

/**
 Returns the SDK Version (CFBundleShortVersionString).
 */
+ (NSString *)version;

/**
 Returns the SDK Build (CFBundleVersion) as a string.
 */
+ (NSString *)build;

#pragma mark - Public Properties

///-----------------------------------------------------------------------------
/// @name Debug Logging
///-----------------------------------------------------------------------------

/**
 This property is used indicate the amount of verboseness and severity for which
 you want to see log messages in the console.
 */
@property (class, nonatomic, assign) PREDLogLevel logLevel;

/**
 Set a custom block that handles all the log messages that are emitted from the SDK.
 
 You can use this to reroute the messages that would normally be logged by `NSLog();`
 to your own custom logging framework.
 
 An example of how to do this with NSLogger:
 
 ```
 [[PREDManager sharedPREDManager] setLogHandler:^(PREDLogMessageProvider messageProvider, PREDLogLevel logLevel, const char *file, const char *function, uint line) {
 LogMessageRawF(file, (int)line, function, @"PreDemObjc", (int)logLevel-1, messageProvider());
 }];
 ```
 
 or with CocoaLumberjack:
 
 ```
 [[PREDManager sharedPREDManager] setLogHandler:^(PREDLogMessageProvider messageProvider, PREDLogLevel logLevel, const char *file, const char *function, uint line) {
 [DDLog log:YES message:messageProvider() level:ddLogLevel flag:(DDLogFlag)(1 << (logLevel-1)) context:CocoaLumberjackContext file:file function:function line:line tag:nil];
 }];
 ```
 
 @param logHandler The block of type PREDLogHandler that will process all logged messages.
 */
+ (void)setLogHandler:(PREDLogHandler _Nullable )logHandler;

@end

NS_ASSUME_NONNULL_END
