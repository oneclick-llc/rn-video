#import <React/RCTViewManager.h>
#import <React/RCTUIManager.h>
#import "RCTBridge.h"
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

@end

#endif
