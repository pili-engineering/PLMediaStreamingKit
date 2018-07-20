# PLMediaStreamingKit Release Notes for 2.3.2

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
	- 重构了音频采集模块，包含音频数据采集、背景音乐播放、混音、音效、返听。重构后，插入耳机与否，背景音乐的声音都会从扬声器/耳机发出。
	- 支持在推流过程中往视频画面上添加多个静态图片和文字