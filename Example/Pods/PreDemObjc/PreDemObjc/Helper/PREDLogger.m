//
//  PREDLogger.m
//  PreDemObjc
//
//  Created by WangSiyu on 21/02/2017.
//  Copyright © 2017 pre-engineering. All rights reserved.
//

#import "PREDLogger.h"
#import "PreDemObjc.h"

@implementation PREDLogger

static PREDLogLevel _currentLogLevel = PREDLogLevelWarning;
static PREDLogHandler currentLogHandler;

static NSString *levelString(PREDLogLevel logLevel) {
    switch (logLevel) {
        case PREDLogLevelNone:
            return @"None";
            break;
        case PREDLogLevelError:
            return @"Error";
        case PREDLogLevelWarning:
            return @"Warning";
        case PREDLogLevelDebug:
            return @"Debug";
        case PREDLogLevelVerbose:
            return @"Verbose";
        default:
            return @"";
            break;
    }
}

PREDLogHandler defaultLogHandler = ^(PREDLogMessageProvider messageProvider, PREDLogLevel logLevel, const char *file, const char *function, uint line) {
    if (messageProvider) {
        if (_currentLogLevel < logLevel) {
            return;
        }
        NSLog((@"[PreDemObjc]%@: %s/%d %@"), levelString(logLevel), function, line, messageProvider());
    }
};

+ (void)initialize {
    currentLogHandler = defaultLogHandler;
}

+ (PREDLogLevel)currentLogLevel {
    return _currentLogLevel;
}

+ (void)setCurrentLogLevel:(PREDLogLevel)currentLogLevel {
    _currentLogLevel = currentLogLevel;
}

+ (void)setLogHandler:(PREDLogHandler)logHandler {
    currentLogHandler = logHandler;
}

+ (void)logMessage:(PREDLogMessageProvider)messageProvider level:(PREDLogLevel)loglevel file:(const char *)file function:(const char *)function line:(uint)line {
    if (currentLogHandler) {
        currentLogHandler(messageProvider, loglevel, file, function, line);
    }
}

@end
