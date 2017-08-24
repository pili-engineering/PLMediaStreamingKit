//
//  QNUpToken.m
//  QiniuSDK
//
//  Created by bailong on 15/6/7.
//  Copyright (c) 2015年 Qiniu. All rights reserved.
//

#import "QNUrlSafeBase64.h"
#import "QNUpToken.h"

@interface QNUpToken ()

- (instancetype)init:(NSDictionary *)policy token:(NSString *)token;

@end

@implementation QNUpToken

- (instancetype)init:(NSDictionary *)policy token:(NSString *)token {
    if (self = [super init]) {
        _token = token;
        _access = [self getAccess];
        _bucket = [self getBucket:policy];
        _hasReturnUrl = (policy[@"returnUrl"] != nil);
    }

    return self;
}

- (NSString *)getAccess {

    NSRange range = [_token rangeOfString:@":" options:NSCaseInsensitiveSearch];
    return [_token substringToIndex:range.location];
}

- (NSString *)getBucket:(NSDictionary *)info {

    NSString *scope = [info objectForKey:@"scope"];
    if (!scope) {
        return @"";
    }

    NSRange range = [scope rangeOfString:@":"];
    if (range.location == NSNotFound) {
        return scope;
    }
    return [scope substringToIndex:range.location];
}

+ (instancetype)parse:(NSString *)token {
    if (token == nil) {
        return nil;
    }
    NSArray *array = [token componentsSeparatedByString:@":"];
    if (array == nil || array.count != 3) {
        return nil;
    }

    NSData *data = [QNUrlSafeBase64 decodeString:array[2]];
    NSError *tmp = nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&tmp];
    if (tmp != nil || dict[@"scope"] == nil || dict[@"deadline"] == nil) {
        return nil;
    }
    return [[QNUpToken alloc] init:dict token:token];
}

- (NSString *)index {
    return [NSString stringWithFormat:@"%@:%@", _access, _bucket];
}

@end
