//
//  PREDVersion.h
//  PreDemObjc
//
//  Created by WangSiyu on 22/05/2017.
//  Copyright © 2017 pre-engineering. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PREDVersion : NSObject

+ (NSString *)getSDKVersion;
+ (NSString *)getSDKBuild;

@end
