//
//  SCModel.h
//  SoundCloudStatusBar
//
//  Created by Sashke on 03.12.14.
//  Copyright (c) 2014 Alexander Rubin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

typedef NS_ENUM(NSInteger, SHKTrackButtonType) {
    SHKPlayButton = 0,
    SHKPreviousTrackButton,
    SHKNextTrackButton,
    SHKButtonTypeCount,
};

@protocol SCModel <NSObject>
- (void)statesUpdatedWithPlayingState:(BOOL)playingState trackTitle:(NSString *)trackTitle;
- (NSString *)needToEvaluateJavaScriptString:(NSString *)javaScriptString;
@end

@interface SCModel : NSObject
@property (weak, nonatomic) id<SCModel> delegate;

- (void)buttonDidPressWithType:(SHKTrackButtonType)buttonType;
@end
