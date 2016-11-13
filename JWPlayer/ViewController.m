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
//    NSURL *videoUrl = [NSURL URLWithString:@"http://120.25.226.186:32812/resources/videos/minion_01.mp4"];
//    self.playerItem = [AVPlayerItem playerItemWithURL:videoUrl];
//    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];// 监听status属性
//    [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];// 监听loadedTimeRanges属性
//    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
//    
//    _playerView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 180)];
//    [self.view addSubview:_playerView];
//_playerLayer=[AVPlayerLayer playerLayerWithPlayer:self.player];
//    _playerLayer.frame=CGRectMake(0, 0, 320, 180);
//    _playerLayer.backgroundColor=[UIColor blackColor].CGColor;
//    [_playerView.layer addSublayer:_playerLayer];
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
    // Do any additional setup after loading the view, typically from a nib.
}
-(void)moviePlayDidEnd:(NSNotification*)noti
{
    NSLog(@"endPlay");
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:@"status"]) {
        if ([playerItem status] == AVPlayerStatusReadyToPlay) {
            NSLog(@"AVPlayerStatusReadyToPlay");
//            self.stateButton.enabled = YES;
            CMTime duration = self.playerItem.duration;// 获取视频总长度
            CGFloat totalSecond = playerItem.duration.value / playerItem.duration.timescale;// 转换成秒
//            _totalTime = [self convertTime:totalSecond];// 转换成播放时间
            [_player play];
//            [self customVideoSlider:duration];// 自定义UISlider外观
            NSLog(@"movie total duration:%f",CMTimeGetSeconds(duration));
//            [self monitoringPlayback:self.playerItem];// 监听播放状态
        } else if ([playerItem status] == AVPlayerStatusFailed) {
            NSLog(@"AVPlayerStatusFailed");
        }
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        NSTimeInterval timeInterval = [self availableDuration];// 计算缓冲进度
        NSLog(@"Time Interval:%f",timeInterval);
        CMTime duration = self.playerItem.duration;
        CGFloat totalDuration = CMTimeGetSeconds(duration);
//        [self.videoProgress setProgress:timeInterval / totalDuration animated:YES];
    }
}

- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [[self.player currentItem] loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}

- (NSString *)convertTime:(CGFloat)second{
    NSDate *d = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (second/3600 >= 1) {
        [formatter setDateFormat:@"HH:mm:ss"];
    } else {
        [formatter setDateFormat:@"mm:ss"];
    }
    NSString *showtimeNew = [formatter stringFromDate:d];
    return showtimeNew;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
