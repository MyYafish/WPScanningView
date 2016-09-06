//
//  ViewController.m
//  WPCodeScaning
//
//  Created by 吴鹏 on 16/9/5.
//  Copyright © 2016年 wupeng. All rights reserved.
//

#import "ViewController.h"
#import "WPZBarViewController.h"

@interface ViewController ()<WPZBarViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton * button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, 70)];
    button.center = CGPointMake(CGRectGetWidth(self.view.frame)/2, CGRectGetHeight(self.view.frame)/2);
    [button setTitle:@"二维码扫描" forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor blueColor]];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(btnclick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)btnclick
{
    WPZBarViewController*vc=[[WPZBarViewController alloc]init];
    vc.delegate = self;
    
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)wp_scanningResultStr:(NSString *)str
{
    NSLog(@" %@ ",str);
}

@end
