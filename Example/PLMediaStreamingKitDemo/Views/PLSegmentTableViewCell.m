//
//  PLSegmentTableViewCell.m
//  PLMediaStreamingKitDemo
//
//  Created by 冯文秀 on 2017/6/27.
//  Copyright © 2017年 0dayZh. All rights reserved.
//

#import "PLSegmentTableViewCell.h"

#define PLLABEL_Y_SPACE 0
#define PLSEGMENT_Y_SPACE 30

#define PLLABEL_X_SPACE 0

@implementation PLSegmentTableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _configLabel = [[UILabel alloc]initWithFrame:CGRectMake(PLLABEL_X_SPACE, PLLABEL_Y_SPACE, PLTABLE_VIEW_WIDTH - PLLABEL_X_SPACE * 2, 26)];
        _configLabel.numberOfLines = 0;
        _configLabel.textAlignment = NSTextAlignmentLeft;
        _configLabel.font = FONT_LIGHT(11);
        [self.contentView addSubview:_configLabel];
    }
    return self;
}

- (void)confugureSegmentCellWithConfigureModel:(PLConfigureModel *)configureModel {
    _configLabel.text = configureModel.configuraKey;
    
    [_segmentControl removeFromSuperview];
    UISegmentedControl *seg = [[UISegmentedControl alloc]initWithItems:configureModel.configuraValue];
    seg.backgroundColor = [UIColor whiteColor];
    seg.tintColor = COLOR_RGB(16, 169, 235, 1);
    NSInteger index = [configureModel.selectedNum integerValue];
    seg.selectedSegmentIndex = index;
    _segmentControl = seg;
    [self.contentView addSubview:_segmentControl];

    CGRect bounds = [configureModel.configuraKey boundingRectWithSize:CGSizeMake(KSCREEN_WIDTH - PLLABEL_X_SPACE * 2, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObject:FONT_LIGHT(11) forKey:NSFontAttributeName] context:nil];
    if (bounds.size.height > 30) {
        _configLabel.frame = CGRectMake(PLLABEL_X_SPACE, PLLABEL_Y_SPACE, PLTABLE_VIEW_WIDTH - PLLABEL_X_SPACE * 2, bounds.size.height);
        _segmentControl.frame = CGRectMake(PLLABEL_X_SPACE, PLSEGMENT_Y_SPACE + bounds.size.height - 26, PLTABLE_VIEW_WIDTH - PLLABEL_X_SPACE * 2, 26);
    } else{
        _segmentControl.frame = CGRectMake(PLLABEL_X_SPACE, PLSEGMENT_Y_SPACE, PLTABLE_VIEW_WIDTH -  PLLABEL_X_SPACE * 2, 26);
    }
}

+ (CGFloat)configureSegmentCellHeightWithString:(NSString *)string {
    CGRect bounds = [string boundingRectWithSize:CGSizeMake(PLTABLE_VIEW_WIDTH -  PLLABEL_X_SPACE * 2, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObject:FONT_LIGHT(11) forKey:NSFontAttributeName] context:nil];
    if (bounds.size.height > 26) {
        return PLSEGMENT_Y_SPACE + bounds.size.height;
    } else{
        return PLSEGMENT_Y_SPACE + 26;
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
