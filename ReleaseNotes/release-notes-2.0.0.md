# PLMediaStreamingKit Release Notes for 2.0.0

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
  - 提供 PLCameraStreamingKit 和 PLStreamingKit 两个层次的 API
  - 支持直接传入 stream URL 进行推流
  - 提供推流节点调度功能
  - 支持音频数据回调及处理功能
- 缺陷
  - 修复orientation 在切换摄像头之后不起作用的问题
  - 修复初始化之后 inputGain 获取到的值始终为 0 的问题
  - 修复多种原因导致的死锁问题
  - 修复弱网推流可能出现的内存泄露问题
  - 修复特殊机器状态可能出现的 crash 问题
- 优化
  - 优化对设备采样率的适配，推流过程中设备采样率变更将不再重新开始推流
