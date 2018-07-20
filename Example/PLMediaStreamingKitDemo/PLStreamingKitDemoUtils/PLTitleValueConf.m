//
//  PLTitleValueConf.m
//  PLStreamingKitExample
//
//  Created by TaoZeyu on 16/5/26.
//  Copyright © 2016年 pili-engineering. All rights reserved.
//

#import "PLTitleValueConf.h"

@implementation PLTitleValueConf

- (instancetype)initWithTitles:(NSArray *)titles withValues:(NSArray *)values
{
    if (self = [self init]) {
        _titles = titles;
        _values = values;
    }
    return self;
}

- (instancetype)initWithValues:(NSArray *)values
{
    return [self initWithTitleFormat:@"%@" withValues:values];
}

- (instancetype)initWithTitleFormat:(NSString *)titleFormat withValues:(NSArray *)values
{
    NSMutableArray *titles = [[NSMutableArray alloc] initWithCapacity:values.count];
    for (id value in values) {
        NSString *title = [NSString stringWithFormat:titleFormat, value];
        [titles addObject:title];
    }
    return [self initWithTitles:titles withValues:values];
}

+ (PLTitleValueConf *)confWithTitles:(NSArray *)titles withValues:(NSArray *)values
{
    return [[self alloc] initWithTitles:titles withValues:values];
}

+ (PLTitleValueConf *)confWithValues:(NSArray *)values
{
    return [[self alloc] initWithValues:values];
}

+ (PLTitleValueConf *)confWithTitleFormat:(NSString *)titleFormat withValues:(NSArray *)values
{
    return [[self alloc] initWithTitleFormat:titleFormat withValues:values];
}

- (NSNumber *)numberAt:(NSUInteger)index
{
    return (NSNumber *)_values[index];
}

- (int)intAt:(NSUInteger)index
{
    return [((NSNumber *)_values[index]) intValue];
}

- (unsigned int)unsignedIntAt:(NSUInteger)index
{
    return [((NSNumber *)_values[index]) unsignedIntValue];
}

- (BOOL)boolAt:(NSUInteger)index
{
    return [((NSNumber *)_values[index]) boolValue];
}

- (double)doubleAt:(NSUInteger)index
{
    return [((NSNumber *)_values[index]) doubleValue];
}

- (NSInteger)integerAt:(NSUInteger)index
{
    return [((NSNumber *)_values[index]) integerValue];
}

- (NSUInteger)unsignedIntegerAt:(NSUInteger)index
{
    return [((NSNumber *)_values[index]) unsignedIntegerValue];
}

- (NSString *)stringAt:(NSUInteger)index
{
    return [NSString stringWithFormat:@"%@", _values[index]];
}

@end
