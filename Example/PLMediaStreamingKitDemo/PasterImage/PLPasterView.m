//
//  PLPasterView.m
//  PLMediaStreamingKitDemo
//
//  Created by suntongmian on 2018/3/28.
//  Copyright © 2018年 Pili. All rights reserved.
//

#import "PLPasterView.h"

// 默认删除和缩放按钮的大小
#define btnW_H 24.0
// 默认的图片宽高
#define defaultImageViewW_H self.frame.size.width - btnW_H
// 缩放和删除按钮与图片的间隔距离
#define paster_insert_space btnW_H/2
// 总高度
#define PASTER_SLIDE 120
// 安全边框
#define SECURITY_LENGTH PASTER_SLIDE/2

@interface PLPasterView ()
{
    CGFloat minWidth;
    CGFloat minHeight;
    CGFloat deltaAngle;
    CGPoint prevPoint;
    CGPoint touchStart;
    CGRect  bgRect ;
}
// 删除按钮
@property (nonatomic, strong) UIImageView *delegateImageView;
// 缩放和旋转按钮
@property (nonatomic, strong) UIImageView *scaleImageView;
// 贴纸图片
@property (nonatomic, strong) UIImageView *pasterImageView;

@end


@implementation PLPasterView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // 设置UI
        [self setupUI];
    }
    return self;
}

// 隐藏“删除”和“缩放”按钮
- (void)hiddenButton {
    [UIView animateWithDuration:.5 animations:^{
        self.delegateImageView.alpha = 0.0;
        self.delegateImageView.hidden = YES;
        self.scaleImageView.alpha = 0.0;
        self.scaleImageView.hidden = YES;
    }];
}

// 显示“删除”和“缩放”按钮
- (void)showButton {
    [UIView animateWithDuration:.5 animations:^{
        self.delegateImageView.alpha = 1.0;
        self.scaleImageView.alpha = 1.0;
        self.delegateImageView.hidden = NO;
        self.scaleImageView.hidden = NO;
    }];
}

// 设置UI
- (void)setupUI {
    self.backgroundColor = [UIColor clearColor];
    
    minWidth = self.bounds.size.width * 0.5;
    minHeight = self.bounds.size.height * 0.5;
    deltaAngle = atan2(self.frame.origin.y+self.frame.size.height - self.center.y, self.frame.origin.x+self.frame.size.width - self.center.x);
    
    UIImageView *pasterImageView = [[UIImageView alloc]init];
    pasterImageView.backgroundColor = [UIColor clearColor];
    pasterImageView.layer.borderColor = [UIColor redColor].CGColor;
    pasterImageView.layer.borderWidth = 0.5;
    pasterImageView.userInteractionEnabled = YES;
    [self addSubview:pasterImageView];
    self.pasterImageView = pasterImageView;
    
    UIImageView *delegateImageView = [[UIImageView alloc]init];
    [delegateImageView setImage:[UIImage imageNamed:@"bt_paster_delete"]];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(btDeletePressed:)];
    delegateImageView.userInteractionEnabled = YES;
    [delegateImageView addGestureRecognizer:tap];
    [self addSubview:delegateImageView];
    self.delegateImageView = delegateImageView;
    
    UIImageView *scaleImageView = [[UIImageView alloc]init];
    [scaleImageView setImage:[UIImage imageNamed:@"bt_paster_transform"]];
    UIPanGestureRecognizer *panResizeGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(resizeTranslate:)] ;
    scaleImageView.userInteractionEnabled = YES;
    [scaleImageView addGestureRecognizer:panResizeGesture] ;
    [self addSubview:scaleImageView];
    self.scaleImageView = scaleImageView;
    
    self.pasterImageView.frame = CGRectMake(paster_insert_space, paster_insert_space, defaultImageViewW_H, defaultImageViewW_H);
    self.delegateImageView.frame = CGRectMake(0, 0, btnW_H, btnW_H);
    self.scaleImageView.frame = CGRectMake(CGRectGetMaxX(self.pasterImageView.frame) - btnW_H/2, CGRectGetMaxY(self.pasterImageView.frame) - btnW_H/2, btnW_H, btnW_H);
}

// 右下角的缩放和旋转手势
- (void)resizeTranslate:(UIPanGestureRecognizer *)recognizer {
    if ([recognizer state] == UIGestureRecognizerStateBegan) {
        prevPoint = [recognizer locationInView:self];
        [self setNeedsDisplay];
        
    } else if ([recognizer state] == UIGestureRecognizerStateChanged) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(draggingPasterView:)]) {
            [self.delegate draggingPasterView:self];
        }
        
        if (self.bounds.size.width < minWidth || self.bounds.size.height < minHeight) {
            self.bounds = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, minWidth + 1 , minHeight + 1);
            self.scaleImageView.frame =CGRectMake(self.bounds.size.width-btnW_H,self.bounds.size.height-btnW_H,btnW_H,btnW_H);
            prevPoint = [recognizer locationInView:self];
            
        } else {
            CGPoint point = [recognizer locationInView:self];
            float wChange = 0.0, hChange = 0.0;
            wChange = (point.x - prevPoint.x);
            float wRatioChange = (wChange/(float)self.bounds.size.width);
            hChange = wRatioChange * self.bounds.size.height;
            
            if (ABS(wChange) > 50.0f || ABS(hChange) > 50.0f) {
                prevPoint = [recognizer locationOfTouch:0 inView:self];
                return;
            }
            
            CGFloat finalWidth  = self.bounds.size.width + (wChange) ;
            CGFloat finalHeight = self.bounds.size.height + (wChange) ;
            if (finalWidth > PASTER_SLIDE*(1+0.5)) {
                finalWidth = PASTER_SLIDE*(1+0.5);
            }
            if (finalWidth < PASTER_SLIDE*(1-0.5)) {
                finalWidth = PASTER_SLIDE*(1-0.5);
            }
            if (finalHeight > PASTER_SLIDE*(1+0.5)) {
                finalHeight = PASTER_SLIDE*(1+0.5);
            }
            if (finalHeight < PASTER_SLIDE*(1-0.5)) {
                finalHeight = PASTER_SLIDE*(1-0.5);
            }
            
            self.bounds = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, finalWidth, finalHeight);
            self.scaleImageView.frame = CGRectMake(self.bounds.size.width-btnW_H, self.bounds.size.height-btnW_H, btnW_H, btnW_H);
            self.pasterImageView.frame = CGRectMake(paster_insert_space, paster_insert_space, self.bounds.size.width - paster_insert_space*2, self.bounds.size.height - paster_insert_space*2);
            
            prevPoint = [recognizer locationOfTouch:0 inView:self];
        }
        
        // 旋转
        float ang = atan2([recognizer locationInView:self.superview].y - self.center.y, [recognizer locationInView:self.superview].x - self.center.x) ;
        float angleDiff = deltaAngle - ang ;
        self.transform = CGAffineTransformMakeRotation(-angleDiff);
        [self setNeedsDisplay];
        
    } else if ([recognizer state] == UIGestureRecognizerStateEnded) {
        prevPoint = [recognizer locationInView:self];
        [self setNeedsDisplay];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(endDragPasterView:)]) {
            [self.delegate endDragPasterView:self];
        }
    }
    
    // 检查旋转和缩放是否出界
    [self checkIsOut];
}

// 左上角的删除点击手势
- (void)btDeletePressed:(UITapGestureRecognizer *)recognizer {
    if (self.delegate && [self.delegate respondsToSelector:@selector(deletePasterView:)]) {
        [self.delegate deletePasterView:self];
    }
    [self removeFromSuperview];
}

// 重写pasterImage的set方法
- (void)setPasterImage:(UIImage *)pasterImage {
    _pasterImage = pasterImage;
    if (pasterImage) {
        self.pasterImageView.image = pasterImage;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

// 检查在添加tag的时候是否超出了显示范围，如果超出，移动进显示范围内
- (void)checkIsOut {
    CGPoint point = self.center;
    CGFloat top;
    CGFloat left;
    CGFloat bottom;
    CGFloat right;
    top = point.y - self.frame.size.height/2;
    bottom = (self.superview.frame.size.height - point.y) - self.frame.size.height/2;
    
    if (point.y < self.superview.frame.size.height/2) {
        // 顶部超出范围时
        if (top < 0) {
            point.y += ABS(top);
        }
    } else {
        // 底部超出范围时
        if (bottom < 0) {
            point.y -= ABS(bottom);
        }
    }
    
    left = point.x - self.frame.size.width/2;
    right =(self.superview.frame.size.width - point.x) - self.frame.size.width/2;
    if (point.x < self.superview.frame.size.width/2) {
        // 左边超出范围时
        if (left < 0) {
            point.x += ABS(left);
        }
    } else {
        // 右边超出范围时
        if (right < 0) {
            point.x -= ABS(right);
        }
    }
    
    if (point.x == self.center.x && point.y == self.center.y) {
    
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            self.center = point;
            
        }];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject] ;
    touchStart = [touch locationInView:self.superview] ;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.delegate && [self.delegate respondsToSelector:@selector(endDragPasterView:)]) {
        [self.delegate endDragPasterView:self];
    }
}

// 移动
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.delegate && [self.delegate respondsToSelector:@selector(draggingPasterView:)]) {
        [self.delegate draggingPasterView:self];
    }
    
    CGPoint touchLocation = [[touches anyObject] locationInView:self];
    if (CGRectContainsPoint(self.scaleImageView.frame, touchLocation)) {
        return;
    }
    CGPoint touch = [[touches anyObject] locationInView:self.superview];
    [self translateUsingTouchLocation:touch];
    [self checkIsOut];
    touchStart = touch;
}

// 确保移动时不超出屏幕
- (void)translateUsingTouchLocation:(CGPoint)touchPoint {
    CGPoint newCenter = CGPointMake(self.center.x + touchPoint.x - touchStart.x,
                                    self.center.y + touchPoint.y - touchStart.y) ;
    
    // Ensure the translation won't cause the view to move offscreen. BEGIN
    CGFloat midPointX = CGRectGetMidX(self.bounds) ;
    if (newCenter.x > self.superview.bounds.size.width - midPointX + SECURITY_LENGTH) {
        newCenter.x = self.superview.bounds.size.width - midPointX + SECURITY_LENGTH;
    }
    if (newCenter.x < midPointX - SECURITY_LENGTH) {
        newCenter.x = midPointX - SECURITY_LENGTH;
    }
    
    CGFloat midPointY = CGRectGetMidY(self.bounds);
    if (newCenter.y > self.superview.bounds.size.height - midPointY + SECURITY_LENGTH) {
        newCenter.y = self.superview.bounds.size.height - midPointY + SECURITY_LENGTH;
    }
    if (newCenter.y < midPointY - SECURITY_LENGTH)
    {
        newCenter.y = midPointY - SECURITY_LENGTH;
    }
    // Ensure the translation won't cause the view to move offscreen. END
    self.center = newCenter;
}

@end

