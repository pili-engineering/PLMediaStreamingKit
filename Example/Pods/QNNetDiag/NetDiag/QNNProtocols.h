//
//  QNNProtocols.h
//  NetDiag
//
//  Created by bailong on 15/12/30.
//  Copyright © 2015年 Qiniu Cloud Storage. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol QNNStopDelegate <NSObject>

- (void)stop;

@end

@protocol QNNOutputDelegate <NSObject>

- (void)write:(NSString*)line;

@end

/**
 *    中途取消的状态码
 */
extern const NSInteger kQNNRequestStoped;
