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
        label.text = @"100:00";
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
                            parent.width - 12 - label.frame.size.width - 12,
                            parent.height - 12 - ToggleMuteButton.size - 4 - VideoDurationView.height,
                            size.width + 12,
                            VideoDurationView.height);
}

- (void) updateTime:(NSNumber*)time {
    
}

@end
