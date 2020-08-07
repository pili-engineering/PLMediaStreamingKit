//
//  PLCategoryModel.m
//  PLMediaStreamingKitDemo
//
//  Created by 冯文秀 on 2017/6/29.
//  Copyright © 2017年 0dayZh. All rights reserved.
//

#import "PLCategoryModel.h"

@implementation PLCategoryModel
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.categoryKey = [aDecoder decodeObjectForKey:@"categoryKey"];
        self.categoryValue = [aDecoder decodeObjectForKey:@"categoryValue"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.categoryKey forKey:@"categoryKey"];
    [aCoder encodeObject:self.categoryValue forKey:@"categoryValue"];
}

+ (NSArray *)categoryArrayWithArray:(NSArray *)array {
    NSMutableArray *categoryArr = [NSMutableArray array];
    for (NSDictionary *dict in array) {
        PLCategoryModel *categoryModel = [[PLCategoryModel alloc]init];
        categoryModel.categoryKey = dict.allKeys[0];
        NSMutableArray *configureArr = [NSMutableArray array];
        for (NSDictionary *configurDictionary in dict.allValues[0]) {
            PLConfigureModel *configureModel = [PLConfigureModel configureModelWithDictionary:configurDictionary];
            [configureArr addObject:configureModel];
        }
        categoryModel.categoryValue = [configureArr copy];
        [categoryArr addObject:categoryModel];
    }
    return [categoryArr copy];
}

@end

@implementation PLConfigureModel
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.configuraKey = [aDecoder decodeObjectForKey:@"configuraKey"];
        self.configuraValue = [aDecoder decodeObjectForKey:@"configuraValue"];
        self.selectedNum = [aDecoder decodeObjectForKey:@"selectedNum"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.configuraKey forKey:@"configuraKey"];
    [aCoder encodeObject:self.configuraValue forKey:@"configuraValue"];
    [aCoder encodeObject:self.selectedNum forKey:@"selectedNum"];
}

+ (PLConfigureModel *)configureModelWithDictionary:(NSDictionary *)dictionary {
    PLConfigureModel *configureModel = [[PLConfigureModel alloc]init];
    for (NSString *key in dictionary) {
        if ([key isEqualToString:@"default"]) {
            configureModel.selectedNum = dictionary[key];
        } else{
            configureModel.configuraKey = key;
            configureModel.configuraValue = dictionary[key];
        }
    }
    return configureModel;
}

@end
