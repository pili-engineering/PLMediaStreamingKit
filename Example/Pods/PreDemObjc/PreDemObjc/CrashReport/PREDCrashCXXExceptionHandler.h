//
//  PREDCrashCXXExceptionHandler.h
//  PreDemObjc
//
//  Created by WangSiyu on 21/02/2017.
//  Copyright © 2017 pre-engineering. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PREDNullability.h"

typedef struct {
    const void * __nullable exception;
    const char * __nullable exception_type_name;
    const char * __nullable exception_message;
    uint32_t exception_frames_count;
    const uintptr_t * __nonnull exception_frames;
} PREDCrashUncaughtCXXExceptionInfo;

typedef void (*PREDCrashUncaughtCXXExceptionHandler)(
const PREDCrashUncaughtCXXExceptionInfo * __nonnull info
);

@interface PREDCrashUncaughtCXXExceptionHandlerManager : NSObject

+ (void)addCXXExceptionHandler:(nonnull PREDCrashUncaughtCXXExceptionHandler)handler;
+ (void)removeCXXExceptionHandler:(nonnull PREDCrashUncaughtCXXExceptionHandler)handler;

@end
