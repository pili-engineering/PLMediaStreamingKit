//
//  PLAppDelegate.m
//  PLMediaStreamingKit
//
//  Created on 01/10/2015.
//  Copyright (c) Pili Engineering, Qiniu Inc. All rights reserved.
//

#import "PLAppDelegate.h"

// PLMediaStreamSession 初始化配置界面
#import "PLInitViewController.h"

@interface PLAppDelegate ()

@end

@implementation PLAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [Fabric with:@[[Crashlytics class]]];

    
    // 设计用户唯一标识
    NSString *userUid = [NSString stringWithFormat:@"%@_%@_demo_test",[[NSBundle mainBundle] bundleIdentifier],  [[UIDevice currentDevice] identifierForVendor].UUIDString];
    // 1.初始化 StreamingSession 的运行环境
    [PLStreamingEnv initEnvWithUserUID:userUid];
    // 2.设置日志 log 等级
    [PLStreamingEnv setLogLevel:PLStreamLogLevelDebug];
    // 3.开启写 SDK 的日志文件到沙盒
    [PLStreamingEnv enableFileLogging];
    
    PLInitViewController *initViewController = [[PLInitViewController alloc] init];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = initViewController;
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController.view.frame = self.window.bounds;
    self.window.rootViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth |
    UIViewAutoresizingFlexibleHeight;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

