//
//  JWPlayer.m
//  JWPlayer
//
//  Created by jarvis on 2016/11/12.
//  Copyright © 2016年 jarvis jiangjjw. All rights reserved.
//
#define WeakSealf(weakself) __weak typeof(self) weakself = self;
#import "JWPlayer.h"
#import "UIDevice+JWDevice.h"
#import "JWFullViewController.h"
@interface JWPlayer()
{
    BOOL isIntoBackground;
    BOOL isShowToolbar;
    NSTimer *_timer;
    AVPlayerItem *_playerItem;
    AVPlayerLayer *_playerLayer;
    id _playTimeObserver; // 播放进度观察者
    UIActivityIndicatorView*loadActivity;
}
@property (weak, nonatomic) IBOutlet UIView *playerView;
@property (weak, nonatomic) IBOutlet UIView *downView;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *bufferProgress;
@property (weak, nonatomic) IBOutlet UISlider *playProgress;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *totateBtn;
@property(nonatomic,assign)CGRect oldFrame;
@property(nonatomic,strong)UIView*oldView;
@property(nonatomic,strong)UIViewController*SuperVC;
@property(nonatomic,strong)JWFullViewController*fullVC;
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
//        self.view=[[[NSBundle mainBundle] loadNibNamed:@"JWPlayer" owner:self options:nil] firstObject];
//        [self addSubview:self.view];
        self=[[[NSBundle mainBundle] loadNibNamed:@"JWPlayer" owner:self options:nil] firstObject];
        self.frame=frame;
        _oldFrame=frame;
        [self.playProgress setThumbImage:[UIImage imageNamed:@"MoviePlayer_Slider"] forState:UIControlStateNormal];
        [self setPortraitLayout];
        self.player = [[AVPlayer alloc] init];
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
        [self.playerView.layer addSublayer:_playerLayer];
        loadActivity=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        loadActivity.center=self.center;
        [self addSubview:loadActivity];
       
    }
     return self;
}
-(void)showInSuperView:(UIView*)SuperView andSuperVC:(UIViewController *)SuperVC
{
    [SuperView addSubview:self];
    _oldView=SuperView;
    _SuperVC=SuperVC;
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
- (void)layoutSubviews{
    [super layoutSubviews];
    _playerLayer.frame = self.bounds;
}
- (void)updatePlayerWith:(NSURL *)url{
    _playerItem = [AVPlayerItem playerItemWithURL:url];
    [_player replaceCurrentItemWithPlayerItem:_playerItem];
    [self addObserverAndNotification];
    [loadActivity startAnimating];
}

- (void)addObserverAndNotification{
    [_playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];// 监听status属性
    [_playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];// 监听缓冲进度
//    [_playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
//    [_playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    [self monitoringPlayback:_playerItem];// 监听播放状态
    [self addNotification];
}
-(void)addNotification{
    //给AVPlayerItem添加播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    // 后台&前台通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterForegroundNotification) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resignActiveNotification) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loadedReady:) name:AVPlayerItemNewAccessLogEntryNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loadUp:) name:AVPlayerItemPlaybackStalledNotification object:nil];
}
-(void)loadedReady:(NSNotification*)noti
{
    NSLog(@"noti----%@",noti);
    [loadActivity stopAnimating];
}
-(void)loadUp:(NSNotification*)noti
{
    NSLog(@"loadUp------%@",noti.userInfo);
    [loadActivity startAnimating];
}
-(void)playbackFinished:(NSNotification *)notification{
    NSLog(@"视频播放完成.");
    _playerItem = [notification object];
    [_playerItem seekToTime:kCMTimeZero];
    [self pause];
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
                NSLog(@"%f", CMTimeGetSeconds(duration));
                [self setMaxDuratuin:CMTimeGetSeconds(duration)];
                [self play];
                [loadActivity stopAnimating];
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
    }else if (object == _playerItem && [keyPath isEqualToString:@"playbackBufferEmpty"])
    {
        if (_playerItem.playbackBufferEmpty) {
            //Your code here
            NSLog(@"bufer Empty---");
        }
    }
    
    else if (object == _playerItem && [keyPath isEqualToString:@"playbackLikelyToKeepUp"])
    {
        if (_playerItem.playbackLikelyToKeepUp)
        {
            //Your code here
            NSLog(@"keep   up");

        }
    }

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

#pragma mark - _playTimeObserver
- (void)monitoringPlayback:(AVPlayerItem *)item {
    WeakSealf(ws);
    //这里设置每秒执行30次
    _playTimeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 30) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {

            // 计算当前在第几秒
            float currentPlayTime = (double)item.currentTime.value/item.currentTime.timescale;
            [ws updateVideoSlider:currentPlayTime];
    }];
}

- (void)updateVideoSlider:(float)currentTime{
    self.playProgress.value = currentTime;
    self.currentTimeLabel.text = [self convertTime:currentTime];
}

- (void)setlandscapeLayout{
    self.isLandscape = YES;
    [self landscapeHide];
//    self.downHeight.constant = 44.0f;
//    self.speedTopHeight.constant = 80.0f;
    self.frame=[UIScreen mainScreen].bounds;
    
    [self.totateBtn setImage:[UIImage imageNamed:@"MoviePlayer_小屏"] forState:UIControlStateNormal];
}

- (void)setPortraitLayout{
    self.isLandscape = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    [self portraitHide];
    self.frame=_oldFrame;
//    self.topView.hidden = YES;
//    self.downHeight.constant = 32.0f;
//    self.speedTopHeight.constant = 50.0f;
    [self.totateBtn setImage:[UIImage imageNamed:@"MoviePlayer_Full"] forState:UIControlStateNormal];
}


- (IBAction)playORPause:(id)sender {
    if (_isPlaying) {
        [self pause];
    }else{
        [self play];
    }
    [self chickToolBar];
}
- (IBAction)playerSliderChanged:(UISlider *)sender {
    [self pause];
    //转换成CMTime才能给player来控制播放进度
    CMTime dragedCMTime = CMTimeMake(self.playProgress.value, 1);
    [_playerItem seekToTime:dragedCMTime];
    [self chickToolBar];
}
- (IBAction)playerSliderInside:(UISlider *)sender {
    NSLog(@"释放播放");
    [self play];
}
- (IBAction)playerSliderDown:(UISlider *)sender {
    NSLog(@"按动暂停");
    [self pause];
}
- (IBAction)rotationChanged:(id)sender {
    [self chickToolBar];
    if ([UIDevice isOrientationLandscape]) {
        [UIDevice setOrientation:UIInterfaceOrientationPortrait];
        if (self.SuperVC!=nil) {
            [self.fullVC dismissViewControllerAnimated:NO completion:^{
                
                [_oldView addSubview:self];

            }];
        }else{
            [self setPortraitLayout];
        }
        
        
    }else{
        [UIDevice setOrientation:UIInterfaceOrientationLandscapeRight];
        if (_SuperVC!=nil) {
            [_SuperVC presentViewController:self.fullVC animated:NO completion:^{
                [self.fullVC.view addSubview:self];

            }];
        }else{
                [self setlandscapeLayout]; 
        }
        
    }
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchBegan");

}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchEnd");
        if (self.isLandscape) {
            if (isShowToolbar) {
                [self landscapeHide];
            }else{
                [self landscapeShow];
            }
        }else{
            if (isShowToolbar) {
                [self portraitHide];
            }else{
                [self portraitShow];
            }
        }
    
}


- (void)portraitShow{
    isShowToolbar = YES;
    self.downView.hidden = NO;
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:5]; //fireDate
    [_timer invalidate];
    _timer = nil;
    _timer = [[NSTimer alloc] initWithFireDate:date interval: 1 target:self selector:@selector(portraitHide) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)chickToolBar{
    if (self.isLandscape) {
        [self landscapeShow];
    }else{
        [self portraitShow];
    }
}

- (void)portraitHide{
    isShowToolbar = NO;
    self.downView.hidden=YES;
}

- (void)landscapeShow{
    isShowToolbar = YES;
    self.downView.hidden = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:5]; //fireDate
    [_timer invalidate];
    _timer = nil;
    _timer = [[NSTimer alloc] initWithFireDate:date interval: 1 target:self selector:@selector(landscapeHide) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)landscapeHide{
    isShowToolbar = NO;
    self.downView.hidden = YES;
    if (self.isLandscape) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    }
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
-(JWFullViewController*)fullVC
{
    if (_fullVC==nil) {
        _fullVC=[[JWFullViewController alloc]init];
    }
    return _fullVC;
}

@end
