//
//  PREDGZIP.h
//  PreDemObjc
//
//  Created by WangSiyu on 21/02/2017.
//  Copyright © 2017 pre-engineering. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PREDNullability.h"
NS_ASSUME_NONNULL_BEGIN

@interface NSData (PREDGZIP)

- (nullable NSData *)gzippedDataWithCompressionLevel:(float)level;
- (nullable NSData *)gzippedData;
- (nullable NSData *)gunzippedData;

@end

NS_ASSUME_NONNULL_END
