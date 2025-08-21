//
//  WrapperBaseControl.m
//  MacSimpe
//
//  Created by Catherine Gramze on 8/14/25.
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

#import "WrapperBaseControl.h"
#import "IFileWrapper.h"
#import "HeaderView.h"

// MARK: - WrapperChangedEventArgs Implementation

@implementation WrapperChangedEventArgs

- (instancetype)initWithOldWrapper:(id<IFileWrapper>)oldWrapper
                        newWrapper:(id<IFileWrapper>)updatedWrapper {
    self = [super init];
    if (self) {
        _oldWrapper = oldWrapper;
        _updatedWrapper = updatedWrapper;
    }
    return self;
}

@end

// MARK: - WrapperBaseControl Implementation

@interface WrapperBaseControl ()
@property (nonatomic, strong, readwrite) id<IFileWrapper> wrapper;
@property (nonatomic, strong) NSView *headerView;
@end

@implementation WrapperBaseControl

// MARK: - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupDefaults];
        [self setupUI];
    }
    return self;
}

- (void)dealloc {
    if (self.wrapper != nil) {
        [self setWrapper:nil];
    }
}

- (void)setupDefaults {
    _headerText = @"";
    _headBackColor = [NSColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.47]; // Color.FromArgb(120, 0, 0, 0)
    _headForeColor = [NSColor whiteColor];
    _headFont = [NSFont boldSystemFontOfSize:12]; // Equivalent to 9.75pt bold
    _gradientColor = [NSColor controlColor]; // SystemColors.InactiveCaption equivalent
    _headerHeight = 24;
    _canCommit = YES;
}

- (void)setupUI {
    self.view = [[NSView alloc] init];
    [self.view setWantsLayer:YES];
    
    // Create header view
    self.headerView = [[HeaderView alloc] initWithController:self];
    [self.headerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:self.headerView];
    
    // Add constraints for header at top
    [NSLayoutConstraint activateConstraints:@[
        [self.headerView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.headerView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.headerView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor]
    ]];
    
    // Create content view
    self.contentView = [[NSView alloc] init];
    [self.contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:self.contentView];
    
    // Create commit button
    self.btCommit = [[NSButton alloc] init];
    [self.btCommit setTitle:@"Commit"];
    [self.btCommit setTarget:self];
    [self.btCommit setAction:@selector(commitAction:)];
    [self.btCommit setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.headerView addSubview:self.btCommit];
    
    [self setupConstraints];
    [self updateCommitButtonVisibility];
}

- (void)setupConstraints {
    // Header view constraints
    [NSLayoutConstraint activateConstraints:@[
        [self.headerView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.headerView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.headerView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.headerView.heightAnchor constraintEqualToConstant:self.headerHeight]
    ]];
    
    // Content view constraints
    [NSLayoutConstraint activateConstraints:@[
        [self.contentView.topAnchor constraintEqualToAnchor:self.headerView.bottomAnchor],
        [self.contentView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.contentView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.contentView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
    
    // Commit button constraints (positioned in top-right of header)
    [NSLayoutConstraint activateConstraints:@[
        [self.btCommit.trailingAnchor constraintEqualToAnchor:self.headerView.trailingAnchor constant:-4],
        [self.btCommit.centerYAnchor constraintEqualToAnchor:self.headerView.centerYAnchor],
        [self.btCommit.widthAnchor constraintEqualToConstant:75],
        [self.btCommit.heightAnchor constraintEqualToConstant:23]
    ]];
}

// MARK: - Property Setters

- (void)setHeaderText:(NSString *)headerText {
    if (![_headerText isEqualToString:headerText]) {
        _headerText = [headerText copy];
        [self.headerView setNeedsDisplay:YES];
    }
}

- (void)setHeadBackColor:(NSColor *)headBackColor {
    if (![_headBackColor isEqual:headBackColor]) {
        _headBackColor = headBackColor;
        [self.headerView setNeedsDisplay:YES];
    }
}

- (void)setHeadForeColor:(NSColor *)headForeColor {
    if (![_headForeColor isEqual:headForeColor]) {
        _headForeColor = headForeColor;
        [self.headerView setNeedsDisplay:YES];
    }
}

- (void)setHeadFont:(NSFont *)headFont {
    if (![_headFont isEqual:headFont]) {
        _headFont = headFont;
        [self.headerView setNeedsDisplay:YES];
    }
}

- (void)setGradientColor:(NSColor *)gradientColor {
    if (![_gradientColor isEqual:gradientColor]) {
        _gradientColor = gradientColor;
        [self.view setNeedsDisplay:YES];
    }
}

- (void)setCanCommit:(BOOL)canCommit {
    if (_canCommit != canCommit) {
        _canCommit = canCommit;
        [self updateCommitButtonVisibility];
    }
}

- (void)updateCommitButtonVisibility {
    [self.btCommit setHidden:!self.canCommit];
}



// MARK: - IPackedFileUI Protocol

- (NSView *)guiHandle {
    return self.view;
}

- (void)updateGUI:(id<IFileWrapper>)wrapper {
    [self setWrapper:wrapper];
    [self refreshGUI];
}

// MARK: - Wrapper Management

- (void)setWrapper:(id<IFileWrapper>)wrapper {
    id<IFileWrapper> oldWrapper = self.wrapper;
    _wrapper = wrapper;
    
    WrapperChangedEventArgs *args = [[WrapperChangedEventArgs alloc] initWithOldWrapper:oldWrapper
                                                                             newWrapper:wrapper];
    [self onWrapperChanged:args];
    
    if (self.wrapperChangedHandler) {
        self.wrapperChangedHandler(args);
    }
}

// MARK: - Template Methods (Override in Subclasses)

- (void)refreshGUI {
    // Override in subclasses
}

- (void)onCommit {
    // Override in subclasses
}

- (void)onWrapperChanged:(WrapperChangedEventArgs *)args {
    // Override in subclasses
}

// MARK: - Actions

- (IBAction)commitAction:(id)sender {
    if (self.commitHandler) {
        self.commitHandler();
    }
    [self onCommit];
}

@end

