//
//  ExtObjdWrapper.m
//  MacSimpe
//
//  Created by Catherine Gramze on 9/9/25.
//
// ***************************************************************************
// *   Copyright (C) 2005 by Peter L Jones                                   *
// *   pljones@users.sf.net                                                  *
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

#import "ExtObjdWrapper.h"
#import "BinaryReader.h"
#import "BinaryWriter.h"
#import "Helper.h"
#import "ObjdPropertyParser.h"
#import "AbstractWrapperInfo.h"
#import "MetaData.h"
#import "FileStream.h"
#import "Stream.h"

@interface ExtObjd ()
@property (nonatomic, strong) NSMutableData *filename;
@property (nonatomic, strong) NSMutableData *filename2;
@property (nonatomic, assign, readwrite) ObjdHealth ok;
@end

static ObjdPropertyParser *tpp = nil;

@implementation ExtObjd

// MARK: - Class Properties

+ (ObjdPropertyParser *)propertyParser {
    if (tpp == nil) {
        NSString *dataPath = [Helper simPeDataPath];
        NSString *xmlPath = [dataPath stringByAppendingPathComponent:@"objddefinition.xml"];
        tpp = [[ObjdPropertyParser alloc] initWithPath:xmlPath];
    }
    return tpp;
}

// MARK: - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        self.filename = [[NSMutableData alloc] initWithLength:0x40];
        self.filename2 = [[NSMutableData alloc] init];
        self.data = [[NSMutableArray alloc] initWithCapacity:0xdc];
        
        // Initialize data array with zeros
        for (int i = 0; i < 0xdc; i++) {
            [self.data addObject:@(0)];
        }
        
        self.guid = 0;
        self.proxyGuid = 0;
        self.originalGuid = 0;
        self.diagonalGuid = 0;
        self.gridAlignedGuid = 0;
        
        self.roomSort = [[ObjRoomSort alloc] initWithFlags:0];
        self.functionSort = [[ObjFunctionSort alloc] initWithFlags:0];
        
        self.type = ObjectTypesNormal;
        self.ok = ObjdHealthOk;
    }
    return self;
}

// MARK: - Properties

- (NSString *)fileName {
    return [Helper dataToString:self.filename];
}

- (void)setFileName:(NSString *)fileName {
    NSData *data = [Helper stringToBytes:fileName length:64];
    self.filename = [[Helper setLength:data length:64] mutableCopy];
}

- (ShelveDimension)shelveDimension {
    if ([self.data count] > 0x004F) {
        int16_t v = [[self.data objectAtIndex:0x004F] shortValue];
        if (v != 0x64 && v != 0x96 && v != 0 && v != 1 && v != 2) {
            return ShelveDimensionIndetermined;
        }
        return (ShelveDimension)v;
    }
    return ShelveDimensionBig;
}

- (void)setShelveDimension:(ShelveDimension)shelveDimension {
    if ([self.data count] > 0x004F) {
        [self.data setObject:@((int16_t)shelveDimension) atIndexedSubscript:0x004F];
    }
}

- (uint16_t)ctssInstance {
    if ([self.data count] > 0x29) {
        return (uint16_t)[[self.data objectAtIndex:0x29] shortValue];
    }
    return 0;
}

- (void)setCtssInstance:(uint16_t)ctssInstance {
    if ([self.data count] > 0x29) {
        [self.data setObject:@((int16_t)ctssInstance) atIndexedSubscript:0x29];
    }
}

- (ObjectTypes)type {
    if ([self.data count] > 0x09) {
        return (ObjectTypes)[[self.data objectAtIndex:0x09] shortValue];
    }
    return ObjectTypesNormal;
}

- (void)setType:(ObjectTypes)type {
    if ([self.data count] > 0x09) {
        [self.data setObject:@((int16_t)type) atIndexedSubscript:0x09];
    }
}

- (ObjFunctionSubSort)functionSubSort {
    if ([self.data count] > 0x5e) {
        uint32_t val = (uint32_t)(([[self.data objectAtIndex:0x5e] shortValue] & 0xff) |
                                  ((self.functionSort.value & 0xfff) << 8));
        return (ObjFunctionSubSort)val;
    }
    return 0;
}

- (void)setFunctionSubSort:(ObjFunctionSubSort)functionSubSort {
    if ([self.data count] > 0x5e) {
        uint32_t val = (uint32_t)functionSubSort;
        self.functionSort.value = (uint16_t)((val >> 8) & 0xfff);
        [self.data setObject:@((int16_t)(val & 0xff)) atIndexedSubscript:0x5e];
    }
}

- (int16_t)price {
    if ([self.data count] > 0x12) {
        return [[self.data objectAtIndex:0x12] shortValue];
    }
    return 0;
}

- (void)setPrice:(int16_t)price {
    if ([self.data count] > 0x12) {
        [self.data setObject:@(price) atIndexedSubscript:0x12];
    }
}

- (NSInteger)length {
    return (NSInteger)([self.data count] * 2 + 0x40);
}

// MARK: - Methods

- (void)updateFlags {
    if ([self.data count] > 0x28) {
        self.roomSort = [[ObjRoomSort alloc] initWithFlags:[[self.data objectAtIndex:0x27] shortValue]];
        self.functionSort = [[ObjFunctionSort alloc] initWithFlags:[[self.data objectAtIndex:0x28] shortValue]];
    }
}

// MARK: - AbstractWrapper Overrides

- (id<IPackedFileUI>)createDefaultUIHandler {
    // TODO: Return actual UI handler when ExtObjdForm is translated
    return nil;
}

- (id<IWrapperInfo>)createWrapperInfo {
    // TODO: Get actual icon when resource loading is implemented
    return [[AbstractWrapperInfo alloc] initWithName:@"Extended OBJD Wrapper"
                                              author:@"Quaxi, Peter L Jones"
                                         description:@"This file is used to set up the basic catalog properties of an Object. It also contains the unique ID for the Object (or part of the Object)."
                                             version:7
                                                icon:nil];
}

- (void)serialize:(BinaryWriter *)writer {
    const int MAX_VALUES = 0x6c;
    
    // Update flags in data array
    if ([self.data count] > 0x27) {
        [self.data setObject:@((int16_t)self.roomSort.value) atIndexedSubscript:0x27];
        [self.data setObject:@((int16_t)self.functionSort.value) atIndexedSubscript:0x28];
    }
    
    // Write filename
    [writer writeData:self.filename];
    
    // Write data array
    int ct = 0;
    for (NSNumber *number in self.data) {
        [writer writeInt16:[number shortValue]];
        ct++;
        if (ct >= MAX_VALUES) break;
    }
    
    // Pad with zeros if needed
    while (ct < MAX_VALUES) {
        [writer writeInt16:0];
        ct++;
    }
    
    // Write filename2 section
    NSString *flname = self.fileName;
    NSData *nameData = [Helper stringToBytes:flname length:0];
    [writer writeUInt32:(uint32_t)[nameData length]];
    [writer writeData:nameData];
    
    // Write special GUID fields at specific offsets
    if ([self length] > 0x5c + 4) {
        [writer.fileStream seekToOffset:0x5c origin:SeekOriginBegin];
        [writer writeUInt32:self.guid];
    }
    
    if ([self length] > 0x6A + 8) {
        [writer.fileStream seekToOffset:0x6A origin:SeekOriginBegin];
        [writer writeUInt32:self.diagonalGuid];
        [writer writeUInt32:self.gridAlignedGuid];
    }
    
    if ([self length] > 0x7a + 4) {
        [writer.fileStream seekToOffset:0x7a origin:SeekOriginBegin];
        [writer writeUInt32:self.proxyGuid];
    }
    
    if ([self length] > 0xcc + 4) {
        [writer.fileStream seekToOffset:0xcc origin:SeekOriginBegin];
        [writer writeUInt32:self.originalGuid];
    }
}

- (void)unserialize:(BinaryReader *)reader {
    self.ok = ObjdHealthOk;
    
    @try {
        [self unserializeNew:reader];
    }
    @catch (NSException *exception) {
        self.ok = ObjdHealthUnreadable;
        [reader.baseStream seekToOffset:0 origin:SeekOriginBegin];
        [self unserializeOld:reader];
    }
    
    // Read special GUID data at specific offsets
    if ([self length] > 0x5c + 4) {
        [reader.baseStream seekToOffset:0x5c origin:SeekOriginBegin];
        self.guid = [reader readUInt32];
    }
    
    if ([self length] > 0x6A + 8) {
        [reader.baseStream seekToOffset:0x6A origin:SeekOriginBegin];
        self.diagonalGuid = [reader readUInt32];
        self.gridAlignedGuid = [reader readUInt32];
    }
    
    if ([self length] > 0x7a + 4) {
        [reader.baseStream seekToOffset:0x7A origin:SeekOriginBegin];
        self.proxyGuid = [reader readUInt32];
    }
    
    if ([self length] > 0xcc + 4) {
        [reader.baseStream seekToOffset:0xcc origin:SeekOriginBegin];
        self.originalGuid = [reader readUInt32];
    }
    
    [self updateFlags];
}

- (void)unserializeNew:(BinaryReader *)reader {
    // Read filename
    self.filename = [[reader readBytes:0x40] mutableCopy];
    
    // Read data array
    NSInteger count = (NSInteger)(([reader.baseStream length] - 0x40) / 2);
    count = 0x6c;
    
    self.data = [[NSMutableArray alloc] initWithCapacity:count];
    for (int i = 0; i < count; i++) {
        [self.data addObject:@([reader readInt16])];
    }
    
    // Read filename2
    int32_t sz = [reader readInt32];
    self.filename2 = [[reader readBytes:sz] mutableCopy];
    
    // Check filename consistency
    if (![[Helper dataToString:self.filename2] isEqualToString:self.fileName]) {
        self.ok = ObjdHealthUnmatchingFilenames;
    }
    
    // Check file length
    if ([reader.baseStream position] != [reader.baseStream length]) {
        self.ok = ObjdHealthOverLength;
    }
}

- (void)unserializeOld:(BinaryReader *)reader {
    // Read filename
    self.filename = [[reader readBytes:0x40] mutableCopy];
    
    // Read data array
    NSInteger count = (NSInteger)(([reader.baseStream length] - 0x40) / 2);
    self.data = [[NSMutableArray alloc] initWithCapacity:count];
    
    for (int i = 0; i < count; i++) {
        @try {
            [self.data addObject:@([reader readInt16])];
        }
        @catch (NSException *exception) {
            @throw [NSException exceptionWithName:@"EndOfStreamException"
                                           reason:[NSString stringWithFormat:@"Reading Error in OBJd at %d.", i]
                                         userInfo:@{NSUnderlyingErrorKey: exception}];
        }
    }
}

// MARK: - IFileWrapper Protocol

- (NSArray<NSNumber *> *)assignableTypes {
    return @[@(0x4F424A44)];
}

- (NSData *)fileSignature {
    return [[NSData alloc] init];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"FileName=%@,GUID=0x%@,Type=%d",
            self.fileName, [Helper hexString:self.guid], (int)self.type];
}

// MARK: - IMultiplePackedFileWrapper Protocol

- (NSArray *)getConstructorArguments {
    return @[];
}

@end

// MARK: - ObjRoomSort Implementation

@implementation ObjRoomSort

- (instancetype)initWithFlags:(int16_t)flags {
    self = [super init];
    if (self) {
        self.value = (uint16_t)flags;
    }
    return self;
}

- (instancetype)initWithObject:(id)object {
    if ([object isKindOfClass:[NSNumber class]]) {
        return [self initWithFlags:[(NSNumber *)object shortValue]];
    }
    return [self initWithFlags:0];
}

// Room flag properties
- (BOOL)inBathroom {
    return [self getBit:ObjRoomSortBitsBathroom];
}

- (void)setInBathroom:(BOOL)inBathroom {
    [self setBit:ObjRoomSortBitsBathroom value:inBathroom];
}

- (BOOL)inBedroom {
    return [self getBit:ObjRoomSortBitsBedroom];
}

- (void)setInBedroom:(BOOL)inBedroom {
    [self setBit:ObjRoomSortBitsBedroom value:inBedroom];
}

- (BOOL)inDiningRoom {
    return [self getBit:ObjRoomSortBitsDiningRoom];
}

- (void)setInDiningRoom:(BOOL)inDiningRoom {
    [self setBit:ObjRoomSortBitsDiningRoom value:inDiningRoom];
}

- (BOOL)inKitchen {
    return [self getBit:ObjRoomSortBitsKitchen];
}

- (void)setInKitchen:(BOOL)inKitchen {
    [self setBit:ObjRoomSortBitsKitchen value:inKitchen];
}

- (BOOL)inLivingRoom {
    return [self getBit:ObjRoomSortBitsLivingRoom];
}

- (void)setInLivingRoom:(BOOL)inLivingRoom {
    [self setBit:ObjRoomSortBitsLivingRoom value:inLivingRoom];
}

- (BOOL)inMisc {
    return [self getBit:ObjRoomSortBitsMisc];
}

- (void)setInMisc:(BOOL)inMisc {
    [self setBit:ObjRoomSortBitsMisc value:inMisc];
}

- (BOOL)inOutside {
    return [self getBit:ObjRoomSortBitsOutside];
}

- (void)setInOutside:(BOOL)inOutside {
    [self setBit:ObjRoomSortBitsOutside value:inOutside];
}

- (BOOL)inStudy {
    return [self getBit:ObjRoomSortBitsStudy];
}

- (void)setInStudy:(BOOL)inStudy {
    [self setBit:ObjRoomSortBitsStudy value:inStudy];
}

- (BOOL)inKids {
    return [self getBit:ObjRoomSortBitsKids];
}

- (void)setInKids:(BOOL)inKids {
    [self setBit:ObjRoomSortBitsKids value:inKids];
}

// Bit manipulation helper methods
- (BOOL)getBit:(uint8_t)bit {
    return (self.value & (1 << bit)) != 0;
}

- (void)setBit:(uint8_t)bit value:(BOOL)value {
    if (value) {
        self.value |= (1 << bit);
    } else {
        self.value &= ~(1 << bit);
    }
}

@end

// MARK: - ObjFunctionSort Implementation

@implementation ObjFunctionSort

- (instancetype)initWithFlags:(int16_t)flags {
    self = [super init];
    if (self) {
        self.value = (uint16_t)flags;
    }
    return self;
}

- (instancetype)initWithObject:(id)object {
    if ([object isKindOfClass:[NSNumber class]]) {
        return [self initWithFlags:[(NSNumber *)object shortValue]];
    }
    return [self initWithFlags:0];
}

// Function flag properties
- (BOOL)inAppliances {
    return [self getBit:ObjFunctionSortBitsAppliances];
}

- (void)setInAppliances:(BOOL)inAppliances {
    [self setBit:ObjFunctionSortBitsAppliances value:inAppliances];
}

- (BOOL)inDecorative {
    return [self getBit:ObjFunctionSortBitsDecorative];
}

- (void)setInDecorative:(BOOL)inDecorative {
    [self setBit:ObjFunctionSortBitsDecorative value:inDecorative];
}

- (BOOL)inElectronics {
    return [self getBit:ObjFunctionSortBitsElectronics];
}

- (void)setInElectronics:(BOOL)inElectronics {
    [self setBit:ObjFunctionSortBitsElectronics value:inElectronics];
}

- (BOOL)inGeneral {
    return [self getBit:ObjFunctionSortBitsGeneral];
}

- (void)setInGeneral:(BOOL)inGeneral {
    [self setBit:ObjFunctionSortBitsGeneral value:inGeneral];
}

- (BOOL)inLighting {
    return [self getBit:ObjFunctionSortBitsLighting];
}

- (void)setInLighting:(BOOL)inLighting {
    [self setBit:ObjFunctionSortBitsLighting value:inLighting];
}

- (BOOL)inPlumbing {
    return [self getBit:ObjFunctionSortBitsPlumbing];
}

- (void)setInPlumbing:(BOOL)inPlumbing {
    [self setBit:ObjFunctionSortBitsPlumbing value:inPlumbing];
}

- (BOOL)inSeating {
    return [self getBit:ObjFunctionSortBitsSeating];
}

- (void)setInSeating:(BOOL)inSeating {
    [self setBit:ObjFunctionSortBitsSeating value:inSeating];
}

- (BOOL)inSurfaces {
    return [self getBit:ObjFunctionSortBitsSurfaces];
}

- (void)setInSurfaces:(BOOL)inSurfaces {
    [self setBit:ObjFunctionSortBitsSurfaces value:inSurfaces];
}

- (BOOL)inHobbies {
    return [self getBit:ObjFunctionSortBitsHobbies];
}

- (void)setInHobbies:(BOOL)inHobbies {
    [self setBit:ObjFunctionSortBitsHobbies value:inHobbies];
}

- (BOOL)inAspirationRewards {
    return [self getBit:ObjFunctionSortBitsAspirationRewards];
}

- (void)setInAspirationRewards:(BOOL)inAspirationRewards {
    [self setBit:ObjFunctionSortBitsAspirationRewards value:inAspirationRewards];
}

- (BOOL)inCareerRewards {
    return [self getBit:ObjFunctionSortBitsCareerRewards];
}

- (void)setInCareerRewards:(BOOL)inCareerRewards {
    [self setBit:ObjFunctionSortBitsCareerRewards value:inCareerRewards];
}

// Bit manipulation helper methods
- (BOOL)getBit:(uint8_t)bit {
    return (self.value & (1 << bit)) != 0;
}

- (void)setBit:(uint8_t)bit value:(BOOL)value {
    if (value) {
        self.value |= (1 << bit);
    } else {
        self.value &= ~(1 << bit);
    }
}

@end
