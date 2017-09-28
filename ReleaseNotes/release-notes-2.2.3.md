# PLMediaStreamingKit Release Notes for 2.2.3

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

- 缺陷
  - 修复频繁设置 pushImage 内存未释放的问题
  - 修复在 iOS 8.1 设备上预览画面卡住的问题
  - 修复 VideoToolbox 编码方式下特定分辨率裁剪未居中的问题
  - 修复推流超过 4.5 小时掉线的问题
  - 修复 Xcode 9 下编译报错的问题

