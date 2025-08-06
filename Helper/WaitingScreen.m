//
//  WaitingForm.m
//  MacSimpe
//
//  Created by Catherine Gramze on 8/3/25.
//
// ***************************************************************************
// *   Copyright (C) 2005 by Ambertation                                     *
// *   quaxi@ambertation.de                                                  *
// *   Copyright (C) 2008 by Peter L Jones                                   *
// *   pljones@users.sf.net                                                  *
// *                                                                         *
// *   Objective-C translation Copyright (C) 2025 by GramzeSweatShop         *
// *   rhiamom@mac.com                                                       *
// *                                                                         *
// *   This program is free software; you can redistribute it and/or modify  *
// *   it under the terms of the GNU General Public License as published by  *
// *   the Free Software Foundation; either version 2 of the License, or     *
// *   (at your option) any later version.                                   *
// *                                                                         *
// *   This program is distributed in the hope that it will be useful,       *
// *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
// *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
// *   GNU General Public License for more details.                          *
// *                                                                         *
// *   You should have received a copy of the GNU General Public License     *
// *   along with this program; if not, write to the                         *
// *   Free Software Foundation, Inc.,                                       *
// *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
// ***************************************************************************

#import "WaitingForm.h"

@interface WaitingForm ()

@property (nonatomic, strong, readwrite) NSWindow *window;
@property (nonatomic, strong) NSImageView *customImageView;
@property (nonatomic, strong) NSImageView *simpeImageView;
@property (nonatomic, strong) NSTextField *messageLabel;
@property (nonatomic, strong) NSTextField *waitLabel;
@property (nonatomic, strong) NSView *containerView;
@property (nonatomic, strong) NSImage *defaultSimpeImage;

- (void)loadDefaultImages;

@end

@implementation WaitingForm

// MARK: - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupWindow];
        [self setupUI];
        
        // Set default values
        _image = nil; // Custom image starts as nil
        _message = @"Loading...";
        
        [self updateDisplay];
    }
    return self;
}

// MARK: - Setup

- (void)setupWindow {
    // Create a window matching the original size (240x80)
    NSRect frame = NSMakeRect(0, 0, 240, 80);
    
    _window = [[NSWindow alloc] initWithContentRect:frame
                                          styleMask:NSWindowStyleMaskBorderless
                                            backing:NSBackingStoreBuffered
                                              defer:NO];
    
    [_window setLevel:NSFloatingWindowLevel];
    [_window setOpaque:NO];
    [_window setBackgroundColor:[NSColor clearColor]];
    [_window setHasShadow:YES];
    [_window setMovableByWindowBackground:NO];
    [_window setReleasedWhenClosed:NO];
}

- (void)setupUI {
    // Create container view with background matching original
    _containerView = [[NSView alloc] init];
    [_containerView setWantsLayer:YES];
    [_containerView.layer setBackgroundColor:[[NSColor colorWithRed:102.0/255.0
                                                              green:102.0/255.0
                                                               blue:153.0/255.0
                                                              alpha:1.0] CGColor]];
    
    // Create custom image view (initially hidden)
    _customImageView = [[NSImageView alloc] init];
    [_customImageView setImageScaling:NSImageScaleAxesIndependently];
    [_customImageView setImageAlignment:NSImageAlignCenter];
    [_customImageView setHidden:YES];
    
    // Create SimPE image view (default visible)
    _simpeImageView = [[NSImageView alloc] init];
    [_simpeImageView setImageScaling:NSImageScaleAxesIndependently];
    [_simpeImageView setImageAlignment:NSImageAlignCenter];
    
    // Create message label
    _messageLabel = [[NSTextField alloc] init];
    [_messageLabel setBezeled:NO];
    [_messageLabel setDrawsBackground:NO];
    [_messageLabel setEditable:NO];
    [_messageLabel setSelectable:NO];
    [_messageLabel setAlignment:NSTextAlignmentCenter];
    [_messageLabel setFont:[NSFont systemFontOfSize:11]];
    [_messageLabel setTextColor:[NSColor colorWithRed:204.0/255.0
                                                green:211.0/255.0
                                                 blue:213.0/255.0
                                                alpha:1.0]];
    
    // Create "Please wait..." label
    _waitLabel = [[NSTextField alloc] init];
    [_waitLabel setBezeled:NO];
    [_waitLabel setDrawsBackground:NO];
    [_waitLabel setEditable:NO];
    [_waitLabel setSelectable:NO];
    [_waitLabel setAlignment:NSTextAlignmentCenter];
    [_waitLabel setFont:[NSFont boldSystemFontOfSize:12]];
    [_waitLabel setTextColor:[NSColor grayColor]];
    [_waitLabel setStringValue:@"Please wait..."];
    
    // Set up auto layout
    [_containerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_customImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_simpeImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_messageLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_waitLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    // Add views to window
    [_window.contentView addSubview:_containerView];
    [_containerView addSubview:_customImageView];
    [_containerView addSubview:_simpeImageView];
    [_containerView addSubview:_messageLabel];
    [_containerView addSubview:_waitLabel];
    
    // Set up constraints to match original layout
    [NSLayoutConstraint activateConstraints:@[
        // Container view fills the window
        [_containerView.topAnchor constraintEqualToAnchor:_window.contentView.topAnchor],
        [_containerView.bottomAnchor constraintEqualToAnchor:_window.contentView.bottomAnchor],
        [_containerView.leadingAnchor constraintEqualToAnchor:_window.contentView.leadingAnchor],
        [_containerView.trailingAnchor constraintEqualToAnchor:_window.contentView.trailingAnchor],
        
        // Custom image view positioned like original pb
        [_customImageView.topAnchor constraintEqualToAnchor:_containerView.topAnchor constant:8],
        [_customImageView.leadingAnchor constraintEqualToAnchor:_containerView.leadingAnchor constant:8],
        [_customImageView.widthAnchor constraintEqualToConstant:64],
        [_customImageView.heightAnchor constraintEqualToConstant:64],
        
        // SimPE image view positioned like original pbsimpe
        [_simpeImageView.topAnchor constraintEqualToAnchor:_containerView.topAnchor constant:8],
        [_simpeImageView.leadingAnchor constraintEqualToAnchor:_containerView.leadingAnchor constant:8],
        [_simpeImageView.widthAnchor constraintEqualToConstant:64],
        [_simpeImageView.heightAnchor constraintEqualToConstant:64],
        
        // Message label positioned like original lbmsg
        [_messageLabel.topAnchor constraintEqualToAnchor:_containerView.topAnchor constant:8],
        [_messageLabel.leadingAnchor constraintEqualToAnchor:_containerView.leadingAnchor constant:80],
        [_messageLabel.trailingAnchor constraintEqualToAnchor:_containerView.trailingAnchor constant:-8],
        [_messageLabel.heightAnchor constraintEqualToConstant:32],
        
        // Wait label positioned like original lbwait
        [_waitLabel.topAnchor constraintEqualToAnchor:_containerView.topAnchor constant:48],
        [_waitLabel.leadingAnchor constraintEqualToAnchor:_containerView.leadingAnchor constant:80],
        [_waitLabel.trailingAnchor constraintEqualToAnchor:_containerView.trailingAnchor constant:-8],
        [_waitLabel.heightAnchor constraintEqualToConstant:18]
    ]];
    
    // Load default images
    [self loadDefaultImages];
}

- (void)loadDefaultImages {
    // Load the embedded SimPE icon from app bundle
    _defaultSimpeImage = [NSImage imageNamed:@"SimPE-Icon"];
    
    // If the bundle image isn't available, create a default
    if (_defaultSimpeImage == nil) {
        _defaultSimpeImage = [NSImage imageNamed:NSImageNameApplicationIcon];
    }
    
    [_simpeImageView setImage:_defaultSimpeImage];
}

// MARK: - Public Methods

- (void)startSplash {
    dispatch_async(dispatch_get_main_queue(), ^{
        // Center the window on screen
        [self.window center];
        
        // Show the window
        [self.window orderFront:nil];
        
        NSLog(@"WaitingForm: Started splash screen");
    });
}

- (void)stopSplash {
    dispatch_async(dispatch_get_main_queue(), ^{
        // Hide the window
        [self.window orderOut:nil];
        
        NSLog(@"WaitingForm: Stopped splash screen");
    });
}

- (void)setImage:(NSImage *)image {
    if (_image != image) {
        _image = image;
        [self updateDisplay];
    }
}

- (void)setMessage:(NSString *)message {
    if (![_message isEqualToString:message]) {
        _message = message;
        [self updateDisplay];
    }
}

// MARK: - Private Methods

- (void)updateDisplay {
    dispatch_async(dispatch_get_main_queue(), ^{
        // Update message
        [self.messageLabel setStringValue:self.message ?: @""];
        
        // Handle image visibility like the original Windows form
        if (self.image != nil) {
            // Show custom image, hide SimPE image
            [self.customImageView setImage:self.image];
            [self.customImageView setHidden:NO];
            [self.simpeImageView setHidden:YES];
        } else {
            // Show SimPE image, hide custom image
            [self.customImageView setHidden:YES];
            [self.simpeImageView setHidden:NO];
        }
    });
}

@end
