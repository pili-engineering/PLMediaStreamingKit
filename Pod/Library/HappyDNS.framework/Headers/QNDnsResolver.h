//
//  QNDnsResolver.h
//  HappyDNS
//
//  Created by yangsen on 2021/7/28.
//  Copyright © 2021 Qiniu Cloud Storage. All rights reserved.
//

#import "QNDnsDefine.h"
#import "QNRecord.h"
#import "QNResolverDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@class QNDnsResponse;
// 抽象对象，不能直接使用，使用其子类
@interface QNDnsResolver : NSObject <QNResolverDelegate>

@property(nonatomic, assign, readonly)int recordType;
@property(nonatomic, assign, readonly)int timeout;
@property(nonatomic,   copy, readonly)NSArray *servers;



// 抽象方法，子类实现
- (void)request:(NSString *)server
           host:(NSString *)host 
     recordType:(int)recordType
       complete:(void(^)(QNDnsResponse *response, NSError *error))complete;

@end

NS_ASSUME_NONNULL_END
