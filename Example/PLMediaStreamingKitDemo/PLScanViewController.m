//
//  PLScanViewController.m
//  PLMediaStreamingKitDemo
//
//  Created by 冯文秀 on 2017/7/26.
//  Copyright © 2017年 0dayZh. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "PLScanViewController.h"

@interface PLScanViewController ()<
 AVCaptureMetadataOutputObjectsDelegate
>

@property (nonatomic, strong) UIView *boxView;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;

// 扫码结果
@property (nonatomic, strong) NSString *scanResult;

@end

@implementation PLScanViewController

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    // 停止读取
    [self stopReading];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 开始读取
    [self startReading];
    
    [self layoutUIInterface];
}

#pragma mark - 开始扫描
- (BOOL)startReading {
    NSError *error;
    
    // 初始化捕捉设备（AVCaptureDevice），类型为 AVMediaTypeVideo
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // 用 captureDevice 创建输入流
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (!input) {
        NSLog(@"%@", [error localizedDescription]);
        return NO;
    }
    
    // 创建媒体数据输出流
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    
    // 实例化捕捉会话
    _captureSession = [[AVCaptureSession alloc] init];
    
    // 将添加输入流和媒体输出流到会话
    [_captureSession addInput:input];
    [_captureSession addOutput:captureMetadataOutput];
    
    // 创建串行队列，并加媒体输出流添加到队列当中
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    
    // 设置输出媒体数据类型为QRCode
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    
    // 实例化预览图层
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    
    // 设置预览图层填充方式
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_videoPreviewLayer setFrame:self.view.layer.bounds];
    [self.view.layer addSublayer:_videoPreviewLayer];
    
    // 设置扫描范围
    captureMetadataOutput.rectOfInterest = CGRectMake(0.2f, 0.2f, 0.8f, 0.8f);
    
    // 扫描框
    _boxView = [[UIView alloc] init];
    _boxView.layer.borderColor = [UIColor greenColor].CGColor;
    _boxView.layer.borderWidth = 1.0f;
    [self.view addSubview:_boxView];
    [_boxView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(300, 300));
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.centerY.mas_equalTo(self.view.mas_centerY).offset(22);
    }];
    
    // 开始扫描
    [_captureSession startRunning];
    return YES;
}

#pragma mark - 停止扫描
- (void)stopReading {
    [_captureSession stopRunning];
    _captureSession = nil;
    [_videoPreviewLayer removeFromSuperlayer];
}

#pragma mark - UI 布局
- (void)layoutUIInterface {
    // 适配顶部
    CGFloat space = 26;
    if (PL_iPhoneX || PL_iPhoneXR || PL_iPhoneXSMAX ||
        PL_iPhone12Min || PL_iPhone12Pro || PL_iPhone12PMax) {
        space = 44;
    }
    
    UILabel *titleLab = [[UILabel alloc]init];
    titleLab.font = FONT_MEDIUM(13);
    titleLab.text = @"推流地址二维码扫描";
    titleLab.textColor = [UIColor whiteColor];
    titleLab.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLab];
    
    UIButton *closeButton = [[UIButton alloc]init];
    closeButton.backgroundColor = COLOR_RGB(0, 0, 0, 0.3);
    [closeButton addTarget:self action:@selector(closeButtonSelected) forControlEvents:UIControlEventTouchDown];
    [closeButton setTitle:@"返回" forState:UIControlStateNormal];
    closeButton.titleLabel.font = FONT_MEDIUM(12.f);
    [self.view addSubview:closeButton];
    
    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(160, 26));
        make.top.mas_equalTo(space);
        make.centerX.mas_equalTo(self.view.mas_centerX);
    }];
    
    [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(56, 26));
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(titleLab);
    }];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    dispatch_async(dispatch_get_main_queue(), ^{
        // 判断是否有数据
        if (metadataObjects != nil && [metadataObjects count] > 0) {
            AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
            // 判断回传的数据类型
            if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
                NSLog(@"input QR: %@", [metadataObj stringValue]);
                self.scanResult = [metadataObj stringValue];
                [self performSelectorOnMainThread:@selector(stopReading) withObject:nil waitUntilDone:NO];
                UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"提示" message:self.scanResult preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self startReading];
                    });
                }];
                UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ([self.delegate respondsToSelector:@selector(scanQRResult:)]) {
                            [self.delegate scanQRResult:self.scanResult];
                        }
                        [self dismissViewControllerAnimated:YES completion:nil];
                    });
                }];
                [alertVc addAction:cancelAction];
                [alertVc addAction:sureAction];
                [self presentViewController:alertVc animated:YES completion:nil];

            }
        }
    });
}

- (BOOL)shouldAutorotate {
    return NO;
}

#pragma mark - 返回上个界面
- (void)closeButtonSelected {
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
