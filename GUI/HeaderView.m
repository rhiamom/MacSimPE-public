//
//  HeaderView.m
//  MacSimpe
//
//  Created by Catherine Gramze on 8/17/25.
//
//***************************************************************************
//*  Copyright (C) 2025 by GramzeSweatShop                                  *
//*   rhiamom@mac.com                                                       *
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
//*  along with this program; if not, write to the                          *
//*   Free Software Foundation, Inc.,                                       *
//*   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
//***************************************************************************/

#import "HeaderView.h"
#import "WrapperBaseControl.h"

@implementation HeaderView

- (instancetype)initWithController:(WrapperBaseControl *)controller {
    self = [super init];
    if (self) {
        _controller = controller;
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    // Set background color to match SimPE's gray header
    [self setWantsLayer:YES];
    [self.layer setBackgroundColor:[[NSColor controlBackgroundColor] CGColor]];
    
    // Create title label
    self.titleLabel = [[NSTextField alloc] init];
    [self.titleLabel setBezeled:NO];
    [self.titleLabel setDrawsBackground:NO];
    [self.titleLabel setEditable:NO];
    [self.titleLabel setSelectable:NO];
    [self.titleLabel setFont:[NSFont boldSystemFontOfSize:13]];
    [self.titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:self.titleLabel];
    
    // Create commit button
    self.commitButton = [[NSButton alloc] init];
    [self.commitButton setTitle:@"Commit"];
    [self.commitButton setTarget:self.controller];
    [self.commitButton setAction:@selector(commitAction:)];
    [self.commitButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:self.commitButton];
    
    // Setup constraints
    [NSLayoutConstraint activateConstraints:@[
        [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:16],
        [self.titleLabel.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
        
        [self.commitButton.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-16],
        [self.commitButton.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
        
        [self.heightAnchor constraintEqualToConstant:32]
    ]];
}

- (void)updateTitle:(NSString *)title {
    [self.titleLabel setStringValue:title ?: @""];
}

- (void)setCommitEnabled:(BOOL)enabled {
    [self.commitButton setEnabled:enabled];
}

@end


