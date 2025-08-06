//
//  WaitControl.m
//  MacSimpe
//
//  Created by Catherine Gramze on 7/29/25.
//
// ***************************************************************************
// *   Copyright (C) 2005 by Ambertation                                     *
// *   quaxi@ambertation.de                                                  *
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

#import "WaitControl.h"
#import "Registry.h"
#import "Localization.h"

@implementation WaitControl

- (instancetype)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        [self setupUI];
        [self setupDefaults];
    }
    return self;
}

- (void)setupUI {
    // Create progress indicator (determinate)
    self.progressIndicator = [[NSProgressIndicator alloc] init];
    [self.progressIndicator setStyle:NSProgressIndicatorStyleBar];
    [self.progressIndicator setIndeterminate:NO];
    [self.progressIndicator setMinValue:0];
    [self.progressIndicator setMaxValue:100];
    [self addSubview:self.progressIndicator];
    
    // Create spinning indicator (indeterminate)
    self.spinningIndicator = [[NSProgressIndicator alloc] init];
    [self.spinningIndicator setStyle:NSProgressIndicatorStyleSpinning];
    [self.spinningIndicator setControlSize:NSControlSizeSmall];
    [self.spinningIndicator setDisplayedWhenStopped:NO];
    [self addSubview:self.spinningIndicator];
    
    // Create message label
    self.messageLabel = [[NSTextField alloc] init];
    [self.messageLabel setBezeled:NO];
    [self.messageLabel setDrawsBackground:NO];
    [self.messageLabel setEditable:NO];
    [self.messageLabel setSelectable:NO];
    [self.messageLabel setFont:[NSFont systemFontOfSize:11]];
    [self.messageLabel setTextColor:[NSColor secondaryLabelColor]];
    [self addSubview:self.messageLabel];
    
    // Create percent label
    self.percentLabel = [[NSTextField alloc] init];
    [self.percentLabel setBezeled:NO];
    [self.percentLabel setDrawsBackground:NO];
    [self.percentLabel setEditable:NO];
    [self.percentLabel setSelectable:NO];
    [self.percentLabel setFont:[NSFont systemFontOfSize:11]];
    [self.percentLabel setTextColor:[NSColor secondaryLabelColor]];
    [self.percentLabel setAlignment:NSTextAlignmentRight];
    [self addSubview:self.percentLabel];
    
    [self setupConstraints];
}

- (void)setupConstraints {
    [self.progressIndicator setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.spinningIndicator setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.messageLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.percentLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [NSLayoutConstraint activateConstraints:@[
        // Progress indicator
        [self.progressIndicator.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:8],
        [self.progressIndicator.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
        [self.progressIndicator.widthAnchor constraintEqualToConstant:200],
        [self.progressIndicator.heightAnchor constraintEqualToConstant:16],
        
        // Percent label
        [self.percentLabel.leadingAnchor constraintEqualToAnchor:self.progressIndicator.trailingAnchor constant:8],
        [self.percentLabel.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
        [self.percentLabel.widthAnchor constraintEqualToConstant:40],
        
        // Message label
        [self.messageLabel.leadingAnchor constraintEqualToAnchor:self.percentLabel.trailingAnchor constant:12],
        [self.messageLabel.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
        [self.messageLabel.trailingAnchor constraintEqualToAnchor:self.spinningIndicator.leadingAnchor constant:-8],
        
        // Spinning indicator
        [self.spinningIndicator.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-8],
        [self.spinningIndicator.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
        [self.spinningIndicator.widthAnchor constraintEqualToConstant:16],
        [self.spinningIndicator.heightAnchor constraintEqualToConstant:16]
    ]];
}

- (void)setupDefaults {
    _message = @"";
    _maxProgress = 0;
    _progress = 0;
    _waiting = NO;
    _showProgress = NO;
    _showAnimation = YES;
    _showText = YES;
    
    [self updateVisibility];
}

// MARK: - Property Setters

- (void)setMessage:(NSString *)message {
    _message = [message copy];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.messageLabel setStringValue:self.message ?: @""];
    });
}

- (void)setProgress:(NSInteger)progress {
    _progress = progress;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressIndicator setDoubleValue:(double)self.progress];
        
        if (self.maxProgress > 0) {
            NSInteger percent = (self.progress * 100) / self.maxProgress;
            [self.percentLabel setStringValue:[NSString stringWithFormat:@"%ld%%", (long)percent]];
        }
    });
}

- (void)setMaxProgress:(NSInteger)maxProgress {
    _maxProgress = maxProgress;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressIndicator setMaxValue:(double)self.maxProgress];
        self.showProgress = (self.maxProgress > 1);
    });
}

- (void)setWaiting:(BOOL)waiting {
    _waiting = waiting;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateVisibility];
        
        if (self.waiting) {
            [self.spinningIndicator startAnimation:nil];
        } else {
            [self.spinningIndicator stopAnimation:nil];
            self.message = @"";
            self.progress = 0;
            self.showProgress = NO;
        }
    });
}

- (void)setShowProgress:(BOOL)showProgress {
    _showProgress = showProgress;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateVisibility];
    });
}

- (void)setShowAnimation:(BOOL)showAnimation {
    _showAnimation = showAnimation;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateVisibility];
    });
}

- (void)setShowText:(BOOL)showText {
    _showText = showText;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateVisibility];
    });
}

- (void)updateVisibility {
    BOOL shouldShow = self.waiting || [[Registry windowsRegistry] showWaitBarPermanent];
    [self setHidden:!shouldShow];
    
    [self.progressIndicator setHidden:!self.showProgress];
    [self.percentLabel setHidden:!self.showProgress];
    [self.spinningIndicator setHidden:!self.showAnimation];
    [self.messageLabel setHidden:!self.showText];
}

// MARK: - IWaitingBarControl Protocol

- (BOOL)running {
    return self.waiting;
}

- (void)wait {
    self.message = [[Localization shared] getString:@"Please Wait"];
    self.image = nil;
    self.waiting = YES;
}

- (void)waitWithMax:(NSInteger)max {
    self.showProgress = YES;
    self.message = [[Localization shared] getString:@"Please Wait"];
    self.image = nil;
    self.maxProgress = max;
    self.waiting = YES;
}

- (void)stop {
    self.showProgress = NO;
    self.waiting = NO;
}

@end
