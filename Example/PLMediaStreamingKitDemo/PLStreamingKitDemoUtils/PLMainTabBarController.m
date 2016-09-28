//
//  PLMainTabBarController.m
//  PLStreamingKitExample
//
//  Created by TaoZeyu on 16/5/23.
//  Copyright © 2016年 com.pili-engineering.private. All rights reserved.
//

#import "PLMainTabBarController.h"
#import "PLPanelModel.h"
#import "PLLogDisplayer.h"

#import <Masonry/Masonry.h>

@interface PLMainTabBarController ()

@end

@interface _PLMainWrapperViewController : UIViewController
- (instancetype)initWithView:(UIView *)view;
+ (_PLMainWrapperViewController *)wrapView:(UIView *)view withDictionary:(NSMutableDictionary *)dictionary;
@end


@implementation PLMainTabBarController
{
    NSMutableArray *_panelModels;
    NSMutableDictionary *_viewControllerDictionary;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _refreshViewControllers];
}

- (void)addPanelModel:(PLPanelModel *)panelModel
{
    _panelModels = _panelModels ?: [[NSMutableArray alloc] init];
    [_panelModels addObject:panelModel];
    [self _refreshViewControllers];
}

- (void)setPanelModels:(NSArray *)panelModels
{
    _panelModels = [[NSMutableArray alloc] initWithArray:panelModels];
    [self _refreshViewControllers];
}

- (void)setCameraPreviewView:(UIView *)cameraPreviewView
{
    if (_cameraPreviewView != cameraPreviewView) {
        _cameraPreviewView = cameraPreviewView;
        [self _refreshViewControllers];
    }
}

- (void)_refreshViewControllers
{
    _cameraPreviewView = _cameraPreviewView ?: [[UIView alloc] init];
    
    _panelModels = _panelModels ?: [[NSMutableArray alloc] init];
    _viewControllerDictionary = _viewControllerDictionary ?: [[NSMutableDictionary alloc] init];
    
    self.viewControllers = ({
        NSMutableArray *vcs = [[NSMutableArray alloc] initWithCapacity:_panelModels.count + 1];
        [self _addViews:@[_cameraPreviewView]
             wihtTitles:@[@"预览"] toArray:vcs];
        [self _addAllPanelModelsToArray:vcs];
        vcs;
    });
}

- (void)_addViews:(NSArray *)views wihtTitles:(NSArray *)titles toArray:(NSMutableArray *)vcs
{
    for (NSUInteger i=0; i<views.count; ++i) {
        UIView *view = views[i];
        NSString *title = titles[i];
        _PLMainWrapperViewController *viewController = [_PLMainWrapperViewController wrapView:view withDictionary:_viewControllerDictionary];
        [viewController setTitle:title];
        [vcs addObject:viewController];
    }
}

- (void)_addAllPanelModelsToArray:(NSMutableArray *)vcs
{
    for (PLPanelModel *panelModel in _panelModels) {
        _PLMainWrapperViewController *panelModelViewController = [_PLMainWrapperViewController wrapView:panelModel.view withDictionary:_viewControllerDictionary];
        [panelModelViewController setTitle:panelModel.title];
        [vcs addObject:panelModelViewController];
    }
}

@end

@implementation _PLMainWrapperViewController

- (instancetype)initWithView:(UIView *)view
{
    if (self = [self init]) {
        [self.view addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).with.offset(56);
            make.bottom.equalTo(self.view).with.offset(-39);
            make.left.and.right.equalTo(self.view);
        }];
    }
    return self;
}

+ (_PLMainWrapperViewController *)wrapView:(UIView *)view withDictionary:(NSMutableDictionary *)dictionary
{
    NSValue *keyView = [NSValue valueWithNonretainedObject:view];
    _PLMainWrapperViewController *vc = [dictionary objectForKey:keyView];
    if (!vc) {
        vc = [[_PLMainWrapperViewController alloc] initWithView:view];
        [dictionary setObject:vc forKey:keyView];
    }
    return vc;
}

@end
