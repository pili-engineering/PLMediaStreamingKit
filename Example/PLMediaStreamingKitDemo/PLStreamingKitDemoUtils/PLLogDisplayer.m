//
//  PLLogDisplayer.m
//  PLStreamingKitExample
//
//  Created by TaoZeyu on 16/5/25.
//  Copyright © 2016年 pili-engineering. All rights reserved.
//

#import "PLLogDisplayer.h"

#import <Masonry/Masonry.h>

#define kPLLogDisplayerRecordContainerMaxCount 1000
#define kPLLogDisplayerrecordCellIdentifer @"kPLLogDisplayerrecordCellIdentifer"

@interface PLLogDisplayer () <UITableViewDelegate, UITableViewDataSource> @end

@interface _PLLogDisplayerRecord : NSObject
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *content;
@end

@interface _PLLogDisplayerrecordCell : UITableViewCell
- (void)_displayRecord:(_PLLogDisplayerRecord *)record;
@end

@interface _PLLogDisplayerRecordContainer : NSObject
@property (nonatomic, readonly) NSUInteger count;
- (void)addRecord:(_PLLogDisplayerRecord *)record;
- (_PLLogDisplayerRecord *)recordAt:(NSUInteger)index;
@end

@implementation PLLogDisplayer
{
    _PLLogDisplayerRecordContainer *_recordContainer;
}

- (instancetype)init
{
    if (self = [super init]) {
        _recordContainer = [[_PLLogDisplayerRecordContainer alloc] init];
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self setBackgroundColor:[UIColor blackColor]];
        [self registerClass:[_PLLogDisplayerrecordCell class] forCellReuseIdentifier:kPLLogDisplayerrecordCellIdentifer];
        self.delegate = self;
        self.dataSource = self;
    }
    return self;
}

- (void)print:(NSString *)content
{
    [self printWithKey:@"System" withContent:content];
}

- (void)printWithKey:(NSString *)key withContent:(NSString *)content
{
    NSUInteger originalContainerCount = _recordContainer.count;
    _PLLogDisplayerRecord *record = ({
        _PLLogDisplayerRecord *record = [[_PLLogDisplayerRecord alloc] init];
        record.key = key;
        record.content = content;
        record;
    });
    NSLog(@"[%@] %@", key, content);
    
    [_recordContainer addRecord:record];
    
    if (originalContainerCount != _recordContainer.count) {
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:_recordContainer.count - 1 inSection:0];
        [self insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        
        if ([self _checkTouchTheBottom]) {
            [self scrollToRowAtIndexPath:newIndexPath atScrollPosition:UITableViewScrollPositionBottom
                                animated:NO];
        }
    } else {
        [self reloadData];
    }
}

- (BOOL)_checkTouchTheBottom
{
    CGPoint bottomPoint = CGPointMake(self.bounds.size.width/2, self.bounds.size.height);
    NSIndexPath *indexPath = [self indexPathForRowAtPoint:bottomPoint];
    return indexPath.row == _recordContainer.count - 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _recordContainer.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    _PLLogDisplayerrecordCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:kPLLogDisplayerrecordCellIdentifer];
    [cell _displayRecord:[_recordContainer recordAt:indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 21;
}

@end

@implementation _PLLogDisplayerRecord @end

@implementation _PLLogDisplayerrecordCell
{
    UILabel *_label;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        self.selectedBackgroundView = ({
            UIView *view = [[UIView alloc] initWithFrame:self.bounds];
            view.backgroundColor = [UIColor blueColor];
            view;
        });
        _label = ({
            UILabel *label = [[UILabel alloc] init];
            [self.contentView addSubview:label];
            [label setTextColor:[UIColor whiteColor]];
            [label setFont:[UIFont systemFontOfSize:14]];
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.left.right.and.bottom.equalTo(self);
            }];
            label;
        });
    }
    return self;
}

- (void)_displayRecord:(_PLLogDisplayerRecord *)record
{
    [_label setText:[NSString stringWithFormat:@"[%@] %@", record.key, record.content]];
}

@end

@implementation _PLLogDisplayerRecordContainer
{
    NSMutableArray *_recordArray;
    NSUInteger _offset;
}

- (instancetype)init
{
    if (self = [super init]) {
        _recordArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addRecord:(_PLLogDisplayerRecord *)record
{
    if (_recordArray.count < kPLLogDisplayerRecordContainerMaxCount) {
        [_recordArray addObject:record];
    } else {
        [_recordArray replaceObjectAtIndex:_offset withObject:record];
        _offset = (_offset + 1) % _recordArray.count;
    }
}

- (_PLLogDisplayerRecord *)recordAt:(NSUInteger)index
{
    return [_recordArray objectAtIndex:(index + _offset) % _recordArray.count];
}

- (NSUInteger)count
{
    return _recordArray.count;
}

@end