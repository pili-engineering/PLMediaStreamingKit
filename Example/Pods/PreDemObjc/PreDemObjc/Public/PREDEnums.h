//
//  PREDEnums.h
//  PreDemObjc
//
//  Created by WangSiyu on 21/02/2017.
//  Copyright © 2017 pre-engineering. All rights reserved.
//

#ifndef PreDemObjc_Enums_h
#define PreDemObjc_Enums_h

#import "PREDNetDiagResult.h"

/**
 *  PreDemObjc Log Levels
 */
typedef NS_ENUM(NSUInteger, PREDLogLevel) {
    /**
     *  Logging is disabled
     */
    PREDLogLevelNone = 0,
    /**
     *  Only errors will be logged
     */
    PREDLogLevelError = 1,
    /**
     *  Errors and warnings will be logged
     */
    PREDLogLevelWarning = 2,
    /**
     *  Debug information will be logged
     */
    PREDLogLevelDebug = 3,
    /**
     *  Logging will be very chatty
     */
    PREDLogLevelVerbose = 4
};

/**
 *  PreDemObjc Crash Reporter error domain
 */
typedef NS_ENUM (NSInteger, PREDCrashErrorReason) {
    /**
     *  Unknown error
     */
    PREDCrashErrorUnknown,
    /**
     *  API Server rejected app version
     */
    PREDCrashAPIAppVersionRejected,
    /**
     *  API Server returned empty response
     */
    PREDCrashAPIReceivedEmptyResponse,
    /**
     *  Connection error with status code
     */
    PREDCrashAPIErrorWithStatusCode
};

typedef void (^PREDNetDiagCompleteHandler)(PREDNetDiagResult* result);

typedef NSString *(^PREDLogMessageProvider)(void);

typedef void (^PREDLogHandler)(PREDLogMessageProvider messageProvider, PREDLogLevel logLevel, const char *file, const char *function, uint line);

#endif /* PreDemObjc_Enums_h */
