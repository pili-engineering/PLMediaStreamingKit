//
//  PREDHTTPMonitorModel.h
//  PreDemObjc
//
//  Created by WangSiyu on 15/03/2017.
//  Copyright © 2017 pre-engineering. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PREDHTTPMonitorModel : NSObject

@property (nonatomic, assign) NSInteger     platform;
@property (nonatomic, strong) NSString      *appName;
@property (nonatomic, strong) NSString      *appBundleId;
@property (nonatomic, strong) NSString      *osVersion;
@property (nonatomic, strong) NSString      *deviceModel;
@property (nonatomic, strong) NSString      *deviceUUID;
@property (nonatomic, strong) NSString      *tag;
@property (nonatomic, strong) NSString      *domain;
@property (nonatomic, strong) NSString      *path;
@property (nonatomic, strong) NSString      *method;
@property (nonatomic, strong) NSString      *hostIP;
@property (nonatomic, assign) NSInteger     statusCode;
@property (nonatomic, assign) UInt64        startTimestamp;
@property (nonatomic, assign) UInt64        responseTimeStamp;
@property (nonatomic, assign) UInt64        endTimestamp;
@property (nonatomic, assign) NSUInteger    DNSTime;
@property (nonatomic, assign) NSInteger     dataLength;
@property (nonatomic, assign) NSInteger     networkErrorCode;
@property (nonatomic, strong) NSString      *networkErrorMsg;

@end
