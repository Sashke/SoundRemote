//
//  WebViewWindowController.m
//  SoundCloudStatusBar
//
//  Created by Налия on 08.12.14.
//  Copyright (c) 2014 Alexander Rubin. All rights reserved.
//

#import "WebViewWindowController.h"
#import <WebKit/WebKit.h>
#import "INAppStoreWindow.h"
#import "TrackTitleView.h"
#import "StatusMenuView.h"

@interface WebViewWindowController ()
@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet WebView *webView;
@property (weak) IBOutlet NSMenu *statusBarMenu;
@property (strong) IBOutlet StatusMenuView *statusMenuView;
@property (strong) IBOutlet TrackTitleView *trackTitleView;

@property (strong, nonatomic) SCModel *model;
@property (assign, nonatomic) BOOL playing;

@property (strong, nonatomic) NSView *titleBarView;
@property (strong, nonatomic) NSStatusItem *statusItem;
@property (strong, nonatomic) NSButton *backButton;
@property (strong, nonatomic) NSButton *refreshButton;
@property (strong, nonatomic) NSButton *forwardButton;
@property (strong, nonatomic) NSButton *playButton;
@property (strong, nonatomic) NSButton *previousTrackButton;
@property (strong, nonatomic) NSButton *nextTrackButton;

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

@implementation WebViewWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    NSURL *url = [NSURL URLWithString:@"http://soundcloud.com"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView.mainFrame loadRequest:request];
    INAppStoreWindow *aWindow = (INAppStoreWindow*)self.window;
    aWindow.titleBarHeight = 40;
    self.titleBarView = aWindow.titleBarView;
    [self setupBarLayout];
    self.model = [[SCModel alloc] init];
    self.model.delegate = self;
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
    self.trackTitleView.trackTitle = trackTitle;
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
    CGRect frame;
    NSString *imageName;
    SEL selector;
    
    CGFloat navigationButtonSize = 20;
    CGFloat trackButtonSize = 30;
    CGFloat centerNavigationY = NSMidY(self.titleBarView.bounds) - navigationButtonSize / 2;
    CGFloat centerTrackY = NSMidY(self.titleBarView.bounds) - trackButtonSize / 2;
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
        
        [self.titleBarView addSubview:button];
    }
    
    
    [self setupTrackTitleView];
    [self setupStatusBarItem];
}

- (void)setupTrackTitleView {
    [[NSBundle mainBundle] loadNibNamed:@"TrackTitleView" owner:self topLevelObjects:nil];
    [self.titleBarView addSubview:self.trackTitleView];
    self.trackTitleView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary *views = @{@"nextTrackButton" : self.nextTrackButton, @"titleBarView" : self.titleBarView, @"trackView" : self.trackTitleView};
    [self.titleBarView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[nextTrackButton]-40-[trackView]"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:views]];
    NSLayoutConstraint *xCenterConstraint = [NSLayoutConstraint constraintWithItem:self.trackTitleView
                                                                         attribute:NSLayoutAttributeCenterY
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.titleBarView
                                                                         attribute:NSLayoutAttributeCenterY
                                                                        multiplier:1.0
                                                                          constant:0];
    NSLayoutConstraint *yCenterConstraint = [NSLayoutConstraint constraintWithItem:self.trackTitleView
                                                                         attribute:NSLayoutAttributeCenterX
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.titleBarView
                                                                         attribute:NSLayoutAttributeCenterX
                                                                        multiplier:1.0
                                                                          constant:0];
    [self.titleBarView addConstraint:yCenterConstraint];
    
    [self.titleBarView addConstraint:xCenterConstraint];
    
    [self.titleBarView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[trackView]-5-|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:views]];
    
    [self.trackTitleView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[trackView(>=200)]"
                                                                                options:0
                                                                                metrics:nil
                                                                                  views:views]];
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
