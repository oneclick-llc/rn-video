#import <React/RCTViewManager.h>
#import <React/RCTUIManager.h>
#import <React/RCTBridge.h>
#import "AppVideoView.h"

#ifndef RCT_NEW_ARCH_ENABLED

@interface VideoViewManager : RCTViewManager
@end

@implementation VideoViewManager

RCT_EXPORT_MODULE(VideoView)

- (AppVideoView *)view
{
  return [[AppVideoView alloc] init];
}

RCT_EXPORT_VIEW_PROPERTY(videoUri, NSString)
RCT_EXPORT_VIEW_PROPERTY(resizeMode, NSString)
RCT_EXPORT_VIEW_PROPERTY(muted, BOOL)
RCT_EXPORT_VIEW_PROPERTY(loop, BOOL)
RCT_EXPORT_VIEW_PROPERTY(hudOffset, NSDictionary)
RCT_EXPORT_VIEW_PROPERTY(onMuteToggle, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onEndPlay, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onVideoTap, RCTDirectEventBlock)

@end

#endif
