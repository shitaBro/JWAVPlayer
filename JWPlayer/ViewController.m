//
//  ViewController.m
//  JWPlayer
//
//  Created by jarvis on 2016/11/12.
//  Copyright © 2016年 jarvis jiangjjw. All rights reserved.
//

#import "ViewController.h"
#import "JWPlayer.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    JWPlayer*player=[[JWPlayer alloc]initWithFrame:CGRectMake(0, 0, 414,9*414/16)];
    [player updatePlayerWith:[NSURL URLWithString:@"http://120.25.226.186:32812/resources/videos/minion_01.mp4"]];
    [self.view addSubview:player];
//    [player showInSuperView:self.view andSuperVC:self];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
