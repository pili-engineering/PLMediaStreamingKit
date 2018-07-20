//
//  PLTitleValueConf.h
//  PLStreamingKitExample
//
//  Created by TaoZeyu on 16/5/26.
//  Copyright © 2016年 pili-engineering. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PLTitleValueConf : NSObject

@property (nonatomic, readonly) NSArray *titles;
@property (nonatomic, readonly) NSArray *values;

- (instancetype)initWithValues:(NSArray *)values;
- (instancetype)initWithTitles:(NSArray *)titles withValues:(NSArray *)values;
- (instancetype)initWithTitleFormat:(NSString *)titleFormat withValues:(NSArray *)values;

+ (PLTitleValueConf *)confWithValues:(NSArray *)values;
+ (PLTitleValueConf *)confWithTitles:(NSArray *)titles withValues:(NSArray *)values;
+ (PLTitleValueConf *)confWithTitleFormat:(NSString *)titleFormat withValues:(NSArray *)values;

- (NSNumber *)numberAt:(NSUInteger)index;
- (int)intAt:(NSUInteger)index;
- (unsigned int)unsignedIntAt:(NSUInteger)index;
- (BOOL)boolAt:(NSUInteger)index;
- (double)doubleAt:(NSUInteger)index;
- (NSInteger)integerAt:(NSUInteger)index;
- (NSUInteger)unsignedIntegerAt:(NSUInteger)index;
- (NSString *)stringAt:(NSUInteger)index;

@end
