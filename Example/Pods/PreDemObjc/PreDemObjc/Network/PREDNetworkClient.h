//
//  PREDNetworkClient.h
//  PreDemObjc
//
//  Created by WangSiyu on 21/02/2017.
//  Copyright © 2017 pre-engineering. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PREDHTTPOperation.h" //needed for typedef

@interface PREDNetworkClient : NSObject

@property (nonatomic, strong) NSURL *baseURL;

@property (nonatomic, strong) NSOperationQueue *operationQueue;

- (instancetype) initWithBaseURL:(NSURL*) baseURL;

- (void) getPath:(NSString*) path
      parameters:(NSDictionary *) params
      completion:(PREDNetworkCompletionBlock) completion;

- (void) postPath:(NSString*) path
       parameters:(id) params
       completion:(PREDNetworkCompletionBlock) completion;

- (void) postPath:(NSString*) path
             data:(NSData *) data
          headers:(NSDictionary *)headers
       completion:(PREDNetworkCompletionBlock) completion;
@end
