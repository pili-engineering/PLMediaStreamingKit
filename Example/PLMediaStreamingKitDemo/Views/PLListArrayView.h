//
//  PLListArrayView.h
//  PLMediaStreamingKitDemo
//
//  Created by 冯文秀 on 2017/6/29.
//  Copyright © 2017年 0dayZh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLCategoryModel.h"

@protocol PLListArrayViewDelegate<NSObject>
- (void)listArrayViewSelectedWithIndex:(NSInteger)index configureModel:(PLConfigureModel *)configureModel categoryModel:(PLCategoryModel *)categoryModel;

@end

@interface PLListArrayView : UIView
@property (nonatomic, weak) id<PLListArrayViewDelegate> delegate;
@property (nonatomic, strong) NSArray *listArray;
@property (nonatomic, strong) PLConfigureModel *configureModel;
@property (nonatomic, strong) PLCategoryModel *categoryModel;

@property (nonatomic, copy) NSString *listStr;

- (instancetype)initWithFrame:(CGRect)frame listArray:(NSArray *)listArray superView:(UIView *)superView;
@end
