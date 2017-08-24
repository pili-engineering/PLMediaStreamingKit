//
//  PREDNetDiag.h
//  PreDemObjc
//
//  Created by WangSiyu on 24/05/2017.
//  Copyright © 2017 pre-engineering. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PreDemObjc.h"
#import "PREDNetworkClient.h"

@interface PREDNetDiag : NSObject

+ (void)diagnose:(NSString *)host
       netClient:(PREDNetworkClient *)client
        complete:(PREDNetDiagCompleteHandler)complete;

@end
