//
//  FamilyTiesWrapper.m
//  MacSimpe
//
//  Created by Catherine Gramze on 9/23/25.
//
//**************************************************************************
//*   Copyright (C) 2005 by Ambertation                                     *
//*   quaxi@ambertation.de                                                  *
//*                                                                         *
//*   Objective-C translation Copyright (C) 2025 by GramzeSweatShop         *
//*   rhiamom@mac.com                                                       *
//*                                                                         *
//*   This program is free software; you can redistribute it and/or modify  *
//*   it under the terms of the GNU General Public License as published by  *
//*   the Free Software Foundation; either version 2 of the License, or     *
//*   (at your option) any later version.                                   *
//*                                                                         *
//*   This program is distributed in the hope that it will be useful,       *
//*   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
//*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
//*   GNU General Public License for more details.                          *
//*                                                                         *
//*   You should have received a copy of the GNU General Public License     *
//*   along with this program; if not, write to the                         *
//*   Free Software Foundation, Inc.,                                       *
//*   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
//**************************************************************************/

#import "FamilyTiesWrapper.h"
#import "BinaryReader.h"
#import "BinaryWriter.h"
#import "SDescWrapper.h"
#import "FamilyTieItem.h"
#import "MetaData.h"
#import "AbstractWrapperInfo.h"
#import "ISimNames.h"

@interface FamilyTies ()
@property (nonatomic, strong, nullable) id<ISimNames> nameProvider;
@property (nonatomic, strong) NSMutableArray<FamilyTieSim *> *simsArray;
@end

@implementation FamilyTies

#pragma mark - Initialization

- (instancetype)init {
    return [self initWithNameProvider:nil];
}

- (instancetype)initWithNameProvider:(nullable id<ISimNames>)names {
    if (self = [super init]) {
        _nameProvider = names;
        _simsArray = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - Properties

- (NSArray<FamilyTieSim *> *)sims {
    return [self.simsArray copy];
}

- (void)setSims:(NSArray<FamilyTieSim *> *)sims {
    [self.simsArray removeAllObjects];
    if (sims) {
        [self.simsArray addObjectsFromArray:sims];
    }
}

#pragma mark - Tie Management

- (nullable FamilyTieSim *)findTies:(nullable SDesc *)sdsc {
    if (sdsc == nil) {
        return nil;
    }
    
    for (FamilyTieSim *sim in self.simsArray) {
        if (sim.instance == sdsc.instance) {
            return sim;
        }
    }
    
    return nil;
}

- (FamilyTieSim *)createTie:(SDesc *)sdsc {
    FamilyTieSim *sim = [self findTies:sdsc];
    if (sim == nil) {
        sim = [[FamilyTieSim alloc] initWithSimInstance:sdsc.instance
                                                   ties:@[]
                                                   famt:self];
        [self.simsArray addObject:sim];
    }
    return sim;
}

#pragma mark - AbstractWrapper Override Methods

- (id<IPackedFileUI>)createDefaultUIHandler {
    // Return the UI handler for FamilyTies files
    // This would need to be implemented based on the UI framework
    return nil; // Placeholder
}

- (void)unserialize:(BinaryReader *)reader {
    uint32_t id = [reader readUInt32];
    if (id != 0x00000001) {
        @throw [NSException exceptionWithName:@"InvalidDataException"
                                       reason:@"File is not Recognized by the Family Ties Wrapper!"
                                     userInfo:nil];
    }
    
    int32_t count = [reader readInt32];
    self.simsArray = [[NSMutableArray alloc] initWithCapacity:count];
    
    for (int32_t i = 0; i < count; i++) {
        uint16_t instance = [reader readUInt16];
        int32_t blockDelimiter = [reader readInt32];
        int32_t itemCount = [reader readInt32];
        
        NSMutableArray<FamilyTieItem *> *items = [[NSMutableArray alloc] initWithCapacity:itemCount];
        for (int32_t k = 0; k < itemCount; k++) {
            FamilyTieTypes type = (FamilyTieTypes)[reader readUInt32];
            uint16_t tInstance = [reader readUInt16];
            FamilyTieItem *item = [[FamilyTieItem alloc] initWithType:type
                                                          simInstance:tInstance
                                                                 famt:self];
            [items addObject:item];
        }
        
        FamilyTieSim *simTie = [[FamilyTieSim alloc] initWithSimInstance:instance
                                                                    ties:[items copy]
                                                                    famt:self];
        simTie.blockDelimiter = blockDelimiter;
        [self.simsArray addObject:simTie];
    }
}

- (void)serialize:(BinaryWriter *)writer {
    [writer writeInt32:0x00000001];
    [writer writeInt32:(int32_t)self.simsArray.count];
    
    for (FamilyTieSim *sim in self.simsArray) {
        [writer writeUInt16:sim.instance];
        [writer writeInt32:sim.blockDelimiter];
        [writer writeInt32:(int32_t)sim.ties.count];
        
        for (FamilyTieItem *tie in sim.ties) {
            [writer writeUInt32:(uint32_t)tie.type];
            [writer writeUInt16:tie.instance];
        }
    }
}

#pragma mark - IWrapper Protocol

- (id<IWrapperInfo>)createWrapperInfo {
    return [[AbstractWrapperInfo alloc] initWithName:@"Family Ties Wrapper"
                                              author:@"Quaxi"
                                         description:@"---"
                                             version:1
                                                icon:nil];
}

#pragma mark - IFileWrapper Protocol

- (NSArray<NSNumber *> *)assignableTypes {
    return @[@([MetaData FAMILY_TIES_FILE])];
}

- (NSData *)fileSignature {
    // Return empty signature as in the original C# code
    return [NSData data];
}

@end
