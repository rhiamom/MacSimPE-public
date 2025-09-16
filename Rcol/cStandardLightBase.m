//
//  cStandardLightBase.m
//  MacSimpe
//
//  Created by Catherine Gramze on 9/15/25.
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

#import "cStandardLightBase.h"
#import "BinaryReader.h"
#import "BinaryWriter.h"
#import "RcolWrapper.h"

@interface StandardLightBase ()

// Private UI reference
@property (nonatomic, strong) NSViewController *genericRcolViewController;

@end

@implementation StandardLightBase

// MARK: - Initialization

- (instancetype)initWithParent:(Rcol *)parent {
    self = [super initWithParent:parent];
    if (self) {
        self.version = 11;
        self.blockId = 0;
    }
    return self;
}

// MARK: - IRcolBlock Protocol Methods

- (void)unserialize:(BinaryReader *)reader {
    self.version = [reader readUInt32];
}

- (void)serialize:(BinaryWriter *)writer {
    [writer writeUInt32:self.version];
}

// MARK: - UI Management

- (NSViewController *)viewController {
    if (self.genericRcolViewController == nil) {
        // TODO: Create GenericRcolViewController
        // self.genericRcolViewController = [[GenericRcolViewController alloc] init];
        // [self initTabPage];
    }
    return self.genericRcolViewController;
}

- (void)initTabPage {
    if (self.genericRcolViewController == nil) {
        // TODO: Create GenericRcolViewController
        // self.genericRcolViewController = [[GenericRcolViewController alloc] init];
    }
    
    // TODO: Set version text field to hex string of version
    // Set property grid selected object to self
}

// MARK: - Memory Management

- (void)dispose {
    [self.genericRcolViewController.view removeFromSuperview];
    self.genericRcolViewController = nil;
    
    [super dispose];
}

@end
