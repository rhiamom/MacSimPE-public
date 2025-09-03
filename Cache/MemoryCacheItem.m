//
//  MemoryCacheItem.m
//  MacSimpe
//
//  Created by Catherine Gramze on 8/30/25.
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
// ***************************************************************************/

#import "MemoryCacheItem.h"
#import "BinaryReader.h"
#import "BinaryWriter.h"
#import "PackedFileDescriptor.h"
#import "CacheContainer.h"
#import "CacheException.h"
#import "IPackedFileDescriptor.h"

// MARK: - Constants

const uint8_t MEMORY_CACHE_ITEM_VERSION = 3;
const uint8_t MEMORY_CACHE_ITEM_DISCARD_VERSIONS_SMALLER_THAN = 3;

@interface MemoryCacheItem ()

@property (nonatomic, assign) uint8_t version;

@end

@implementation MemoryCacheItem

static NSImage *_emptyImage = nil;

// MARK: - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        _version = MEMORY_CACHE_ITEM_VERSION;
        _name = @"";
        _fileDescriptor = [[PackedFileDescriptor alloc] init];
        _valueNames = @[];
        _objectType = ObjectTypesNormal;
    }
    return self;
}

// MARK: - Property Accessors

- (id<IPackedFileDescriptor>)fileDescriptor {
    _fileDescriptor.tag = self;
    return _fileDescriptor;
}

- (void)setFileDescriptor:(id<IPackedFileDescriptor>)fileDescriptor {
    _fileDescriptor = fileDescriptor;
}

- (void)setValueNames:(NSArray<NSString *> *)valueNames {
    if (valueNames == nil) {
        _valueNames = @[];
    } else {
        _valueNames = valueNames;
    }
}

- (NSString *)objdName {
    if (_objdName == nil) {
        return self.name;
    }
    return _objdName;
}

- (NSImage *)image {
    if (self.icon == nil) {
        if (_emptyImage == nil) {
            _emptyImage = [[NSImage alloc] initWithSize:NSMakeSize(1, 1)];
        }
        return _emptyImage;
    }
    return self.icon;
}

// MARK: - Object Classification Properties

- (BOOL)isAspiration {
    return [self.objdName.lowercaseString.stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] hasPrefix:@"aspiration"] &&
           self.objectType == ObjectTypesNormal;
}

- (BOOL)isToken {
    return self.isAspiration ||
           ([self.objdName.lowercaseString.stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] hasPrefix:@"token"] &&
            (self.objectType == ObjectTypesNormal || self.objectType == ObjectTypesMemory));
}

- (BOOL)isJobData {
    return [self.objdName.lowercaseString.stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] hasPrefix:@"jobdata"] &&
           self.objectType == ObjectTypesNormal;
}

- (BOOL)isMemory {
    return self.isToken || self.objectType == ObjectTypesMemory;
}

- (BOOL)isBadge {
    return [self.objdName.lowercaseString.stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] hasPrefix:@"token - badge"] &&
           self.objectType == ObjectTypesNormal && self.isToken;
}

- (BOOL)isSkill {
    return ([self.objdName.lowercaseString.stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] containsString:@"skill"]) &&
           self.objectType == ObjectTypesNormal && self.isToken;
}

- (BOOL)isInventory {
    return !self.isAspiration && !self.isToken && !self.isJobData && !self.isMemory && self.objectType == ObjectTypesNormal;
}

// MARK: - ICacheItem Protocol Implementation

- (void)load:(BinaryReader *)reader {
    @try {
        self.version = [reader readByte];
        if (self.version > MEMORY_CACHE_ITEM_VERSION) {
            @throw [[CacheException alloc] initWithMessage:@"Unknown CacheItem Version."
                                                  innerException:nil
                                                         version:self.version];
        }
        
        self.name = [reader readString];
        
        if (self.version >= 2) {
            self.objdName = [reader readString];
        } else {
            self.objdName = nil;
        }
        
        if (self.version >= 3) {
            uint16_t count = [reader readUInt16];
            NSMutableArray *valueNames = [[NSMutableArray alloc] initWithCapacity:count];
            for (int i = 0; i < count; i++) {
                [valueNames addObject:[reader readString]];
            }
            self.valueNames = [valueNames copy];
        } else {
            self.valueNames = @[];
        }
        
        self.objectType = (ObjectTypes)[reader readUInt16];
        
        PackedFileDescriptor *pfd = [[PackedFileDescriptor alloc] init];
        pfd.type = [reader readUInt32];
        pfd.group = [reader readUInt32];
        pfd.longInstance = [reader readUInt64];
        self.fileDescriptor = pfd;
        
        self.guid = [reader readUInt32];
        
        int32_t size = [reader readInt32];
        if (size == 0) {
            self.icon = nil;
        } else {
            NSData *imageData = [reader readBytes:size];
            self.icon = [[NSImage alloc] initWithData:imageData];
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Error loading MemoryCacheItem: %@", exception.reason);
        @throw exception;
    }
}

- (void)save:(BinaryWriter *)writer {
    @try {
        self.version = MEMORY_CACHE_ITEM_VERSION;
        [writer writeByte:self.version];
        [writer writeString:self.name];
        [writer writeString:self.objdName ?: @""];
        [writer writeUInt16:(uint16_t)self.valueNames.count];
        for (NSString *valueName in self.valueNames) {
            [writer writeString:valueName];
        }
        [writer writeUInt16:(uint16_t)self.objectType];
        [writer writeUInt32:self.fileDescriptor.type];
        [writer writeUInt32:self.fileDescriptor.group];
        [writer writeUInt64:self.fileDescriptor.longInstance];
        [writer writeUInt32:self.guid];
        
        if (self.icon == nil) {
            [writer writeInt32:0];
        } else {
            // Convert NSImage to PNG data
            NSData *imageData = [self.icon TIFFRepresentation];
            NSBitmapImageRep *bitmapRep = [NSBitmapImageRep imageRepWithData:imageData];
            NSData *pngData = [bitmapRep representationUsingType:NSBitmapImageFileTypePNG properties:@{}];
            
            [writer writeInt32:(int32_t)pngData.length];
            [writer writeData:pngData];
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Error saving MemoryCacheItem: %@", exception.reason);
        @throw exception;
    }
}

// MARK: - String Representation

- (NSString *)description {
    return [NSString stringWithFormat:@"name=%@", self.name];
}

// MARK: - Memory Management

- (void)dealloc {
    // ARC handles memory management automatically
}

@end
