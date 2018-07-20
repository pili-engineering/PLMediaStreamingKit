//
//  PLPasterView.h
//  PLMediaStreamingKitDemo
//
//  Created by suntongmian on 2018/3/28.
//  Copyright © 2018年 Pili. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PLPasterView;

@protocol PLPasterViewDelegate <NSObject>

@optional;
- (void)deletePasterView:(PLPasterView *)PasterView;
- (void)draggingPasterView:(PLPasterView *)PasterView;
- (void)endDragPasterView:(PLPasterView *)PasterView;

@end

@interface PLPasterView : UIView

@property (nonatomic, weak) id<PLPasterViewDelegate> delegate;
/**图片，所要加成贴纸的图片*/
@property (nonatomic, strong) UIImage *pasterImage;
/**隐藏“删除”和“缩放”按钮*/
- (void)hiddenButton;
/**显示“删除”和“缩放”按钮*/
- (void)showButton;

@end
