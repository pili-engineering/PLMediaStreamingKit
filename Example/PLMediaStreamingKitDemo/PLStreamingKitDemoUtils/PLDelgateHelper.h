//
//  PLDelgateHelper.h
//  PLStreamingKitExample
//
//  Created by TaoZeyu on 16/5/26.
//  Copyright © 2016年 pili-engineering. All rights reserved.
//

#import <Foundation/Foundation.h>

@class A2DynamicDelegate;

@interface PLDelgateHelper : NSObject

+ (void)bindTarget:(id)target property:(NSString *)propertyName
             block:(void (^)(A2DynamicDelegate *dynamicDelegate))block;

@end
