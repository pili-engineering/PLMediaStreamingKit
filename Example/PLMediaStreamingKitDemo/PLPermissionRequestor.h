//
//  PLPermissionRequestor.h
//  PLStreamingKitExample
//
//  Created by TaoZeyu on 16/5/24.
//  Copyright © 2016年 pili-engineering. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PLPermissionRequestor : NSObject

@property (nonatomic, strong) void (^permissionGranted)();
@property (nonatomic, strong) void (^noPermission)();

- (instancetype)initWithPermissionGranted:(void (^)())permissionGranted
                         withNoPermission:(void (^)())noPermission;
- (void)checkAndRequestPermission;

@end
