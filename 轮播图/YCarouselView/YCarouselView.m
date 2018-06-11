//
//  YCarouselView.m
//  GameBox
//
//  Created by yun on 2018/6/5.
//  Copyright © 2018年 yun. All rights reserved.
//

#import "YCarouselView.h"
#import "UIImageView+WebCache.h"

static CGFloat const TimeInterval = 3;
static CGFloat const AfterDelay = 1;
static CGFloat const AnimateDuration = 0.3;
static CGFloat const PageWidth = 16;

@interface YCarouselView ()<UIScrollViewDelegate>
// 图片数组
@property(nonatomic,copy) NSArray *imageArray;
// 是否是网络图片
@property(nonatomic,assign,getter=isUrlImage) BOOL urlImage;
// 当前index
@property(nonatomic,assign) NSInteger curIndex;

@property(nonatomic,strong) UIScrollView *scrollView;
@property(nonatomic,strong) UIImageView *leftImgV;
@property(nonatomic,strong) UIImageView *middleImgV;
@property(nonatomic,strong) UIImageView *rightImgV;

@property(nonatomic,strong) UIPageControl *pageControl;

@property(nonatomic,strong) NSTimer *timer;
@property(nonatomic,assign,getter=isTimerEnd) BOOL timerEnd;


@end

@implementation YCarouselView

- (instancetype)initWithFrame:(CGRect)frame urlImages:(NSArray *)urlImages {
    return [self initWithFrame:frame urlImages:urlImages localImages:nil];
}

- (instancetype)initWithFrame:(CGRect)frame localImages:(NSArray *)localImages{
    return [self initWithFrame:frame urlImages:nil localImages:localImages];
}

- (instancetype)initWithFrame:(CGRect)frame urlImages:(NSArray *)urlImages localImages:(NSArray *)localImages
{
    self = [super initWithFrame:frame];
    if (self) {
        if (urlImages.count > 0) {
            self.imageArray = urlImages;
            self.urlImage = YES;
        } else {
            self.imageArray = localImages;
            self.urlImage = NO;
        }
        [self initSubviews];
    }
    return self;
}


- (void)initSubviews{
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
//    self.scrollView.bounces = NO;
    self.scrollView.delegate = self;
    self.scrollView.contentSize = CGSizeMake(kScreenWidth * 3, CGRectGetHeight(self.frame));
    [self addSubview:self.scrollView];
    
    self.leftImgV = [self createImageView];
    self.middleImgV = [self createImageView];
    self.rightImgV = [self createImageView];
    self.leftImgV.frame = CGRectMake(0, 0, kScreenWidth, CGRectGetHeight(self.frame));
    self.middleImgV.frame = CGRectMake(kScreenWidth, 0, kScreenWidth, CGRectGetHeight(self.frame));
    self.rightImgV.frame = CGRectMake(kScreenWidth * 2, 0, kScreenWidth, CGRectGetHeight(self.frame));
    
    
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 0, PageWidth*self.imageArray.count, 30)];
    self.pageControl.center = CGPointMake(self.center.x, CGRectGetMaxY(self.bounds) - 15);
    self.pageControl.numberOfPages = self.imageArray.count;
    self.pageControl.currentPageIndicatorTintColor = kHexColor(0x4A9BF0);
    self.pageControl.pageIndicatorTintColor = [UIColor whiteColor];
    [self addSubview:self.pageControl];
    
    self.curIndex = 0;
    
    [self setupCurrentValue];
    self.scrollView.contentOffset = CGPointMake(kScreenWidth, 0);
    
    [self launchTimer];
}


// 图片
- (UIImageView *)createImageView{
    UIImageView *imgV = [[UIImageView alloc] init];
    imgV.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGes:)];
    [imgV addGestureRecognizer:tap];
    
    [self.scrollView addSubview:imgV];
    return imgV;
}

// 赋值
- (void)setupCurrentValue{
    
    NSInteger tc = self.imageArray.count;
    // 考虑图片的个数
    if (self.isUrlImage) {
        [self.middleImgV sd_setImageWithURL:[NSURL URLWithString:self.imageArray[_curIndex]] placeholderImage:nil options:SDWebImageRetryFailed];
        if (tc == 1) {
            [self.leftImgV sd_setImageWithURL:[NSURL URLWithString:self.imageArray[_curIndex]] placeholderImage:nil options:SDWebImageRetryFailed];
            [self.rightImgV sd_setImageWithURL:[NSURL URLWithString:self.imageArray[_curIndex]] placeholderImage:nil options:SDWebImageRetryFailed];
        } else if (tc == 2){
            [self.leftImgV sd_setImageWithURL:[NSURL URLWithString:self.imageArray[(tc - 1 + _curIndex)%tc]] placeholderImage:nil options:SDWebImageRetryFailed];
            [self.rightImgV sd_setImageWithURL:[NSURL URLWithString:self.imageArray[(tc - 1 + _curIndex)%tc]] placeholderImage:nil options:SDWebImageRetryFailed];
            
        } else if (tc >= 3){
            [self.leftImgV sd_setImageWithURL:[NSURL URLWithString:self.imageArray[(tc - 1 + _curIndex)%tc]] placeholderImage:nil options:SDWebImageRetryFailed];
            [self.rightImgV sd_setImageWithURL:[NSURL URLWithString:self.imageArray[(tc + 1 + _curIndex)%tc]] placeholderImage:nil options:SDWebImageRetryFailed];
        }
        
        
    } else {
        // 看图片放在哪，一般都是Assets.xcassets
        self.middleImgV.image = [UIImage imageNamed:self.imageArray[_curIndex]];
        if (tc == 1) {
            self.leftImgV.image = [UIImage imageNamed:self.imageArray[_curIndex]];
            self.rightImgV.image = [UIImage imageNamed:self.imageArray[_curIndex]];
        } else if (tc == 2){
            self.leftImgV.image = [UIImage imageNamed:self.imageArray[(tc - 1 + _curIndex)%tc]];
            self.rightImgV.image = [UIImage imageNamed:self.imageArray[(tc - 1 + _curIndex)%tc]];
        } else if (tc >= 3){
            self.leftImgV.image = [UIImage imageNamed:self.imageArray[(tc - 1 + _curIndex)%tc]];
            self.rightImgV.image = [UIImage imageNamed:self.imageArray[(tc + 1 + _curIndex)%tc]];
        }
        
    }

}

// 算法逻辑
- (void)slidingAlgorithmWithRight:(BOOL)right animation:(BOOL)animation{
    if (right) {
        if (self.curIndex >= self.imageArray.count - 1) {
            self.curIndex = 0;
        } else {
            self.curIndex ++;
        }
        
        /*
         设置setContentOffset:animated:/contentOffset不触发scrollViewDidEndDecelerating代理
         */
        if (animation) {
            [UIView animateWithDuration:AnimateDuration delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                self.scrollView.contentOffset = CGPointMake(kScreenWidth*2, 0);
            } completion:^(BOOL finished) {
                [self setupCurrentValue];
                self.scrollView.contentOffset = CGPointMake(kScreenWidth, 0);
            }];
        } else {
            self.scrollView.contentOffset = CGPointMake(kScreenWidth*2, 0);
            [self setupCurrentValue];
            self.scrollView.contentOffset = CGPointMake(kScreenWidth, 0);
        }
        
        
    } else{
    
        if (self.curIndex <= 0) {
            self.curIndex = self.imageArray.count - 1;
        } else {
            self.curIndex --;
        }
        
        if (animation) {
            [UIView animateWithDuration:AnimateDuration delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                self.scrollView.contentOffset = CGPointMake(0, 0);
            } completion:^(BOOL finished) {
                [self setupCurrentValue];
                self.scrollView.contentOffset = CGPointMake(kScreenWidth, 0);
            }];
        } else {
            self.scrollView.contentOffset = CGPointMake(0, 0);
            [self setupCurrentValue];
            self.scrollView.contentOffset = CGPointMake(kScreenWidth, 0);
        }
        
    }
    self.pageControl.currentPage = _curIndex;
}

// 启动计时器
- (void)launchTimer{
    self.timerEnd = NO;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:TimeInterval target:self selector:@selector(timerRun:) userInfo:nil repeats:YES];
}

#pragma mark -- action

- (void)timerRun:(NSTimer *)timer{
    // 右划操作
    [self slidingAlgorithmWithRight:YES animation:YES];
}
// 点击图片操作
- (void)tapGes:(UITapGestureRecognizer *)tap{
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickCurrrentImageViewWithIndex:)]) {
        [self.delegate clickCurrrentImageViewWithIndex:_curIndex];
    }
}


#pragma mark -- UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    // 定时器销毁后，手动滑动设置当前值
    if (self.isTimerEnd) {
        [self setupCurrentValue];
    }
}

// 拖拽时计时器失效
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (self.isTimerEnd == NO) {
        [self.timer invalidate];
        self.timerEnd = YES;
    }
}

// 减速
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    // 取消launchTimer事件
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    CGFloat offset = scrollView.contentOffset.x;
    [self slidingAlgorithmWithRight:offset > kScreenWidth animation:NO];
    // 开启launchTimer
    [self performSelector:@selector(launchTimer) withObject:nil afterDelay:AfterDelay];
}

@end
