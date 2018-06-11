# YCarouselView

### 封装轮播图

#### 使用方法：
1、导入头文件 #import "YCarouselView.h"

2、
```
NSArray *a = @[@"1.jpg",@"2.jpg",@"3.jpg",@"4.jpg",@"5.jpg",@"6.jpg",@"7.jpg",@"8.jpg",@"9.jpg"];
YCarouselView *c = [[YCarouselView alloc] initWithFrame:CGRectMake(0, 100, kScreenWidth, 200) localImages:a];
[self.view addSubview:c];

```

#### 功能：
1、支持定时轮播<br/>
2、支持手动滑动<br/>
3、支持点击图片链接

#### 重点：

1、给UIImageView赋值(增加兼容只有一张或两张图的情况)
```
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

```

2、计算当前index及设置scrollView的contentOffset
```
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

```
