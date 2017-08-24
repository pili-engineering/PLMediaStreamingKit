# Qiniu Resource Storage SDK for Objective-C

[![@qiniu on weibo](http://img.shields.io/badge/weibo-%40qiniutek-blue.svg)](http://weibo.com/qiniutek)
[![Software License](https://img.shields.io/badge/license-MIT-brightgreen.svg)](LICENSE.md)
[![Build Status](https://travis-ci.org/qiniu/objc-sdk.svg?branch=master)](https://travis-ci.org/qiniu/objc-sdk)
[![Latest Stable Version](http://img.shields.io/cocoapods/v/Qiniu.svg)](https://github.com/qiniu/objc-sdk/releases)
![Platform](http://img.shields.io/cocoapods/p/Qiniu.svg)

## 安装

通过 CocoaPods

```ruby
pod "Qiniu", "~> 7.1"
```

## 运行环境

|               Qiniu SDK 版本               | 最低 iOS版本 | 最低 OS X 版本 |     Notes     |
| :--------------------------------------: | :------: | :--------: | :-----------: |
|         7.1.x / AFNetworking-3.x         |  iOS 7   | OS X 10.9  | Xcode 最低版本 6. |
| [7.0.x / AFNetworking-2.x](https://github.com/qiniu/objc-sdk/tree/7.0.x/AFNetworking-2.x) |  iOS 6   | OS X 10.8  | Xcode 最低版本 5. |
| [7.x / AFNetworking-1.x](https://github.com/qiniu/objc-sdk/tree/AFNetworking-1.x) |  iOS 5   | OS X 10.7  | Xcode 最低版本 5. |
| [6.x](https://github.com/qiniu/ios-sdk)  |  iOS 6   |    None    | Xcode 最低版本 5. |

## 使用方法

```Objective-C
#import <QiniuSDK.h>
...
    NSString *token = @"从服务端SDK获取";
    QNUploadManager *upManager = [[QNUploadManager alloc] init];
    NSData *data = [@"Hello, World!" dataUsingEncoding : NSUTF8StringEncoding];
    [upManager putData:data key:@"hello" token:token
        complete: ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
        NSLog(@"%@", info);
        NSLog(@"%@", resp);
    } option:nil];
...
```

建议 QNUploadManager 创建一次重复使用, 或者使用单例方式创建.



**注意**： 如使用最新版的sdk(7.1.4),可自动判断上传空间。按如下方式使用：

```objective-c
QNConfiguration *config =[QNConfiguration  	build:^(QNConfigurationBuilder *builder) {
  NSMutableArray *array = [[NSMutableArray alloc] init];
  [array addObject:[QNResolver systemResolver]];
  QNDnsManager *dns = [[QNDnsManager alloc] init:array networkInfo:[QNNetworkInfo normal]];//是否选择  https  上传
  builder.zone = [[QNAutoZone alloc] initWithHttps:YES dns:dns];//设置断点续传
  NSError *error;
  builder.recorder =  [QNFileRecorder fileRecorderWithFolder:@"保存目录" error:&error];}];
```



## 测试

### 所有测试

``` bash
$ xctool -workspace QiniuSDK.xcworkspace -scheme "QiniuSDK Mac" -sdk macosx -configuration Release test -test-sdk macosx
```
### 指定测试

可以在单元测试上修改, 熟悉 SDK

``` bash
$ xctool -workspace QiniuSDK.xcworkspace -scheme "QiniuSDK_Mac" -sdk macosx -configuration Debug test -test-sdk macosx -only "QiniuSDK MacTests:QNResumeUploadTest/test500k"
```

## 示例代码
* 完整的demo 见 QiniuDemo 目录下的代码
* 具体细节的一些配置 可参考 QiniuSDKTests 下面的一些单元测试，以及源代码

## 常见问题

- 如果碰到 crc 链接错误, 请把 libz.dylib 加入到项目中去
- 如果碰到 res_9_ninit 链接错误, 请把 libresolv.dylib 加入到项目中去
- 如果需要支持 iOS 5 或者支持 RestKit, 请用 AFNetworking 1.x 分支的版本
- 如果碰到其他编译错误, 请参考 CocoaPods 的 [troubleshooting](http://guides.cocoapods.org/using/troubleshooting.html)
- iOS 9+ 强制使用https，需要在project build info 添加NSAppTransportSecurity类型Dictionary。在NSAppTransportSecurity下添加NSAllowsArbitraryLoads类型Boolean,值设为YES。 具体操作可参见 http://blog.csdn.net/guoer9973/article/details/48622823

## 代码贡献

详情参考 [代码提交指南](https://github.com/qiniu/objc-sdk/blob/master/Contributing.md).

## 贡献记录

- [所有贡献者](https://github.com/qiniu/objc-sdk/contributors)

## 联系我们

- 如果需要帮助, 请提交工单 (在 portal 右侧点击咨询和建议提交工单, 或者直接向 support@qiniu.com 发送邮件)
- 如果有什么问题, 可以到问答社区提问, [问答社区](http://qiniu.segmentfault.com/)
- 更详细的文档, 见 [官方文档站](http://developer.qiniu.com/)
- 如果发现了 bug, 欢迎提交 [issue](https://github.com/qiniu/objc-sdk/issues)
- 如果有功能需求, 欢迎提交 [issue](https://github.com/qiniu/objc-sdk/issues)
- 如果要提交代码, 欢迎提交 pull request
- 欢迎关注我们的 [微信](http://www.qiniu.com/#weixin) && [微博](http://weibo.com/qiniutek), 及时获取动态信息

## 代码许可

The MIT License (MIT). 详情见 [License 文件](https://github.com/qiniu/objc-sdk/blob/master/LICENSE).
