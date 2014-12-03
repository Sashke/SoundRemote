//
//  SCModel.m
//  SoundCloudStatusBar
//
//  Created by Sashke on 03.12.14.
//  Copyright (c) 2014 Alexander Rubin. All rights reserved.
//

#import "SCModel.h"

@interface SCModel()
@property (strong, nonatomic) NSTimer *updateStateTimer;
@property (assign, nonatomic) BOOL playing;
@property (assign, nonatomic) NSString *trackTitle;
@end

@implementation SCModel

- (instancetype)init {
    if (self = [super init]) {
        _updateStateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                             target:self
                                                           selector:@selector(updateStates)
                                                           userInfo:nil
                                                            repeats:YES];
    }
    return self;
}

- (void)buttonDidPressWithType:(SHKTrackButtonType)buttonType {
    NSString *className;
    switch (buttonType) {
        case SHKPlayButton:
            className = @"playControl sc-ir";
            break;
        case SHKNextTrackButton:
            className = @"skipControl sc-ir skipControl__next";
            break;
        case SHKPreviousTrackButton:
            className = @"skipControl sc-ir skipControl__previous";
            break;
        default:
            break;
    }
    NSString *javaScriptString;
    if (buttonType == SHKPlayButton) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"PlayButtonScript" ofType:@"txt"];
        javaScriptString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    } else {
        javaScriptString = [NSString stringWithFormat:@"var array = document.getElementsByClassName('%@'); array[0].click();", className];
    }
    [self.delegate needToEvaluateJavaScriptString:javaScriptString];
}

- (void)updateStates {
    NSString *stringToEvaluate = @"document.getElementsByClassName('playControl sc-ir')[0].className;";
    NSString *classNameOfPlayingButton = [self.delegate needToEvaluateJavaScriptString: stringToEvaluate];
    BOOL playing;
    if ([classNameOfPlayingButton isEqualToString:@"playControl sc-ir"]) {
        playing = NO;
    } else if ([classNameOfPlayingButton isEqualToString:@"playControl sc-ir playing"]) {
        playing = YES;
    } else {
        playing = NO;
    }
    stringToEvaluate = @"document.getElementsByClassName('playbackTitle__link')[0].innerHTML;";
    NSString *trackTitle = [self.delegate needToEvaluateJavaScriptString:stringToEvaluate];
    [self.delegate statesUpdatedWithPlayingState:playing trackTitle:trackTitle];
}

@end
