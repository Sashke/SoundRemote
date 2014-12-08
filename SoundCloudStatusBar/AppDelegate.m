//
//  AppDelegate.m
//  SoundCloudStatusBar
//
//  Created by Sashke on 30.11.14.
//  Copyright (c) 2014 Alexander Rubin. All rights reserved.
//

#import "AppDelegate.h"

#import "WebViewWindowController.h"

@interface AppDelegate ()
@property (strong, nonatomic) WebViewWindowController *controller;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.controller = [[WebViewWindowController alloc] initWithWindowNibName:@"WebViewWindowController"];
    [self.controller showWindow:nil];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end