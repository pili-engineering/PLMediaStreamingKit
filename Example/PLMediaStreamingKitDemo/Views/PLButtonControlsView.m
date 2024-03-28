//
//  PLButtonControlsView.m
//  PLMediaStreamingKitDemo
//
//  Created by 冯文秀 on 2020/6/10.
//  Copyright © 2020 Pili. All rights reserved.
//

#import "PLButtonControlsView.h"

@interface PLButtonControlsView()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *buttonView;
@property (nonatomic, strong) UIButton *hideButton;

@end

@implementation PLButtonControlsView

- (id)initWithFrame:(CGRect)frame show:(BOOL)show {
    if ([super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        [self layoutButtonsView];
        
        if (!show) {
            _hideButton.selected = YES;
            _scrollView.hidden = YES;
        }
    }
    return self;
}

- (void)layoutButtonsView {
    NSArray *titleArray = @[@"旋转方向", @"预览镜像", @"编码镜像", @"关闭麦克风", @"美颜设置", @"图片推流", @"贴纸设置", @"水印设置", @"混音设置", @"音效设置", @"截图", @"人工报障"];
    NSArray *selectedTitleArray = @[@"旋转方向", @"预览镜像", @"编码镜像", @"打开麦克风", @"美颜设置", @"图片推流", @"贴纸设置", @"水印设置", @"混音设置", @"音效设置", @"截图", @"人工报障"];
    
    CGRect maxBounds =  [titleArray[3] boundingRectWithSize:CGSizeMake(1000, 28) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObject:FONT_MEDIUM(13.f) forKey:NSFontAttributeName] context:nil];
    CGFloat viewWidth = maxBounds.size.width;
    CGFloat viewHeight = 40 * titleArray.count;
    
    // 显示/隐藏 控件按钮
    _hideButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, viewWidth, 28)];
    _hideButton.backgroundColor = COLOR_RGB(0, 0, 0, 0.3);
    [_hideButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _hideButton.titleLabel.font = FONT_MEDIUM(12.f);
    [_hideButton setTitle:@"隐藏控件" forState:UIControlStateNormal];
    [_hideButton setTitle:@"显示控件" forState:UIControlStateSelected];
    [_hideButton addTarget:self action:@selector(hideOrShowButtonView:) forControlEvents:UIControlEventTouchDown];
    [self addSubview:_hideButton];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 40, viewWidth, 270)];
    _scrollView.layer.borderColor = COLOR_RGB(0, 0, 0, 0.3).CGColor;
    _scrollView.layer.borderWidth = 1.f;
    _scrollView.contentSize = CGSizeMake(viewWidth, viewHeight);
    _scrollView.showsVerticalScrollIndicator = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:_scrollView];

    _buttonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, viewHeight)];
    [_scrollView addSubview:_buttonView];
    
    // 循环创建控件按钮
    for (NSInteger i = 0; i < titleArray.count; i++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 40 * i, viewWidth, 28)];
        button.backgroundColor = COLOR_RGB(0, 0, 0, 0.3);
        button.tag = 2000 + i;
        [button addTarget:self action:@selector(buttonViewAction:) forControlEvents:UIControlEventTouchDown];
        [button setTitle:titleArray[i] forState:UIControlStateNormal];
        [button setTitle:selectedTitleArray[i] forState:UIControlStateSelected];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.titleLabel.font = FONT_LIGHT(12.f);
        [_buttonView addSubview:button];
    }
}

#pragma mark - buttons event
- (void)hideOrShowButtonView:(UIButton *)button {
    button.selected = !button.selected;
    _scrollView.hidden = button.selected;
}

- (void)buttonViewAction:(UIButton *)button {
    NSInteger index = button.tag - 2000;
    button.selected = !button.selected;
    
    for (UIButton *currentButton in _buttonView.subviews) {
        if (![currentButton isEqual:button]) {
            if (currentButton.selected) {
                currentButton.selected = NO;
            }
        }
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(buttonControlsView:didClickIndex:selected:)]) {
        [self.delegate buttonControlsView:self didClickIndex:index selected:button.selected];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
