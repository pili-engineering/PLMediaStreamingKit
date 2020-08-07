//
//  PLButtonControlsView.h
//  PLMediaStreamingKitDemo
//
//  Created by 冯文秀 on 2020/6/10.
//  Copyright © 2020 Pili. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PLButtonControlsView;

@protocol PLButtonControlsViewDelegate <NSObject>

@optional

- (void)buttonControlsView:(PLButtonControlsView *)buttonControlsView didClickIndex:(NSInteger)index selected:(BOOL)selected;

@end


@interface PLButtonControlsView : UIView

@property (nonatomic, assign) id<PLButtonControlsViewDelegate> delegate;

// show 默认是否显示
- (id)initWithFrame:(CGRect)frame show:(BOOL)show;
@end

NS_ASSUME_NONNULL_END
