//
//  JWPlayer.m
//  JWPlayer
//
//  Created by jarvis on 2016/11/13.
//  Copyright © 2016年 jarvis jiangjjw. All rights reserved.
//

#import "JWPlayer.h"
#import <AVFoundation/AVFoundation.h>
#define WeakSealf(weakself) __weak typeof(self) weakself = self;
@interface JWPlayer()
{
    BOOL isIntoBackground;
    BOOL isShowToolbar;
    NSTimer *_timer;
    AVPlayerItem *_playerItem;
    AVPlayerLayer *_playerLayer;
    id _playTimeObserver; // 播放进度观察者

}
@property(nonatomic,strong)AVPlayer*player;
@property (weak, nonatomic) IBOutlet UIView *playerView;
@property (weak, nonatomic) IBOutlet UIView *downView;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *bufferProgress;
@property (weak, nonatomic) IBOutlet UISlider *playProgress;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *rotateBtn;
@end
@implementation JWPlayer
-(void)awakeFromNib
{
    [super awakeFromNib];
}
-(instancetype)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    if (self) {
        self=[[NSBundle mainBundle]loadNibNamed:@"JWPlayer" owner:self options:nil][0];
        self.frame=frame;
        [self.playProgress setThumbImage:[UIImage imageNamed:@"MoviePlayer_Slider"] forState:UIControlStateNormal];
        self.player = [[AVPlayer alloc] init];
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
        _playerLayer.frame=frame;
        [self.playerView.layer addSublayer:_playerLayer];



    }
    return self;
}
-(void)setVideoUrl:(NSString *)videoUrl
{
    _videoUrl=videoUrl;
    _playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:videoUrl]];

    [_player replaceCurrentItemWithPlayerItem:_playerItem];
    [self addObserverAndNotification];
}

- (void)addObserverAndNotification{
    [_playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];// 监听status属性
    [_playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];// 监听缓冲进度
//    [self monitoringPlayback:_playerItem];// 监听播放状态
    [self addNotification];
}

- (IBAction)playOrpause:(UIButton *)sender {
}
- (IBAction)playerSliderChanged:(UISlider *)sender {
}
- (IBAction)playerSliderInside:(UISlider *)sender {
}
- (IBAction)playerSliderDown:(UISlider *)sender {
}

- (IBAction)rotationChanged:(UIButton *)sender {
}

#pragma mark - KVO - status
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    AVPlayerItem *item = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:@"status"]) {
        if (isIntoBackground) {
            return;
        }else{
            if ([item status] == AVPlayerStatusReadyToPlay) {
                NSLog(@"AVPlayerStatusReadyToPlay");
                CMTime duration = item.duration;// 获取视频总长度
                NSLog(@"-----ready---%f", CMTimeGetSeconds(duration));
                [self setMaxDuratuin:CMTimeGetSeconds(duration)];
                [self play];
            }else if([item status] == AVPlayerStatusFailed) {
                NSLog(@"AVPlayerStatusFailed");
            }else{
                NSLog(@"AVPlayerStatusUnknown");
            }
        }
    }else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        
        NSTimeInterval timeInterval = [self availableDurationRanges];//缓冲进度
        CMTime duration = _playerItem.duration;
        CGFloat totalDuration = CMTimeGetSeconds(duration);
        [self.bufferProgress setProgress: timeInterval / totalDuration animated:YES];
    }
}

-(void)addNotification{
    //给AVPlayerItem添加播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    // 后台&前台通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterForegroundNotification) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resignActiveNotification) name:UIApplicationDidEnterBackgroundNotification object:nil];
}
-(void)playbackFinished:(NSNotification *)notification{
    NSLog(@"视频播放完成.");
    _playerItem = [notification object];
    [_playerItem seekToTime:kCMTimeZero];
//    [_player play];
}
// 后台
- (void)resignActiveNotification{
    NSLog(@"进入后台");
    isIntoBackground = YES;
    [self pause];
}

// 前台
- (void)enterForegroundNotification
{
    NSLog(@"回到前台");
    isIntoBackground = NO;
    [self play];
}
- (NSTimeInterval)availableDurationRanges {
    NSArray *loadedTimeRanges = [_playerItem loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}
#pragma mark - 移除通知&KVO
- (void)removeObserverAndNotification{
    [_player replaceCurrentItemWithPlayerItem:nil];
    [_playerItem removeObserver:self forKeyPath:@"status"];
    [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [_player removeTimeObserver:_playTimeObserver];
    _playTimeObserver = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setMaxDuratuin:(float)total{
    self.playProgress.maximumValue = total;
    self.totalTimeLabel.text = [self convertTime:self.playProgress.maximumValue];
}


- (void)play{
    _isPlaying = YES;
    [_player play];
    [self.playBtn  setImage:[UIImage imageNamed:@"MoviePlayer_Play"] forState:UIControlStateNormal];
}

- (void)pause{
    _isPlaying = NO;
    [_player pause];
    [self.playBtn  setImage:[UIImage imageNamed:@"MoviePlayer_Stop"] forState:UIControlStateNormal];
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */
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


@end
