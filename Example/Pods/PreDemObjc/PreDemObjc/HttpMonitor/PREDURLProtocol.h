//
//  PREDURLProtocol.h
//  PreDemObjc
//
//  Created by WangSiyu on 21/02/2017.
//  Copyright © 2017 pre-engineering. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PREDNetworkClient.h"

@interface PREDURLProtocol : NSURLProtocol

+ (void)setClient:(PREDNetworkClient *)client;

+ (void)enableHTTPDem;
+ (void)disableHTTPDem;

@end
