//
//  PLLogDisplayer.h
//  PLStreamingKitExample
//
//  Created by TaoZeyu on 16/5/25.
//  Copyright © 2016年 pili-engineering. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PLLogDisplayer : UITableView

- (void)print:(NSString *)content;
- (void)printWithKey:(NSString *)key withContent:(NSString *)content;

@end
