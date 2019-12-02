//
//  YUFlowLayoutExampleCell.m
//  YUFlowLayoutView_Example
//
//  Created by Yanyuxxxx on 2019/12/2.
//  Copyright © 2019 Yanyuxxxx. All rights reserved.
//

#import "YUFlowLayoutExampleCell.h"
#import "Masonry.h"

@interface YUFlowLayoutExampleCell ()

@property (nonatomic, strong) UILabel *kTitleLabel;

@end

@implementation YUFlowLayoutExampleCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor greenColor];
        [self setUpSubViews];
    }
    return self;
}

- (void)setUpSubViews {
    [self addSubview:self.kTitleLabel];
    [self.kTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
}

- (void)configWith:(NSString *)text {
    self.kTitleLabel.text = text;
}

- (UILabel *)kTitleLabel {
    if (_kTitleLabel == nil) {
        _kTitleLabel = [UILabel new];
        _kTitleLabel.font = [UIFont systemFontOfSize:16];
        _kTitleLabel.textColor = [UIColor blackColor];
    }
    return _kTitleLabel;
}

@end
