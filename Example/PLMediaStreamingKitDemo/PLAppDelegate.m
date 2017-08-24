//
//  PLAppDelegate.m
//  PLCameraStreamingKit
//
//  Created on 01/10/2015.
//  Copyright (c) Pili Engineering, Qiniu Inc. All rights reserved.
//

#import "PLAppDelegate.h"
#import "PLMainViewController.h"
#import "PLMediaStreamingKit.h"
#import <PreDemObjc/PREDemObjc.h>

@interface PLAppDelegate ()

@end

@implementation PLAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [PREDManager startWithAppKey:@"00000002000ad127kgc9rqsp"
                   serviceDomain:@"http://pili-dem-push.qbox.net"];
    
    [PLStreamingEnv initEnv];
    
    PLMainViewController *mainVC = [[PLMainViewController alloc] init];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = mainVC;
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController.view.frame = self.window.bounds;
    self.window.rootViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth |
    UIViewAutoresizingFlexibleHeight;
    [self.window makeKeyAndVisible];
    
    [PLStreamingEnv setLogLevel:PLStreamLogLevelDebug];
    [PLStreamingEnv enableFileLogging];
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

