# PLMediaStreamingKit Release Notes for 3.1.1

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
   - 支持推流过程中修改 fps

- 缺陷
   - 修复 iOS 17.4.1 SRT 无法推流
   - 修复 HEVC 编码，HLS 拉流异常
   - 修复其它已知问题
   

## 注意事项

- **从 v3.0.7 开始，HappyDNS 版本更新至 v1.0.0**
- **从 v3.0.0 版本开始，七牛直播推流 SDK 需要先获取授权才能使用。授权分为试用版和正式版，可通过 400-808-9176 转 2 号线联系七牛商务咨询，或者 [通过工单](https://support.qiniu.com/?ref=developer.qiniu.com) 联系七牛的技术支持。**
- **v3.0.0 之前的版本不受影响，请继续放心使用。**
- **老客户升级 v3.0.0 版本之前，请先联系七牛获取相应授权，以免发生鉴权不通过的现象。**
- **基于 114 dns 解析的不确定性，使用该解析可能会导致解析的网络 ip 无法做到最大的优化策略，进而出现推流质量不佳的现象。因此建议使用非 114 dns 解析**
- **目前还不支持使用 srt 协议 HEVC 编码推流**
