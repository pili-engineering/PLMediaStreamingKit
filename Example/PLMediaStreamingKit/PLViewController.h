//
//  PLCameraStreamingViewController.h
//  PLCameraStreamingKit
//
//  Created on 01/10/2015.
//  Copyright (c) Pili Engineering, Qiniu Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PLViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@property (weak, nonatomic) IBOutlet UIButton *toggleCameraButton;
@property (weak, nonatomic) IBOutlet UIButton *torchButton;
@property (weak, nonatomic) IBOutlet UIButton *muteButton;
@property (weak, nonatomic) IBOutlet UIButton *playbackButton;
@property (weak, nonatomic) IBOutlet UIButton *audioEffectButton;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UISlider *zoomSlider;

- (IBAction)zoomSliderValueDidChange:(id)sender;
- (IBAction)playbackButtonPressed:(id)sender;
- (IBAction)audioEffectButtonPressed:(id)sender;

@end
