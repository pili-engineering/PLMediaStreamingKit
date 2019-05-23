# PLMediaStreamingKit Release Notes for 2.3.4

## 内容

- [简介](#简介)
- [问题反馈](#问题反馈)
- [记录](#记录)

## 简介

PLMediaStreamingKit 为 iOS 开发者提供直播推流 SDK。

## 问题反馈

当你遇到任何问题时，可以通过在 GitHub 的 repo 提交 ```issues``` 来反馈问题，请尽可能的描述清楚遇到的问题，如果有错误信息也一同附带，并且在 ```Labels``` 中指明类型为 bug 或者其他。

[通过这里查看已有的 issues 和提交 Bug](https://github.com/pili-engineering/PLMediaStreamingKit/issues)

## 记录
- 功能
	- 支持在竖屏尺寸采集状态下推横屏尺寸的 buffer 
	- 支持视频帧 BGRA32、NV12 的旋转、裁剪及缩放
	- 支持蓝牙耳机的音频采集
- 缺陷
	- 修复 videoToolBox 编码时，进入后台 setPushImage 后黑屏的问题
	- 修复 replaykit 录屏推流 AVFoundation 编码时，播放端画面大概率黑屏的问题
	- 修复推流过程中音频被电话中断后无法恢复的问题
	- 解决不在主线程访问 UI 的告警问题