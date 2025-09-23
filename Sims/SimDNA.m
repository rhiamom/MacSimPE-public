//
//  SimDNA.m
//  MacSimpe
//
//  Created by Catherine Gramze on 9/19/25.
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

#import "SimDNA.h"
#import "CpfItem.h"
#import "MetaData.h"
#import "AbstractWrapperInfo.h"

// MARK: - Gene Implementation

@interface Gene ()
@property (nonatomic, weak) Cpf *dna;
@property (nonatomic, assign) uint32_t b;
@end

@implementation Gene

// MARK: - Initialization

- (instancetype)initWithDna:(Cpf *)dna base:(uint32_t)b {
    self = [super init];
    if (self) {
        self.dna = dna;
        self.b = b;
    }
    return self;
}

// MARK: - Private Methods

- (NSString *)getName:(uint32_t)line {
    line += self.b;
    uint32_t workingB = self.b;
    if (workingB == 0x10000005) workingB = 4;
    if (workingB == 0x10000007) workingB = 10;
    return [NSString stringWithFormat:@"%u", (unsigned int)line];
}

- (NSString *)getItem:(uint32_t)line {
    return [self.dna getSaveItem:[self getName:line]].stringValue;
}

- (void)setItem:(uint32_t)line value:(NSString *)val {
    NSString *name = [self getName:line];
    CpfItem *item = [self.dna getItem:name];
    if (item == nil) {
        item = [[CpfItem alloc] init];
        item.name = name;
        [self.dna addItem:item allowDuplicate:NO];
    }
    
    item.stringValue = val;
}

// MARK: - Properties

- (NSString *)hair {
    return [self getItem:1];
}

- (void)setHair:(NSString *)hair {
    [self setItem:1 value:hair];
}

- (NSString *)skintoneRange {
    return [self getItem:2];
}

- (void)setSkintoneRange:(NSString *)skintoneRange {
    [self setItem:2 value:skintoneRange];
}

- (NSString *)eye {
    return [self getItem:3];
}

- (void)setEye:(NSString *)eye {
    [self setItem:3 value:eye];
}

- (NSString *)facialFeature {
    return [self getItem:5];
}

- (void)setFacialFeature:(NSString *)facialFeature {
    [self setItem:5 value:facialFeature];
}

- (NSString *)skintone {
    return [self getItem:6];
}

- (void)setSkintone:(NSString *)skintone {
    [self setItem:6 value:skintone];
}

- (NSString *)description {
    return [Serializer serialize:self];
}

@end

// MARK: - SimDNA Implementation

@implementation SimDNA

// MARK: - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        _dominant = [[Gene alloc] initWithDna:self base:0];
        _recessive = [[Gene alloc] initWithDna:self base:0x10000000];
    }
    return self;
}

// MARK: - AbstractWrapper Overrides

- (id<IPackedFileUI>)createDefaultUIHandler {
    // TODO: Implement SimDNAUI when available
    return nil;
}

- (id<IWrapperInfo>)createWrapperInfo {
    return [[AbstractWrapperInfo alloc] initWithName:@"Sim DNA Wrapper"
                                              author:@"Quaxi"
                                         description:@"This File contains the DNA of a Sim."
                                             version:1
                                                icon:nil]; // TODO: Add image when resource loading is implemented
}

- (NSData *)fileSignature {
    return [[NSData alloc] init];
}

- (NSArray<NSNumber *> *)assignableTypes {
    return @[@([MetaData SDNA])];
}

- (NSString *)descriptionHeader {
    NSMutableArray *list = [[NSMutableArray alloc] init];
    
    [list addObject:[NSString stringWithFormat:@"Dominant %@", [Serializer serializeTypeHeader:self.dominant]]];
    [list addObject:[NSString stringWithFormat:@"Recessive %@", [Serializer serializeTypeHeader:self.recessive]]];
    
    return [Serializer concatHeader:list];
}

- (NSString *)description {
    NSMutableArray *list = [[NSMutableArray alloc] init];
    [list addObject:[self.dominant toStringWithName:@"Dominant"]];
    [list addObject:[self.recessive toStringWithName:@"Recessive"]];
    
    return [Serializer concat:list];
}

@end
