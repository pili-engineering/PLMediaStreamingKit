//
//  PLCategoryModel.h
//  PLMediaStreamingKitDemo
//
//  Created by 冯文秀 on 2017/6/29.
//  Copyright © 2017年 0dayZh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PLCategoryModel : NSObject
@property (nonatomic, copy) NSString *categoryKey;
@property (nonatomic, strong) NSArray *categoryValue;

+ (NSArray *)categoryArrayWithArray:(NSArray *)array;
@end


@interface PLConfigureModel : NSObject
@property (nonatomic, copy) NSString *configuraKey;
@property (nonatomic, strong) NSArray *configuraValue;
@property (nonatomic, strong) NSNumber *selectedNum;

+ (PLConfigureModel *)configureModelWithDictionary:(NSDictionary *)dictionary;
@end
