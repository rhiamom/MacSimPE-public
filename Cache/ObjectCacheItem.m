//
//  ObjectCacheItem.m
//  MacSimpe
//
//  Created by Catherine Gramze on 8/29/25.
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

#import "ObjectCacheItem.h"
#import "BinaryReader.h"
#import "BinaryWriter.h"
#import "MemoryStream.h"
#import "PackedFileDescriptor.h"
#import "CacheException.h"
#import "Helper.h"
#import "Localization.h"

// MARK: - Constants

const uint8_t OBJECT_CACHE_ITEM_VERSION = 4;

// MARK: - ObjectCacheItem Implementation

@implementation ObjectCacheItem {
    uint8_t _version;
    NSString *_name;
    NSString *_modelName;
    id<IPackedFileDescriptor> _pfd;
    uint32_t _localGroup;
    NSImage *_thumbnail;
    ObjectTypes _objectType;
    NSString *_objectName;
    uint32_t _objectFunctionSort;
    BOOL _useable;
    ObjectClass _objectClass;
    id _tag;
}

// MARK: - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        _version = OBJECT_CACHE_ITEM_VERSION;
        _name = @"";
        _modelName = @"";
        _objectName = @"";
        _useable = YES;
        _pfd = [[PackedFileDescriptor alloc] init];
    }
    return self;
}

// MARK: - Properties

- (id)tag {
    return _tag;
}

- (void)setTag:(id)tag {
    _tag = tag;
}

- (ObjectCacheItemVersions)objectVersion {
    if (_version == (uint8_t)ObjectCacheItemVersionsClassicOW) {
        return ObjectCacheItemVersionsClassicOW;
    }
    if (_version == (uint8_t)ObjectCacheItemVersionsDockableOW) {
        return ObjectCacheItemVersionsDockableOW;
    }
    if (_version > OBJECT_CACHE_ITEM_VERSION) {
        return ObjectCacheItemVersionsUnsupported;
    }
    return ObjectCacheItemVersionsOutdated;
}

- (id<IPackedFileDescriptor>)fileDescriptor {
    _pfd.tag = self;
    return _pfd;
}

- (void)setFileDescriptor:(id<IPackedFileDescriptor>)fileDescriptor {
    _pfd = fileDescriptor;
}

- (ObjectTypes)objectType {
    return _objectType;
}

- (void)setObjectType:(ObjectTypes)objectType {
    _objectType = objectType;
}

- (ObjectClass)objectClass {
    return _objectClass;
}

- (void)setObjectClass:(ObjectClass)objectClass {
    _objectClass = objectClass;
}

- (uint32_t)objectFunctionSort {
    return _objectFunctionSort;
}

- (void)setObjectFunctionSort:(uint32_t)objectFunctionSort {
    _objectFunctionSort = objectFunctionSort;
}

- (uint32_t)localGroup {
    return _localGroup;
}

- (void)setLocalGroup:(uint32_t)localGroup {
    _localGroup = localGroup;
}

- (NSString *)name {
    return _name;
}

- (void)setName:(NSString *)name {
    _name = [name copy];
}

- (NSString *)objectFileName {
    return _objectName;
}

- (void)setObjectFileName:(NSString *)objectFileName {
    _objectName = [objectFileName copy];
}

- (BOOL)useable {
    return _useable;
}

- (void)setUseable:(BOOL)useable {
    _useable = useable;
}

- (NSString *)modelName {
    return _modelName;
}

- (void)setModelName:(NSString *)modelName {
    _modelName = [modelName copy];
}

- (NSImage *)thumbnail {
    return _thumbnail;
}

- (void)setThumbnail:(NSImage *)thumbnail {
    _thumbnail = thumbnail;
}

- (NSArray<NSArray<NSString *> *> *)objectCategory {
    return [[self class] getCategory:self.objectVersion
                             subsort:(ObjFunctionSubSort)self.objectFunctionSort
                                type:self.objectType
                         objectClass:self.objectClass];
}

// MARK: - Category Methods

+ (NSArray<NSArray<NSString *> *> *)getCategory:(ObjectCacheItemVersions)version
                                        subsort:(ObjFunctionSubSort)subsort
                                           type:(ObjectTypes)type {
    return [self getCategory:version subsort:subsort type:type objectClass:ObjectClassObject];
}

+ (NSArray<NSArray<NSString *> *> *)getCategory:(ObjectCacheItemVersions)version
                                        subsort:(ObjFunctionSubSort)subsort
                                           type:(ObjectTypes)type
                                    objectClass:(ObjectClass)objectClass {
    uint32_t ofss = (uint32_t)subsort;
    NSMutableArray<NSArray<NSString *> *> *result = nil;
    
    if (version == ObjectCacheItemVersionsClassicOW) {
        NSMutableArray *list = [[NSMutableArray alloc] init];
        
        // Process all ObjFunctionSortBits enum values
        for (int i = 0; i <= 31; i++) { // Check all possible bit positions
            uint32_t bitValue = 1U << i;
            if ((ofss & bitValue) != 0) {
                // Convert bit position back to enum for localization
                ObjFunctionSortBits sortBit = (ObjFunctionSortBits)i;
                NSString *key = [NSString stringWithFormat:@"SimPe.Data.ObjFunctionSortBits.%d", (int)sortBit];
                NSString *localizedString = [Localization getString:key];
                [list addObject:@[localizedString]];
            }
        }
        
        result = [[NSMutableArray alloc] initWithCapacity:list.count];
        for (NSArray *item in list) {
            [result addObject:item];
        }
    } else if (version == ObjectCacheItemVersionsDockableOW) {
        if (objectClass == ObjectClassXObject) {
            XObjFunctionSubSort fss = (XObjFunctionSubSort)subsort;
            NSString *key = [NSString stringWithFormat:@"SimPe.Data.XObjFunctionSubSort.%d", (int)fss];
            NSString *localizedString = [Localization getString:key];
            NSArray *parts = [localizedString componentsSeparatedByString:@" / "];
            
            if (parts.count >= 2) {
                result = [NSMutableArray arrayWithArray:@[@[[Localization getString:@"XObject"], parts[0], parts[1]]]];
            } else if (parts.count == 1) {
                result = [NSMutableArray arrayWithArray:@[@[[Localization getString:@"XObject"], parts[0]]]];
            }
        } else {
            ObjFunctionSubSort fss = subsort;
            uint32_t upper = (ofss >> 8) & 0xfff;
            uint32_t lower = ofss & 0xff;
            
            NSMutableArray *list = [[NSMutableArray alloc] init];
            
            // Process all ObjFunctionSortBits enum values for upper bits
            for (int i = 0; i <= 31; i++) {
                uint32_t bitValue = 1U << i;
                if ((upper & bitValue) != 0) {
                    BOOL added = NO;
                    
                    // Check lower 8 bits
                    for (int j = 0; j < 8; j++) {
                        uint32_t lowerBit = 1U << j;
                        if ((lower & lowerBit) != 0) {
                            ObjFunctionSubSort mss = (ObjFunctionSubSort)(((bitValue & 0xfff) << 8) | (lowerBit & 0xff));
                            NSString *key = [NSString stringWithFormat:@"SimPe.Data.ObjFunctionSubSort.%d", (int)mss];
                            NSString *localizedString = [Localization getString:key];
                            NSArray *parts = [localizedString componentsSeparatedByString:@" / "];
                            
                            if (parts.count >= 2) {
                                [list addObject:@[parts[0], parts[1]]];
                                added = YES;
                            } else if (parts.count == 1) {
                                ObjFunctionSortBits sortBit = (ObjFunctionSortBits)i;
                                NSString *sortKey = [NSString stringWithFormat:@"SimPe.Data.ObjFunctionSortBits.%d", (int)sortBit];
                                NSString *sortString = [Localization getString:sortKey];
                                [list addObject:@[sortString]];
                                added = YES;
                            }
                        }
                    }
                    
                    if (!added) {
                        ObjFunctionSortBits sortBit = (ObjFunctionSortBits)i;
                        NSString *sortKey = [NSString stringWithFormat:@"SimPe.Data.ObjFunctionSortBits.%d", (int)sortBit];
                        NSString *sortString = [Localization getString:sortKey];
                        [list addObject:@[sortString]];
                    }
                }
            }
            
            result = [[NSMutableArray alloc] initWithCapacity:list.count];
            for (NSArray *item in list) {
                [result addObject:item];
            }
        }
    }
    
    // Handle non-normal object types
    if (type != ObjectTypesNormal) {
        NSMutableArray *list = [[NSMutableArray alloc] init];
        if (result != nil) {
            [list addObjectsFromArray:result];
        }
        
        NSString *typeKey = [NSString stringWithFormat:@"SimPe.Data.ObjectTypes.%d", (int)type];
        NSString *typeString = [Localization getString:typeKey];
        [list addObject:@[[Localization getString:@"Other"], typeString]];
        
        result = list;
    }
    
    // Return default if no result
    if (result == nil || result.count == 0) {
        result = [NSMutableArray arrayWithArray:@[@[[Localization getString:@"Unknown"]]]];
    }
    
    return result;
}

// MARK: - Description

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ (0x%@)", self.name, [Helper hexString:self.localGroup]];
}

// MARK: - ICacheItem Protocol

- (void)load:(BinaryReader *)reader {
    _version = [reader readByte];
    if (_version > OBJECT_CACHE_ITEM_VERSION) {
        [CacheException raiseWithMessage:@"Unknown CacheItem Version."
                                filename:nil
                                 version:_version];
    }
    
    _name = [[reader readString] copy];
    _modelName = [[reader readString] copy];
    
    _pfd = [[PackedFileDescriptor alloc] init];
    _pfd.type = [reader readUInt32];
    _pfd.group = [reader readUInt32];
    _localGroup = [reader readUInt32];
    _pfd.longInstance = [reader readUInt64];
    
    int32_t size = [reader readInt32];
    if (size == 0) {
        _thumbnail = nil;
    } else {
        NSData *data = [reader readBytes:size];
        _thumbnail = [[NSImage alloc] initWithData:data];
    }
    
    _objectType = (ObjectTypes)[reader readUInt16];
    
    if (_version >= 4) {
        _objectFunctionSort = [reader readUInt32];
    } else {
        _objectFunctionSort = (uint32_t)[reader readInt16];
    }
    
    if (_version >= 2) {
        _objectName = [[reader readString] copy];
        _useable = [reader readBoolean];
    } else {
        _objectName = [_modelName copy];
        _useable = YES;
    }
    
    if (_version >= 3) {
        _objectClass = (ObjectClass)[reader readByte];
    } else {
        _objectClass = ObjectClassObject;
    }
}

- (void)save:(BinaryWriter *)writer {
    _version = OBJECT_CACHE_ITEM_VERSION;
    [writer writeUInt8:_version];
    [writer writeString:_name];
    [writer writeString:_modelName];
    [writer writeUInt32:_pfd.type];
    [writer writeUInt32:_pfd.group];
    [writer writeUInt32:_localGroup];
    [writer writeUInt64:_pfd.longInstance];
    
    if (_thumbnail == nil) {
        [writer writeInt32:0];
    } else {
        @try {
            NSData *imageData = [_thumbnail TIFFRepresentation];
            // Convert to BMP format using NSBitmapImageRep
            NSBitmapImageRep *bitmapRep = [NSBitmapImageRep imageRepWithData:imageData];
            NSData *bmpData = [bitmapRep representationUsingType:NSBitmapImageFileTypeBMP properties:@{}];
            
            if (bmpData != nil) {
                [writer writeInt32:(int32_t)bmpData.length];
                [writer writeData:bmpData];
            } else {
                [writer writeInt32:0];
            }
        } @catch (NSException *exception) {
            [writer writeInt32:0];
        }
    }
    
    [writer writeUInt16:(uint16_t)_objectType];
    [writer writeUInt32:_objectFunctionSort];
    [writer writeString:_objectName];
    [writer writeBoolean:_useable];
    [writer writeUInt8:(uint8_t)_objectClass];
}

- (uint8_t)version {
    return _version;
}

@end
