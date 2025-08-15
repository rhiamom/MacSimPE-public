//
//  GenericRcolWrapper.m
//  MacSimpe
//
//  Created by Catherine Gramze on 8/6/25.
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
// *  along with this program; if not, write to the                          *
// *   Free Software Foundation, Inc.,                                       *
// *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
// ***************************************************************************

#import "GenericRcolWrapper.h"
#import "RcolUI.h"
#import "ScenegraphHelper.h"
#import "MetaData.h"
#import "IProviderRegistry.h"
#import "IPackedFileUI.h"
#import "IPackedFileDescriptor.h"
#import "IRcolBlock.h"
#import "IScenegraphBlock.h"
#import "IScenegraphFileIndexItem.h"
#import "FileTable.h"
#import "FileIndex.h"
#import "File.h"


@implementation GenericRcol

// MARK: - Initialization

- (instancetype)initWithProvider:(id<IProviderRegistry>)provider fast:(BOOL)fast {
    self = [super initWithProvider:provider fast:fast];
    if (self) {
        // Additional initialization if needed
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // Additional initialization if needed
    }
    return self;
}

// MARK: - Abstract Wrapper Methods

- (id<IPackedFileUI>)createDefaultUIHandler {
    return [[RcolUI alloc] init];
}

// MARK: - File Wrapper Properties

- (NSString *)description {
    NSMutableString *str = [[NSMutableString alloc] initWithString:@"filename="];
    [str appendString:self.fileName];
    [str appendString:@", references="];
    
    NSDictionary *map = self.referenceChains;
    for (NSString *key in map.allKeys) {
        [str appendFormat:@"%@: ", key];
        NSArray *descriptors = map[key];
        for (id<IPackedFileDescriptor> pfd in descriptors) {
            [str appendFormat:@"%@ (%@) | ", pfd.filename, [pfd description]];
        }
        if (descriptors.count > 0) {
            str = [[str substringToIndex:str.length - 2] mutableCopy];
        }
        [str appendString:@","];
    }
    if (map.count > 0) {
        str = [[str substringToIndex:str.length - 1] mutableCopy];
    }
    
    return [str copy];
}

- (NSArray<NSNumber *> *)assignableTypes {
    return @[
        @(SCENEGRAPH_TXMT),
        @(SCENEGRAPH_CRES),
        @(SCENEGRAPH_GMND),
        @(SCENEGRAPH_GMDC),
        @(SCENEGRAPH_SHPE),
        @(SCENEGRAPH_ANIM),      // ANIM
        @(0x4D51F042),           // CINE
        @([MetaData LDIR]),
        @([MetaData LAMB]),
        @([MetaData LPNT]),
        @([MetaData LSPT])
    ];
}

// MARK: - Reference Management

- (void)findReferences:(NSMutableDictionary *)refmap {
    // Subclasses can override this method to add additional references
}

- (void)findGenericReferences:(NSMutableDictionary *)refmap {
    NSMutableArray *list = [[NSMutableArray alloc] init];
    for (id<IPackedFileDescriptor> pfd in self.referencedFiles) {
        [list addObject:pfd];
    }
    
    refmap[@"Generic"] = list;
    
    // Now check each stored block if it implements IScenegraphBlock
    for (id<IRcolBlock> irb in self.blocks) {
        if ([irb conformsToProtocol:@protocol(IScenegraphBlock)]) {
            id<IScenegraphBlock> sgb = (id<IScenegraphBlock>)irb;
            [sgb referencedItems:refmap parentGroup:self.fileDescriptor.group];
        }
    }
}

// MARK: - IScenegraphItem Implementation

- (id<IScenegraphFileIndexItem>)findReferencedType:(uint32_t)type {
    NSDictionary *chains = self.referenceChains;
    
    for (NSArray *list in chains.allValues) {
        for (id obj in list) {
            id<IPackedFileDescriptor> opfd = (id<IPackedFileDescriptor>)obj;
            if (opfd.type == type) {
                id<IPackageFile> pkg = self.package;
                id<IPackedFileDescriptor> pfd = nil;  // Declare pfd here outside the if block
                
                if ([pkg isKindOfClass:[File class]]) {
                    pfd = [(File *)pkg findFileWithDescriptor:opfd];
                }
                
                if (pfd == nil) {
                    opfd.group = self.fileDescriptor.group;
                    pfd = [self.package findFileWithDescriptor:opfd];
                }
                if (pfd == nil) {
                    opfd.group = [MetaData LOCAL_GROUP];
                    pfd = [self.package findFileWithDescriptor:opfd];
                }
                
                id<IScenegraphFileIndexItem> item = nil;
                if (pfd == nil) {
                    FileIndex *fileIndex = (FileIndex *)[FileTable fileIndex];
                    [fileIndex load];  // Call load on the FileIndex instance
                    NSArray<id<IScenegraphFileIndexItem>> *items = [fileIndex findFile:(id<IPackedFileDescriptor>)obj package:nil];
                    if (items.count > 0) {
                        item = items[0];
                    }
                
                } else {
                    item = [[FileTable fileIndex] createFileIndexItem:pfd package:self.package];
                }
                
                if (item != nil) {
                    return item;
                }
            }
        }
    }
    return nil;
}

- (NSDictionary *)referenceChains {
    NSMutableDictionary *refmap = [[NSMutableDictionary alloc] init];
    [self findGenericReferences:refmap];
    [self findReferences:refmap];
    return [refmap copy];
}

@end
