//
//  ToggleMuteButton.h
//  Video
//
//  Created by sergeymild on 14/06/2023.
//  Copyright © 2023 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ToggleMuteButton : UIButton

@property (class, readonly) CGFloat size;

+(NSBundle *)getResourcesBundle;

- (void) toggleMuted:(BOOL) muted;
@end

NS_ASSUME_NONNULL_END
