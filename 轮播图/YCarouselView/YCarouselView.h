//
//  YCarouselView.h
//  GameBox
//
//  Created by yun on 2018/6/5.
//  Copyright © 2018年 yun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"

#define kScreenWidth    [UIScreen mainScreen].bounds.size.width
#define kHexColor(hexValue) [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0 green:((float)((hexValue & 0xFF00) >> 8))/255.0 blue:((float)(hexValue & 0xFF))/255.0 alpha:1.0]

@protocol YCarouselViewDelegate <NSObject>

@optional
// 点击当前图片
- (void)clickCurrrentImageViewWithIndex:(NSInteger)index;

@end

@interface YCarouselView : UIView

@property(nonatomic,weak) id<YCarouselViewDelegate> delegate;


- (instancetype)initWithFrame:(CGRect)frame;

/*
 网络图片
 */
- (instancetype)initWithFrame:(CGRect)frame urlImages:(NSArray *)urlImages;

/*
 本地图片
 */
- (instancetype)initWithFrame:(CGRect)frame localImages:(NSArray *)localImages;

/*
 设置图片
 */
- (void)setupImageArray:(NSArray *)imageArray urlImage:(BOOL)urlImage;


@end
