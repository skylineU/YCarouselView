//
//  ViewController.m
//  轮播图
//
//  Created by yun on 2018/6/5.
//  Copyright © 2018年 yun. All rights reserved.
//

#import "ViewController.h"
#import "YCarouselView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSArray *a = @[@"1.jpg",@"2.jpg",@"3.jpg",@"4.jpg",@"5.jpg",@"6.jpg",@"7.jpg",@"8.jpg",@"9.jpg"];
    YCarouselView *c = [[YCarouselView alloc] initWithFrame:CGRectMake(0, 100, kScreenWidth, 200) localImages:a];
    [self.view addSubview:c];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
