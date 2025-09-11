//
//  SplashForm.m
//  MacSimpe
//
//  Created by Catherine Gramze on 9/11/25.
//
//***************************************************************************
//*   Copyright (C) 2005 by Ambertation                                     *
//*   quaxi@ambertation.de                                                  *
//*   Copyright (C) 2008 by Peter L Jones                                   *
//*   pljones@users.sf.net                                                  *
//*                                                                         *
//*   This program is free software; you can redistribute it and/or modify  *
//*   it under the terms of the GNU General Public License as published by  *
//*   the Free Software Foundation; either version 2 of the License, or     *
//*   (at your option) any later version.                                   *
//*                                                                         *
//*   This program is distributed in the hope that it will be useful,       *
//*   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
//*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
//*   GNU General Public License for more details.                          *
//*                                                                         *
//*   You should have received a copy of the GNU General Public License     *
//*   along with this program; if not, write to the                         *
//*   Free Software Foundation, Inc.,                                       *
//*   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
//***************************************************************************/
/***************************************************************************
 *   Copyright (C) 2005 by Ambertation                                     *
 *   quaxi@ambertation.de                                                  *
 *   Copyright (C) 2008 by Peter L Jones                                   *
 *   pljones@users.sf.net                                                  *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
 ***************************************************************************/

#import "SplashForm.h"
#import "Helper.h"

static NSImage *bg = nil;
static NSString *const WM_CHANGE_MESSAGE = @"WM_CHANGE_MESSAGE";
static NSString *const WM_SHOW_HIDE = @"WM_SHOW_HIDE";

@implementation SplashForm

- (instancetype)init {
    NSRect windowFrame = NSMakeRect(0, 0, 461, 212);
    NSWindow *window = [[NSWindow alloc] initWithContentRect:windowFrame
                                                   styleMask:NSWindowStyleMaskBorderless
                                                     backing:NSBackingStoreBuffered
                                                       defer:NO];
    
    self = [super initWithWindow:window];
    if (self) {
        _message = @"";
        [self initializeComponent];
        
        [window setMinSize:NSMakeSize(461, 212)];
        [window setMaxSize:NSMakeSize(461, 212)];
        [window center];
        [window setLevel:NSStatusWindowLevel]; // Higher level for splash screen
        [window setBackgroundColor:[NSColor clearColor]];
        [window setOpaque:NO];
        [window setHasShadow:YES]; // Add subtle shadow for better visual separation
        [window setMovable:NO]; // Prevent user from moving splash screen
        
        self.lbtxt.stringValue = self.message;
        self.lbver.stringValue = [Helper versionToString:[Helper simPeVersion]];
        
        if ([Helper debugMode] && [Helper qaRelease]) {
            self.lbver.stringValue = [self.lbver.stringValue stringByAppendingString:@" [Debug, QA]"];
        } else if ([Helper debugMode]) {
            self.lbver.stringValue = [self.lbver.stringValue stringByAppendingString:@" [Debug]"];
        } else if ([Helper qaRelease]) {
            self.lbver.stringValue = [self.lbver.stringValue stringByAppendingString:@" [QA]"];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleMessageChange:)
                                                     name:WM_CHANGE_MESSAGE
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleShowHide:)
                                                     name:WM_SHOW_HIDE
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initializeComponent {
    NSWindow *window = self.window;
    NSView *contentView = window.contentView;
    
    // Load background image
    if (bg == nil) {
        // Option 1: From bundle resources (if PNG is added directly to project)
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *imagePath = [bundle pathForResource:@"splash" ofType:@"png"];
        if (imagePath) {
            bg = [[NSImage alloc] initWithContentsOfFile:imagePath];
        }
        
        // Option 2: From Asset Catalog (if using .xcassets)
        if (!bg) {
            bg = [NSImage imageNamed:@"splash"];
        }
        
        // Fallback: Create a placeholder if image not found
        if (!bg) {
            bg = [[NSImage alloc] initWithSize:NSMakeSize(461, 212)];
            [bg lockFocus];
            [[NSColor colorWithRed:0.2 green:0.4 blue:0.8 alpha:1.0] setFill];
            NSRectFill(NSMakeRect(0, 0, 461, 212));
            [bg unlockFocus];
        }
    }
    
    // Background image view
    self.backgroundImageView = [[NSImageView alloc] initWithFrame:contentView.bounds];
    self.backgroundImageView.image = bg;
    self.backgroundImageView.imageScaling = NSImageScaleAxesIndependently ;
    [contentView addSubview:self.backgroundImageView];
    
    // lbtxt label (status message)
    self.lbtxt = [[NSTextField alloc] initWithFrame:NSMakeRect(12, 80, 427, 18)];
    self.lbtxt.backgroundColor = [NSColor clearColor];
    self.lbtxt.font = [NSFont fontWithName:@"Georgia" size:12];
    self.lbtxt.alignment = NSTextAlignmentCenter;
    self.lbtxt.stringValue = @"";
    self.lbtxt.bordered = NO;
    self.lbtxt.editable = NO;
    self.lbtxt.selectable = NO;
    self.lbtxt.drawsBackground = NO;
    [contentView addSubview:self.lbtxt];
    
    // label2 ("Version:" label)
    self.label2 = [[NSTextField alloc] initWithFrame:NSMakeRect(11, 45, 62, 14)];
    self.label2.backgroundColor = [NSColor clearColor];
    self.label2.textColor = [NSColor colorWithRed:0.41 green:0.41 blue:0.41 alpha:1.0];
    self.label2.font = [NSFont fontWithName:@"Georgia-Bold" size:8.25];
    self.label2.stringValue = @"Version:";
    self.label2.bordered = NO;
    self.label2.editable = NO;
    self.label2.selectable = NO;
    self.label2.drawsBackground = NO;
    [self.label2 sizeToFit];
    [contentView addSubview:self.label2];
    
    // lbver label (version number)
    self.lbver = [[NSTextField alloc] initWithFrame:NSMakeRect(73, 45, 100, 14)];
    self.lbver.backgroundColor = [NSColor clearColor];
    self.lbver.textColor = [NSColor colorWithRed:0.41 green:0.41 blue:0.41 alpha:1.0];
    self.lbver.font = [NSFont fontWithName:@"Georgia" size:8.25];
    self.lbver.stringValue = @"00.00";
    self.lbver.bordered = NO;
    self.lbver.editable = NO;
    self.lbver.selectable = NO;
    self.lbver.drawsBackground = NO;
    [self.lbver sizeToFit];
    [contentView addSubview:self.lbver];
}

- (void)setMessage:(NSString *)message {
    @synchronized(self) {
        if (![_message isEqualToString:message]) {
            _message = message ? [message copy] : @"";
            [self sendMessageChangeSignal];
        }
    }
}

- (void)sendMessageChangeSignal {
    [[NSNotificationCenter defaultCenter] postNotificationName:WM_CHANGE_MESSAGE object:self];
}

- (void)handleMessageChange:(NSNotification *)notification {
    if (notification.object == self) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.lbtxt.stringValue = self.message;
        });
    }
}

- (void)handleShowHide:(NSNotification *)notification {
    if (notification.object == self) {
        NSNumber *showFlag = notification.userInfo[@"show"];
        BOOL show = [showFlag boolValue];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (show) {
                if (!self.window.isVisible) {
                    [self showWindow:nil];
                    [self.window makeKeyAndOrderFront:nil];
                } else {
                    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
                }
            } else {
                [self.window close];
            }
        });
    }
}

- (void)startSplash {
    NSDictionary *userInfo = @{@"show": @YES};
    [[NSNotificationCenter defaultCenter] postNotificationName:WM_SHOW_HIDE
                                                        object:self
                                                      userInfo:userInfo];
}

- (void)stopSplash {
    // Fade out animation for smooth transition
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = 0.3;
        self.window.animator.alphaValue = 0.0;
    } completionHandler:^{
        [self.window close];
    }];
}

- (void)updateProgress:(NSString *)progressMessage {
    self.message = progressMessage;
}

+ (SplashForm *)sharedSplash {
    static SplashForm *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SplashForm alloc] init];
    });
    return sharedInstance;
}

@end
