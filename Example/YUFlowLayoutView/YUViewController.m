//
//  YUViewController.m
//  YUFlowLayoutView
//
//  Created by Yanyuxxxx on 12/02/2019.
//  Copyright (c) 2019 Yanyuxxxx. All rights reserved.
//

#import "YUViewController.h"
#import "YUFlowLayoutView.h"
#import "Masonry.h"
#import "YUFlowLayoutExampleCell.h"

@interface YUViewController () <YUFlowLayoutViewDataSource, YUFlowLayoutViewDelegate>

@property (nonatomic, copy) NSArray *dataSource;

@property (nonatomic, strong) YUFlowLayoutView *layoutView;

@end

@implementation YUViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    _dataSource = @[@"文字文字文字", @"文字", @"文字", @"文字", @"文字文字文字文字文字文字文字文字文字文字文字文字文字文字文字文字文字文字文字文字文字", @"文字", @"文字", @"文字文字文字", @"文字文字", @"文字文", @"文字", @"文字", @"文字文字文字", @"文字"];
    
    [self.view addSubview:self.layoutView];
    [self.layoutView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(60);
        make.left.right.mas_equalTo(0);
    }];
    self.layoutView.backgroundColor = [UIColor yellowColor];
    [self.layoutView reloadData];
}


#pragma mark - YUFlowLayoutViewDataSource
- (NSInteger)numberOfItemsInLayoutView:(YUFlowLayoutView *)layoutView {
    return self.dataSource.count;
}

- (YUFlowLayoutCell *)layoutView:(YUFlowLayoutView *)layoutView cellForItemAtIndexPath:(YUFLIndexPath *)indexPath {
    NSString *text = self.dataSource[indexPath.index];
    NSString *reusedId = @"YUFlowLayoutExampleCell";
    YUFlowLayoutExampleCell *cell = [layoutView dequeueReusableCellWithIdentifier:reusedId forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[YUFlowLayoutExampleCell alloc] initWithReuseIdentifier:reusedId];
    }
    [cell configWith:text];
    return cell;
}


#pragma mark - YUFlowLayoutViewDelegate
- (CGFloat)layoutView:(YUFlowLayoutView *)layoutView itemWidthAtIndex:(NSInteger)index {
    NSString *text = self.dataSource[index];
    CGFloat width = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 20)
                                       options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                    attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16]}
                                       context:nil].size.width;
    return width;
}


#pragma mark - getter setter
- (YUFlowLayoutView *)layoutView {
    if (_layoutView == nil) {
        YUFlowLayoutViewConfig *config = [YUFlowLayoutViewConfig new];
        config.minItemSpacing = 10;
        config.itemWidth = 100;
        config.itemHeight = 20;
        config.contentInset = UIEdgeInsetsMake(15, 15, 15, 15);
        config.alignment = YUFlowLayoutViewAlignmentLeft;
        
        _layoutView = [[YUFlowLayoutView alloc] initWithConfig:config];
        _layoutView.dataSource = self;
        _layoutView.delegate = self;
    }
    return _layoutView;
}


@end
