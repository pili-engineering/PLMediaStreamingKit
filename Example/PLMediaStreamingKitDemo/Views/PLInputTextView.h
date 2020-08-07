//
//  PLInputTextView.h
//  PLMediaStreamingKitDemo
//
//  Created by 冯文秀 on 2020/7/23.
//  Copyright © 2020 Pili. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class PLInputTextView;

@protocol PLInputTextViewDelegate <NSObject>

@optional

- (void)inputTextView:(PLInputTextView *)inputTextView didClickIndex:(NSInteger)index text:(NSString *)text;
@end

@interface PLInputTextView : UIView
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, assign) id<PLInputTextViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame view:(UIView *)view;
@end

NS_ASSUME_NONNULL_END
