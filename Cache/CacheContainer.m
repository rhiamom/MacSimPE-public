//
//  CacheContainer.m
//  MacSimpe
//
//  Created by Catherine Gramze on 8/28/25.
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

#import "CacheContainer.h"
#import "BinaryReader.h"
#import "BinaryWriter.h"
#import "CacheItems.h"
#import "ObjectCacheItem.h"
#import "MmatCacheItem.h"
#import "RcolCacheItem.h"
#import "WantCacheItem.h"
#import "MemoryCacheItem.h"
#import "PackageCacheItem.h"

// MARK: - Constants

const uint8_t CACHE_CONTAINER_VERSION = 1;

@interface CacheContainer ()
@property (nonatomic, assign) uint8_t version;
@property (nonatomic, assign) ContainerType type;
@property (nonatomic, assign) ContainerValid validState;
@property (nonatomic, strong) CacheItems *items;
@end

@implementation CacheContainer

// MARK: - Initialization

- (instancetype)initWithType:(ContainerType)type {
    self = [super init];
    if (self) {
        _version = CACHE_CONTAINER_VERSION;
        _type = type;
        _added = [[NSDate date] timeIntervalSince1970];
        _fileName = @"";
        _validState = ContainerValidYes;
        _items = [[CacheItems alloc] init];
    }
    return self;
}

// MARK: - Properties

- (BOOL)valid {
    return (self.validState == ContainerValidYes);
}

- (void)setFileName:(NSString *)fileName {
    _fileName = [[fileName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString];
}

// MARK: - File Operations

- (void)load:(BinaryReader *)reader {
    self.validState = ContainerValidFileNotFound;
    [self.items removeAllObjects];
    
    int32_t offset = [reader readInt32];
    self.version = [reader readUInt8];
    self.type = (ContainerType)[reader readUInt8];
    int32_t count = [reader readInt32];
    
    long long pos = [reader position];
    @try {
        if (self.version <= CACHE_CONTAINER_VERSION) {
            [reader seekToPosition:offset];
            
            // Read file time and convert to NSTimeInterval
            int64_t fileTime = [reader readInt64];
            self.added = [self timeIntervalFromFileTime:fileTime];
            self.fileName = [reader readString];
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:self.fileName]) {
                NSError *error;
                NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:self.fileName error:&error];
                if (!error) {
                    NSDate *modificationDate = attributes[NSFileModificationDate];
                    NSTimeInterval modTime = [modificationDate timeIntervalSince1970];
                    if (modTime <= self.added) {
                        self.validState = ContainerValidYes;
                    } else {
                        self.validState = ContainerValidModified;
                    }
                }
            }
            
            if (self.validState == ContainerValidYes) {
                switch (self.type) {
                    case ContainerTypeObject: {
                        for (int32_t i = 0; i < count; i++) {
                            ObjectCacheItem *oci = [[ObjectCacheItem alloc] init];
                            [oci load:reader];
                            [self.items addObject:oci];
                        }
                        break;
                    }
                    case ContainerTypeMaterialOverride: {
                        for (int32_t i = 0; i < count; i++) {
                            MmatCacheItem *oci = [[MmatCacheItem alloc] init];
                            [oci load:reader];
                            [self.items addObject:oci];
                        }
                        break;
                    }
                    case ContainerTypeRcol: {
                        for (int32_t i = 0; i < count; i++) {
                            RcolCacheItem *oci = [[RcolCacheItem alloc] init];
                            [oci load:reader];
                            [self.items addObject:oci];
                        }
                        break;
                    }
                    case ContainerTypeWant: {
                        for (int32_t i = 0; i < count; i++) {
                            WantCacheItem *oci = [[WantCacheItem alloc] init];
                            [oci load:reader];
                            [self.items addObject:oci];
                        }
                        break;
                    }
                    case ContainerTypeMemory: {
                        for (int32_t i = 0; i < count; i++) {
                            MemoryCacheItem *oci = [[MemoryCacheItem alloc] init];
                            [oci load:reader];
                            oci.parentCacheContainer = self;
                            if (oci.version >= MEMORY_CACHE_ITEM_DISCARD_VERSIONS_SMALLER_THAN) {
                                [self.items addObject:oci];
                            }
                        }
                        break;
                    }
                    case ContainerTypePackage: {
                        for (int32_t i = 0; i < count; i++) {
                            PackageCacheItem *oci = [[PackageCacheItem alloc] init];
                            [oci load:reader];
                            [self.items addObject:oci];
                        }
                        break;
                    }
                    case ContainerTypeNone:
                        // No items to load for None type
                        break;
                }
            }
        } else {
            self.validState = ContainerValidUnknownVersion;
        }
    }
    @finally {
        [reader seekToPosition:pos];
    }
}

- (void)save:(BinaryWriter *)writer offset:(int32_t)offset {
    [writer writeInt32:offset];
    
    // Prewrite Phase
    if (offset == -1) {
        self.version = CACHE_CONTAINER_VERSION;
        [writer writeUInt8:self.version];
        [writer writeUInt8:(uint8_t)self.type];
        [writer writeInt32:(int32_t)self.items.count];
    } else {
        // Item writing Phase
        [writer seekToPosition:offset];
        [writer writeInt64:[self fileTimeFromTimeInterval:self.added]];
        [writer writeString:self.fileName];
        
        for (NSUInteger i = 0; i < self.items.count; i++) {
            id<ICacheItem> item = self.items[i];
            [item save:writer];
        }
    }
}

// MARK: - Helper Methods

- (NSTimeInterval)timeIntervalFromFileTime:(int64_t)fileTime {
    // Windows FILETIME epoch starts at January 1, 1601
    // Unix epoch starts at January 1, 1970
    // Difference is 11644473600 seconds
    const int64_t FILETIME_UNIX_DIFF = 11644473600LL;
    const int64_t FILETIME_TICKS_PER_SECOND = 10000000LL;
    
    return (double)(fileTime / FILETIME_TICKS_PER_SECOND - FILETIME_UNIX_DIFF);
}

- (int64_t)fileTimeFromTimeInterval:(NSTimeInterval)timeInterval {
    const int64_t FILETIME_UNIX_DIFF = 11644473600LL;
    const int64_t FILETIME_TICKS_PER_SECOND = 10000000LL;
    
    return (int64_t)((timeInterval + FILETIME_UNIX_DIFF) * FILETIME_TICKS_PER_SECOND);
}

// MARK: - Memory Management

- (void)dispose {
    if (self.items != nil) {
        for (id item in self.items) {
            if ([item respondsToSelector:@selector(dispose)]) {
                [item dispose];
            }
        }
        [self.items removeAllObjects];
    }
    self.items = nil;
}

- (void)dealloc {
    [self dispose];
}

@end
