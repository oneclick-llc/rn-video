//
//  VideosController.m
//  Video
//
//  Created by sergeymild on 15/06/2023.
//  Copyright © 2023 Facebook. All rights reserved.
//

#import "VideosController.h"
#import "rn_video-Swift.h"

//// MARK: VideoChannel
//@implementation VideoChannel
//
//- (id)init {
//  if (self = [super init]) {
//      _videos = [[NSMutableDictionary alloc] init];
//  }
//  return self;
//}
//
//- (AppVideoView *)currentPlaying {
//    for (NSString* key in _videos) {
//        if (![[_videos objectForKey:key] isVideoPaused]) {
//            return [_videos objectForKey:key];
//        }
//    }
//    return nil;
//}
//
//- (AppVideoView *)forRestore {
//    if (!self.backgroundRestore) return NULL;
//    return [_videos objectForKey:self.backgroundRestore];
//}
//
//- (NSString *)currentPlayingKey {
//    for (NSString* key in _videos) {
//        if (![[_videos objectForKey:key] isVideoPaused]) {
//            return key;
//        }
//    }
//    return nil;
//}
//
//@end
//
//
//// MARK: AppVideosManager
//@implementation AppVideosManager
//
//+ (id)sharedManager {
//    static AppVideosManager *sharedMyManager = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        sharedMyManager = [[self alloc] init];
//    });
//    return sharedMyManager;
//}
//
//- (id)init {
//    if (self = [super init]) {
//        _channels = [[NSMutableDictionary alloc] init];
//    }
//    return self;
//}
//
//-(NSString*) videoId:(AppVideoView*)video {
//    if (!video) return nil;
//    NSArray<NSString*> *parts = [video.nativeID componentsSeparatedByString:@":"];
//    NSString *vID = [parts objectAtIndex:1];
//    return vID;
//}
//
//- (nonnull VideoChannel*) getChannel:(nonnull NSString*)name {
//    VideoChannel *videoChannel = [_channels objectForKey:name];
//    if (!videoChannel) {
//        videoChannel = [[VideoChannel alloc] init];
//    }
//    [_channels setValue:videoChannel forKey:name];
//    return videoChannel;
//}
//
//- (void)addVideo:(AppVideoView *)video nativeID:(NSString*)nativeID {
//    NSLog(@"🤖 video.addVideo %@", nativeID);
//
//    NSArray<NSString*> *parts = [nativeID componentsSeparatedByString:@":"];
//    NSString *channel = [parts objectAtIndex:0];
//    NSString *vID = [parts objectAtIndex:1];
//#ifdef RCT_NEW_ARCH_ENABLED
//    video.nativeID = nativeID;
//#endif
//
//    VideoChannel *videoChannel = [self getChannel:channel];
//    [videoChannel.videos setObject:video forKey:vID];
//
//    [_channels setObject:videoChannel forKey:channel];
//    if (videoChannel.laterRestore && [vID isEqualToString:videoChannel.laterRestore]) {
//        [video setPaused:false];
//        videoChannel.laterRestore = nil;
//    }
//}
//
//- (void)removeVideo:(NSString *)nativeID {
//    NSLog(@"🤖 video.removeVideo %@", nativeID);
//
//    NSArray<NSString*> *parts = [nativeID componentsSeparatedByString:@":"];
//    NSString *channel = [parts objectAtIndex:0];
//    NSString *vID = [parts objectAtIndex:1];
//
//    VideoChannel *videoChannel = [self getChannel:channel];
//    [videoChannel.videos removeObjectForKey:vID];
//    if ([videoChannel.videos count] == 0) {
//        [_channels removeObjectForKey:channel];
//    }
//}
//
//-(void) pauseVideo:(VideoChannel*)channel {
//    AppVideoView *video = [channel currentPlaying];
//    if (!video) return;
//    [video setPaused:true];
//}
//
//-(void) pauseAllVideos {
//    NSDictionary<NSString*, VideoChannel*> *channels = AppVideosManager.sharedManager.channels;
//    NSArray<NSString*> *keys = channels.allKeys;
//    for (NSString *key in keys) {
//        VideoChannel *channel = [channels objectForKey:key];
//        if (!channel) continue;
//        NSArray<NSString*> *videoKeys = channel.videos.allKeys;
//        for (NSString *vKey in videoKeys) {
//            AppVideoView *video = [channel.videos objectForKey:vKey];
//            if (!video) continue;;
//            if (video.isVideoPaused) continue;
//            [video setPaused:true];
//        }
//    }
//}
//
//-(nullable AppVideoView*) findFirstPlayingVideo {
//    NSDictionary<NSString*, VideoChannel*> *channels = AppVideosManager.sharedManager.channels;
//    NSArray<NSString*> *keys = channels.allKeys;
//    for (NSString *key in keys) {
//        VideoChannel *channel = [channels objectForKey:key];
//        if (!channel) continue;
//        return [self findFirstPlayingVideo: key];
//    }
//    return nil;
//}
//
//-(nullable AppVideoView*) findFirstPlayingVideo:(nullable NSString*) channelId {
//    if (!channelId) return nil;
//    NSDictionary<NSString*, VideoChannel*> *channels = AppVideosManager.sharedManager.channels;
//    VideoChannel *channel = [channels objectForKey:channelId];
//    if (!channel) return nil;
//    NSArray<NSString*> *videoKeys = channel.videos.allKeys;
//    for (NSString *vKey in videoKeys) {
//        AppVideoView *video = [channel.videos objectForKey:vKey];
//        if (!video) continue;;
//        if (video.isVideoPaused) continue;
//        return video;
//    }
//    return nil;
//}
//
//
//@end


// MARK: VideosController
@implementation VideosController

RCT_EXPORT_MODULE();


-(void)togglePlay:(NSString*)channel
          videoId:(NSString *)videoId
      seekToStart:(BOOL)seekToStart {
    VideoChannel *videoChannel = [AppVideosManager.shared getChannel:channel];
    if (!videoChannel) return;
    VideoViewSwift *playingVideo = [AppVideosManager.shared findFirstPlayingVideo:channel];
    VideoViewSwift *video = [videoChannel videoFor:videoId];
    NSString *playingVideId = [AppVideosManager.shared videoId:playingVideo];
    // pause current playing video
    if (playingVideId && ![playingVideId isEqualToString:videoId]) {
        [playingVideo setPaused:true];
        NSLog(@"👺 togglePlay channel: %@ id: %@ paused: true", channel, videoId);
    }

    if (video) {
        NSLog(@"👺 togglePlay channel: %@ id: %@ paused: false", channel, videoId);
        if (seekToStart) [video seekToStart];
        [video setPaused:false];
    }
}

RCT_EXPORT_METHOD(playVideo:(NSString *)channel
                  videoId:(NSString *)videoId) {
    [self togglePlay:channel videoId:videoId seekToStart:false];
}
RCT_EXPORT_METHOD(pauseVideo:(NSString *)channelName
                  videoId:(NSString *)videoId) {
    NSLog(@"👺pauseVideo channelName: %@ videoId: %@", channelName, videoId);

    VideoChannel *videoChannel = [AppVideosManager.shared getChannel:channelName];
    if (!videoChannel) {
        NSLog(@"VideoManager couldn't find videoChannel");
        return;
    }

    VideoViewSwift *video = [videoChannel videoFor:videoId];
    if (video) {
        NSLog(@"VideoManager found Video to pause");
        [video setPaused: true];
    } else {
        NSLog(@"VideoManager couldn't find video to pause by provided videoId (%@)", videoId);
    }
}

RCT_EXPORT_METHOD(pauseCurrentPlaying) {
    NSLog(@"👺 pauseAllVideos");
    [AppVideosManager.shared pauseAllVideos];
}

RCT_EXPORT_METHOD(pauseCurrentPlayingWithLaterRestore:(nullable NSString *)channel) {
    NSLog(@"pauseCurrentPlayingWithLaterRestore(channelName: %@)", channel);
    if (channel) {
        VideoChannel *c = [AppVideosManager.shared getChannel:channel];
        if (!c) return;
        NSLog(@"Found videoChannel, going to seek Video");
        VideoViewSwift *video = [AppVideosManager.shared findFirstPlayingVideo:channel];
        if (video) {
            NSLog(@"Found Video, going to put its' ID (%@) in laterRestore", [AppVideosManager.shared videoId:video]);
            c.laterRestore = [AppVideosManager.shared videoId:video];
            [video setPaused:true];
            NSLog(@"👺 pauseCurrentPlayingWithLaterRestore channel: %@ id: %@", channel, c.laterRestore);
        }
        return;
    }

    NSArray<NSString*> *keys = [AppVideosManager.shared.channels allKeys];
    for (NSString *key in keys) {
        VideoChannel *channel = [AppVideosManager.shared.channels objectForKey:key];
        if (!channel) continue;
        VideoViewSwift *video = [AppVideosManager.shared findFirstPlayingVideo:key];
        if (!video) continue;
        channel.laterRestore = [AppVideosManager.shared videoId:video];
        [video setPaused:true];
        NSLog(@"👺 pauseCurrentPlayingWithLaterRestore channel: %@ id: %@", key, channel.laterRestore);
        break;
    }
}

RCT_EXPORT_METHOD(restoreLastPlaying:(nullable NSString *)channel) {
    if (channel) {
        VideoChannel *videoChannel = [AppVideosManager.shared getChannel:channel];
        if (videoChannel.laterRestore) {
            NSLog(@"👺 restoreLastPlaying channel: %@ id: %@", channel, videoChannel.laterRestore);
            [self togglePlay:channel videoId:videoChannel.laterRestore seekToStart:true];
        }
        videoChannel.laterRestore = nil;
        return;
    }

    NSArray<NSString*> *keys = [AppVideosManager.shared.channels allKeys];
    for (NSString *key in keys) {
        VideoChannel *channel = [AppVideosManager.shared.channels objectForKey:key];
        if (!channel) continue;
        if (!channel.laterRestore) continue;
        NSLog(@"👺 restoreLastPlaying channel: %@ id: %@", channel, channel.laterRestore);
        [self togglePlay:key videoId:channel.laterRestore seekToStart: true];
        channel.laterRestore = nil;
    }
}

RCT_EXPORT_METHOD(togglePlay:(NSString *)channel
                  videoId:(NSString *)videoId) {
    VideoViewSwift *video = [AppVideosManager.shared findFirstPlayingVideo:channel];
    if (video) {
        [self pauseCurrentPlaying];
    } else {
        [self playVideo:channel videoId:videoId];
    }
}

RCT_EXPORT_METHOD(toggleVideosMuted:(BOOL)muted) {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray<NSString*> *keys = [AppVideosManager.shared.channels allKeys];
        for (NSString *key in keys) {
            VideoChannel *channel = [AppVideosManager.shared.channels objectForKey:key];
            if (!channel) continue;
            for (NSString* videoId in channel.videos) {
                [[channel.videos objectForKey:videoId] setMuted:muted];
            }
        }
    });
}

RCT_EXPORT_METHOD(togglePlayInBackground:(NSString*)channelName
                  playInBackground:(BOOL) playInBackground) {
    VideoChannel *channel = [AppVideosManager.shared.channels objectForKey:channelName];
    if (!channel) return;

    if (playInBackground) {
        VideoViewSwift *video = [AppVideosManager.shared findFirstPlayingVideo:channelName];
        if (!video) return;
        [video applicationDidEnterBackground];
        channel.backgroundRestore = [AppVideosManager.shared videoId:video];
    } else {
        VideoViewSwift *video = [channel forRestore];
        if (!video) return;
        [video applicationWillEnterForeground];
        channel.backgroundRestore = NULL;
    }
}


@end
