//
//  TrackTitleView.m
//  SoundCloudStatusBar
//
//  Created by Sashke on 02.12.14.
//  Copyright (c) 2014 Alexander Rubin. All rights reserved.
//

#import "TrackTitleView.h"
#import "GTMNSString+HTML.h"

@interface TrackTitleView()
@property (weak) IBOutlet NSTextField *textField;
@end

@implementation TrackTitleView

- (void)drawRect:(NSRect)dirtyRect {
    [[NSColor colorWithCalibratedRed:249 / 255.0 green:249 / 255.0 blue:249 / 255.0 alpha:1.0] set];
    NSRectFill([self bounds]);
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)setTrackTitle:(NSString *)trackTitle {
    if (_trackTitle != trackTitle) {
        _trackTitle = trackTitle;
        self.textField.stringValue = [_trackTitle gtm_stringByUnescapingFromHTML];
    }
    
}

@end
