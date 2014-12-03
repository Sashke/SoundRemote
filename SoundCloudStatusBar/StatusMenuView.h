//
//  StatusMenuView.h
//  SoundCloudStatusBar
//
//  Created by Sashke on 03.12.14.
//  Copyright (c) 2014 Alexander Rubin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SCModel.h"

@interface StatusMenuView : NSView
@property (weak) IBOutlet NSButton *playButton;
@property (weak) IBOutlet NSButton *nextTrackButton;
@property (weak) IBOutlet NSButton *previousTrackButton;
@end
