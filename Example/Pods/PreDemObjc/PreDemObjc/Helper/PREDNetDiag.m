//
//  PREDNetDiag.m
//  PreDemObjc
//
//  Created by WangSiyu on 21/02/2017.
//  Copyright © 2017 pre-engineering. All rights reserved.
//

#import "PREDNetDiag.h"
#import "QNNetDiag.h"
#import "PREDNetDiagResult.h"
#import "PREDNetDiagResultPrivate.h"

@implementation PREDNetDiag

+ (void)diagnose:(NSString *)host
       netClient:(PREDNetworkClient *)client
        complete:(PREDNetDiagCompleteHandler)complete {
    NSString *httpHost;
    if ([host hasPrefix:@"http://"] || [host hasPrefix:@"https://"]) {
        httpHost = host;
        host = [[host componentsSeparatedByString:@"//"] lastObject];
    } else {
        httpHost = [NSString stringWithFormat:@"http://%@", host];
    }
    PREDNetDiagResult *result = [[PREDNetDiagResult alloc] initWithComplete:complete netClient:client];
    [QNNPing start:host size:64 output:nil complete:^(QNNPingResult *r) {
        [result gotPingResult:r];
    }];
    [QNNTcpPing start:host output:nil complete:^(QNNTcpPingResult *r) {
        [result gotTcpResult:r];
    }];
    [QNNTraceRoute start:host output:nil complete:^(QNNTraceRouteResult *r) {
        [result gotTrResult:r];
    }];
    [QNNNslookup start:host output:nil complete:^(NSArray *r) {
        [result gotNsLookupResult:r];
    }];
    [QNNHttp start:httpHost output:nil complete:^(QNNHttpResult *r) {
        [result gotHttpResult:r];
    }];
}

@end
