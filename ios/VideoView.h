// This guard prevent this file to be compiled in the old architecture.
#ifdef RCT_NEW_ARCH_ENABLED
#import <React/RCTViewComponentView.h>
#import <UIKit/UIKit.h>

#ifndef VideoViewNativeComponent_h
#define VideoViewNativeComponent_h

NS_ASSUME_NONNULL_BEGIN

@interface VideoView : RCTViewComponentView
@end

NS_ASSUME_NONNULL_END

#endif /* VideoViewNativeComponent_h */
#endif /* RCT_NEW_ARCH_ENABLED */
