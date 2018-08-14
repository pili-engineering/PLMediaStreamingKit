# PLMediaStreamingKit Release Notes for 2.3.3

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
	- 支持 bitcode
- 优化
	- 优化相机的对焦效果和曝光效果
	- 优化 pod install 或 update 时进度缓慢的问题
- 缺陷
	- 修复特殊场景下 Wi-Fi 和 4G 之间频繁切换偶现的预览画面卡住的问题
	- 修复开始推流后 0.2 秒内音频爆音的问题