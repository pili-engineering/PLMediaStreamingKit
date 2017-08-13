//
//  PREDConfig.h
//  PreDemObjc
//
//  Created by WangSiyu on 10/05/2017.
//  Copyright © 2017 pre-engineering. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PREDConfig.h"
#import "PREDNetworkClient.h"

@class PREDConfigManager;

@protocol PREDConfigManagerDelegate <NSObject>

- (void)configManager:(PREDConfigManager *)manager didReceivedConfig:(PREDConfig *)config;

@end

@interface PREDConfigManager : NSObject

@property(nonatomic, weak) id<PREDConfigManagerDelegate> delegate;

- (instancetype)initWithNetClient:(PREDNetworkClient *)client;

- (PREDConfig *)getConfig;

@end
