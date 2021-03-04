//
//  BroadcastSetupViewController.m
//  BroadcastUploadExtensionSetupUI
//
//  Created by 冯文秀 on 2021/3/4.
//  Copyright © 2021 0dayZh. All rights reserved.
//

#import "BroadcastSetupViewController.h"

@implementation BroadcastSetupViewController

// Call this method when the user has finished interacting with the view controller and a broadcast stream can start
- (void)userDidFinishSetup {
    
    // URL of the resource where broadcast can be viewed that will be returned to the application
    NSURL *broadcastURL = [NSURL URLWithString:@"http://apple.com/broadcast/streamID"];
    
    // Dictionary with setup information that will be provided to broadcast extension when broadcast is started
    NSDictionary *setupInfo = @{ @"broadcastName" : @"example" };
    
    // Tell ReplayKit that the extension is finished setting up and can begin broadcasting
    [self.extensionContext completeRequestWithBroadcastURL:broadcastURL setupInfo:setupInfo];
}

- (void)userDidCancelSetup {
    // Tell ReplayKit that the extension was cancelled by the user
    [self.extensionContext cancelRequestWithError:[NSError errorWithDomain:@"YourAppDomain" code:-1 userInfo:nil]];
}

@end
