//
//  cDirectionalLight.m
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

#import "cDirectionalLight.h"
#import "cStandardLightBase.h"
#import "cLightT.h"
#import "cReferentNode.h"
#import "cObjectGraphNode.h"
#import "cSGResource.h"
#import "BinaryReader.h"
#import "BinaryWriter.h"
#import "RcolWrapper.h"

@interface DirectionalLight ()

// Private UI reference
@property (nonatomic, strong) NSViewController *directionalLightViewController;

@end

@implementation DirectionalLight

// MARK: - Initialization

- (instancetype)initWithParent:(Rcol *)parent {
    self = [super initWithParent:parent];
    if (self) {
        self.version = 1;
        self.blockId = 0xC9C81BA3;
        
        self.standardLightBase = [[StandardLightBase alloc] initWithParent:nil];
        self.sgres = [[SGResource alloc] initWithParent:nil];
        self.lightT = [[LightT alloc] initWithParent:nil];
        self.referentNode = [[ReferentNode alloc] initWithParent:nil];
        self.objectGraphNode = [[ObjectGraphNode alloc] initWithParent:nil];
        
        self.name = @"";
    }
    return self;
}

// MARK: - IRcolBlock Protocol Methods

- (void)unserialize:(BinaryReader *)reader {
    self.version = [reader readUInt32];
    
    self.standardLightBase.blockName = [reader readString];
    self.standardLightBase.blockId = [reader readUInt32];
    [self.standardLightBase unserialize:reader];
    
    self.sgres.blockName = [reader readString];
    self.sgres.blockId = [reader readUInt32];
    [self.sgres unserialize:reader];
    
    self.lightT.blockName = [reader readString];
    self.lightT.blockId = [reader readUInt32];
    [self.lightT unserialize:reader];
    
    self.referentNode.blockName = [reader readString];
    self.referentNode.blockId = [reader readUInt32];
    [self.referentNode unserialize:reader];
    
    self.objectGraphNode.blockName = [reader readString];
    self.objectGraphNode.blockId = [reader readUInt32];
    [self.objectGraphNode unserialize:reader];
    
    self.name = [reader readString];
    self.val1 = [reader readSingle];
    self.val2 = [reader readSingle];
    self.red = [reader readSingle];
    self.green = [reader readSingle];
    self.blue = [reader readSingle];
}

- (void)serialize:(BinaryWriter *)writer {
    [writer writeUInt32:self.version];
    
    [writer writeString:self.standardLightBase.blockName];
    [writer writeUInt32:self.standardLightBase.blockId];
    [self.standardLightBase serialize:writer];
    
    [writer writeString:self.sgres.blockName];
    [writer writeUInt32:self.sgres.blockId];
    [self.sgres serialize:writer];
    
    [writer writeString:self.lightT.blockName];
    [writer writeUInt32:self.lightT.blockId];
    [self.lightT serialize:writer];
    
    [writer writeString:self.referentNode.blockName];
    [writer writeUInt32:self.referentNode.blockId];
    [self.referentNode serialize:writer];
    
    [writer writeString:self.objectGraphNode.blockName];
    [writer writeUInt32:self.objectGraphNode.blockId];
    [self.objectGraphNode serialize:writer];
    
    [writer writeString:self.name];
    [writer writeFloat:self.val1];
    [writer writeFloat:self.val2];
    [writer writeFloat:self.red];
    [writer writeFloat:self.green];
    [writer writeFloat:self.blue];
}

// MARK: - UI Management

- (NSViewController *)viewController {
    if (self.directionalLightViewController == nil) {
        // TODO: Create DirectionalLightViewController
        // self.directionalLightViewController = [[DirectionalLightViewController alloc] init];
        // [self initTabPage];
    }
    return self.directionalLightViewController;
}

- (void)initTabPage {
    if (self.directionalLightViewController == nil) {
        // TODO: Create DirectionalLightViewController
        // self.directionalLightViewController = [[DirectionalLightViewController alloc] init];
    }
    
    // TODO: Update UI controls with data
    // Set version label to hex string of version
    // Set name field to self.name
    // Set val1, val2, red, green, blue text fields
    // Hide unnecessary labels and text fields
}

- (void)extendTabView:(NSTabView *)tabView {
    [super extendTabView:tabView];
    [self.standardLightBase addToTabControl:tabView];
    [self.lightT addToTabControl:tabView];
    [self.referentNode addToTabControl:tabView];
    [self.objectGraphNode addToTabControl:tabView];
}

// MARK: - Memory Management

- (void)dispose {
    [self.directionalLightViewController.view removeFromSuperview];
    self.directionalLightViewController = nil;
    
    [self.standardLightBase dispose];
    [self.lightT dispose];
    [self.referentNode dispose];
    [self.objectGraphNode dispose];
    
    [super dispose];
}

@end
