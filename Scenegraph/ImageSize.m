//
//  ImageSize.m
//  MacSimpe
//
//  Created by Catherine Gramze on 8/27/25.
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

#import "ImageSize.h"
#import "Helper.h"
#import "RemoteControl.h"
#import <Foundation/Foundation.h>

@implementation ImageSizeDialog

// MARK: - Class Methods

+ (NSSize)executeWithSize:(NSSize)size {
    ImageSizeDialog *dialog = [[ImageSizeDialog alloc] init];
    dialog.imageSize = size;
    
    // Set initial values
    [dialog.widthTextField setStringValue:[NSString stringWithFormat:@"%.0f", size.width]];
    [dialog.heightTextField setStringValue:[NSString stringWithFormat:@"%.0f", size.height]];
    
    // Show the dialog using RemoteControl equivalent
    [RemoteControl showSubForm:dialog.window];
    
    // Parse the results
    NSSize newSize;
        newSize.width = (CGFloat)[Helper stringToInt32:[dialog.widthTextField stringValue]
                                               default:(int32_t)size.width
                                                  base:10];
        newSize.height = (CGFloat)[Helper stringToInt32:[dialog.heightTextField stringValue]
                                                default:(int32_t)size.height
                                                   base:10];
        
        return newSize;
}

// MARK: - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        _cancelled = NO;
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    // Create the window
    NSRect windowFrame = NSMakeRect(0, 0, 194, 72);
    NSWindow *window = [[NSWindow alloc] initWithContentRect:windowFrame
                                                   styleMask:NSWindowStyleMaskTitled
                                                     backing:NSBackingStoreBuffered
                                                       defer:NO];
    
    [window setTitle:@"Image Size"];
    [window setLevel:NSFloatingWindowLevel];
    [window setReleasedWhenClosed:NO];
    
    // Create content view
    NSView *contentView = [[NSView alloc] initWithFrame:windowFrame];
    [window setContentView:contentView];
    
    // Create "Size:" label
    self.sizeLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(8, 40, 35, 17)];
    [self.sizeLabel setStringValue:@"Size:"];
    [self.sizeLabel setBezeled:NO];
    [self.sizeLabel setDrawsBackground:NO];
    [self.sizeLabel setEditable:NO];
    [self.sizeLabel setSelectable:NO];
    [self.sizeLabel setFont:[NSFont boldSystemFontOfSize:11]];
    [contentView addSubview:self.sizeLabel];
    
    // Create width text field
    self.widthTextField = [[NSTextField alloc] initWithFrame:NSMakeRect(48, 37, 56, 21)];
    [self.widthTextField setStringValue:@""];
    [contentView addSubview:self.widthTextField];
    
    // Create "x" label
    self.xLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(104, 40, 12, 17)];
    [self.xLabel setStringValue:@"x"];
    [self.xLabel setBezeled:NO];
    [self.xLabel setDrawsBackground:NO];
    [self.xLabel setEditable:NO];
    [self.xLabel setSelectable:NO];
    [self.xLabel setFont:[NSFont boldSystemFontOfSize:11]];
    [self.xLabel setAlignment:NSTextAlignmentCenter];
    [contentView addSubview:self.xLabel];
    
    // Create height text field
    self.heightTextField = [[NSTextField alloc] initWithFrame:NSMakeRect(128, 37, 56, 21)];
    [self.heightTextField setStringValue:@""];
    [contentView addSubview:self.heightTextField];
    
    // Create OK button
    self.okButton = [[NSButton alloc] initWithFrame:NSMakeRect(112, 8, 75, 23)];
    [self.okButton setTitle:@"OK"];
    [self.okButton setButtonType:NSButtonTypeMomentaryPushIn];
    [self.okButton setBezelStyle:NSBezelStyleRounded];
    [self.okButton setTarget:self];
    [self.okButton setAction:@selector(okButtonPressed:)];
    [contentView addSubview:self.okButton];
    
    // Set the window
    [self setWindow:window];
    
    // Center the window
    [window center];
    
    // Make width field first responder
    [window makeFirstResponder:self.widthTextField];
}

// MARK: - Actions

- (IBAction)okButtonPressed:(id)sender {
    [self close];
}

// MARK: - Window Management

- (void)windowWillClose:(NSNotification *)notification {
    // This matches the original behavior where clicking OK just closes the dialog
}

// MARK: - Memory Management

- (void)dealloc {
    // ARC handles cleanup automatically
}

@end
