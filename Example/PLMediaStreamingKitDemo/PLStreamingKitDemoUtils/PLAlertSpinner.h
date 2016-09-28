//
//  PLAlertSpinner.h
//  PLStreamingKitExample
//
//  Created by TaoZeyu on 16/5/25.
//  Copyright © 2016年 pili-engineering. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PLAlertSpinner : UIControl

@property (nonatomic, readonly) NSString *selectedTitle;
@property (nonatomic) NSUInteger selectedIndex;

- (instancetype)initWithTitles:(NSArray *)titles withDefaultIndex:(NSUInteger)defaultIndex;

@end
