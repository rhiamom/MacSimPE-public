//
//  PackageCacheItem.m
//  MacSimpe
//
//  Created by Catherine Gramze on 9/23/25.
//
// ***************************************************************************
// *   Copyright (C) 2005 by Ambertation                                     *
// *   quaxi@ambertation.de                                                  *
// *                                                                         *
// *   Objective-C translation Copyright (C) 2025                            *
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

#import "PackageCacheItem.h"
#import "BinaryReader.h"
#import "BinaryWriter.h"
#import "CacheException.h"

// MARK: - PackageState Implementation

@implementation PackageState

- (instancetype)initWithUid:(uint32_t)uid state:(TriState)state info:(NSString *)info {
    self = [super init];
    if (self) {
        self.uid = uid;
        self.state = state;
        self.info = info;
        self.data = @[];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.state = TriStateNull;
        self.info = @"";
        self.data = @[];
        self.uid = 0;
    }
    return self;
}

- (void)load:(BinaryReader *)reader {
    self.state = (TriState)[reader readByte];
    self.uid = [reader readUInt32];
    self.info = [reader readString];
    
    uint8_t count = [reader readByte];
    NSMutableArray<NSNumber *> *dataArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count; i++) {
        [dataArray addObject:@([reader readUInt32])];
    }
    self.data = [dataArray copy];
}

- (void)save:(BinaryWriter *)writer {
    [writer writeByte:(uint8_t)self.state];
    [writer writeUInt32:self.uid];
    [writer writeString:self.info];
    
    if (self.data == nil) {
        [writer writeByte:0];
    } else {
        uint8_t count = (uint8_t)[self.data count];
        [writer writeByte:count];
        for (NSNumber *num in self.data) {
            [writer writeUInt32:[num unsignedIntValue]];
        }
    }
}

@end

// MARK: - PackageStates Implementation

@implementation PackageStates

- (PackageState *)objectAtIndex:(NSUInteger)index {
    return [super objectAtIndex:index];
}

- (PackageState *)objectAtUnsignedIndex:(uint32_t)index {
    return [super objectAtIndex:index];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(PackageState *)object {
    [super replaceObjectAtIndex:index withObject:object];
}

- (void)replaceObjectAtUnsignedIndex:(uint32_t)index withObject:(PackageState *)object {
    [super replaceObjectAtIndex:index withObject:object];
}

- (NSInteger)addPackageState:(PackageState *)item {
    [self addObject:item];
    return [self count] - 1;
}

- (void)insertPackageState:(PackageState *)item atIndex:(NSUInteger)index {
    [self insertObject:item atIndex:index];
}

- (void)removePackageState:(PackageState *)item {
    [self removeObject:item];
}

- (BOOL)containsPackageState:(PackageState *)item {
    return [self containsObject:item];
}

- (NSInteger)length {
    return [self count];
}

- (id)clone {
    PackageStates *clonedStates = [[PackageStates alloc] init];
    for (PackageState *state in self) {
        [clonedStates addPackageState:state];
    }
    return clonedStates;
}

@end

// MARK: - PackageCacheItem Implementation

@implementation PackageCacheItem {
    uint8_t _version;
}

+ (uint8_t)VERSION {
    return 1;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _version = [[self class] VERSION];
        _name = @"";
        _guids = @[];
        _type = PackageTypeUndefined;
        _states = [[PackageStates alloc] init];
        _enabled = NO;
        _thumbnail = nil;
    }
    return self;
}

- (uint8_t)version {
    return _version;
}

- (NSInteger)stateCount {
    return [self.states count];
}

- (nullable PackageState *)findState:(uint32_t)uid create:(BOOL)create {
    for (PackageState *ps in self.states) {
        if (ps.uid == uid) {
            return ps;
        }
    }
    
    if (create) {
        PackageState *ps = [[PackageState alloc] init];
        ps.uid = uid;
        [self.states addPackageState:ps];
        return ps;
    }
    
    return nil;
}

- (void)load:(BinaryReader *)reader {
    [self.states removeAllObjects];
    
    _version = [reader readByte];
    if (_version > [[self class] VERSION]) {
        @throw [[CacheException alloc] initWithMessage:@"Unknown CacheItem Version."
                                              filename:nil
                                               version:_version];
    }
    
    self.name = [reader readString];
    self.type = (PackageType)[reader readUInt32];
    self.enabled = [reader readBoolean];
    
    // Read GUIDs
    uint8_t guidCount = [reader readByte];
    NSMutableArray<NSNumber *> *guidsArray = [NSMutableArray arrayWithCapacity:guidCount];
    for (int i = 0; i < guidCount; i++) {
        [guidsArray addObject:@([reader readUInt32])];
    }
    self.guids = [guidsArray copy];
    
    // Read States
    uint8_t stateCount = [reader readByte];
    for (int i = 0; i < stateCount; i++) {
        PackageState *ps = [[PackageState alloc] init];
        [ps load:reader];
        [self.states addPackageState:ps];
    }
    
    // Read thumbnail
    int32_t size = [reader readInt32];
    if (size == 0) {
        self.thumbnail = nil;
    } else {
        NSData *imageData = [reader readBytes:size];
        self.thumbnail = [[NSImage alloc] initWithData:imageData];
    }
}

- (void)save:(BinaryWriter *)writer {
    _version = [[self class] VERSION];
    [writer writeByte:_version];
    [writer writeString:self.name];
    [writer writeUInt32:(uint32_t)self.type];
    [writer writeBoolean:self.enabled];
    
    // Write GUIDs
    [writer writeByte:(uint8_t)[self.guids count]];
    for (NSNumber *guid in self.guids) {
        [writer writeUInt32:[guid unsignedIntValue]];
    }
    
    // Write States
    uint8_t stateCount = (uint8_t)[self.states count];
    [writer writeByte:stateCount];
    for (int i = 0; i < stateCount; i++) {
        [self.states[i] save:writer];
    }
    
    // Write thumbnail
    if (self.thumbnail == nil) {
        [writer writeInt32:0];
    } else {
        // Convert NSImage to PNG data
        CGImageRef cgImage = [self.thumbnail CGImageForProposedRect:NULL context:nil hints:nil];
        NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithCGImage:cgImage];
        NSData *pngData = [bitmapRep representationUsingType:NSBitmapImageFileTypePNG properties:@{}];
        
        [writer writeInt32:(int32_t)[pngData length]];
        [writer writeData:pngData];
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"name=%@", self.name];
}

@end
