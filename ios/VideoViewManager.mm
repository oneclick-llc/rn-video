#import <React/RCTViewManager.h>
#import <React/RCTUIManager.h>
#import <React/RCTBridge.h>
#import "rn_video-Swift.h"

#ifndef RCT_NEW_ARCH_ENABLED

@interface VideoViewManager : RCTViewManager
@end

@implementation VideoViewManager

RCT_EXPORT_MODULE(LookyVideoView)

- (VideoViewSwift *)view
{
  return [[VideoViewSwift alloc] init];
}

RCT_EXPORT_VIEW_PROPERTY(videoUri, NSString)
RCT_EXPORT_VIEW_PROPERTY(resizeMode, NSString)
RCT_EXPORT_VIEW_PROPERTY(muted, BOOL)
RCT_EXPORT_VIEW_PROPERTY(loop, BOOL)
RCT_EXPORT_VIEW_PROPERTY(onVideoEnd, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onVideoTap, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onVideoDoubleTap, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onVideoProgress, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onVideoLoad, RCTDirectEventBlock)

@end

#endif
