# PLMediaStreamingKit Release Notes for 2.1.4

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
  - 增加对 iOS 10 ReplayKit 录屏推流的支持
  - 增加 VideoToolbox 视频硬件编码功能
  - 增加人工报障和自动报障功能
- 缺陷
  - 修复 iPhone 6s 及以上机型在 iOS 10 上的电流音问题
  - 修复 iPhone 6 及以上机型在 iOS 10 上同时开启自动对焦和手动对焦功能时，手动对焦失效问题
- 优化
  - 优化 RGB 转 YUV 的效率，去除对 libyuv 库的依赖
