//
//  PLMainViewController.m
//  PLCameraStreamingKitDemo
//
//  Created by TaoZeyu on 16/5/27.
//  Copyright © 2016年 Pili. All rights reserved.
//

#import "PLMainViewController.h"
#import "PLModelPanelGenerator.h"
#import "PLStreamingSessionConstructor.h"
#import "PLPermissionRequestor.h"
#import "PLPanelDelegateGenerator.h"

#import "NSString+Random.h"

#import <PLMediaStreamingKit/PLMediaStreamingKit.h>

#import <Masonry/Masonry.h>
#import <BlocksKit/BlocksKit.h>
#import <BlocksKit/BlocksKit+UIKit.h>
#import <WeiboSDK/WeiboSDK.h>
#import "WXApi.h"

#warning 如果需要分享到微博或微信，请在这里填写相应的 key

#define kWeiboAppKey     @"Your weibo app key"
#define kWeiboAppSecret  @"Your weibo app secret"
#define kWeiXinAppID     @"Your weixin app ID"

static NSString *authenticationStatus[] = {
    @"PLAuthenticationResultNotDetermined",
    @"PLAuthenticationResultDenied",
    @"PLAuthenticationResultAuthorized"
};

@interface PLMainViewController ()
<
PLMediaStreamingSessionDelegate,
PLPanelDelegateGeneratorDelegate,
UIAlertViewDelegate
>
@end

@implementation PLMainViewController
{
    PLMediaStreamingSession *_streamingSession;
    PLModelPanelGenerator *_modelPanelGenerator;
    PLPanelDelegateGenerator *_panelDelegateGenerator;
    PLStreamingSessionConstructor *_sessionConstructor;
    PLAudioCaptureConfiguration *_audioCaptureConfiguration;
    UIButton *_startButton;
    UIButton *_liveButton;
    UISlider *_zoomSlider;
    NSURL *_streamCloudURL;
    NSURL *_streamURL;
    UIView *_inputURLView;
    UITextView *_inputURLTextView;
}

- (void)dealloc
{

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [WeiboSDK registerApp:kWeiboAppKey];
    
    [WXApi registerApp:kWeiXinAppID withDescription:@"PLMediaStreamingKitDemo"];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"需要开启回声消除么？" delegate:self cancelButtonTitle:@"不要" otherButtonTitles:@"开开开", nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    UITextField *textFiled = [alertView textFieldAtIndex:0];
    if (textFiled) {
        if (buttonIndex == 0) {
            return;
        }
        
        NSString *deviceID = textFiled.text;
        [PLStreamingEnv setDeviceID:deviceID];
        return;
    }
    
    if (!_audioCaptureConfiguration) {
        _audioCaptureConfiguration = [PLAudioCaptureConfiguration defaultConfiguration];
    }
    _audioCaptureConfiguration.acousticEchoCancellationEnable = (buttonIndex == 1);
    
    // 获取推流地址，该地址要拿去鉴权获取 token，最终使用的推流 URL 为 _streamURL
    [self _getStreamCloudURL];
    [self _generateStreamURLFromServerWithURL:_streamCloudURL];
    
    [self _prepareForCameraSetting];
    [self _prepareButtons];
    
    _panelDelegateGenerator = [[PLPanelDelegateGenerator alloc] initWithMediaStreamingSession:_streamingSession];
    [_panelDelegateGenerator generate];
    _panelDelegateGenerator.delegate = self;
    
    _modelPanelGenerator = [[PLModelPanelGenerator alloc] initWithMediaStreamingSession:_streamingSession panelDelegateGenerator:_panelDelegateGenerator];
    self.panelModels = [_modelPanelGenerator generate];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_streamingSession destroy];
}

- (void)_getStreamCloudURL {
#warning 在这里填写获取推流地址的业务服务器 url
    NSString *streamServer = @"your app server url";
    NSString *streamID = [NSString randomizedString];
    
    NSString *streamURLString = [streamServer stringByAppendingPathComponent:streamID];
    
    _streamCloudURL = [NSURL URLWithString:streamURLString];
}

- (void)_prepareForCameraSetting
{
    _sessionConstructor = [[PLStreamingSessionConstructor alloc] initWithAudioCaptureConfiguration:_audioCaptureConfiguration];
    _streamingSession = [_sessionConstructor streamingSession];
    
    _streamingSession.delegate = self;
    PLPermissionRequestor *permission = [[PLPermissionRequestor alloc] init];
    permission.noPermission = ^{};
    permission.permissionGranted = ^{
        UIView *previewView = _streamingSession.previewView;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.cameraPreviewView insertSubview:previewView atIndex:0];
            [previewView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.left.and.right.equalTo(self.cameraPreviewView);
            }];
        });
    };
    [permission checkAndRequestPermission];
}

- (void)_generateStreamURLFromServerWithURL:(NSURL *)url
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"GET";
    request.timeoutInterval = 10;
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error != nil || response == nil || data == nil) {
            NSLog(@"get play json faild, %@, %@, %@", error, response, data);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self _generateStreamURLFromServerWithURL:url];
            });
            return;
        }
        
        NSURL *streamURL = [NSURL URLWithString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *streamURLString = streamURL.absoluteString;
            
            // 将推流地址复制到剪切板
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = streamURLString;
            
            // 弹出提示框，显示推流地址，当点击 ok 确认键后，推流被复制到了剪切板，方便将推流地址粘贴用于其它地方
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"streamURL" message:streamURLString delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
            [alert show];
        });
        
        // 更新推流的 URL
        _streamURL = streamURL;
    }];
    [task resume];
}

- (void)_prepareButtons
{
    _startButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.cameraPreviewView addSubview:button];
        [button setTitle:@"start" forState:UIControlStateNormal];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(100, 50));
            make.bottom.equalTo(self.cameraPreviewView).with.offset(-25);
            make.centerX.equalTo(self.cameraPreviewView).with.offset(-120);
        }];
        button;
    });
    UIButton *qrCodeButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.cameraPreviewView addSubview:button];
        [button setTitle:@"二维码" forState:UIControlStateNormal];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(100, 50));
            make.bottom.equalTo(self.cameraPreviewView).with.offset(-25);
            make.centerX.equalTo(self.cameraPreviewView).with.offset(-40);
        }];
        button;
    });
    UIButton *screenshotButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.cameraPreviewView addSubview:button];
        [button setTitle:@"截图" forState:UIControlStateNormal];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(100, 50));
            make.bottom.equalTo(self.cameraPreviewView).with.offset(-25);
            make.centerX.equalTo(self.cameraPreviewView).with.offset(40);
        }];
        button;
    });
    UIButton *changeCameraButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.cameraPreviewView addSubview:button];
        [button setTitle:@"转" forState:UIControlStateNormal];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(100, 50));
            make.bottom.equalTo(self.cameraPreviewView).with.offset(-25);
            make.centerX.equalTo(self.cameraPreviewView).with.offset(120);
        }];
        button;
    });
    
    _zoomSlider = ({
        UISlider *slider = [[UISlider alloc] init];
        [self.cameraPreviewView addSubview:slider];
        slider.value = 1.0;
        slider.minimumValue = 1.0;
        slider.maximumValue = MIN(5, _streamingSession.videoActiveFormat.videoMaxZoomFactor);
        [slider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(320, 20));
            make.bottom.equalTo(self.cameraPreviewView).with.offset(-100);
            make.centerX.equalTo(self.cameraPreviewView).with.offset(0);
        }];
        slider;
    });
    
    UIButton *inputPushURLButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.cameraPreviewView addSubview:button];
        [button setTitle:@"输入 pushURL" forState:UIControlStateNormal];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(100, 50));
            make.bottom.equalTo(self.cameraPreviewView).with.offset(-140);
            make.centerX.equalTo(self.cameraPreviewView).with.offset(0);
        }];
        button;
    });
    
    UIButton *shareWeiXinButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.cameraPreviewView addSubview:button];
        [button setTitle:@"分享WeiXin" forState:UIControlStateNormal];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(100, 50));
            make.bottom.equalTo(self.cameraPreviewView).with.offset(-140);
            make.centerX.equalTo(self.cameraPreviewView).with.offset(-120);
        }];
        button;
    });
    
    UIButton *shareWeiboButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.cameraPreviewView addSubview:button];
        [button setTitle:@"分享Weibo" forState:UIControlStateNormal];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(100, 50));
            make.bottom.equalTo(self.cameraPreviewView).with.offset(-140);
            make.centerX.equalTo(self.cameraPreviewView).with.offset(120);
        }];
        button;
    });
    
    UIButton *seiTestButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.cameraPreviewView addSubview:button];
        [button setTitle:@"SEI" forState:UIControlStateNormal];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(100, 50));
            make.top.equalTo(self.cameraPreviewView).with.offset(150);
            make.centerX.equalTo(self.cameraPreviewView).with.offset(0);
        }];
        button;
    });
    
    UIButton *authButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.cameraPreviewView addSubview:button];
        [button setTitle:@"auth" forState:UIControlStateNormal];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(100, 50));
            make.top.equalTo(self.cameraPreviewView).with.offset(150);
            make.left.equalTo(self.cameraPreviewView).with.offset(60);
        }];
        button;
    });
    
    [_startButton addTarget:self action:@selector(_pressedStartButton:)
           forControlEvents:UIControlEventTouchUpInside];
    [qrCodeButton addTarget:self action:@selector(_pressedQRButton:)
           forControlEvents:UIControlEventTouchUpInside];
    [changeCameraButton addTarget:self action:@selector(_pressedChangeCameraButton:)
                 forControlEvents:UIControlEventTouchUpInside];
    [shareWeiboButton addTarget:self action:@selector(_pressedWeiboShareButton:)
               forControlEvents:UIControlEventTouchUpInside];
    [shareWeiXinButton addTarget:self action:@selector(_pressedWeiXinShareButton:)
               forControlEvents:UIControlEventTouchUpInside];
    [screenshotButton addTarget:self action:@selector(_pressedScreenshotButton:)
               forControlEvents:UIControlEventTouchUpInside];
    [_zoomSlider addTarget:self action:@selector(_scrollSlider:) forControlEvents:UIControlEventValueChanged];
    [inputPushURLButton addTarget:self action:@selector(_pressedInputURL:) forControlEvents:UIControlEventTouchUpInside];
    [seiTestButton addTarget:self action:@selector(sendSETData:) forControlEvents:UIControlEventTouchUpInside];
    [authButton addTarget:self action:@selector(initiativeAuthCheck:) forControlEvents:UIControlEventTouchUpInside];
    
    _inputURLView = ({
        UIView *view = [[UIView alloc] init];
        [self.cameraPreviewView addSubview:view];
        view.backgroundColor = [UIColor whiteColor];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(300, 200));
            make.top.equalTo(self.cameraPreviewView).with.offset(50);
            make.centerX.equalTo(self.cameraPreviewView);
        }];
        
        _inputURLTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, 280, 100)];
        _inputURLTextView.backgroundColor = [UIColor lightGrayColor];
        [view addSubview:_inputURLTextView];
        
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        cancelButton.frame = CGRectMake(0, 130, 150, 50);
        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        cancelButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [cancelButton addTarget:self action:@selector(_cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:cancelButton];
        
        UIButton *sureButton = [UIButton buttonWithType:UIButtonTypeSystem];
        sureButton.frame = CGRectMake(150, 130, 150, 50);
        [sureButton setTitle:@"确定" forState:UIControlStateNormal];
        sureButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [sureButton addTarget:self action:@selector(_sureButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:sureButton];
        
        view;
    });
    _inputURLView.hidden = YES;
}

- (void)sendSETData:(UIButton *)button {
    if (_streamingSession.isStreamingRunning) {
        [_streamingSession pushSEIMessage:@"seitest" repeat:6];
    }
}

- (void)initiativeAuthCheck:(UIButton *)button {
    [PLMediaStreamingSession checkAuthentication:^(PLAuthenticationResult result) {
        NSArray *array = @[
            @"还未进行鉴权",
            @"未经授权",
            @"授权通过"
        ];

        NSLog(@"PLMediaStreamingKit authentication - %@", authenticationStatus[result]);
        [[[UIAlertView alloc] initWithTitle:@"主动鉴权" message:array[result] delegate:nil cancelButtonTitle:@"知道啦" otherButtonTitles:nil] show];
    }];
}

- (void)_pressedStartButton:(UIButton *)button
{
    if (!_streamingSession.isStreamingRunning) {
        if (!_streamURL) {
            [[[UIAlertView alloc] initWithTitle:@"错误" message:@"还没有获取到 streamURL 不能推流哦" delegate:nil cancelButtonTitle:@"知道啦" otherButtonTitles:nil] show];
            return;
        }
        button.enabled = NO;
        [_streamingSession startStreamingWithPushURL:_streamURL feedback:^(PLStreamStartStateFeedback feedback) {
            NSString *log = [NSString stringWithFormat:@"session start state %lu",(unsigned long)feedback];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"%@", log);
                button.enabled = YES;
                if (PLStreamStartStateSuccess == feedback) {
                    [button setTitle:@"stop" forState:UIControlStateNormal];
                } else {
                    [[[UIAlertView alloc] initWithTitle:@"错误" message:@"推流失败了，将重新请求有效的URL" delegate:nil cancelButtonTitle:@"知道啦" otherButtonTitles:nil] show];
                    
                    // 重新获取有效的URL，即更换 token，播放端的地址不会变
                    [self _generateStreamURLFromServerWithURL:_streamCloudURL];
                }
            });
        }];
    } else {
        [_streamingSession stopStreaming];
        [button setTitle:@"start" forState:UIControlStateNormal];
    }
}

- (void)_cancelButtonPressed:(UIButton *)button {
    _inputURLView.hidden = YES;
    [_inputURLTextView resignFirstResponder];
}

- (void)_sureButtonPressed:(UIButton *)button {
    _inputURLView.hidden = YES;
    [_inputURLTextView resignFirstResponder];
    NSString *pushURL = [_inputURLTextView text];
    if (pushURL && pushURL.length) {
        _streamURL = [NSURL URLWithString:pushURL];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"streamURL" message:pushURL delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)_pressedQRButton:(UIButton *)button
{
    if (!_streamURL) {
        [[[UIAlertView alloc] initWithTitle:@"错误" message:@"还没有获取到 streamJson 没有可供播放的二维码哦" delegate:nil cancelButtonTitle:@"知道啦" otherButtonTitles:nil] show];
    } else {
        NSString *host = @"rtmp://pili-live-rtmp.pili2test.qbox.net";
        NSString *hub = @"pili2test";
        NSString *streamID = [[[[_streamURL.absoluteString componentsSeparatedByString:@"/"] objectAtIndex:4] componentsSeparatedByString:@"?"] objectAtIndex:0];
        NSString *url = [NSString stringWithFormat:@"%@/%@/%@",host, hub,  streamID];
        UIImage *image = [self createQRForString:url];
        UIControl *screenMaskView = ({
            UIControl *mask = [[UIControl alloc] init];
            [self.view addSubview:mask];
            UIImageView *imgView = [[UIImageView alloc] initWithImage:image];
            [mask addSubview:imgView];
            [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(204, 204));
                make.center.equalTo(mask);
            }];
            [mask mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.left.right.and.bottom.equalTo(self.view);
            }];
            mask;
        });
        [screenMaskView addTarget:self action:@selector(_onTapQRCodeImageView:)
                 forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)_pressedWeiboShareButton:(UIButton *)button {
    
    if (![WeiboSDK isWeiboAppInstalled]) {
        [[[UIAlertView alloc] initWithTitle:@"矮油" message:@"您还没有安装微博哦" delegate:nil cancelButtonTitle:@"知道啦" otherButtonTitles:nil] show];
        return;
    }
    
    WBMessageObject *message = [WBMessageObject message];
    
    message.text = [NSString stringWithFormat:@"直播开始啦: %@", [_streamURL absoluteString]];
    
    WBImageObject *image = [WBImageObject object];
    image.imageData = UIImagePNGRepresentation([UIImage imageNamed:@"qiniu.png"]);
    message.imageObject = image;
    
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message];
    
    [WeiboSDK sendRequest:request];
}

- (void)_pressedWeiXinShareButton:(UIButton *)button {
    if (![WXApi isWXAppInstalled] || ![WXApi isWXAppSupportApi] ) {
        [[[UIAlertView alloc] initWithTitle:@"矮油" message:@"您还没有安装微信哦" delegate:nil cancelButtonTitle:@"知道啦" otherButtonTitles:nil] show];
        return;
    }
    
    SendMessageToWXReq *WXMessage = [[SendMessageToWXReq alloc] init];
    WXMessage.text = [NSString stringWithFormat:@"直播开始啦: %@", [_streamURL absoluteString]];
    WXMessage.bText = YES;
    WXMessage.scene = WXSceneTimeline;
    
    [WXApi sendReq:WXMessage];
    
    return;
}

- (void)_pressedScreenshotButton:(UIButton *)button {
    static NSUInteger screenshotCount = 0;
    [_streamingSession getScreenshotWithCompletionHandler:^(UIImage * _Nullable image) {
        if (image == nil) {
            return;
        }
        
        screenshotCount++;
        uint64_t timestamp = (uint64_t)[[NSDate date] timeIntervalSince1970];
        
        NSString *savedPath = [NSString stringWithFormat:@"%@screenshot_%llu_%lu.png",
                               [[[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] objectAtIndex:0] absoluteString] substringFromIndex:7], timestamp, screenshotCount];
        NSData *imageData=UIImagePNGRepresentation(image);
        [imageData writeToFile:savedPath atomically:YES];
    }];
}

- (void)_pressedChangeCameraButton:(UIButton *)button
{
    [_streamingSession toggleCamera];
    _zoomSlider.minimumValue = 1.0;
    _zoomSlider.maximumValue = MIN(5, _streamingSession.videoActiveFormat.videoMaxZoomFactor);
}

- (void)_onTapQRCodeImageView:(UIView *)screenMask
{
    [screenMask removeFromSuperview];
}

- (void)_scrollSlider:(UISlider *)slider {
    _streamingSession.videoZoomFactor = slider.value;
}

- (void)_pressedInputURL:(UIButton *)button {
    _inputURLView.hidden = NO;
}

- (UIImage *)createQRForString:(NSString *)qrString
{
    NSData *stringData = [qrString dataUsingEncoding:NSUTF8StringEncoding];
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
    return [[UIImage alloc] initWithCIImage:qrFilter.outputImage];
}

#pragma mark - delegate

- (void)panelDelegateGenerator:(PLPanelDelegateGenerator *)panelDelegateGenerator streamDidDisconnectWithError:(NSError *)error {
    [_startButton setTitle:@"start" forState:UIControlStateNormal];
    [[[UIAlertView alloc] initWithTitle:@"错误" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

- (void)panelDelegateGenerator:(PLPanelDelegateGenerator *)panelDelegateGenerator streamStateDidChange:(PLStreamState)state {
    if (PLStreamStateDisconnected == state) {
        [_startButton setTitle:@"start" forState:UIControlStateNormal];
    } else if (PLStreamStateConnected == state) {
        [_startButton setTitle:@"stop" forState:UIControlStateNormal];
    }
}

@end
