# PLMediaStreamingKit Release Notes for 2.1.6

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
  - 支持苹果 ATS 安全标准
  - PLMediaStreamingSession 增加外部传入 QNDnsManager 的接口
- 缺陷
  - 修复设置音效后内存泄漏的问题
  - 修复设置推流镜像时预览画面会闪一下的问题
- 其它
  - 废弃 PLCameraStreamingSession，请使用 PLMediaStreamingSession 
