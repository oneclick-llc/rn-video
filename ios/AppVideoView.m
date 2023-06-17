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

@implementation AppVideoView {
    AVPlayer* _player;
    AVPlayerItem* _playerItem;
    AVPlayerLayer* _playerLayer;
    UIView* _videoPlayerParent;
    ToggleMuteButton* _toggleMuteButton;
    VideoDurationView* _videoDurationView;
    BOOL _paused;
    BOOL _muted;
    
    NSObject *_timeObserverToken;
    
}

- (instancetype)init {
    if ((self = [super init])) {
        _muted = YES;
        _paused = YES;
    }
    
    return self;
}

-(void) setVideoUri:(NSString*)uri {
    self.uri = uri;
    if (_playerItem == NULL) {
        NSURL *url = [[NSURL alloc] initWithString:self.uri];
        _playerItem = [[AVPlayerItem alloc] initWithURL:url];
        _player = [[AVPlayer alloc] initWithPlayerItem:_playerItem];
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
        //_playerLayer.frame = self.bounds;
    } else {
        NSURL *url = [[NSURL alloc] initWithString:self.uri];
        _playerItem = [[AVPlayerItem alloc] initWithURL:url];
        [_player replaceCurrentItemWithPlayerItem:_playerItem];
    }
    [self setPaused:_paused];
    [self setMuted:_muted];
}

- (void)setNativeID:(NSString *)nativeID {
    [super setNativeID:nativeID];
    
#ifndef RCT_NEW_ARCH_ENABLED
    [AppVideosManager.sharedManager addVideo:self nativeID:nativeID];
#endif
}

- (void) applyGestures {
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onVideoTap)];
    [self addGestureRecognizer:tap];

    [_toggleMuteButton addTarget:self action:@selector(toggleMuted) forControlEvents:UIControlEventTouchUpInside];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    _videoPlayerParent.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    _playerLayer.frame = _videoPlayerParent.frame;
//    if (_playerLayer) {
//
//    }
    
    if (_toggleMuteButton) {
        _toggleMuteButton.frame = CGRectMake(self.bounds.size.width - ToggleMuteButton.size - 12, self.bounds.size.height - ToggleMuteButton.size - 12, ToggleMuteButton.size, ToggleMuteButton.size);
    }
}

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

- (void)setMuted:(BOOL)muted {
    _muted = muted;
    if (!_player) return;
    [_player setVolume:muted ? 0 : 1.0];
    [_player setMuted:muted];
    
    [_toggleMuteButton toggleMuted:muted];
}

- (void) onVideoTap {
    [self setPaused:!_paused];
}

- (void) toggleMuted {
    [self setMuted:!_muted];
}

- (void) cleanUp {
    if (_player == NULL) return;
    [self setPaused:true];
    _player = nil;
    _playerItem = NULL;
    [_playerLayer removeFromSuperlayer];
    _playerLayer.player = NULL;
    _uri = NULL;
    
    [AppVideosManager.sharedManager removeVideo:self.nativeID];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    _videoPlayerParent = [[UIView alloc] init];
    [self addSubview:_videoPlayerParent];
    [_videoPlayerParent.layer addSublayer:_playerLayer];
    [_playerLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    if (!_toggleMuteButton) {
        _toggleMuteButton = [[ToggleMuteButton alloc] init];
        [self addSubview:_toggleMuteButton];
        [self setMuted:_muted];
    }
    
    if (!_videoDurationView) {
        _videoDurationView = [[VideoDurationView alloc] init];
        [self addSubview:_videoDurationView];
    }
    
    [self applyGestures];
}

- (void)removeFromSuperview {
    [super removeFromSuperview];
    [self cleanUp];
}

- (void)dealloc {
    NSLog(@"---=====++");
}


- (BOOL)isVideoPaused {
    return _paused;
}

-(void)seekToStart {
    AVPlayerItem *item = _player.currentItem;
    if (item && item.status == AVPlayerItemStatusReadyToPlay) {
        [item seekToTime:kCMTimeZero];
    }
}

@end
