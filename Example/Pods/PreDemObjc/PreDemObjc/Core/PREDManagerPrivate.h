//
//  PREDManagerPrivate.h
//  PreDemObjc
//
//  Created by Troy on 2017/6/27.
//  Copyright © 2017 pre-engineering. All rights reserved.
//

#ifndef PREDManagerPrivate_h
#define PREDManagerPrivate_h

#import "PREDManager.h"
#import "PREDConfigManager.h"
#import "PREDNetworkClient.h"

@interface PREDManager ()
<
PREDConfigManagerDelegate
>

+ (PREDManager *_Nonnull)sharedPREDManager;

@property (nonatomic, strong, nonnull) PREDNetworkClient *networkClient;

@property (nonatomic, getter = isCrashManagerEnabled) BOOL enableCrashManager;

@property (nonatomic, getter = isHttpMonitorEnabled) BOOL enableHttpMonitor;

@property (nonatomic, getter = isLagMonitorEnabled) BOOL enableLagMonitor;

@end

#endif /* PREDManagerPrivate_h */
