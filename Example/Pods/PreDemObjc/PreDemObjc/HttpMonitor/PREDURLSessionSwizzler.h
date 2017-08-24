//
//  PREDURLSessionSwizzler.h
//  PreDemObjc
//
//  Created by WangSiyu on 14/03/2017.
//  Copyright © 2017 pre-engineering. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PREDURLSessionSwizzler : NSObject

@property (class, nonatomic, assign) BOOL isSwizzle;

+ (void)load;
+ (void)unload;

@end
