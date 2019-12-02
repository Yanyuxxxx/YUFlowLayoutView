//
//  YUFlowLayoutView.m
//  YUFlowLayoutView
//
//  Created by Yanyuxxxx on 2019/11/11.
//  Copyright © 2019 Yanyuxxxx.com. All rights reserved.
//

#import "YUFlowLayoutView.h"
#import "Masonry.h"
//#import "HDFKitColor.h"
//#import "UIView+HDFView.h"

@implementation YUFLIndexPath

- (NSString *)description {
    NSString *s = [NSString stringWithFormat:@"index: %@, row: %@, rowIndex:%@", @(self.index), @(self.row), @(self.rowIndex)];
    return s;
}

+ (instancetype)indexPathWithIndex:(NSInteger)index {
    return [self indexPathWithIndex:index row:0 rowIndex:0];
}

+ (instancetype)indexPathWithIndex:(NSInteger)index row:(NSInteger)row rowIndex:(NSInteger)rowIndex {
    YUFLIndexPath *indexPath = [YUFLIndexPath new];
    indexPath.index = index;
    indexPath.row = row;
    indexPath.rowIndex = rowIndex;
    return indexPath;
}

@end

@implementation YUFlowLayoutViewConfig

- (instancetype)init {
    self = [super init];
    if (self) {
        _contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _itemWidth = 0;
        _itemHeight = 0;
        _minItemSpacing = 10;
        _rowSpacing = 10;
        _limitRowCount = 0;
        _alignment = YUFlowLayoutViewAlignmentJustified;
    }
    return self;
}

@end

@interface YUFlowLayoutCell ()

@property (nonatomic, copy, readwrite) NSString *reuseIdentifier;

@end

@implementation YUFlowLayoutCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _reuseIdentifier = reuseIdentifier;
    }
    return self;
}

@end

@interface YUFlowLayoutView () {
    struct {
        unsigned int numberOfItems                  :1;
        unsigned int cellForItemAtIndexPath         :1;
    } _dataSourceFlags;
    struct {
        unsigned int itemWidthAtIndex               :1;
        unsigned int itemHeightAtRow                :1;
        unsigned int didSelectItemAtIndexPath       :1;
        unsigned int relayoutCell                   :1;
    } _delegateFlags;
}

@property (nonatomic, strong) YUFlowLayoutViewConfig *config;

@property (nonatomic, strong) UIView *contentView;

/** 缓存池 */
@property (nonatomic, strong) NSMutableDictionary *cellCachepool;
@property (nonatomic, copy, readwrite) NSArray<YUFlowLayoutCell *> *cells;

/** item的width数组 (二维数组) */
@property (nonatomic, strong) NSMutableArray *itemWidths;
@property (nonatomic, assign) NSInteger itemCount;

@property (nonatomic, assign) BOOL needReloadItems;

@end

@implementation YUFlowLayoutView

- (instancetype)initWithConfig:(YUFlowLayoutViewConfig *)config {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _config = config;
        _needReloadItems = NO;
        _cellCachepool = [NSMutableDictionary new];
        [self setUpSubViews];
    }
    return self;
}

- (void)setUpSubViews {
    [self addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.config.contentInset);
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (_needReloadItems == YES) {
        _needReloadItems = NO;
        [self reloadItems];
    }
}


#pragma mark - action
- (void)cellTap:(UITapGestureRecognizer *)tap {
    YUFlowLayoutCell *cell = (YUFlowLayoutCell *)tap.view;
    if (_delegateFlags.didSelectItemAtIndexPath == 1) {
        [self.delegate layoutView:self didSelectItemAtIndexPath:cell.indePath];
    }
}


#pragma mark - public
- (void)reloadData {
    _needReloadItems = YES;
    [self setNeedsLayout];
}

- (__kindof YUFlowLayoutCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier forIndexPath:(YUFLIndexPath *)indexPath {
    return [self fetchCellWithReuseIdentifier:identifier atIndex:indexPath.index];
}


#pragma mark - privite
- (void)reloadItems {
    
    if (self.contentView.frame.size.width <= 0) {
        return;
    }
    
    if (_dataSourceFlags.numberOfItems == 0) {
        NSAssert(NO, @"numberOfItemsInLayoutView: is nil");
        return;
    }
    _itemCount = [_dataSource numberOfItemsInLayoutView:self];
    
    YUFlowLayoutViewConfig *config = self.config;
    
    // 获取所有的itemWidths
    for (UIView *subView in self.contentView.subviews) {
        [subView removeFromSuperview];
    }
    [self.itemWidths removeAllObjects];
    NSArray *itemWidths = [self calculateItemWidths];
    [self.itemWidths addObjectsFromArray:itemWidths];
    NSMutableArray *cells = [NSMutableArray new];
    
    CGFloat minItemSpacing = config.minItemSpacing;
    CGFloat rowSpacing = config.rowSpacing;
    CGFloat contentWidth = self.contentView.frame.size.width;
    NSInteger rowCount = self.itemWidths.count;
    
    CGFloat ex = 0;
    CGFloat ey = 0;
    NSInteger index = 0;
    CGFloat contentHeight = 0;
    for (int row = 0; row < rowCount; row++) {
        NSArray *rowWidths = self.itemWidths[row];
        
        // 排列对齐方式, 计算 itemSpacing, ex
        CGFloat itemSpacing;
        switch (config.alignment) {
            case YUFlowLayoutViewAlignmentLeft: {
                itemSpacing = minItemSpacing;
                ex = ex;
                break;
            }
            case YUFlowLayoutViewAlignmentRight: {
                itemSpacing = minItemSpacing;
                CGFloat rw = 0;
                for (int i = 0; i < rowWidths.count; i++) {
                    CGFloat iw = [rowWidths[i] floatValue];
                    if (i == 0) {
                        rw = rw + iw;
                    } else {
                        rw = rw + itemSpacing + iw;
                    }
                }
                ex = contentWidth - rw;
                break;
            }
            case YUFlowLayoutViewAlignmentJustified: {
                CGFloat riw = 0;
                for (int i = 0; i < rowWidths.count; i++) {
                    CGFloat iw = [rowWidths[i] floatValue];
                    riw = riw + iw;
                }
                itemSpacing = (contentWidth-riw)/(rowWidths.count-1);
                ex = ex;
                break;
            }
            case YUFlowLayoutViewAlignmentJustifiedLeft: {
                if (row == 0) {
                    CGFloat riw = 0;
                    for (int i = 0; i < rowWidths.count; i++) {
                        CGFloat iw = [rowWidths[i] floatValue];
                        riw = riw + iw;
                    }
                    itemSpacing = (contentWidth-riw)/(rowWidths.count-1);
                } else {
                    itemSpacing = itemSpacing;
                }
                ex = ex;
                break;
            }
            case YUFlowLayoutViewAlignmentJustifiedRight: {
                if (row == 0) {
                    CGFloat riw = 0;
                    for (int i = 0; i < rowWidths.count; i++) {
                        CGFloat iw = [rowWidths[i] floatValue];
                        riw = riw + iw;
                    }
                    itemSpacing = (contentWidth-riw)/(rowWidths.count-1);
                } else {
                    itemSpacing = itemSpacing;
                }
                CGFloat rw = 0;
                for (int i = 0; i < rowWidths.count; i++) {
                    CGFloat iw = [rowWidths[i] floatValue];
                    if (i == 0) {
                        rw = rw + iw;
                    } else {
                        rw = rw + itemSpacing + iw;
                    }
                }
                ex = contentWidth - rw;
                break;
            }
            default:
                break;
        }
        
        CGFloat itemHeight = config.itemHeight;
        if (_delegateFlags.itemHeightAtRow == 1) {
            itemHeight = [_delegate layoutView:self itemHeightAtRow:row];
        }
        if (row == 0) {
            contentHeight = contentHeight + itemHeight;
        } else {
            contentHeight = contentHeight + rowSpacing + itemHeight;
        }
        for (int rowIndex = 0; rowIndex < rowWidths.count; rowIndex++) {
            CGFloat itemWidth = [rowWidths[rowIndex] floatValue];
            if (_dataSourceFlags.cellForItemAtIndexPath == 0) {
                NSAssert(NO, @"layoutView cellForItemAtIndexPath: is nil");
                return;
            }
            YUFLIndexPath *indePath = [YUFLIndexPath indexPathWithIndex:index row:row rowIndex:rowIndex];
            YUFlowLayoutCell *cell = [_dataSource layoutView:self cellForItemAtIndexPath:indePath];
            cell.indePath = indePath;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTap:)];
            [cell addGestureRecognizer:tap];
            if (_delegateFlags.relayoutCell == 1) {
                [_delegate layoutView:self relayoutCell:cell inRow:row rowIndex:rowIndex itemSpacing:&itemSpacing ex:&ex itemWidth:&itemWidth];
            }
            cell.frame = CGRectMake(ex, ey, itemWidth, itemHeight);
            [self.contentView addSubview:cell];
            [self cacheCell:cell atIndex:index];
            [cells addObject:cell];
            
            ex = ex + itemWidth + itemSpacing;
            index++;
        }
        ex = 0;
        ey = ey + itemHeight + rowSpacing;
    }
    [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(contentHeight);
    }];
    self.cells = [cells copy];
}

- (NSArray *)calculateItemWidths {
    
    if (self.contentView.frame.size.width <= 0) {
        return nil;
    }
    
    YUFlowLayoutViewConfig *config = self.config;

    CGFloat minItemSpacing = config.minItemSpacing;
    CGFloat contentWidth = self.contentView.frame.size.width;
    NSInteger limitRowCount = config.limitRowCount;
    NSInteger itemCount = _itemCount;
    
    CGFloat itemSpacing = minItemSpacing;
    CGFloat ex = 0;
    NSInteger row = 0; // row
    BOOL newlineFlag = YES;
    NSMutableArray *itemWidths = [NSMutableArray new];
    NSMutableArray *rowWidths = [NSMutableArray new];
    for (int index = 0; index < itemCount; index++) {
        
        CGFloat itemWidth = config.itemWidth;
        if (_delegateFlags.itemWidthAtIndex == 1) {
            itemWidth = [_delegate layoutView:self itemWidthAtIndex:index];
        }
        if (itemWidth > contentWidth) {
            itemWidth = contentWidth;
        }
        
        // 当前item超过content边界，下一行摆放
        if (ex + itemWidth > contentWidth) {
            row++;
            if (limitRowCount > 0) {
                if (row > limitRowCount - 1) {
                    row--;
                    break;
                }
            }
            // 如果排列方式为 justifiedLeft || justifiedRight, 则需计算余下行数的 itemSpacing
            if (config.alignment == YUFlowLayoutViewAlignmentJustifiedLeft || config.alignment == YUFlowLayoutViewAlignmentJustifiedRight) {
                if (row == 1) {
                    CGFloat riw = 0;
                    for (int i = 0; i < rowWidths.count; i++) {
                        CGFloat iw = [rowWidths[i] floatValue];
                        riw = riw + iw;
                    }
                    itemSpacing = (contentWidth-riw)/(rowWidths.count-1);
                }
            }
            ex = 0;
            newlineFlag = YES;
            rowWidths = [NSMutableArray new];
        }
        if (newlineFlag == YES) {
            [itemWidths addObject:rowWidths];
            newlineFlag = NO;
        }
        [rowWidths addObject:@(itemWidth)];
        
        ex = ex + itemWidth + itemSpacing;
    }
    
    return [itemWidths copy];
}

- (void)cacheCell:(YUFlowLayoutCell *)cell atIndex:(NSInteger)index {
    NSString *reuseIdentifier = cell.reuseIdentifier;
    NSString *key = [NSString stringWithFormat:@"y_reuseIdentifier_%@_index_%@", reuseIdentifier, @(index)];
    [self.cellCachepool setObject:cell forKey:key];
}

- (YUFlowLayoutCell *)fetchCellWithReuseIdentifier:(NSString *)reuseIdentifier atIndex:(NSInteger)index {
    NSString *key = [NSString stringWithFormat:@"y_reuseIdentifier_%@_index_%@", reuseIdentifier, @(index)];
    return [self.cellCachepool objectForKey:key];
}


#pragma mark - setter
- (void)setDataSource:(id<YUFlowLayoutViewDataSource>)dataSource {
    _dataSource = dataSource;
    _dataSourceFlags.numberOfItems = [dataSource respondsToSelector:@selector(numberOfItemsInLayoutView:)];
    _dataSourceFlags.cellForItemAtIndexPath = [dataSource respondsToSelector:@selector(layoutView:cellForItemAtIndexPath:)];
}

- (void)setDelegate:(id<YUFlowLayoutViewDelegate>)delegate {
    _delegate = delegate;
    _delegateFlags.itemWidthAtIndex = [delegate respondsToSelector:@selector(layoutView:itemWidthAtIndex:)];
    _delegateFlags.itemHeightAtRow = [delegate respondsToSelector:@selector(layoutView:itemHeightAtRow:)];
    _delegateFlags.didSelectItemAtIndexPath = [delegate respondsToSelector:@selector(layoutView:didSelectItemAtIndexPath:)];
    _delegateFlags.relayoutCell = [delegate respondsToSelector:@selector(layoutView:relayoutCell:inRow:rowIndex:itemSpacing:ex:itemWidth:)];
}


#pragma mark - getter
- (UIView *)contentView {
    if (_contentView == nil) {
        _contentView = [UIView new];
    }
    return _contentView;
}

- (NSMutableArray *)itemWidths {
    if (_itemWidths == nil) {
        _itemWidths = [NSMutableArray new];
    }
    return _itemWidths;
}

@end
