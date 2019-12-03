//
//  YUFlowLayoutView.h
//  YUFlowLayoutView
//
//  Created by Yanyuxxxx on 2019/11/11.
//  Copyright © 2019 Yanyuxxxx.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class YUFlowLayoutView;
@class YUFlowLayoutCell;
@class YUFLIndexPath;

typedef enum : NSUInteger {
    YUFlowLayoutViewAlignmentLeft,                 // 左对齐
    YUFlowLayoutViewAlignmentRight,                // 右对齐
    YUFlowLayoutViewAlignmentJustified,            // 两端对齐
    YUFlowLayoutViewAlignmentJustifiedLeft,        // 首行两端对齐, 其余行左对齐, 使用首行的itemSpacing
    YUFlowLayoutViewAlignmentJustifiedRight,       // 首行两端对齐, 其余行右对齐, 使用首行的itemSpacing
} YUFlowLayoutViewAlignment;

@protocol YUFlowLayoutViewDataSource <NSObject>

- (NSInteger)numberOfItemsInLayoutView:(YUFlowLayoutView *)layoutView;

- (__kindof YUFlowLayoutCell *)layoutView:(YUFlowLayoutView *)layoutView cellForItemAtIndexPath:(YUFLIndexPath *)indexPath;

@end

@protocol YUFlowLayoutViewDelegate <NSObject>

@optional
- (void)layoutView:(YUFlowLayoutView *)layoutView didSelectItemAtIndexPath:(YUFLIndexPath *)indexPath;

- (CGFloat)layoutView:(YUFlowLayoutView *)layoutView itemWidthAtIndex:(NSInteger)index;

- (CGFloat)layoutView:(YUFlowLayoutView *)layoutView itemHeightAtRow:(NSInteger)row;

- (void)layoutView:(YUFlowLayoutView *)layoutView relayoutCell:(YUFlowLayoutCell *)cell inRow:(NSInteger)row rowIndex:(NSInteger)rowIndex itemSpacing:(CGFloat *)itemSpacing ex:(CGFloat *)ex itemWidth:(CGFloat *)itemWidth;

@end

@interface YUFLIndexPath : NSObject

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) NSInteger row;
@property (nonatomic, assign) NSInteger rowIndex;

+ (instancetype)indexPathWithIndex:(NSInteger)index;
+ (instancetype)indexPathWithIndex:(NSInteger)index row:(NSInteger)row rowIndex:(NSInteger)rowIndex;

@end

@interface YUFlowLayoutViewConfig : NSObject

/** 间隙 */
@property (nonatomic, assign) UIEdgeInsets contentInset;
@property (nonatomic, assign) CGFloat minItemSpacing;
@property (nonatomic, assign) CGFloat rowSpacing;
/** itemWidth*/
@property (nonatomic, assign) CGFloat itemWidth;
/** itemHeight */
@property (nonatomic, assign) CGFloat itemHeight;
/** 限制行数 0 == 不限制行数 */
@property (nonatomic, assign) NSInteger limitRowCount;
/** 排列对齐方式, 默认两端对齐 */
@property (nonatomic, assign) YUFlowLayoutViewAlignment alignment;

@end

@interface YUFlowLayoutCell : UIView

@property (nonatomic, copy, readonly) NSString *reuseIdentifier;
@property (nonatomic, strong) YUFLIndexPath *indePath;

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@end

@interface YUFlowLayoutView : UIView

@property (nonatomic, copy, readonly) NSArray<YUFlowLayoutCell *> *cells;

@property (nonatomic, weak) id<YUFlowLayoutViewDataSource> dataSource;
@property (nonatomic, weak) id<YUFlowLayoutViewDelegate> delegate;

- (instancetype)initWithConfig:(YUFlowLayoutViewConfig *)config;

- (void)reloadData;

- (__kindof YUFlowLayoutCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier forIndexPath:(YUFLIndexPath *)indexPath;

- (__kindof YUFlowLayoutCell *)cellForItemAtIndexPath:(YUFLIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
