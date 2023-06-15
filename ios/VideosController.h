//
//  VideosController.h
//  Video
//
//  Created by sergeymild on 15/06/2023.
//  Copyright © 2023 Facebook. All rights reserved.
//

#import <React/RCTBridgeModule.h>
#import <React/RCTViewManager.h>
#import "AppVideoView.h"

NS_ASSUME_NONNULL_BEGIN

@interface VideoChannel : NSObject

@property (nonatomic) NSMutableDictionary<NSString*, AppVideoView*>* videos;
//@property (nonatomic) NSString* currentPlaying;
@property (nonatomic, nullable) NSString* laterRestore;

-(AppVideoView*)currentPlaying;
@end


@interface AppVideosManager : NSObject

@property (nonatomic) NSMutableDictionary<NSString*, VideoChannel*> *channels;

+ (AppVideosManager*)sharedManager;
- (void)addVideo:(AppVideoView *)video nativeID:(NSString*)nativeID;
- (void)removeVideo:(NSString *)nativeID;
-(nonnull VideoChannel*)getChannel:(nonnull NSString*)name;

@end


@interface VideosController : NSObject <RCTBridgeModule>

@end

NS_ASSUME_NONNULL_END
