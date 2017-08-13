//
//  PREDManager.m
//  PreDemObjc
//
//  Created by WangSiyu on 21/02/2017.
//  Copyright © 2017 pre-engineering. All rights reserved.
//

#import "PreDemObjc.h"
#import "PREDManagerPrivate.h"
#import "PREDPrivate.h"
#import "PREDHelper.h"
#import "PREDNetworkClient.h"
#import "PREDVersion.h"
#import "PREDConfigManager.h"
#import "PREDNetDiag.h"
#import "PREDURLProtocol.h"
#import "PREDCrashManager.h"
#import "PREDLagMonitorController.h"

static NSString* app_id(NSString* appKey){
    return [appKey substringToIndex:8];
}

@implementation PREDManager {
    BOOL _startManagerIsInvoked;
    
    BOOL _managersInitialized;
    
    PREDConfigManager *_configManager;
    
    PREDCrashManager *_crashManager;
    
    PREDLagMonitorController *_lagManager;
}


#pragma mark - Public Class Methods

+ (void)startWithAppKey:(nonnull NSString *)appKey
          serviceDomain:(nonnull NSString *)serviceDomain{
    if (![NSThread isMainThread]) {
        @throw [NSException exceptionWithName:@"InvalidEnvException" reason:@"You must start pre-dem in main thread" userInfo:nil];
    }
    [[self sharedPREDManager] startWithAppKey:appKey serviceDomain:serviceDomain];
}


+ (void)diagnose:(nonnull NSString *)host
        complete:(nonnull PREDNetDiagCompleteHandler)complete{
    [[self sharedPREDManager] diagnose:host complete:complete];
}

+ (void)trackEventWithName:(nonnull NSString *)eventName
                     event:(nonnull NSDictionary *)event {
    if (event == nil || eventName == nil) {
        return;
    }
    [[self sharedPREDManager].networkClient postPath:[NSString stringWithFormat:@"events/%@", eventName] parameters:@[event] completion:^(PREDHTTPOperation *operation, NSData *data, NSError *error) {
        PREDLogDebug(@"%@", [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil]);
    }];
}

+ (void)trackEventsWithName:(nonnull NSString *)eventName
                     events:(nonnull NSArray<NSDictionary *>*)events{
    if (events == nil || events.count == 0 || eventName == nil) {
        return;
    }
    
    [[self sharedPREDManager].networkClient postPath:[NSString stringWithFormat:@"events/%@", eventName] parameters:events completion:^(PREDHTTPOperation *operation, NSData *data, NSError *error) {
        PREDLogDebug(@"%@", [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil]);
    }];
}

+ (PREDLogLevel)logLevel {
    return PREDLogger.currentLogLevel;
}

+ (void)setLogLevel:(PREDLogLevel)logLevel {
    PREDLogger.currentLogLevel = logLevel;
}

+ (void)setLogHandler:(PREDLogHandler)logHandler {
    [PREDLogger setLogHandler:logHandler];
}

+ (NSString *)version {
    return [PREDVersion getSDKVersion];
}

+ (NSString *)build {
    return [PREDVersion getSDKBuild];
}

#pragma mark - Private Methods

+ (PREDManager *)sharedPREDManager {
    static PREDManager *sharedInstance = nil;
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        sharedInstance = [[PREDManager alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init {
    if ((self = [super init])) {
        _managersInitialized = NO;
        _networkClient = nil;
        _enableCrashManager = YES;
        _enableHttpMonitor = YES;
        _enableLagMonitor = YES;
        _startManagerIsInvoked = NO;
    }
    return self;
}


- (void)startWithAppKey:(NSString *)appKey serviceDomain:(NSString *)serviceDomain {
    [self initNetworkClientWithDomain:serviceDomain appKey:appKey];
    
    [self initializeModules];
    
    [self applyConfig:[_configManager getConfig]];
    
    [self startManager];
}

- (void)startManager {
    if (_startManagerIsInvoked) {
        PREDLogWarning(@"startManager should only be invoked once! This call is ignored.");
        return;
    }
    
    PREDLogDebug(@"Starting PREDManager");
    _startManagerIsInvoked = YES;
    
    // start CrashManager
    if (self.isCrashManagerEnabled) {
        PREDLogDebug(@"Starting CrashManager");
        
        [_crashManager startManager];
    }
    
    if (self.isHttpMonitorEnabled) {
        PREDLogDebug(@"Starting HttpManager");
        
        [PREDURLProtocol enableHTTPDem];
    }
    
    if (self.isLagMonitorEnabled) {
        PREDLogDebug(@"Starting LagManager");
        
        [_lagManager startMonitor];
    }
}

- (void)setEnableCrashManager:(BOOL)enableCrashManager {
    if (_enableCrashManager == enableCrashManager) {
        return;
    }
    _enableCrashManager = enableCrashManager;
    if (enableCrashManager) {
        [_crashManager startManager];
    } else {
        [_crashManager stopManager];
    }
}

- (void)setEnableHttpMonitor:(BOOL)enableHttpMonitor {
    if (_enableHttpMonitor == enableHttpMonitor) {
        return;
    }
    _enableHttpMonitor = enableHttpMonitor;
    if (enableHttpMonitor) {
        [PREDURLProtocol enableHTTPDem];
    } else {
        [PREDURLProtocol disableHTTPDem];
    }
}

- (void)setEnableLagMonitor:(BOOL)enableLagMonitor {
    if (_enableLagMonitor == enableLagMonitor) {
        return;
    }
    _enableLagMonitor = enableLagMonitor;
    if (enableLagMonitor) {
        [_lagManager startMonitor];
    } else {
        [_lagManager endMonitor];
    }
}

- (void)initNetworkClientWithDomain:(NSString *)aServerURL appKey:(NSString *)appKey {
    if (!aServerURL) {
        aServerURL = PRED_DEFAULT_DOMAIN;
    }
    if (![aServerURL hasPrefix:@"http://"] && ![aServerURL hasPrefix:@"https://"]) {
        aServerURL = [NSString stringWithFormat:@"http://%@", aServerURL];
    }
    
    aServerURL = [NSString stringWithFormat:@"%@/v1/%@/", aServerURL, app_id(appKey)];
    
    _networkClient = [[PREDNetworkClient alloc] initWithBaseURL:[NSURL URLWithString:aServerURL]];
}

- (void)initializeModules {
    if (_managersInitialized) {
        PREDLogWarning(@"The SDK should only be initialized once! This call is ignored.");
        return;
    }
    
    _startManagerIsInvoked = NO;
    
    _crashManager = [[PREDCrashManager alloc]
                     initWithNetworkClient:_networkClient];
    [PREDURLProtocol setClient:_networkClient];
    
    _configManager = [[PREDConfigManager alloc] initWithNetClient:_networkClient];
    _configManager.delegate = self;
    _lagManager = [[PREDLagMonitorController alloc] initWithNetworkClient:_networkClient];
    _managersInitialized = YES;
}

- (void)applyConfig:(PREDConfig *)config {
    self.enableCrashManager = config.crashReportEnabled;
    self.enableHttpMonitor = config.httpMonitorEnabled;
    self.enableLagMonitor = config.lagMonitorEnabled;
    _crashManager.enableOnDeviceSymbolication = config.onDeviceSymbolicationEnabled;
}

- (void)diagnose:(NSString *)host
        complete:(PREDNetDiagCompleteHandler)complete {
    [PREDNetDiag diagnose:host netClient:_networkClient complete:complete];
}

- (void)configManager:(PREDConfigManager *)manager didReceivedConfig:(PREDConfig *)config {
    [self applyConfig:config];
}

@end
