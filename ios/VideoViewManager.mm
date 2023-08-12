#import <React/RCTViewManager.h>
#import <React/RCTUIManager.h>
#import <React/RCTBridge.h>
#import "AppVideoView.h"
#import "rn_video-Swift.h"

#ifndef RCT_NEW_ARCH_ENABLED

@interface VideoViewManager : RCTViewManager
@end

@implementation VideoViewManager

RCT_EXPORT_MODULE(VideoView)

- (VideoViewSwift *)view
{
  return [[VideoViewSwift alloc] init];
}

RCT_EXPORT_VIEW_PROPERTY(videoUri, NSString)
RCT_EXPORT_VIEW_PROPERTY(resizeMode, NSString)
RCT_EXPORT_VIEW_PROPERTY(muted, BOOL)
RCT_EXPORT_VIEW_PROPERTY(loop, BOOL)
RCT_EXPORT_VIEW_PROPERTY(isSloMo, BOOL)
RCT_EXPORT_VIEW_PROPERTY(hudHidden, BOOL)
RCT_EXPORT_VIEW_PROPERTY(hudOffset, NSDictionary)
RCT_EXPORT_VIEW_PROPERTY(onMuteToggle, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onEndPlay, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onVideoTap, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onVideoDoubleTap, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onVideoProgress, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onLoad, RCTDirectEventBlock)

@end

#endif
