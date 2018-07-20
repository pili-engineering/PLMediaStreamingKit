//
//  PLPasterScrollView.m
//  PLMediaStreamingKitDemo
//
//  Created by suntongmian on 2018/3/28.
//  Copyright © 2018年 Pili. All rights reserved.
//

#import "PLPasterScrollView.h"

// 底部 scrollView 的高
static CGFloat pasterScrollView_H = 120;
// 贴纸直接间隔距离
static CGFloat inset_space = 15;

@interface PLPasterScrollView ()

@end

@implementation PLPasterScrollView

/**
 *  重新自定义scrollView
 *
 *  @param pasterImageArray 底部贴纸的图片
 *
 *  @return 返回一个 scrollView
 */
- (instancetype)initScrollViewWithPasterImageArray:(NSArray *)pasterImageArray {
    if (self = [super init]) {
        self.pasterImageArray = pasterImageArray;
        self.pasterImage_W_H = pasterScrollView_H - inset_space * 2;
        
        [self setupUI];
    }
    return self;
}

// 设置UI
- (void)setupUI {
    for (int i = 0; i < self.pasterImageArray.count; i ++) {
        CGFloat pasterBtnW_H = self.pasterImage_W_H;
        UIButton *pasterBtn = [[UIButton alloc]init];
        pasterBtn.frame = CGRectMake((i+1)*inset_space + pasterBtnW_H*i, inset_space, pasterBtnW_H, pasterBtnW_H);
        [pasterBtn setImage:self.pasterImageArray[i] forState:UIControlStateNormal];
        pasterBtn.tag = 1000 + i;
        [pasterBtn addTarget:self action:@selector(pasterClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:pasterBtn];
    }
}

// 点击选取贴纸
- (void)pasterClick:(UIButton *)sender {
    // 按钮选中状态切换的逻辑
    self.defaultButton.selected = NO;
    if (!self.defaultButton.selected) {
        [UIView animateWithDuration:.5 animations:^{
            self.defaultButton.layer.borderColor = [UIColor clearColor].CGColor;
            self.defaultButton.layer.borderWidth = 0.1;
        }];
    }
    sender.selected = YES;
    self.defaultButton = sender;
    if (self.defaultButton.selected) {
        [UIView animateWithDuration:.5 animations:^{
            self.defaultButton.layer.borderColor = [UIColor redColor].CGColor;
            self.defaultButton.layer.borderWidth = 2;
        }];
    }
    
    if (_pasterDelegate && [_pasterDelegate respondsToSelector:@selector(pasterScrollView:pasterTag:pasterImage:)]) {
        [_pasterDelegate pasterScrollView:self pasterTag:sender.tag - 1000 pasterImage:[self.pasterImageArray objectAtIndex:sender.tag - 1000]];
    }
}


- (void)layoutSubviews {
    [super layoutSubviews];
}

@end

