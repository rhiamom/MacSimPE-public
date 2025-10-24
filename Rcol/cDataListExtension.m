//
//  cDataListExtension.m
//  MacSimpe
//
//  Created by Catherine Gramze on 9/18/25.
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

#import "cDataListExtension.h"
#import "cExtension.h"
#import "BinaryReader.h"
#import "BinaryWriter.h"
#import "RcolWrapper.h"
#import "Helper.h"
#import "GenericRcolWrapper.h"
#import "ScenegraphHelper.h"

@implementation DataListExtension {
    Extension *_extension;
}

@synthesize extension = _extension;

// MARK: - Initialization

- (instancetype)initWithParent:(Rcol *)parent {
    self = [super initWithParent:parent];
    if (self) {
        _extension = [[Extension alloc] initWithParent:nil];
        self.version = 0x01;
        self.blockId = 0x6a836d56;
    }
    return self;
}

// MARK: - IRcolBlock Protocol Methods

- (void)unserialize:(BinaryReader *)reader {
    self.version = [reader readUInt32];
    
    // Read and discard unused string field (advances stream position)
    (void)[reader readString];
    
    uint32_t myid = [reader readUInt32];
    
    [_extension unserialize:reader version:self.version];
    _extension.blockId = myid;
}

- (void)serialize:(BinaryWriter *)writer {
    [writer writeUInt32:self.version];
    
    NSString *name = [_extension registerInListing:nil];
    [writer writeString:name];
    [writer writeUInt32:_extension.blockId];
    [_extension serialize:writer version:self.version];
}

- (void)initTabPage {
    // Use the base class tab page functionality
    [super initTabPage];
}

- (void)extendTabView:(NSTabView *)tabView {
    [super extendTabView:tabView];
    [_extension addToTabControl:tabView];
    NSTabViewItem *lastItem = [tabView.tabViewItems lastObject];
    if (lastItem != nil) {
        [tabView selectTabViewItem:lastItem];
    }
}


- (NSString *)description {
    return [NSString stringWithFormat:@"%@ (%@)", _extension.varName, [super description]];
}

// MARK: - IScenegraphBlock Protocol Methods

- (void)referencedItems:(NSMutableDictionary<NSString *, NSMutableArray *> *)refmap
            parentGroup:(uint32_t)parentgroup {
    if ([_extension.varName.lowercaseString isEqualToString:@"tsmaterialsmeshname"]) {
        NSMutableArray *list = [[NSMutableArray alloc] init];
        for (ExtensionItem *ei in _extension.items) {
            NSString *name = [ei.string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (![name.lowercaseString hasSuffix:@"_cres"]) {
                name = [name stringByAppendingString:@"_cres"];
            }
            
            id pfd = [ScenegraphHelper buildPfdWithFilename:name
                                                       type:SCENEGRAPH_CRES
                                               defaultGroup:parentgroup];
            [list addObject:pfd];
        }
        
        refmap[@"tsMaterialsMeshName"] = list;
    }
}

// MARK: - Memory Management

- (void)dispose {
    [super dispose];
}

@end
