//
//  QNUpToken.h
//  QiniuSDK
//
//  Created by bailong on 15/6/7.
//  Copyright (c) 2015年 Qiniu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QNUpToken : NSObject

+ (instancetype)parse:(NSString *)token;

@property (copy, nonatomic, readonly) NSString *access;
@property (copy, nonatomic, readonly) NSString *bucket;
@property (copy, nonatomic, readonly) NSString *token;

@property (readonly) BOOL hasReturnUrl;

- (NSString *)index;

@end
