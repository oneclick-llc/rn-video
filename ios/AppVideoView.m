//
//  AppVideoView.m
//  Video
//
//  Created by sergeymild on 14/06/2023.
//  Copyright © 2023 Facebook. All rights reserved.
//

#import "AppVideoView.h"
#include <AVFoundation/AVFoundation.h>

#include "ToggleMuteButton.h"
#include "VideoDurationView.h"
#include "VideosController.h"
#import "rn_video-Swift.h"

@implementation AppVideoView {
    AVPlayer* _player;
    AVPlayerItem* _playerItem;
    AVPlayerLayer* _playerLayer;
    UIView* _videoPlayerParent;
    ToggleMuteButton* _toggleMuteButton;
    VideoDurationView* _videoDurationView;
    BOOL _paused;
    BOOL _muted;
    BOOL _loop;
    NSObject* _timeObserverToken;

}

- (instancetype)init {
    if ((self = [super init])) {
        _muted = YES;
        _paused = YES;
    }

    return self;
}

- (void)setResizeMode:(NSString *)mode {
    _resizeMode = mode;
}

- (void)didSetProps:(NSArray<NSString *> *)changedProps {
    if ([changedProps containsObject:@"resizeMode"]) {
        if ([_resizeMode isEqualToString:@"cover"]) {
            [_playerLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        }

        if ([_resizeMode isEqualToString:@"contain"]) {
            [_playerLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
        }

        if ([_resizeMode isEqualToString:@"stretch"]) {
            [_playerLayer setVideoGravity:AVLayerVideoGravityResize];
        }
    }

    if ([changedProps containsObject:@"hudOffset"]) {
        [self layoutSubviews];
        _videoDurationView.x = [self getHudX];
        _videoDurationView.y = [self getHudY];
        [_videoDurationView layoutSubviews];
    }
}

- (void)initializePlayer {
    if (_playerItem == NULL) {
            NSURL *url = [[NSURL alloc] initWithString:_uri];
            NSString* videoId = [AppVideosManager.sharedManager videoId:self];
//            _playerItem = [CachingPlayerItem createItemWithUrl:url filename:[NSString stringWithFormat:@"%@.%@", videoId, url.pathExtension]];
            _playerItem = [[AVPlayerItem alloc] initWithURL:url];
            _player = [[AVPlayer alloc] initWithPlayerItem:_playerItem];
            _player.automaticallyWaitsToMinimizeStalling = false;
            _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    } else {
        NSURL *url = [[NSURL alloc] initWithString:self.uri];
        NSString* videoId = [AppVideosManager.sharedManager videoId:self];
//        _playerItem = [CachingPlayerItem createItemWithUrl:url filename:[NSString stringWithFormat:@"%@.%@", videoId, url.pathExtension]];
        _playerItem = [[AVPlayerItem alloc] initWithURL:url];
        [_player replaceCurrentItemWithPlayerItem:_playerItem];
    }
    self->_player.preventsDisplaySleepDuringVideoPlayback = true;
    [self setPaused:_paused];
    [self setupUI];
}

- (void)setNativeID:(NSString *)nativeID {
    [super setNativeID:nativeID];

#ifndef RCT_NEW_ARCH_ENABLED
    [AppVideosManager.sharedManager addVideo:self nativeID:nativeID];
#endif
}

// MARK: applyGestures
- (void) applyGestures {
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onVideoTapped)];
    [self addGestureRecognizer:tap];

    UITapGestureRecognizer* doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onVideoDoubleTapped)];
    [doubleTap setNumberOfTapsRequired:2];
    [tap requireGestureRecognizerToFail:doubleTap];
    [self addGestureRecognizer:tap];
    [self addGestureRecognizer:doubleTap];

    [_toggleMuteButton addTarget:self action:@selector(toggleMuted) forControlEvents:UIControlEventTouchUpInside];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    _videoPlayerParent.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    if (_playerLayer) {
        [CATransaction begin];
        [CATransaction setAnimationDuration:0];
        _playerLayer.frame = _videoPlayerParent.bounds;
        [CATransaction commit];
    }

    if (_toggleMuteButton) {
        _toggleMuteButton.frame = CGRectMake(
            self.bounds.size.width - ToggleMuteButton.size - [self getHudX],
            self.bounds.size.height - ToggleMuteButton.size - [self getHudY],
            ToggleMuteButton.size,
            ToggleMuteButton.size);
    }
}

-(CGFloat)getHudX {
    if (_hudOffset) {
        return [RCTConvert CGFloat:[_hudOffset objectForKey:@"x"]];
    }
    return 12;
}

-(CGFloat)getHudY {
    if (_hudOffset) {
        return [RCTConvert CGFloat:[_hudOffset objectForKey:@"y"]];
    }
    return 12;
}

// MARK: setPaused
- (void)setPaused:(BOOL)paused {
    _paused = paused;
    if (!_player) return;
    if (paused) {
        [_player pause];
        [_player setRate:0.0];
    } else {
        [_player playImmediatelyAtRate:1.0];
    }
}

// MARK: setMuted
- (void)setMuted:(BOOL)muted {
    _muted = muted;
    if (!_player) return;
    [_player setVolume:muted ? 0 : 1.0];
    [_player setMuted:muted];

    [_toggleMuteButton toggleMuted:muted];
}

// MARK: setLoop
- (void)setLoop:(BOOL)loop {
    _loop = loop;
}

- (void) onVideoTapped {
    self.onVideoTap(NULL);
}

- (void) onVideoDoubleTapped {
    self.onVideoDoubleTap(NULL);
}

- (void) toggleMuted {
    if (self.onMuteToggle) {
        self.onMuteToggle(@{@"muted": !_muted ? @true : @false});
    }
}

- (void) cleanUp {
    if (_player == NULL) return;
    [self setPaused:true];

    if (self->_timeObserverToken) {
        [_player removeTimeObserver:self->_timeObserverToken];
        self->_timeObserverToken = NULL;
    }
    [_player removeObserver:self forKeyPath:@"status" context:nil];

    _player = NULL;
    _playerItem = NULL;
    [_playerLayer removeFromSuperlayer];
    _playerLayer.player = NULL;
    _uri = NULL;

    [AppVideosManager.sharedManager removeVideo:self.nativeID];
}

- (void)sendProgressUpdate:(CMTime) time {
    CMTime duration = _player.currentItem.duration;
    CMTime timeLeft = CMTimeSubtract(duration, time);
    [_videoDurationView setTime:timeLeft];

    if (CMTimeGetSeconds(timeLeft) == 0) {
        [_player seekToTime:kCMTimeZero];
        if (self.onEndPlay) {
            self.onEndPlay(NULL);
        }
        if (_loop) {
            [_player playImmediatelyAtRate:1.0];
        } else {
            [self setPaused:true];
        }
    }
}

// MARK: setupUI
- (void)setupUI {
    if (_videoPlayerParent != NULL) return;
    _videoPlayerParent = [[UIView alloc] init];
    [self addSubview:_videoPlayerParent];
    [_videoPlayerParent.layer addSublayer:_playerLayer];
    [_playerLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];

    if (!_toggleMuteButton) {
        _toggleMuteButton = [[ToggleMuteButton alloc] init];
        [self addSubview:_toggleMuteButton];
        [_toggleMuteButton toggleMuted:_muted];
    }

    if (!_videoDurationView) {
        _videoDurationView = [[VideoDurationView alloc] init];
        _videoDurationView.x = [self getHudX];
        _videoDurationView.y = [self getHudY];
        [self addSubview:_videoDurationView];
    }

    [self applyGestures];

    // MARK: video observe duration
    __weak AppVideoView *weakSelf = self;
    CMTime interval = CMTimeMakeWithSeconds(1.0, 60000);

    self->_timeObserverToken = [_player addPeriodicTimeObserverForInterval:interval queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        [weakSelf sendProgressUpdate:time];
    }];

    NSLog(@"⚽️ willMoveToSuperview %@", [[AppVideosManager sharedManager] videoId:self]);
    // MARK: video observe status
    [_player addObserver:self
              forKeyPath:@"status"
                 options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial)
                 context:nil];
}

- (void)removeFromSuperview {
    [super removeFromSuperview];
    [self cleanUp];
}

- (void)dealloc {
    [self cleanUp];
    NSLog(@"⚽️ ---=====++");
}


- (BOOL)isVideoPaused {
    return _paused;
}

-(void)seekToStart {
    AVPlayerItem *item = _player.currentItem;
    if (item && item.status == AVPlayerItemStatusReadyToPlay) {
        [item seekToTime:kCMTimeZero completionHandler:NULL];
        //[item seekToTime:kCMTimeZero];
    }
}


- (void)applicationDidEnterBackground {
    [_playerLayer setPlayer:nil];
}

- (void)applicationWillEnterForeground {
    [_playerLayer setPlayer:_player];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        if (_player == NULL) return;
        if (self == NULL) return;
        if (_player.status == AVPlayerStatusReadyToPlay) {
            if (self.onLoad) self.onLoad(NULL);
            if (_videoDurationView == NULL) return;
            [_videoDurationView setTime:self->_player.currentItem.asset.duration];
        }
    }
}

- (void)setVideoUri:(nonnull NSString *)uri {
    self.uri = uri;
    [self initializePlayer];
}

@end
