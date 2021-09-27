//
//  PLInitViewController.m
//  PLMediaStreamingKitDemo
//
//  Created by 冯文秀 on 2020/6/8.
//  Copyright © 2020 Pili. All rights reserved.
//

#import "PLInitViewController.h"
// 预览推流界面
#import "PLStreamViewController.h"
#import "PLSettingsView.h"
// 二维码扫描界面
#import "PLScanViewController.h"

#import <MobileCoreServices/MobileCoreServices.h>


@interface PLInitViewController ()
<
PLSettingsViewDelegate,
PLScanViewControlerDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate
>
// 视频采集配置
@property (nonatomic, strong) PLVideoCaptureConfiguration *videoCaptureConfiguration;
// 视频流配置
@property (nonatomic, strong) PLVideoStreamingConfiguration *videoStreamConfiguration;
// 音频采集配置
@property (nonatomic, strong) PLAudioCaptureConfiguration *audioCaptureConfiguration;
// 音频流配置
@property (nonatomic, strong) PLAudioStreamingConfiguration *audioStreamingConfiguration;

#warning PLMediamediaSession 音视频采集 推流核心类
@property (nonatomic, strong) PLMediaStreamingSession *mediaSession;
#warning PLStreamingSession 外部导入音视频 推流核心类
@property (nonatomic, strong) PLStreamingSession *streamSession;


// UI
@property (nonatomic, strong) PLSettingsView *settingsView;
@property (nonatomic, strong) UIButton *playURLButton;
@property (nonatomic, strong) UIButton *authButton;
@property (nonatomic, strong) UIButton *scanButton;
@property (nonatomic, strong) UIButton *enterPushButton;
@property (nonatomic, assign) CGFloat topSpace;

@end

@implementation PLInitViewController

- (void)dealloc {
    NSLog(@"[PLInitViewController] dealloc !");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 适配顶部
    CGFloat space = 24;
    if (PL_iPhoneX || PL_iPhoneXR || PL_iPhoneXSMAX ||
        PL_iPhone12Min || PL_iPhone12Pro || PL_iPhone12PMax) {
        space = 44;
    }
    _topSpace = space + 4;
    
    // 默认配置
    [self defaultSettings];
    
    // 推荐配置
    _mediaSession.sessionPreset = AVCaptureSessionPreset1280x720;
    _mediaSession.videoStreamingConfiguration.averageVideoBitRate = 1500 *1000;

    [self initUISettingView];
}

#pragma mark - PLMediamediaSession 的默认配置
- (void)defaultSettings {
    /* Configuration */
    // 视频采集分默认配置，帧率 24fps、分辨率 480x640、前置预览镜像 YES、后置预览镜像 NO、前置编码镜像 NO、后置编码镜像 NO、默认后置摄像头、竖屏
    _videoCaptureConfiguration = [PLVideoCaptureConfiguration defaultConfiguration];
    
    // 视频编码默认配置，帧率 24fps、分辨率 368x640、 GOP 最大间隔 72、码率 768kbps
    _videoStreamConfiguration = [PLVideoStreamingConfiguration defaultConfiguration];
    
    // 音频采集默认配置，单声道、回声消除关闭
    _audioCaptureConfiguration = [PLAudioCaptureConfiguration defaultConfiguration];
    
    // 音频编码默认配置，设备采样率、单声道、码率 96kbps、编码类型硬编 AAC、音频流描述单路
    _audioStreamingConfiguration = [PLAudioStreamingConfiguration defaultConfiguration];
    
    // 根据音视频配置 初始化 PLMediaStreamingSession
    _mediaSession = [[PLMediaStreamingSession alloc] initWithVideoCaptureConfiguration:_videoCaptureConfiguration audioCaptureConfiguration:_audioCaptureConfiguration videoStreamingConfiguration:_videoStreamConfiguration audioStreamingConfiguration:_audioStreamingConfiguration stream:nil];

    // 外部导入音视频配置 初始化 PLStreamingSession
    _streamSession = [[PLStreamingSession alloc] initWithVideoStreamingConfiguration:_videoStreamConfiguration audioStreamingConfiguration:_audioStreamingConfiguration stream:nil];
}

- (void)initUISettingView {
    // 推流 SDK 版本号展示
    NSString *versionStr = [PLMediaStreamingSession versionInfo];
    UILabel *versionLabel = [[UILabel alloc] init];
    versionLabel.font = FONT_MEDIUM(13.f);
    versionLabel.textColor = COLOR_RGB(181, 68, 68, 1);
    versionLabel.textAlignment = NSTextAlignmentLeft;
    versionLabel.numberOfLines = 0;
    versionLabel.text = [NSString stringWithFormat:@"Version: %@ Code: %@", PL_MEDIA_STREAM_VERSION, versionStr];
    [self.view addSubview:versionLabel];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:lineView];

    // 操作按钮
    _playURLButton = [[UIButton alloc] init];
    _playURLButton.titleLabel.font = FONT_LIGHT(11.f);
    _playURLButton.layer.borderColor = [UIColor blackColor].CGColor;
    _playURLButton.layer.borderWidth = 0.5f;
    [_playURLButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_playURLButton setTitle:@"Play URL" forState:UIControlStateNormal];
    [_playURLButton addTarget:self action:@selector(playURLCopy) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_playURLButton];
    
    // 鉴权按钮
    _authButton = [[UIButton alloc] init];
    _authButton.titleLabel.font = FONT_LIGHT(11.f);
    _authButton.layer.borderColor = [UIColor blackColor].CGColor;
    _authButton.layer.borderWidth = 0.5f;
    [_authButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_authButton setTitle:@"BundleId Auth" forState:UIControlStateNormal];
    [_authButton addTarget:self action:@selector(bundleIdAuth) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_authButton];
    
    // 扫描按钮
    _scanButton = [[UIButton alloc] init];
    _scanButton.titleLabel.font = FONT_LIGHT(11.f);
    _scanButton.layer.borderColor = [UIColor blackColor].CGColor;
    _scanButton.layer.borderWidth = 0.5f;
    [_scanButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_scanButton setTitle:@"Scan Code" forState:UIControlStateNormal];
    [_scanButton addTarget:self action:@selector(scanCode) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_scanButton];

    // 进入 PLStreamViewController 按钮
    _enterPushButton = [[UIButton alloc] init];
    _enterPushButton.titleLabel.font = FONT_LIGHT(11.f);
    _enterPushButton.layer.borderColor = [UIColor blackColor].CGColor;
    _enterPushButton.layer.borderWidth = 0.5f;
    [_enterPushButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_enterPushButton setTitle:@"Enter Preview" forState:UIControlStateNormal];
    [_enterPushButton addTarget:self action:@selector(nextStep) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_enterPushButton];
    
    // masonry 集中布局
    [versionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).offset(20);
        make.right.mas_equalTo(self.view.mas_right).offset(-20);
        make.top.mas_equalTo(_topSpace);
        make.height.mas_equalTo(30);
    }];
    
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(versionLabel);
        make.right.equalTo(versionLabel);
        make.top.mas_equalTo(versionLabel.mas_bottom);
        make.height.mas_equalTo(0.6f);
    }];
    
    NSArray *buttonArray = @[_playURLButton, _authButton, _scanButton, _enterPushButton];
    [buttonArray mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:10 leadSpacing:20 tailSpacing:20];
    [buttonArray mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_bottom).offset(-55);
        make.height.mas_equalTo(30);
    }];
    
    // 配置视图
    CGFloat setViewHeight = 516;
    if (KSCREEN_HEIGHT < 667) {
        setViewHeight = KSCREEN_HEIGHT - 116;
    }
    _settingsView = [[PLSettingsView alloc] initWithFrame:CGRectMake(0, 0, 0, setViewHeight) mediaSession:_mediaSession streamSession:_streamSession pushURL:@"rtmp://"];
    _settingsView.delegate = self;
    _settingsView.listSuperView = self.view;
    [self.view addSubview:_settingsView];
    
    [_settingsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left);
        make.right.mas_equalTo(self.view.mas_right);
        make.top.mas_equalTo(lineView.mas_bottom).offset(15);
        make.bottom.mas_equalTo(_playURLButton.mas_top).offset(-50);
    }];
}

#pragma mark - PLSettingsViewDelegate
- (void)settingsView:(PLSettingsView *)settingsView didChangedSession:(PLMediaStreamingSession *)mediaSession streamSession:(PLStreamingSession *)streamSession {
    _mediaSession = mediaSession;
    _streamSession = streamSession;
}

#pragma mark - PLScanViewControllerDelegate
- (void)scanQRResult:(NSString *)qrString {
    if (qrString && qrString.length != 0) {
        _settingsView.urlTextField.text = qrString;
    } else {
        [self alertViewWithMessage:[NSString stringWithFormat:@"扫描二维码出错：%@", qrString]];
    }
}

#pragma mark - button actions
// 播放地址复制到剪切板
- (void)playURLCopy {
    NSString *URLString = _settingsView.urlTextField.text;
    NSString *message;
    if ([URLString hasPrefix:@"rtmp://pili-publish.qnsdk.com/sdk-live/"]) {
        NSArray *componentArray = [URLString componentsSeparatedByString:@"sdk-live/"];
        // 将推流地址复制到剪切板
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = [NSString stringWithFormat:@"rtmp://pili-rtmp.qnsdk.com/sdk-live/%@", componentArray[1]];
        message = @"播放地址已成功复制到剪切板！";
    } else{
        message = @"自定义推流地址，无法对应获取播放地址！";
    }
    [self alertViewWithMessage:message];
}

// 二维码扫描推流地址
- (void)scanCode {
    PLScanViewController *scanVc = [PLScanViewController new];
    scanVc.delegate = self;
    scanVc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:scanVc animated:YES completion:nil];
}

// 推流 SDK bundleId 鉴权
- (void)bundleIdAuth {
    [PLMediaStreamingSession checkAuthentication:^(PLAuthenticationResult result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *message;
            switch (result) {
                case PLAuthenticationResultNotDetermined:
                    message = @"还未授权！";
                    break;
                case PLAuthenticationResultDenied:
                    message = @"授权失败！";
                    break;
                case PLAuthenticationResultAuthorized:
                    message = @"授权成功！";
                    break;
                default:
                    break;
            }
            [self alertViewWithMessage:message];
        });
    }];
}

// 进入推流程序
- (void)nextStep {
    if (_settingsView.streamType == 2) {
        // 外部导入数据 推流
        UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
        pickerController.delegate = self;
        pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        pickerController.allowsEditing = NO;
        pickerController.mediaTypes= [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie,nil];
        [self presentViewController:pickerController animated:YES completion:nil];
    } else{
        // 进入预览推流界面
        [self enterPreviewStreamViewWithMedia:nil];
    }
}

// 进入预览推流界面
- (void)enterPreviewStreamViewWithMedia:(NSURL *)mediaURL {
    PLStreamViewController *streamViewController = [[PLStreamViewController alloc] init];
    streamViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    if (_mediaSession) {
        streamViewController.mediaSession = _mediaSession;
    } else{
        streamViewController.streamSession = _streamSession;
    }
    streamViewController.type = _settingsView.streamType;
    streamViewController.pushURL = [NSURL URLWithString:_settingsView.urlTextField.text];
    streamViewController.mediaURL = mediaURL;
    
    if (_settingsView.streamType == 3) {
        if (@available(iOS 10.0, *)) {
            [self presentViewController:streamViewController animated:YES completion:nil];
        } else{
            // 剔除 iOS 10.0 以下的版本，因为 RPScreenRecorder 在 iOS 10.0 以下不支持
            [self alertViewWithMessage:@"低于 iOS 10.0 版本，无法支持录屏推流！"];
            return;
        }
    } else{
        [self presentViewController:streamViewController animated:YES completion:nil];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [self dismissViewControllerAnimated:YES completion:^{
        if (![[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:@"public.movie"]) return;
        
        NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
        if (!url) return;
        [self enterPreviewStreamViewWithMedia:url];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - alert 提示框
- (void)alertViewWithMessage:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:alertAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
