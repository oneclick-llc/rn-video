//
//  AppVideoView.h
//  Video
//
//  Created by sergeymild on 14/06/2023.
//  Copyright © 2023 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <React/RCTComponent.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppVideoView : UIView

@property (nonatomic) NSString* uri;
@property (nonatomic, copy) RCTDirectEventBlock onMuteToggle;
@property (nonatomic, copy) RCTDirectEventBlock onEndPlay;
@property (nonatomic, copy) RCTDirectEventBlock onVideoTap;
@property (nonatomic, copy) NSDictionary* hudPosition;

-(void) setVideoUri:(NSString*)uri;
-(void) cleanUp;
- (void)setPaused:(BOOL)paused;
- (void)setMuted:(BOOL)muted;
-(BOOL) isVideoPaused;
-(void)seekToStart;
@end

NS_ASSUME_NONNULL_END
