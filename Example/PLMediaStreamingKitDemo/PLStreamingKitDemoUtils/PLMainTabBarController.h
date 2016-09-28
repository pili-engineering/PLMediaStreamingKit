//
//  PLMainTabBarController.h
//  PLStreamingKitExample
//
//  Created by TaoZeyu on 16/5/23.
//  Copyright © 2016年 com.pili-engineering.private. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PLPanelModel;

@interface PLMainTabBarController : UITabBarController

@property (nonatomic, strong) UIView *cameraPreviewView;
@property (nonatomic, strong) NSArray *panelModels;

- (void)addPanelModel:(PLPanelModel *)panelModel;

@end
