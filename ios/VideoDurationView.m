//
//  VideoDurationView.m
//  Video
//
//  Created by sergeymild on 14/06/2023.
//  Copyright © 2023 Facebook. All rights reserved.
//

#import "VideoDurationView.h"
#import "ToggleMuteButton.h"


@implementation VideoDurationView {
    UILabel *label;
}

+ (CGFloat)height {
    return 20;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.layer.cornerRadius = 6;

        [self setBackgroundColor:[[UIColor alloc] initWithWhite:0 alpha:0.6]];
        
        label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:10 weight:UIFontWeightSemibold];
        [self addSubview:label];
        label.text = @"00:00";
        label.textColor = UIColor.whiteColor;
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize size = [label.text sizeWithFont:label.font];
    label.frame = CGRectMake(6, 0, size.width, VideoDurationView.height);
    
    CGSize parent = self.superview.frame.size;
    self.frame = CGRectMake(
        parent.width - label.frame.size.width - self.x - 12,
        parent.height - self.y - ToggleMuteButton.size - 4 - VideoDurationView.height,
        size.width + 12,
        VideoDurationView.height);
}

- (void)setTime:(CMTime)time {
    if (self.isHidden) return;
    NSUInteger dTotalSeconds = CMTimeGetSeconds(time);

    NSUInteger dHours = floor(dTotalSeconds / 3600);
    NSUInteger dMinutes = floor(dTotalSeconds % 3600 / 60);
    NSUInteger dSeconds = floor(dTotalSeconds % 3600 % 60);
    
    NSString *videoDurationText;
    if (dHours > 0) {
        videoDurationText = [NSString stringWithFormat:@"%lu:%02lu:%02lu",(unsigned long)dHours, (unsigned long)dMinutes, (unsigned long)dSeconds];
    } else {
        videoDurationText = [NSString stringWithFormat:@"%02lu:%02lu", (unsigned long)dMinutes, (unsigned long)dSeconds];
    }
    
    label.text = videoDurationText;
    [self layoutSubviews];
}

@end
