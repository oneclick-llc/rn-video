//
//  ToggleMuteButton.m
//  Video
//
//  Created by sergeymild on 14/06/2023.
//  Copyright © 2023 Facebook. All rights reserved.
//

#import "ToggleMuteButton.h"

@implementation ToggleMuteButton

+ (CGFloat)size {
    return 34;
}

static NSBundle *iconBundle;

+(NSBundle *)getResourcesBundle {
    if (iconBundle) return iconBundle;
    iconBundle = [NSBundle bundleWithURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"VideoAsset" withExtension:@"bundle"]];
    return iconBundle;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.layer.cornerRadius = ToggleMuteButton.size / 2;

        [self setBackgroundColor:[[UIColor alloc] initWithWhite:0 alpha:0.6]];
        [self setContentMode:UIViewContentModeCenter];
        self.tintColor = UIColor.whiteColor;
    }
    
    return self;
}

- (void) toggleMuted:(BOOL) muted {
    NSBundle *bundle = [ToggleMuteButton getResourcesBundle];
    NSString *name = muted ? @"muted" : @"unmuted";
    
    UIImage *image = [UIImage
                  imageNamed:name
                  inBundle:bundle
                  withConfiguration:nil];
    
    [self setImage:image forState:UIControlStateNormal];
}

@end
