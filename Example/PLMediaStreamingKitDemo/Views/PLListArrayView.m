//
//  PLListArrayView.m
//  PLMediaStreamingKitDemo
//
//  Created by 冯文秀 on 2017/6/29.
//  Copyright © 2017年 0dayZh. All rights reserved.
//

#import "PLListArrayView.h"

@interface PLListArrayView()<
UITableViewDelegate,
UITableViewDataSource,
UIGestureRecognizerDelegate
>

@property (nonatomic, strong) UITableView *listTableView;

@end

@implementation PLListArrayView
static NSString *listIdentifier = @"listCell";

- (instancetype)initWithFrame:(CGRect)frame listArray:(NSArray *)listArray superView:(UIView *)superView{
    if (self = [super initWithFrame:frame]) {
        self.frame = frame;
        self.backgroundColor = COLOR_RGB(210, 210, 210, 1);
        [superView addSubview:self];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
        tap.delegate = self;
        [self addGestureRecognizer:tap];
        
        _listArray = listArray;

        _listTableView = [[UITableView alloc]init];
        _listTableView.delegate = self;
        _listTableView.dataSource = self;
        _listTableView.backgroundColor = [UIColor whiteColor];
        _listTableView.rowHeight = 40.f;
        [_listTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:listIdentifier];
        CGFloat height = listArray.count * 40;
        if (height > KSCREEN_HEIGHT - 60) {
            _listTableView.frame = CGRectMake(25, 30, KSCREEN_WIDTH - 50, KSCREEN_HEIGHT - 60);
        } else{
            _listTableView.frame = CGRectMake(25, KSCREEN_HEIGHT/2 - height/2, KSCREEN_WIDTH - 50, height);
        }
        [self addSubview:_listTableView];
    }
    return self;
}

- (void)tapAction:(UITapGestureRecognizer *)tap {
    if ([tap.view isEqual:self]) {
        [self removeFromSuperview];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isEqual:self]) {
        return YES;
    } else{
        return NO;
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _listArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:listIdentifier forIndexPath:indexPath];
    cell.textLabel.font = FONT_LIGHT(14);
    cell.textLabel.text = _listArray[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if ([_listArray[indexPath.row] isEqualToString:_listStr]) {
        cell.backgroundColor = SELECTED_BLUE;
    } else{
        cell.backgroundColor = [UIColor whiteColor];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(listArrayViewSelectedWithIndex:configureModel:categoryModel:)]) {
        [self removeFromSuperview];
        [self.delegate listArrayViewSelectedWithIndex:indexPath.row configureModel:_configureModel categoryModel:_categoryModel];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
