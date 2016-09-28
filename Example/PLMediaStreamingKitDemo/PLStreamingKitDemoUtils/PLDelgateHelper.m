//
//  PLDelgateHelper.m
//  PLStreamingKitExample
//
//  Created by TaoZeyu on 16/5/26.
//  Copyright © 2016年 pili-engineering. All rights reserved.
//

#import "PLDelgateHelper.h"
#import <BlocksKit/NSObject+A2DynamicDelegate.h>

@implementation PLDelgateHelper

+ (void)bindTarget:(id)target property:(NSString *)propertyName
             block:(void (^)(A2DynamicDelegate *dynamicDelegate))block
{
    A2DynamicDelegate *dynamicDelegate = [target bk_dynamicDelegate];
    block(dynamicDelegate);
    [target setValue:dynamicDelegate forKey:propertyName];
}

@end
