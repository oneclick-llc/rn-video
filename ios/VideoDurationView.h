//
//  VideoDurationView.h
//  Video
//
//  Created by sergeymild on 14/06/2023.
//  Copyright © 2023 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VideoDurationView : UIView

@property (class, readonly) CGFloat height;

-(void) setTime:(CMTime) time;
@end

NS_ASSUME_NONNULL_END
