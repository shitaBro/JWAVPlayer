//
//  ViewController.m
//  JWPlayer
//
//  Created by jarvis on 2016/11/13.
//  Copyright © 2016年 jarvis jiangjjw. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "JWPlayer.h"
@interface ViewController ()
@property (nonatomic ,strong) AVPlayer *player;
@property (nonatomic ,strong) AVPlayerItem *playerItem;
@property (nonatomic ,strong) AVPlayerLayer*playerLayer;
@property (nonatomic ,strong)  UIView *playerView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    JWPlayer*player=[[JWPlayer alloc]initWithFrame:CGRectMake(0, 0, 414, 300)];
    player.videoUrl=@"http://120.25.226.186:32812/resources/videos/minion_01.mp4";
    [self.view addSubview:player];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
