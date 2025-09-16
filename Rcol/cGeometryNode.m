//
//  cGeometryNode.m
//  MacSimpe
//
//  Created by Catherine Gramze on 9/12/25.
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

#import "cGeometryNode.h"
#import "cObjectGraphNode.h"
#import "cSGResource.h"
#import "BinaryReader.h"
#import "BinaryWriter.h"
#import "RcolWrapper.h"
#import "IRcolBlock.h"
#import "Helper.h"
#import "FileTableBase.h"
#import "FileIndex.h"
#import "GenericRcolWrapper.h"
#import "cShape.h"
#import "Hashes.h"
#import "MetaData.h"
#import "IScenegraphFileIndexItem.h"
#import "IPackageFile.h"
#import <Foundation/Foundation.h>

@interface GeometryNode ()
@property (nonatomic, strong) NSViewController *geometryNodeViewController;
@end

@implementation GeometryNode

// MARK: - Properties

- (NSInteger)count {
    return self.blocks.count;
}

// MARK: - Initialization

- (instancetype)initWithParent:(Rcol *)parent {
    self = [super initWithParent:parent];
    if (self) {
        _objectGraphNode = [[ObjectGraphNode alloc] initWithParent:nil];
        self.sgres = [[SGResource alloc] initWithParent:nil];
        
        self.version = 0x0c;
        self.blockId = 0x7BA3838C;
        
        _blocks = [[NSMutableArray alloc] init];
    }
    return self;
}

// MARK: - IRcolBlock Protocol Methods

- (void)unserialize:(BinaryReader *)reader {
    self.version = [reader readUInt32];
    
    NSString *name = [reader readString];
    uint32_t myId = [reader readUInt32];
    [self.objectGraphNode unserialize:reader];
    self.objectGraphNode.blockId = myId;
    
    name = [reader readString];
    myId = [reader readUInt32];
    [self.sgres unserialize:reader];
    self.sgres.blockId = myId;
    
    if (self.version == 0x0b) {
        self.unknown1 = [reader readInt16];
    }
    
    if ((self.version == 0x0b) || (self.version == 0x0c)) {
        self.unknown2 = [reader readInt16];
        self.unknown3 = [reader readByte];
    }
    
    int32_t count = [reader readInt32];
    [self.blocks removeAllObjects];
    
    for (int i = 0; i < count; i++) {
        uint32_t blockId = [reader readUInt32];
        id<IRcolBlock> block = [self.parent readBlockWithId:blockId reader:reader];
        if (block) {
            [self.blocks addObject:block];
        }
    }
}

- (void)serialize:(BinaryWriter *)writer {
    [writer writeUInt32:self.version];
    
    [writer writeString:self.objectGraphNode.blockName];
    [writer writeUInt32:self.objectGraphNode.blockId];
    [self.objectGraphNode serialize:writer];
    
    [writer writeString:self.sgres.blockName];
    [writer writeUInt32:self.sgres.blockId];
    [self.sgres serialize:writer];
    
    if (self.version == 0x0b) {
        [writer writeInt16:self.unknown1];
    }
    
    if ((self.version == 0x0b) || (self.version == 0x0c)) {
        [writer writeInt16:self.unknown2];
        [writer writeUInt8:self.unknown3];
    }
    
    [writer writeInt32:(int32_t)self.blocks.count];
    for (id<IRcolBlock> block in self.blocks) {
        [writer writeUInt32:block.blockId];
        [self.parent writeBlock:block writer:writer];
    }
}

// MARK: - Tab Management

- (NSViewController *)viewController {
    if (!self.geometryNodeViewController) {
        // Create a basic view controller for geometry node
        self.geometryNodeViewController = [[NSViewController alloc] init];
        self.geometryNodeViewController.view = [[NSView alloc] init];
        [self initTabPage];
    }
    return self.geometryNodeViewController;
}

- (void)initTabPage {
    if (!self.geometryNodeViewController) {
        self.geometryNodeViewController = [[NSViewController alloc] init];
        self.geometryNodeViewController.view = [[NSView alloc] init];
    }
    
    // In a full implementation, you would set up the UI controls here
    // For now, this is a placeholder for the macOS adaptation
    NSLog(@"GeometryNode TabPage - Version: 0x%@", [Helper hexStringUInt:self.version]);
    NSLog(@"GeometryNode TabPage - Unknown1: 0x%@", [Helper hexStringUShort:(uint16_t)self.unknown1]);
    NSLog(@"GeometryNode TabPage - Unknown2: 0x%@", [Helper hexStringUShort:(uint16_t)self.unknown2]);
    NSLog(@"GeometryNode TabPage - Unknown3: 0x%@", [Helper hexStringByte:self.unknown3]);
    NSLog(@"GeometryNode TabPage - Count: %ld", (long)self.count);
}

- (void)extendTabView:(NSTabView *)tabView {
    [super extendTabView:tabView];
    [self.objectGraphNode extendTabView:tabView];
}

// MARK: - Shape Referencing

- (Rcol *)findReferencingShpe {
    // Load file table
    [FileIndex load];
    return [self findReferencingShpeNoLoad];
}

- (Rcol *)findReferencingShpeNoLoad {
    // Find SHPE files
    NSArray *items = [[FileTableBase fileIndex] findFileWithType:[MetaData SHPE] noLocal:YES];
    NSString *myName = [[Hashes stripHashFromName:self.parent.fileName.lowercaseString]
                        stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    
    for (id<IScenegraphFileIndexItem> item in items) {
        GenericRcol *rcol = [[GenericRcol alloc] initWithProvider:nil fast:NO];
        
        // Try to open the file in the same package, not in the FileTable package
        if ([[item.package.saveFileName.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]
             isEqualToString:[self.parent.package.saveFileName.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]) {
            
            id<IPackedFileDescriptor> descriptor = [self.parent.package findFileWithDescriptor:item.fileDescriptor];
            [rcol processData:descriptor package:self.parent.package];
        }
        
        if (rcol.blocks.count > 0) {
            Shape *shape = (Shape *)rcol.blocks[0];
            
            for (ShapeItem *shapeItem in shape.items) {
                NSString *itemName = [[Hashes stripHashFromName:shapeItem.fileName] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].lowercaseString;
                if ([itemName isEqualToString:myName]) {
                    return rcol;
                }
            }
        }
    }
    
    return nil;
}

// MARK: - Memory Management

- (void)dispose {
    [super dispose];
    
    if (self.geometryNodeViewController) {
        [self.geometryNodeViewController.view removeFromSuperview];
        self.geometryNodeViewController = nil;
    }
    
    [self.blocks removeAllObjects];
    self.objectGraphNode = nil;
}

@end
