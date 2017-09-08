# PLMediaStreamingKit

PLMediaStreamingKit 是一个适用于 iOS 的 RTMP 直播推流 SDK，可高度定制化和二次开发。特色是支持 iOS Camera 画面捕获并进行 H.264 硬编码，以及支持 iOS 麦克风音频采样并进行 AAC 硬编码；同时，还根据移动网络环境的多变性，实现了一套可供开发者灵活选择的编码参数集合。借助 PLMediaStreamingKit，开发者可以快速构建一款类似 [Meerkat](https://meerkatapp.co/) 或 [Periscope](https://www.periscope.tv/) 的手机直播应用。PLMediaStreamingKit 支持两种不同层次的 API，分别为 PLMediaStreamingKit 和 PLStreamingKit， PLStreamingKit 提供包括音视频编码，封包以及网络发送功能，PLMediaStreamingKit 除了提供 PLStreamingKit 的功能以外还提供了内置的采集，音视频处理以及一些系统打断事件的处理等。我们强烈推荐对音视频没有太多了解的开发者使用 PLMediaStreamingKit 提供的 API 进行开发，如果您对音视频数据的采集和处理有更多的需求，那么需要使用 PLStreamingKit 提供的 API 进行开发，不过在进行开发之前请确保您已经掌握了包括音视频采集，编码以及处理等相关的基础支持。

## 功能特性

- [x] 支持硬件编码
- [x] 多码率可选
- [x] 支持 H.264 视频编码
- [x] 支持 AAC 音频编码
- [x] 支持前后摄像头
- [x] 支持自动对焦
- [x] 支持手动调整对焦点
- [x] 支持闪光灯操作
- [x] 支持多分辨率编码
- [x] 支持 HeaderDoc 文档
- [x] 支持构造带安全授权凭证的 RTMP 推流地址
- [x] 支持 ARMv7, ARM64, i386, x86_64 架构
- [x] 支持 RTMP 协议直播推流
- [x] 支持音视频配置分离
- [x] 支持推流时可变码率
- [x] 提供发送 buffer
- [x] 支持 Zoom 操作
- [x] 支持音频 Mute 操作
- [x] 支持视频 Orientation 操作
- [x] 支持自定义 DNS 解析
- [x] 支持弱网丢帧策略
- [x] 支持纯音频或纯视频推流
- [x] 支持后台音频推流
- [x] 支持自定义滤镜功能
- [x] 内置水印功能
- [x] 内置美颜功能
- [x] 支持返听功能
- [x] 支持内置音乐播放器混音功能
- [x] 支持内置音效功能
- [x] 内置动态帧率功能
- [x] 内置自适应码率功能
- [x] 内置断线及网络切换自动重连功能
- [x] 支持预览与直播流分别镜像
- [x] 支持自定义音视频处理
- [x] 支持苹果 ATS 安全标准
- [x] 提供两种层次的 API，灵活选择，高可定制性与简单两不误

## 系统要求

- iOS Target : >= iOS 8
- iOS Device : >= iPhone 5

## 安装方法

[CocoaPods](https://cocoapods.org/) 是针对 Objective-C 的依赖管理工具，它能够将使用类似 PLMediaStreamingKit 的第三方库的安装过程变得非常简单和自动化，你能够用下面的命令来安装它：

```bash
$ sudo gem install cocoapods
```

>构建 PLMediaStreamingKit 2.0.0+ 需要使用 CocoaPods 0.39.0+

### Podfile

为了使用 CoacoaPods 集成 PLMediaStreamingKit 到你的 Xcode 工程当中，你需要编写你的 `Podfile`

```ruby
source 'https://github.com/CocoaPods/Specs.git'
target 'TargetName' do
pod 'PLMediaStreamingKit'
end
```

然后，运行如下的命令：

```bash
$ pod install
```

## PLMediaStreamingKit 文档

请参考开发者中心文档：[PLMediaStreamingKit 文档](https://developer.qiniu.com/pili/sdk/3778/PLMediaStreamingKit-overview)

## 反馈及意见

当你遇到任何问题时，可以通过在 GitHub 的 repo 提交 issues 来反馈问题，请尽可能的描述清楚遇到的问题，如果有错误信息也一同附带，并且在 Labels 中指明类型为 bug 或者其他。

[通过这里查看已有的 issues 和提交 Bug。](https://github.com/pili-engineering/PLMediaStreamingKit/issues)
