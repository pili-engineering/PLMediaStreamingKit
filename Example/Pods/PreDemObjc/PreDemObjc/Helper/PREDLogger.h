//
//  PREDLogger.h
//  PreDemObjc
//
//  Created by WangSiyu on 21/02/2017.
//  Copyright © 2017 pre-engineering. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PREDEnums.h"

#define PREDLog(_level, _message) [PREDLogger logMessage:_message level:_level file:__FILE__ function:__PRETTY_FUNCTION__ line:__LINE__]

#define PREDLogError(format, ...)   PREDLog(PREDLogLevelError,   (^{ return [NSString stringWithFormat:(format), ##__VA_ARGS__]; }))
#define PREDLogWarning(format, ...) PREDLog(PREDLogLevelWarning, (^{ return [NSString stringWithFormat:(format), ##__VA_ARGS__]; }))
#define PREDLogDebug(format, ...)   PREDLog(PREDLogLevelDebug,   (^{ return [NSString stringWithFormat:(format), ##__VA_ARGS__]; }))
#define PREDLogVerbose(format, ...) PREDLog(PREDLogLevelVerbose, (^{ return [NSString stringWithFormat:(format), ##__VA_ARGS__]; }))

@interface PREDLogger : NSObject

+ (PREDLogLevel)currentLogLevel;
+ (void)setCurrentLogLevel:(PREDLogLevel)currentLogLevel;
+ (void)setLogHandler:(PREDLogHandler)logHandler;

+ (void)logMessage:(PREDLogMessageProvider)messageProvider level:(PREDLogLevel)loglevel file:(const char *)file function:(const char *)function line:(uint)line;

@end
