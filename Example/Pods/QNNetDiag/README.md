# Network Diagnosis for iOS

[![@qiniu on weibo](http://img.shields.io/badge/weibo-%40qiniutek-blue.svg)](http://weibo.com/qiniutek)
[![Software License](https://img.shields.io/badge/license-MIT-brightgreen.svg)](LICENSE.md)
[![Build Status](https://travis-ci.org/qiniu/iOS-netdiag.svg?branch=master)](https://travis-ci.org/qiniu/iOS-netdiag)
[![Latest Stable Version](http://img.shields.io/cocoapods/v/QNNetDiag.svg)](https://github.com/qiniu/iOS-netdiag/releases)
![Platform](http://img.shields.io/cocoapods/p/QNNetDiag.svg)

## [中文](https://github.com/qiniu/iOS-netdiag/blob/master/README_cn.md)

## Summary

Network Diagnosis Library，support Ping/TcpPing/Rtmp/TraceRoute/DNS/external IP/external DNS。

## Install

CocoaPods

```ruby
pod "QNNetDiag"
```

## Usage
### Ping
```
@interface YourLogger : NSObject <QNNOutputDelegate>
...
@end

[QNNPing start:@"www.google.com" output:[[YourLogger alloc] init] complete:^(QNNPingResult* r) {
        ...
}];
```

### TcpPing
```
[QNNTcpPing start:@"www.baidu.com" output:[[QNNTestLogger alloc] init] complete:^(QNNTcpPingResult* r) {
    ...
}];
```
## Test


### All Unit Test

``` bash
$ xctool -workspace NetDiag.xcworkspace -scheme NetDiagTests build test -sdk iphonesimulator
```

## Faq

- If there are any compile errors, please look at Cocoapods's [troubleshooting](http://guides.cocoapods.org/using/troubleshooting.html)

## Contributing

Please Look at[Contributing Guide](https://github.com/qiniu/iOS-netdiag/blob/master/CONTRIBUTING.md)。

## Contributors

- [Contributors](https://github.com/qiniu/iOS-netdiag/contributors)

## Contact us

- If you find any bug， please submit [issue](https://github.com/qiniu/iOS-netdiag/issues)
- If you need any feature， please submit [issue](https://github.com/qiniu/iOS-netdiag/issues)
- If you want to contribute, please submit pull request

## License

The MIT License (MIT). [License](https://github.com/qiniu/iOS-netdiag/blob/master/LICENSE).
