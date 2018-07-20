//
//  PLPasterScrollView.h
//  PLMediaStreamingKitDemo
//
//  Created by suntongmian on 2018/3/28.
//  Copyright © 2018年 Pili. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PLPasterScrollView;

@protocol PLPasterScrollViewDelegate <NSObject>

@required;
- (void)pasterScrollView:(PLPasterScrollView *)pasterScrollView pasterTag:(NSInteger)pasterTag pasterImage:(UIImage *)pasterImage;

@end


@interface PLPasterScrollView : UIScrollView

@property (nonatomic, weak) id<PLPasterScrollViewDelegate> pasterDelegate;
// 贴纸名字数组
@property (nonatomic, copy) NSArray *pasterNameArray;
// 贴纸图片数组
@property (nonatomic, copy) NSArray *pasterImageArray;
// 贴纸的高和宽
@property (nonatomic, assign) CGFloat pasterImage_W_H;
// 默认选中的
@property (nonatomic, strong) UIButton *defaultButton;


/**
 *  创建添加贴纸页底部的 scrollView
 *
 *  @param pasterImageArray 穿过来的图片名字数组
 *
 *  @return 返回创建的自定义 scrollView
 */
- (instancetype)initScrollViewWithPasterImageArray:(NSArray *)pasterImageArray;

@end

