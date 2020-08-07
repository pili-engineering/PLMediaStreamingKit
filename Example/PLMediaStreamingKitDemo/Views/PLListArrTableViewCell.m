//
//  PLListArrTableViewCell.m
//  PLMediaStreamingKitDemo
//
//  Created by 冯文秀 on 2017/6/27.
//  Copyright © 2017年 0dayZh. All rights reserved.
//

#import "PLListArrTableViewCell.h"

#define PLLABEL_Y_SPACE 0
#define PLBUTTON_Y_SPACE 30

#define PLLABEL_X_SPACE 0

@implementation PLListArrTableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _configLabel = [[UILabel alloc]initWithFrame:CGRectMake(PLLABEL_X_SPACE, 0, PLTABLE_VIEW_WIDTH - PLLABEL_X_SPACE * 2, 26)];
        _configLabel.numberOfLines = 0;
        _configLabel.textAlignment = NSTextAlignmentLeft;
        _configLabel.font = FONT_LIGHT(11);
        [self.contentView addSubview:_configLabel];
        
        _listButton = [[UIButton alloc]initWithFrame:CGRectMake(PLLABEL_X_SPACE, PLBUTTON_Y_SPACE, PLTABLE_VIEW_WIDTH - PLLABEL_X_SPACE * 2, 26)];
        _listButton.layer.cornerRadius =4;
        _listButton.layer.borderColor = COLOR_RGB(16, 169, 235, 1).CGColor;
        _listButton.layer.borderWidth = 0.5;
        _listButton.backgroundColor = [UIColor whiteColor];
        _listButton.titleLabel.font = FONT_MEDIUM(11);
        [_listButton setTitleColor:COLOR_RGB(16, 169, 235, 1) forState:UIControlStateNormal];
        _listButton.titleLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_listButton];
    }
    return self;
}

- (void)confugureListArrayCellWithConfigureModel:(PLConfigureModel *)configureModel {
    _configLabel.text = configureModel.configuraKey;
    NSInteger index = [configureModel.selectedNum integerValue];
    [_listButton setTitle:configureModel.configuraValue[index] forState:UIControlStateNormal];

    CGRect bounds = [configureModel.configuraKey boundingRectWithSize:CGSizeMake(PLTABLE_VIEW_WIDTH - PLLABEL_X_SPACE * 2, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObject:FONT_LIGHT(11) forKey:NSFontAttributeName] context:nil];
    if (bounds.size.height > 26) {
        _configLabel.frame = CGRectMake(PLLABEL_X_SPACE, 0, PLTABLE_VIEW_WIDTH - PLLABEL_X_SPACE * 2, bounds.size.height);
        _listButton.frame = CGRectMake(PLLABEL_X_SPACE, PLBUTTON_Y_SPACE + bounds.size.height - 24, PLTABLE_VIEW_WIDTH - PLLABEL_X_SPACE * 2, 26);
    }
}

+ (CGFloat)configureListArrayCellHeightWithString:(NSString *)string {
    CGRect bounds = [string boundingRectWithSize:CGSizeMake(PLTABLE_VIEW_WIDTH - PLLABEL_X_SPACE * 2, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObject:FONT_LIGHT(11) forKey:NSFontAttributeName] context:nil];
    if (bounds.size.height > 26) {
        return PLBUTTON_Y_SPACE + bounds.size.height;
    } else{
        return PLBUTTON_Y_SPACE + 26;
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
