# JWAVPlayer
自定义简单的支持横屏竖屏切换的Avplayer
```javascript     
    JWPlayer*player=[[JWPlayer alloc]initWithFrame:CGRectMake(0, 0, 414,9*414/16)];
    [player updatePlayerWith:[NSURL URLWithString:@"http://120.25.226.186:32812/resources/videos/minion_01.mp4"]];
    [self.view addSubview:player];
```
## 第二种用法
```javascript
    JWPlayer*player=[[JWPlayer alloc]initWithFrame:CGRectMake(0, 0, 414,9*414/16)];
    [player updatePlayerWith:[NSURL URLWithString:@"http://120.25.226.186:32812/resources/videos/minion_01.mp4"]];
    [player showInSuperView:self.view andSuperVC:self];
```

