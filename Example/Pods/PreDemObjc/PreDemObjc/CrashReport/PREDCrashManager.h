//
//  PREDCrashManager.h
//  PreDemObjc
//
//  Created by WangSiyu on 21/02/2017.
//  Copyright © 2017 pre-engineering. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CrashReporter/CrashReporter.h>

@class PREDNetworkClient;

typedef NS_ENUM(NSUInteger, PREDCrashManagerStatus) {
    PREDCrashManagerStatusDisabled = 0,
    PREDCrashManagerStatusAlwaysAsk = 1,
    PREDCrashManagerStatusAutoSend = 2
};

typedef NS_ENUM(NSUInteger, PREDCrashManagerUserInput) {
    PREDCrashManagerUserInputDontSend = 0,
    PREDCrashManagerUserInputSend = 1,
    PREDCrashManagerUserInputAlwaysSend = 2
};

@interface PREDCrashManager : NSObject

@property (nonatomic, assign, getter=isOnDeviceSymbolicationEnabled) BOOL enableOnDeviceSymbolication;

@property (nonatomic, assign, getter = isAppNotTerminatingCleanlyDetectionEnabled) BOOL enableAppNotTerminatingCleanlyDetection;


@property (nonatomic, readonly) BOOL didCrashInLastSession;

@property (nonatomic, readonly) BOOL didReceiveMemoryWarningInLastSession;


@property (nonatomic, strong) PREDNetworkClient *networkClient;

@property (nonatomic) NSUncaughtExceptionHandler *exceptionHandler;

@property (nonatomic, strong) NSFileManager *fileManager;

@property (nonatomic, strong) PREPLCrashReporter *plCrashReporter;

@property (nonatomic, strong) NSString *crashesDir;

- (instancetype)initWithNetworkClient:(PREDNetworkClient *)networkClient;

- (void)startManager;

- (void)stopManager;

@end
