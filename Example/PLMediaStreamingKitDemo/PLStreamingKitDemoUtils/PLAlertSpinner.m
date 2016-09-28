//
//  PLAlertSpinner.m
//  PLStreamingKitExample
//
//  Created by TaoZeyu on 16/5/25.
//  Copyright © 2016年 pili-engineering. All rights reserved.
//

#import "PLAlertSpinner.h"

#import <Masonry/Masonry.h>

#define kTwtPLAlertSpinnerDetailTalbeViewCell @"kTwtPLAlertSpinnerDetailTalbeViewCell"

@interface PLAlertSpinner ()
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIWindow *alertWindow;
@end

@interface _PLAlertSpinnerDetailView : UITableView <UITableViewDelegate, UITableViewDataSource>
- (instancetype)initWithParent:(PLAlertSpinner *)parent
          withSelectedCallback:(void (^)(NSUInteger selectedIndex))selectedCallback;
@end

@interface _PLAlertSpinnerDetailCell : UITableViewCell @end

@implementation PLAlertSpinner

- (instancetype)initWithTitles:(NSArray *)titles withDefaultIndex:(NSUInteger)defaultIndex
{
    if (self = [self init]) {
        _titles = titles;
        _selectedIndex = defaultIndex;
        _label = ({
            UILabel *label = [[UILabel alloc] init];
            [self addSubview:label];
            [label setTextColor:[UIColor blueColor]];
            [label setText:titles[defaultIndex]];
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.left.and.right.equalTo(self);
            }];
            label;
        });
        [self addTarget:self action:@selector(_onTapSelf:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (NSString *)selectedTitle
{
    return _titles[_selectedIndex];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    if (_selectedIndex != selectedIndex) {
        _selectedIndex = selectedIndex;
    }
    [_label setText:_titles[_selectedIndex]];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)_onTapSelf:(id)sender
{
    _alertWindow = ({
        UIWindow *win = [[UIWindow alloc] initWithFrame:self.window.frame];
        win.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        win.windowLevel = UIWindowLevelAlert;
        win;
    });
    __weak typeof(self) wself = self;
    void (^selectedCallback)(NSUInteger) = ^(NSUInteger selectedIndex) {
        __strong typeof(wself) strongSelf = wself;
        [strongSelf->_alertWindow setHidden:YES];
        strongSelf->_alertWindow = nil;
        [strongSelf setSelectedIndex:selectedIndex];
    };
    _PLAlertSpinnerDetailView *alert = ({
        _PLAlertSpinnerDetailView *alert = [[_PLAlertSpinnerDetailView alloc] initWithParent:self withSelectedCallback:selectedCallback];
        [_alertWindow addSubview:alert];
        [alert mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_alertWindow).with.offset(15);
            make.bottom.equalTo(_alertWindow).with.offset(-25);
            make.left.equalTo(_alertWindow).with.offset(12);
            make.right.equalTo(_alertWindow).with.offset(-12);
        }];
        alert;
    });
    [alert selectRowAtIndexPath:[NSIndexPath indexPathForRow:_selectedIndex inSection:0]
                       animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    [_alertWindow makeKeyAndVisible];
}

@end

@implementation _PLAlertSpinnerDetailView
{
    __weak PLAlertSpinner *_parentAlertSpinner;
    void (^_selectedCallback)(NSUInteger selectedIndex);
}

- (instancetype)initWithParent:(PLAlertSpinner *)parent
          withSelectedCallback:(void (^)(NSUInteger selectedIndex))selectedCallback
{
    if (self = [self init]) {
        _parentAlertSpinner = parent;
        _selectedCallback = selectedCallback;
        self.dataSource = self;
        self.delegate = self;
        [self registerClass:[_PLAlertSpinnerDetailCell class] forCellReuseIdentifier:kTwtPLAlertSpinnerDetailTalbeViewCell];
    }
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _parentAlertSpinner.titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    _PLAlertSpinnerDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:kTwtPLAlertSpinnerDetailTalbeViewCell forIndexPath:indexPath];
    [cell.textLabel setText:_parentAlertSpinner.titles[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedCallback(indexPath.row);
}

@end

@implementation _PLAlertSpinnerDetailCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.textLabel.highlightedTextColor = [UIColor whiteColor];
        self.selectedBackgroundView = ({
            UIView *view = [[UIView alloc] initWithFrame:self.bounds];
            view.backgroundColor = [UIColor blueColor];
            view;
        });
    }
    return self;
}

@end