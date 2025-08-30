//
//  GroupCacheWrapper.m
//  MacSimpe
//
//  Created by Catherine Gramze on 8/24/25.
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

#import "GroupCacheWrapper.h"
#import "GroupCacheItem.h"
#import "BinaryReader.h"
#import "BinaryWriter.h"
#import "PathProvider.h"
#import "ExpansionItem.h"
#import "Helper.h"
#import "AbstractWrapperInfo.h"
#import "GroupCacheUI.h"

@implementation GroupCache {
    uint32_t _id;
    GroupCacheItems *_items;
    NSMutableDictionary<NSString *, GroupCacheItem *> *_map;
    uint32_t _maxGroup;
    NSData *_over;
}

// MARK: - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        _id = 0x05;
        _items = [[GroupCacheItems alloc] init];
        _map = [[NSMutableDictionary alloc] init];
        _maxGroup = 0x6f000000;
        _over = [[NSData alloc] init];
    }
    return self;
}

// MARK: - Properties

- (GroupCacheItems *)items {
    return _items;
}

// MARK: - Private Helper Methods

/**
 * Returns an Absolute FileName
 * @param filename The filename to make absolute
 * @return The absolute filename
 */
- (NSString *)absoluteFileName:(NSString *)filename {
    NSString *result = filename;
    
    // Replace %userdatadir% with sim savegame folder
    NSString *savegameFolder = [[PathProvider simSavegameFolder] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].lowercaseString;
    result = [result stringByReplacingOccurrencesOfString:@"%userdatadir%" withString:savegameFolder];
    
    // Replace expansion paths
    NSArray<ExpansionItem *> *expansions = [[PathProvider global] expansions];
    for (ExpansionItem *expansionItem in expansions) {
        NSString *versionString = [@(expansionItem.version) stringValue];
        if ([versionString isEqualToString:@"0"]) {
            versionString = @"";
        }
        
        NSString *placeholder = [NSString stringWithFormat:@"%%gamedatadir%@%%", versionString];
        NSString *installFolder = [expansionItem.installFolder stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].lowercaseString;
        result = [result stringByReplacingOccurrencesOfString:placeholder withString:installFolder];
    }
    
    return result;
}

// MARK: - Item Management

- (void)addItem:(GroupCacheItem *)item {
    if (item.localGroup > _maxGroup) {
        _maxGroup = item.localGroup;
    }
    
    [_items addItem:item];
    _map[[self absoluteFileName:item.fileName]] = item;
}

- (void)removeItem:(GroupCacheItem *)item {
    [_items removeItem:item];
    [_map removeObjectForKey:[self absoluteFileName:item.fileName]];
}

- (id<IGroupCacheItem>)getItem:(NSString *)filename {
    NSString *trimmedFilename = [[filename stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString];
    GroupCacheItem *item = _map[trimmedFilename];
    
    if (item == nil) {
        item = [[GroupCacheItem alloc] init];
        item.fileName = filename;
        item.localGroup = _maxGroup + 1;
        [self addItem:item];
    }
    
    return item;
}

// MARK: - IWrapper Implementation

- (BOOL)checkVersion:(uint32_t)version {
    return YES;
}

// MARK: - AbstractWrapper Implementation

- (id<IPackedFileUI>)createDefaultUIHandler {
    return [[GroupCacheUI alloc] init];
}

- (id<IWrapperInfo>)createWrapperInfo {
    return [[AbstractWrapperInfo alloc] initWithName:@"Group Cache Wrapper"
                                              author:@"Quaxi"
                                         description:@"---"
                                             version:1];
}

- (void)unserialize:(BinaryReader *)reader {
    _maxGroup = 0x6f000000;
    [_items removeAllObjects];
    [_map removeAllObjects];
    
    _id = [reader readUInt32];
    uint32_t count = [reader readUInt32];
    
    for (uint32_t i = 0; i < count; i++) {
        @try {
            GroupCacheItem *item = [[GroupCacheItem alloc] init];
            [item unserialize:reader];
            [self addItem:item];
        }
        @catch (NSException *ex) {
#ifdef DEBUG
            NSLog(@"Exception in GroupCache unserialize: %@", ex.reason);
#endif
            // In release mode, silently continue
        }
    }
    
    // Read any remaining bytes
    NSInteger remainingBytes = reader.baseStream.length - reader.baseStream.position;
    if (remainingBytes > 0) {
        _over = [reader readBytes:(NSInteger)remainingBytes];
    } else {
        _over = [[NSData alloc] init];
    }
}

- (void)serialize:(BinaryWriter *)writer {
    [writer writeUInt32:_id];
    [writer writeUInt32:(uint32_t)_items.length];
    
    for (NSInteger i = 0; i < _items.length; i++) {
        GroupCacheItem *item = [_items objectAtIndex:(NSUInteger)i];
        [item serialize:writer];
    }
    
    [writer writeData:_over];
}

// MARK: - IFileWrapper Implementation

- (NSData *)fileSignature {
    // Empty signature as in the original C# code
    return [[NSData alloc] init];
}

- (NSArray<NSNumber *> *)assignableTypes {
    return @[@0x54535053]; // grop
}

@end
