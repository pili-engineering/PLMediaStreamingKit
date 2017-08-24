//
//  PREDNetDiagResultPrivate.h
//  PreDemObjc
//
//  Created by WangSiyu on 01/06/2017.
//  Copyright © 2017 pre-engineering. All rights reserved.
//

#import "PREDNetDiagResult.h"

@interface PREDNetDiagResult ()

- (instancetype)initWithComplete:(PREDNetDiagCompleteHandler)complete netClient:(PREDNetworkClient *)client;
- (void)gotTcpResult:(QNNTcpPingResult *)r;
- (void)gotPingResult:(QNNPingResult *)r;
- (void)gotHttpResult:(QNNHttpResult *)r;
- (void)gotTrResult:(QNNTraceRouteResult *)r;
- (void)gotNsLookupResult:(NSArray<QNNRecord *> *) r;
- (NSDictionary *)toDic;

@end
