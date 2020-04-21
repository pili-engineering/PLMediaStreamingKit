# PLMediaStreamingKit 2.3.5 to 3.0.0 API Differences

## General Headers

```
PLMediaStreamingSession.h
```   

- *Added* `+ (void)checkAuthentication:(void(^ __nonnull)(PLAuthenticationResult result))resultBlock;`


```
PLTypeDefines.h
``` 

- *Added* `typedef enum {
    // 还没有确定是否授权
    PLAuthenticationResultNotDetermined = 0,
    // 未授权
    PLAuthenticationResultDenied,
    // 已成功
    PLAuthenticationResultAuthorized
} PLAuthenticationResult;`
