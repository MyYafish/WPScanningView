//
//  ViewController.h
//  WPCodeScaning
//
//  Created by 吴鹏 on 16/9/5.
//  Copyright © 2016年 wupeng. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "ZBarReaderController.h"

@class WPZBarViewController;

@protocol WPZBarViewDelegate <NSObject>

- (void)wp_scanningResultStr:(NSString *)str;

@end

@interface WPZBarViewController : UIViewController


@property (assign)id<WPZBarViewDelegate>delegate;


@end
