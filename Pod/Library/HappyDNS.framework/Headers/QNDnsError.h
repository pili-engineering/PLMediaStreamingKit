//
//  QNDnsError.h
//  Doh
//
//  Created by yangsen on 2021/7/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern const int kQNDomainHijackingCode;
extern const int kQNDomainNotOwnCode;
extern const int kQNDomainSeverError;

extern const int kQNDnsMethodErrorCode;
extern const int kQNDnsInvalidParamCode;
extern const int kQNDnsResponseBadTypeCode;
extern const int kQNDnsResponseBadClassCode;
extern const int kQNDnsResponseFormatCode;

#define kQNDnsErrorDomain @"qiniu.dns"

@interface QNDnsError : NSObject

+ (NSError *)error:(int)code desc:(NSString *)desc;

@end

#define kQNDnsMethodError(description)            [QNDnsError error:kQNDnsMethodErrorCode desc:description]
#define kQNDnsInvalidParamError(description)      [QNDnsError error:kQNDnsInvalidParamCode desc:description]
#define kQNDnsResponseBadTypeError(description)   [QNDnsError error:kQNDnsResponseBadTypeCode desc:description]
#define kQNDnsResponseBadClassError(description)  [QNDnsError error:kQNDnsResponseBadClassCode desc:description]
#define kQNDnsResponseFormatError(description)    [QNDnsError error:kQNDnsResponseFormatCode desc:description]

NS_ASSUME_NONNULL_END
