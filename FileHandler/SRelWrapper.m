//
//  SRelWrapper.m
//  MacSimpe
//
//  Created by Catherine Gramze on 9/17/25.
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

#import "SRelWrapper.h"
#import "BinaryReader.h"
#import "BinaryWriter.h"
#import "AbstractWrapperInfo.h"
#import "IPackedFileUI.h"

@implementation RelationshipFlags

#pragma mark - Initialization

- (instancetype)initWithFlags:(uint16_t)flags {
    return [super initWithValue:flags];
}

#pragma mark - Relationship State Properties

- (BOOL)isEnemy {
    return [self getBit:(uint8_t)RelationshipStateBitsEnemy];
}

- (void)setIsEnemy:(BOOL)isEnemy {
    [self setBit:(uint8_t)RelationshipStateBitsEnemy value:isEnemy];
}

- (BOOL)isFriend {
    return [self getBit:(uint8_t)RelationshipStateBitsFriends];
}

- (void)setIsFriend:(BOOL)isFriend {
    [self setBit:(uint8_t)RelationshipStateBitsFriends value:isFriend];
}

- (BOOL)isBuddie {
    return [self getBit:(uint8_t)RelationshipStateBitsBuddies];
}

- (void)setIsBuddie:(BOOL)isBuddie {
    [self setBit:(uint8_t)RelationshipStateBitsBuddies value:isBuddie];
}

- (BOOL)hasCrush {
    return [self getBit:(uint8_t)RelationshipStateBitsCrush];
}

- (void)setHasCrush:(BOOL)hasCrush {
    [self setBit:(uint8_t)RelationshipStateBitsCrush value:hasCrush];
}

- (BOOL)inLove {
    return [self getBit:(uint8_t)RelationshipStateBitsLove];
}

- (void)setInLove:(BOOL)inLove {
    [self setBit:(uint8_t)RelationshipStateBitsLove value:inLove];
}

- (BOOL)goSteady {
    return [self getBit:(uint8_t)RelationshipStateBitsSteady];
}

- (void)setGoSteady:(BOOL)goSteady {
    [self setBit:(uint8_t)RelationshipStateBitsSteady value:goSteady];
}

- (BOOL)isEngaged {
    return [self getBit:(uint8_t)RelationshipStateBitsEngaged];
}

- (void)setIsEngaged:(BOOL)isEngaged {
    [self setBit:(uint8_t)RelationshipStateBitsEngaged value:isEngaged];
}

- (BOOL)isMarried {
    return [self getBit:(uint8_t)RelationshipStateBitsMarried];
}

- (void)setIsMarried:(BOOL)isMarried {
    [self setBit:(uint8_t)RelationshipStateBitsMarried value:isMarried];
}

- (BOOL)isFamilyMember {
    return [self getBit:(uint8_t)RelationshipStateBitsFamily];
}

- (void)setIsFamilyMember:(BOOL)isFamilyMember {
    [self setBit:(uint8_t)RelationshipStateBitsFamily value:isFamilyMember];
}

- (BOOL)isKnown {
    return [self getBit:(uint8_t)RelationshipStateBitsKnown];
}

- (void)setIsKnown:(BOOL)isKnown {
    [self setBit:(uint8_t)RelationshipStateBitsKnown value:isKnown];
}

@end

@implementation UIFlags2

#pragma mark - Initialization

- (instancetype)initWithFlags:(uint16_t)flags {
    return [super initWithValue:flags];
}

#pragma mark - UI State Properties

- (BOOL)isBFF {
    return [self getBit:(uint8_t)UIFlags2NamesBestFriendForever];
}

- (void)setIsBFF:(BOOL)isBFF {
    [self setBit:(uint8_t)UIFlags2NamesBestFriendForever value:isBFF];
}

@end

@interface SRel ()

@property (nonatomic, strong) NSMutableArray<NSNumber *> *values;
@property (nonatomic, assign) uint32_t *reserved;
@property (nonatomic, strong) RelationshipFlags *flags;
@property (nonatomic, strong) UIFlags2 *flags2;

@end

@implementation SRel

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        // Allocate memory for the reserved array first
        _reserved = calloc(3, sizeof(uint32_t));
        _reserved[0] = 0x00000002;
        _reserved[1] = 0;
        _reserved[2] = 0;
        
        _values = [[NSMutableArray alloc] initWithCapacity:4];
        // Initialize with at least 4 elements
        for (int i = 0; i < 4; i++) {
            [_values addObject:@(0)];
        }
        _flags = [[RelationshipFlags alloc] initWithFlags:(uint16_t)(1 << (uint8_t)RelationshipStateBitsKnown)];
        _flags2 = [[UIFlags2 alloc] initWithFlags:0];
    }
    return self;
}

#pragma mark - Property Implementations

- (int32_t)shortterm {
    return [self getValueAtSlot:0];
}

- (void)setShortterm:(int32_t)shortterm {
    [self putValue:shortterm atSlot:0];
}

- (RelationshipFlags *)relationState {
    return _flags;
}

- (int32_t)longterm {
    return [self getValueAtSlot:2];
}

- (void)setLongterm:(int32_t)longterm {
    [self putValue:longterm atSlot:2];
}

- (RelationshipTypes)familyRelation {
    return (RelationshipTypes)[self getValueAtSlot:3];
}

- (void)setFamilyRelation:(RelationshipTypes)familyRelation {
    [self putValue:(int32_t)familyRelation atSlot:3];
}

- (UIFlags2 *)relationState2 {
    return (_values.count > 9) ? _flags2 : nil;
}

#pragma mark - Helper Methods

- (void)putValue:(int32_t)val atSlot:(NSInteger)slot {
    // Expand array if needed
    while (_values.count <= slot) {
        [_values addObject:@(0)];
    }
    _values[slot] = @(val);
}

- (int32_t)getValueAtSlot:(NSInteger)slot {
    if (_values.count > slot) {
        return [_values[slot] intValue];
    } else {
        return 0;
    }
}

#pragma mark - AbstractWrapper Methods

- (id<IWrapperInfo>)createWrapperInfo {
    return [[AbstractWrapperInfo alloc] initWithName:@"Sim Relation Wrapper"
                                              author:@"Quaxi"
                                         description:@"This File Contains the Relationship states for two Sims."
                                             version:6];
}

- (id<IPackedFileUI>)createDefaultUIHandler {
    // Return the appropriate UI handler for SRel files
    // This would need to be implemented based on your UI architecture
    return nil;
}

- (void)unserialize:(BinaryReader *)reader {
    if (reader.baseStream.length <= 0) {
        return;
    }
    
    _reserved[0] = [reader readUInt32];  // unknown
    uint32_t stored = [reader readUInt32];
    
    _values = [[NSMutableArray alloc] initWithCapacity:MAX(3, stored)];
    for (uint32_t i = 0; i < stored; i++) {
        [_values addObject:@([reader readInt32])];
    }
    
    // Set some special Attributes
    if (_values.count > 1) {
        _flags.value = (uint16_t)[_values[1] intValue];
    }
    if (_values.count > 9) {
        _flags2.value = (uint16_t)[_values[9] intValue];
    }
}

- (void)serialize:(BinaryWriter *)writer {
    // Set some special Attributes
    if (_values.count > 1) {
        int32_t oldValue = [_values[1] intValue];
        int32_t newValue = (oldValue & 0xffff0000) | _flags.value;
        _values[1] = @(newValue);
    }
    if (_values.count > 9) {
        int32_t oldValue = [_values[9] intValue];
        int32_t newValue = (oldValue & 0xffff0000) | _flags2.value;
        _values[9] = @(newValue);
    }
    
    // Write to file
    [writer writeUInt32:_reserved[0]];
    [writer writeUInt32:(uint32_t)_values.count];
    for (NSNumber *value in _values) {
        [writer writeInt32:[value intValue]];
    }
}

#pragma mark - IFileWrapper Protocol

- (NSData *)fileSignature {
    return [NSData data]; // SRel files don't have a specific signature
}

- (NSArray<NSNumber *> *)assignableTypes {
    return @[@([MetaData RELATION_FILE])];
}

- (void)dealloc {
    if (_reserved) {
        free(_reserved);
        _reserved = NULL;
    }
}
@end
