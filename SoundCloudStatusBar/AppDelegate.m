//
//  AppDelegate.m
//  SoundCloudStatusBar
//
//  Created by Sashke on 30.11.14.
//  Copyright (c) 2014 Alexander Rubin. All rights reserved.
//

#import "AppDelegate.h"
#import <WebKit/WebKit.h>
#import "INAppStoreWindow.h"
#import "TrackTitleView.h"
#import "StatusMenuView.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet WebView *webView;
@property (weak) IBOutlet NSMenu *statusBarMenu;
@property (strong) IBOutlet StatusMenuView *statusMenuView;

@property (strong, nonatomic) SCModel *model;
@property (assign, nonatomic) BOOL playing;

@property (strong, nonatomic) NSStatusItem *statusItem;
@property (strong, nonatomic) NSButton *backButton;
@property (strong, nonatomic) NSButton *refreshButton;
@property (strong, nonatomic) NSButton *forwardButton;
@property (strong, nonatomic) NSButton *playButton;
@property (strong, nonatomic) NSButton *previousTrackButton;
@property (strong, nonatomic) NSButton *nextTrackButton;
@property (strong, nonatomic) TrackTitleView *trackBackgroundView;
@end

typedef NS_ENUM(NSInteger, barButtonsType)  {
    backButtonType = 0,
    refreshButtonType,
    forwardButtonType,
    previousTrackButtonType,
    playTrackButtonType,
    nextTrackButtonType,
    barButtonsNum,
};

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [[self.webView preferences] setAutosaves:YES];
    [[self.webView preferences] setPlugInsEnabled:YES];
    NSURL *url = [NSURL URLWithString:@"http://soundcloud.com"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView.mainFrame loadRequest:request];
    [self.window setContentView:self.webView];

    [self setupBarLayout];
    self.model = [[SCModel alloc] init];
    self.model.delegate = self;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

#pragma mark - Actions

- (void)backButtonTapped {
    [self.webView goBack];
}

- (void)refreshButtonTapped {
    [self.webView reload:self];
}

- (void)forwardButtonTapped {
    [self.webView goForward];
}

- (void)playButtonTapped {
   if (self.playing) {
        self.playing = NO;
    } else {
        self.playing = YES;
    }
    [self.model buttonDidPressWithType:SHKPlayButton];
}

- (void)previousTrackButtonTapped {
    [self.model buttonDidPressWithType:SHKPreviousTrackButton];
}

- (void)nextTrackButtonTapped {
    [self.model buttonDidPressWithType:SHKNextTrackButton];
}

#pragma mark - SCModel Protocol

- (void)statesUpdatedWithPlayingState:(BOOL)playingState trackTitle:(NSString *)trackTitle {
    self.playing = playingState;
    self.trackBackgroundView.trackTitle = trackTitle;
}

- (NSString *)needToEvaluateJavaScriptString:(NSString *)javaScriptString {
    return [self.webView stringByEvaluatingJavaScriptFromString:javaScriptString];
}

#pragma mark - Custom setter

- (void)setPlaying:(BOOL)playing {
    if (_playing != playing) {
        _playing = playing;
        if (_playing) {
            self.playButton.image = [NSImage imageNamed:@"pauseIcon"];
            self.statusMenuView.playButton.image = [NSImage imageNamed:@"pauseIcon"];
        } else {
            self.playButton.image = [NSImage imageNamed:@"playIcon"];
            self.statusMenuView.playButton.image = [NSImage imageNamed:@"playIcon"];
        }
    }
}

#pragma mark - Subviews

- (void)setupBarLayout {
    INAppStoreWindow *aWindow = (INAppStoreWindow *)self.window;
    aWindow.titleBarHeight = 40;
    NSView *titleBarView = aWindow.titleBarView;
    
    CGRect frame;
    NSString *imageName;
    SEL selector;
    
    CGFloat navigationButtonSize = 20;
    CGFloat trackButtonSize = 30;
    CGFloat centerNavigationY = NSMidY(titleBarView.bounds) - navigationButtonSize / 2;
    CGFloat centerTrackY = NSMidY(titleBarView.bounds) - trackButtonSize / 2;
    CGFloat inset = 5;
    CGFloat bigInset = 40;
    for (int i = 0; i < barButtonsNum; i++) {
        NSButton *button = [self defaultButton];
        switch (i) {
            case backButtonType:
                imageName = @"backIcon";
                selector = @selector(backButtonTapped);
                frame = NSMakeRect(70,
                                   centerNavigationY,
                                   navigationButtonSize,
                                   navigationButtonSize);
                self.backButton = button;
                break;
            case refreshButtonType:
                imageName = @"refreshIcon";
                selector = @selector(refreshButtonTapped);
                frame = NSMakeRect(NSMaxX(self.backButton.frame) + inset,
                                   centerNavigationY,
                                   navigationButtonSize,
                                   navigationButtonSize);
                self.refreshButton = button;
                break;
            case forwardButtonType:
                imageName = @"forwardIcon";
                selector = @selector(forwardButtonTapped);
                frame = NSMakeRect(NSMaxX(self.refreshButton.frame) + inset,
                                   centerNavigationY,
                                   navigationButtonSize,
                                   navigationButtonSize);
                self.forwardButton = button;
                break;
            case previousTrackButtonType:
                imageName = @"prevTrackIcon";
                selector = @selector(previousTrackButtonTapped);
                frame = NSMakeRect(NSMaxX(self.forwardButton.frame) + bigInset,
                                   centerTrackY,
                                   trackButtonSize,
                                   trackButtonSize);
                self.previousTrackButton = button;
                break;
            case playTrackButtonType:
                imageName = @"playIcon";
                selector = @selector(playButtonTapped);
                frame = NSMakeRect(NSMaxX(self.previousTrackButton.frame) + inset + 1,
                                   centerTrackY,
                                   trackButtonSize,
                                   trackButtonSize);
                self.playButton = button;
                break;
            case nextTrackButtonType:
                imageName = @"nextTrackIcon";
                selector = @selector(nextTrackButtonTapped);
                frame = NSMakeRect(NSMaxX(self.playButton.frame) + inset,
                                   centerTrackY,
                                   trackButtonSize,
                                   trackButtonSize);
                self.nextTrackButton = button;
                break;
            default:
                break;
        }
        
        button.image = [NSImage imageNamed:imageName];
        button.action = selector;
        button.frame = frame;
        
        [titleBarView addSubview:button];
    }
    
    CGFloat x = NSMaxX(self.nextTrackButton.frame) + 80;
    CGFloat width = titleBarView.frame.size.width - 100 - x;
    self.trackBackgroundView = [[TrackTitleView alloc] initWithFrame:NSMakeRect(NSMaxX(self.nextTrackButton.frame) + 45,
                                                                                NSMidY(titleBarView.bounds) - 15 ,
                                                                                width,
                                                                                30)];
    [titleBarView addSubview:self.trackBackgroundView];
    
    [self setupStatusBarItem];
}

- (void)setupStatusBarItem {
    NSStatusBar *bar = [NSStatusBar systemStatusBar];
    self.statusItem = [bar statusItemWithLength:NSVariableStatusItemLength];
    self.statusItem.image = [NSImage imageNamed:@"soundCloudIcon"];
    self.statusItem.alternateImage = [NSImage imageNamed:@"statusBarIconAlternate"];
    self.statusItem.highlightMode = YES;
    
    [[NSBundle mainBundle] loadNibNamed:@"StatusMenuView" owner:self topLevelObjects:nil];
    
    self.statusMenuView.previousTrackButton.action = @selector(previousTrackButtonTapped);
    self.statusMenuView.previousTrackButton.target = self;
    self.statusMenuView.playButton.action = @selector(playButtonTapped);
    self.statusMenuView.playButton.target = self;
    self.statusMenuView.nextTrackButton.action = @selector(nextTrackButtonTapped);
    self.statusMenuView.nextTrackButton.target = self;
    
    NSMenuItem *item = [[NSMenuItem alloc] init];
    item.view = self.statusMenuView;
    [self.statusBarMenu addItem:item];
    self.statusItem.menu = self.statusBarMenu;
}

- (NSButton *)defaultButton {
    NSButton *button = [[NSButton alloc] init];
    button.imagePosition = NSImageOnly;
    button.bordered = NO;
    button.target = self;
    return button;
}

@end
