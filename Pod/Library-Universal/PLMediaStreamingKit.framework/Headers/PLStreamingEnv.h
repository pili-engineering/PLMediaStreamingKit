//
//  PLQosEnv.h
//  PLStreamReport
//
//  Created by bailong on 16/4/28.
//  Copyright © 2016年 pili. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PLTypeDefines.h"

@interface PLStreamingEnv : NSObject

/*!
 @abstract 初始化 StreamingSession 的运行环境，需要在 -application:didFinishLaunchingWithOptions: 方法下调用该方法，
 
 @warning 低于 v3.0.3 版本，需要调用该方法初始化 PLStreamingEnv，否则将导致 PLStreamingSession 对象无法初始化
 */
+(void)initEnv __deprecated_msg("Method deprecated in v3.0.3. Use `initEnvWithUserUID:`");;

/*!
 @abstract 初始化 StreamingSession 的运行环境，需要在 -application:didFinishLaunchingWithOptions: 方法下调用该方法，
 
 @param UID 每个用户的唯一标识，若传空，则默认使用 App bundle id 与设备 UUID 拼接组合自动生成
 
 @since v3.0.3
 
 @warning initEnv 已废弃，需要调用该方法初始化 PLStreamingEnv，否则将导致 PLStreamingSession 对象无法初始化
 */

+(void)initEnvWithUserUID:(NSString *)UID;

/*!
 @abstract 判断当前环境是否已经初始化
 
 @return 已初始化返回 YES，否则为 NO
 */
+(BOOL)isInited;

/*!
 @abstract 获取 QoS 的采样间隔
 */
+(NSUInteger)getSampleInterval;

/*!
 @abstract 是否打开测速功能，默认关闭
 
 @param flag 开启为 YES，否则为 NO
 */
+(void)enableSpeedMeasure:(BOOL)flag;

/*!
 @method     enableFileLogging
 @abstract   开启SDK内部写文件日志功能，以方便SDK支持团队定位您所遇到的问题。
 
 @note       日志文件存放位置为 App Container/Library/Caches/Pili/Logs
 */
+ (void)enableFileLogging;

/*!
 @method     setLogLevel:
 @abstract   设置SDK内部输出日志的级别，默认为PLStreamLogLevelWarning级别。
             该方法设置的输出级别会分别同步到控制台与文件日志中。
 
 @warning    请确保不要在线上产品开启PLStreamLogLevelVerbose级别输出，这将影响产品性能。
 */
+ (void)setLogLevel:(PLStreamLogLevel)logLevel;

/*!
 @abstract   获取设备 ID。
 */
+ (NSString *)deviceID;

/*!
 @abstract   设置设备 ID。
 
 @warning    不能为空，且在已传递使用自定义 userUID 的情况下，设置该参数无效
*/
+ (void)setDeviceID:(NSString *)deviceID;

/*!
 @abstract   获取用户唯一标识
 
 @since v3.0.3
 */
+ (NSString *)userUID;

/*!
 @abstract   更新用户唯一标识。
 
 @warning    不能为空
 
 @since v3.0.8
*/
+ (void)setUserUID:(NSString *)userUID;

@end
