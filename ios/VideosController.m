//
//  VideosController.m
//  Video
//
//  Created by sergeymild on 15/06/2023.
//  Copyright © 2023 Facebook. All rights reserved.
//

#import "VideosController.h"

// MARK: VideoChannel
@implementation VideoChannel

- (id)init {
  if (self = [super init]) {
      _videos = [[NSMutableDictionary alloc] init];
  }
  return self;
}

- (AppVideoView *)currentPlaying {
    for (NSString* key in _videos) {
        if (![[_videos objectForKey:key] isVideoPaused]) {
            return [_videos objectForKey:key];
        }
    }
    return nil;
}

- (AppVideoView *)forRestore {
    if (!self.backgroundRestore) return NULL;
    return [_videos objectForKey:self.backgroundRestore];
}

- (NSString *)currentPlayingKey {
    for (NSString* key in _videos) {
        if (![[_videos objectForKey:key] isVideoPaused]) {
            return key;
        }
    }
    return nil;
}

@end


// MARK: AppVideosManager
@implementation AppVideosManager

+ (id)sharedManager {
    static AppVideosManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
  if (self = [super init]) {
      _channels = [[NSMutableDictionary alloc] init];
  }
  return self;
}

-(NSString*) videoId:(AppVideoView*)video {
    if (!video) return nil;
    NSArray<NSString*> *parts = [video.nativeID componentsSeparatedByString:@":"];
    NSString *vID = [parts objectAtIndex:1];
    return vID;
}

- (nonnull VideoChannel*) getChannel:(nonnull NSString*)name {
    VideoChannel *videoChannel = [_channels objectForKey:name];
    if (!videoChannel) {
        videoChannel = [[VideoChannel alloc] init];
    }
    [_channels setValue:videoChannel forKey:name];
    return videoChannel;
}

- (void)addVideo:(AppVideoView *)video nativeID:(NSString*)nativeID {
    NSLog(@"🤖 video.addVideo %@", nativeID);

    NSArray<NSString*> *parts = [nativeID componentsSeparatedByString:@":"];
    NSString *channel = [parts objectAtIndex:0];
    NSString *vID = [parts objectAtIndex:1];
#ifdef RCT_NEW_ARCH_ENABLED
    video.nativeID = nativeID;
#endif

    VideoChannel *videoChannel = [self getChannel:channel];
    [videoChannel.videos setObject:video forKey:vID];

    [_channels setObject:videoChannel forKey:channel];
    if (videoChannel.laterRestore && [vID isEqualToString:videoChannel.laterRestore]) {
        [video setPaused:false];
        videoChannel.laterRestore = nil;
    }
}

- (void)removeVideo:(NSString *)nativeID {
    NSLog(@"🤖 video.removeVideo %@", nativeID);

    NSArray<NSString*> *parts = [nativeID componentsSeparatedByString:@":"];
    NSString *channel = [parts objectAtIndex:0];
    NSString *vID = [parts objectAtIndex:1];

    VideoChannel *videoChannel = [self getChannel:channel];
    [videoChannel.videos removeObjectForKey:vID];
    if ([videoChannel.videos count] == 0) {
        [_channels removeObjectForKey:channel];
    }
}

-(void) pauseVideo:(VideoChannel*)channel {
    AppVideoView *video = [channel currentPlaying];
    if (!video) return;
    [video setPaused:true];
}


@end


// MARK: VideosController
@implementation VideosController

RCT_EXPORT_MODULE();


-(void)togglePlay:(NSString*)channel
          videoId:(NSString *)videoId
      seekToStart:(BOOL)seekToStart {
    VideoChannel *videoChannel = [AppVideosManager.sharedManager getChannel:channel];
    
    if (![[videoChannel currentPlayingKey] isEqualToString:videoId]) {
        [AppVideosManager.sharedManager pauseVideo:videoChannel];
    }

    AppVideoView *video = [videoChannel.videos objectForKey:videoId];
    if (video) {
        NSLog(@"🤖 video.play %@", videoId);
        if (seekToStart) [video seekToStart];
        [video setPaused:false];
    } else {
        videoChannel.laterRestore = videoId;
    }
}

RCT_EXPORT_METHOD(playVideo:(NSString *)channel
                  videoId:(NSString *)videoId) {

    [self togglePlay:channel videoId:videoId seekToStart:false];
}

RCT_EXPORT_METHOD(pauseCurrentPlaying) {
    NSArray<NSString*> *keys = [AppVideosManager.sharedManager.channels allKeys];
    for (NSString *key in keys) {
        VideoChannel *channel = [AppVideosManager.sharedManager.channels objectForKey:key];
        if (!channel) continue;
        if (![channel currentPlaying]) continue;
        [AppVideosManager.sharedManager pauseVideo:channel];
    }
}

RCT_EXPORT_METHOD(pauseCurrentPlayingWithLaterRestore:(nullable NSString *)channel) {
    if (channel) {
        VideoChannel *videoChannel = [AppVideosManager.sharedManager getChannel:channel];
        AppVideoView *video = [videoChannel currentPlaying];
        if (video) videoChannel.laterRestore = [AppVideosManager.sharedManager videoId:video];
        [AppVideosManager.sharedManager pauseVideo:videoChannel];
        return;
    }
    
    NSArray<NSString*> *keys = [AppVideosManager.sharedManager.channels allKeys];
    for (NSString *key in keys) {
        VideoChannel *channel = [AppVideosManager.sharedManager.channels objectForKey:key];
        if (!channel) continue;
        AppVideoView *video = [channel currentPlaying];
        if (!video) continue;
        channel.laterRestore = [AppVideosManager.sharedManager videoId:video];
        [AppVideosManager.sharedManager pauseVideo:channel];
    }
}

RCT_EXPORT_METHOD(restoreLastPlaying:(nullable NSString *)channel) {
    if (channel) {
        VideoChannel *videoChannel = [AppVideosManager.sharedManager getChannel:channel];
        if (videoChannel.laterRestore) {
            [self togglePlay:channel videoId:videoChannel.laterRestore seekToStart:true];
        }
        videoChannel.laterRestore = nil;
        return;
    }
    
    NSArray<NSString*> *keys = [AppVideosManager.sharedManager.channels allKeys];
    for (NSString *key in keys) {
        VideoChannel *channel = [AppVideosManager.sharedManager.channels objectForKey:key];
        if (!channel) continue;
        if (!channel.laterRestore) continue;
        [self togglePlay:key videoId:channel.laterRestore seekToStart: true];
        channel.laterRestore = nil;
    }
}

RCT_EXPORT_METHOD(togglePlay:(NSString *)channel
                  videoId:(NSString *)videoId) {
    VideoChannel *videoChannel = [AppVideosManager.sharedManager getChannel:channel];
    if ([videoChannel currentPlaying]) {
        [self pauseCurrentPlaying];
    } else {
        [self playVideo:channel videoId:videoId];
    }
}

RCT_EXPORT_METHOD(toggleVideosMuted:(BOOL)muted) {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray<NSString*> *keys = [AppVideosManager.sharedManager.channels allKeys];
        for (NSString *key in keys) {
            VideoChannel *channel = [AppVideosManager.sharedManager.channels objectForKey:key];
            if (!channel) continue;
            for (NSString* videoId in channel.videos) {
                [[channel.videos objectForKey:videoId] setMuted:muted];
            }
        }
    });
}

RCT_EXPORT_METHOD(togglePlayInBackground:(NSString*)channelName
                  playInBackground:(BOOL) playInBackground) {
    NSLog(@"🌶️ togglePlayInBackground %@ %id", channelName, playInBackground);
    VideoChannel *channel = [AppVideosManager.sharedManager.channels objectForKey:channelName];
    if (!channel) return;
    
    if (playInBackground) {
        AppVideoView *video = [channel currentPlaying];
        if (!video) return;
        [video applicationDidEnterBackground];
        channel.backgroundRestore = [AppVideosManager.sharedManager videoId:video];
    } else {
        AppVideoView *video = [channel forRestore];
        if (!video) return;
        [video applicationWillEnterForeground];
        channel.backgroundRestore = NULL;
    }
}


@end
