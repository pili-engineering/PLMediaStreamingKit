//
//  PREDURLSessionSwizzler.m
//  PreDemObjc
//
//  Created by WangSiyu on 14/03/2017.
//  Copyright © 2017 pre-engineering. All rights reserved.
//

#import "PREDURLSessionSwizzler.h"
#import <objc/runtime.h>
#import "PREDURLProtocol.h"

static BOOL s_isSwizzle = NO;

@implementation PREDURLSessionSwizzler

+ (void)setIsSwizzle:(BOOL)isSwizzle {
    s_isSwizzle = isSwizzle;
}

+ (BOOL)isSwizzle {
    return s_isSwizzle;
}

+ (void)load {
    self.isSwizzle=YES;
    Class cls = NSClassFromString(@"__NSCFURLSessionConfiguration") ?: NSClassFromString(@"NSURLSessionConfiguration");
    [self swizzleSelector:@selector(protocolClasses) fromClass:cls toClass:self];
    
}

+ (void)unload {
    self.isSwizzle=NO;
    Class cls = NSClassFromString(@"__NSCFURLSessionConfiguration") ?: NSClassFromString(@"NSURLSessionConfiguration");
    [self swizzleSelector:@selector(protocolClasses) fromClass:cls toClass:self];
    
}

+ (void)swizzleSelector:(SEL)selector fromClass:(Class)original toClass:(Class)stub {
    Method originalMethod = class_getInstanceMethod(original, selector);
    Method stubMethod = class_getInstanceMethod(stub, selector);
    if (!originalMethod || !stubMethod) {
        [NSException raise:NSInternalInconsistencyException format:@"Couldn't load NEURLSessionConfiguration."];
    }
    method_exchangeImplementations(originalMethod, stubMethod);
}

- (NSArray *)protocolClasses {
    return @[[PREDURLProtocol class]];
}

@end
