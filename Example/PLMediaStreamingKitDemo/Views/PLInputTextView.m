//
//  PLInputTextView.m
//  PLMediaStreamingKitDemo
//
//  Created by 冯文秀 on 2020/7/23.
//  Copyright © 2020 Pili. All rights reserved.
//

#import "PLInputTextView.h"

@interface PLInputTextView()
<
UITextViewDelegate
>
@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *sureButton;

@end

@implementation PLInputTextView

- (id)initWithFrame:(CGRect)frame view:(nonnull UIView *)view {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 6;
        
        [view insertSubview:self aboveSubview:view.subviews.lastObject];
        
        self.textView = [[UITextView alloc] initWithFrame:CGRectMake(15, 15, 220, 60)];
        self.textView.delegate = self;
        self.textView.layer.cornerRadius = 3;
        self.textView.layer.borderWidth = 0.5;
        self.textView.layer.borderColor = [UIColor blackColor].CGColor;
        [self addSubview:_textView];
        
        self.infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 80, 220, 18)];
        self.infoLabel.font = FONT_MEDIUM(12);
        self.infoLabel.textColor = [UIColor blackColor];
        self.infoLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_infoLabel];
        
        self.cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(15, 106, 80, 20)];
        self.cancelButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.cancelButton.titleLabel.font = FONT_MEDIUM(13);
        [self.cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [self.cancelButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [self.cancelButton addTarget:self action:@selector(cancelTextInput:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_cancelButton];
        
        self.sureButton = [[UIButton alloc] initWithFrame:CGRectMake(155, 106, 80, 20)];
        self.sureButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.sureButton.titleLabel.font = FONT_MEDIUM(13);
        [self.sureButton setTitle:@"确定" forState:UIControlStateNormal];
        [self.sureButton setTitleColor:SELECTED_BLUE forState:UIControlStateNormal];
        [self.sureButton addTarget:self action:@selector(sureTextInput:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_sureButton];
    }
    return self;
}

#pragma mark - buttons event
- (void)cancelTextInput:(UIButton *)button {
    [self.textView resignFirstResponder];
    [self removeFromSuperview];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputTextView:didClickIndex:text:)]) {
        [self.delegate inputTextView:self didClickIndex:0 text:self.textView.text];
    }
}

- (void)sureTextInput:(UIButton *)button {
    [self.textView resignFirstResponder];
    [self removeFromSuperview];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputTextView:didClickIndex:text:)]) {
        [self.delegate inputTextView:self didClickIndex:1 text:self.textView.text];
    }
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
//    NSLog(@"textViewDidChange textView - %@", textView);
    NSData *data = [textView.text dataUsingEncoding:NSUTF8StringEncoding];
    self.infoLabel.text = [NSString stringWithFormat:@"SEI 数据长度: %lu", (unsigned long)data.length];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
//    NSLog(@"textViewDidBeginEditing textView - %@", textView);
}

- (void)textViewDidEndEditing:(UITextView *)textView {
//    NSLog(@"textViewDidEndEditing textView - %@", textView);
}
@end
