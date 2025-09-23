//
//  FamiWrapper.m
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

#import "FamiWrapper.h"
#import "BinaryReader.h"
#import "BinaryWriter.h"
#import "SDescWrapper.h"
#import "StrWrapper.h"
#import "MetaData.h"
#import "Localization.h"
#import "Registry.h"
#import "IPackedFileDescriptor.h"
#import "IPackageFile.h"
#import "ISimNames.h"
#import "AbstractWrapperInfo.h"

// MARK: - FamiFlags Implementation

@implementation FamiFlags

- (instancetype)initWithFlags:(uint16_t)flags {
    if (self = [super initWithValue:flags]) {
        // Initialization complete
    }
    return self;
}

- (BOOL)hasPhone {
    return [self getBit:0];
}

- (void)setHasPhone:(BOOL)hasPhone {
    [self setBit:0 value:hasPhone];
}

- (BOOL)hasBaby {
    return [self getBit:1];
}

- (void)setHasBaby:(BOOL)hasBaby {
    [self setBit:1 value:hasBaby];
}

- (BOOL)newLot {
    return [self getBit:2];
}

- (void)setNewLot:(BOOL)newLot {
    [self setBit:2 value:newLot];
}

- (BOOL)hasComputer {
    return [self getBit:3];
}

- (void)setHasComputer:(BOOL)hasComputer {
    [self setBit:3 value:hasComputer];
}

@end

// MARK: - Fami Implementation

@interface Fami ()
@property (nonatomic, assign) uint32_t strInstance;
@property (nonatomic, assign) uint32_t businessLot, vacationLot;
@property (nonatomic, assign) uint32_t id;
@property (nonatomic, assign) FamiVersions version;
@property (nonatomic, assign) uint32_t unknown;
@property (nonatomic, assign) uint32_t subHood;
@property (nonatomic, strong, nullable) id<ISimNames> nameProvider;
@end

@implementation Fami

#pragma mark - Initialization

- (instancetype)init {
    return [self initWithNameProvider:nil];
}

- (instancetype)initWithNameProvider:(nullable id<ISimNames>)names {
    if (self = [super init]) {
        _id = 0x46414D49;
        _version = FamiVersionsOriginal;
        _unknown = 0;
        _nameProvider = names;
        _flags = 0x04;
        _members = @[];
    }
    return self;
}

#pragma mark - Property Implementations

- (NSArray<NSString *> *)simNames {
    NSMutableArray<NSString *> *names = [NSMutableArray arrayWithCapacity:self.members.count];
    
    if (self.nameProvider != nil) {
        for (NSNumber *simIdNumber in self.members) {
            uint32_t simId = [simIdNumber unsignedIntValue];
            NSString *name = [self.nameProvider findName:simId].name;
            [names addObject:name ?: @""];
        }
    } else {
        // Fill with empty strings if no provider
        for (NSUInteger i = 0; i < self.members.count; i++) {
            [names addObject:@""];
        }
    }
    
    return [names copy];
}

- (uint32_t)currentlyOnLotInstance {
    return self.businessLot;
}

- (void)setCurrentlyOnLotInstance:(uint32_t)currentlyOnLotInstance {
    self.businessLot = currentlyOnLotInstance;
}

- (uint32_t)vacationLotInstance {
    return self.vacationLot;
}

- (void)setVacationLotInstance:(uint32_t)vacationLotInstance {
    self.vacationLot = vacationLotInstance;
}

- (NSString *)name {
    NSString *name = [Localization getString:@"Unknown"];
    
    @try {
        id<IPackedFileDescriptor> pfd = [self.package findFileWithType:MetaData.STRING_FILE
                                                               subtype:0
                                                                 group:self.fileDescriptor.group
                                                              instance:self.fileDescriptor.instance];
        
        // Found a Text Resource
        if (pfd != nil) {
            StrWrapper *str = [[StrWrapper alloc] init];
            [str processData:pfd package:self.package];
            
            StrItemList *items = [str fallbackedLanguageItemsForLanguage:[[Registry windowsRegistry] languageCode]];
            if (items.length > 0) {
                StrToken *token = [items objectAtIndex:0];
                name = token.title;
            }
        }
    } @catch (NSException *exception) {
        // Ignore exception and return default name
    }
    
    return name;
}

- (void)setName:(NSString *)name {
    @try {
        id<IPackedFileDescriptor> pfd = [self.package findFileWithType:MetaData.STRING_FILE
                                                               subtype:0
                                                                 group:self.fileDescriptor.group
                                                              instance:self.fileDescriptor.instance];
        
        // Found a Text Resource
        if (pfd != nil) {
            StrWrapper *str = [[StrWrapper alloc] init];
            [str processData:pfd package:self.package];
            
            for (StrLanguage *lng in str.languages) {
                if (lng == nil) continue;
                StrItemList *list = [str languageItemsForStrLanguage:lng];
                if (list.length > 0) {
                    StrToken *token = [list objectAtIndex:0];
                    if (token != nil) {
                        token.title = name;
                    }
                }
            }
            
            [str synchronizeUserData];
        }
    } @catch (NSException *exception) {
        // Ignore exception
    }
}

- (void)setMembers:(NSArray<NSNumber *> *)members {
    _members = members ?: @[];
}

#pragma mark - Sim Management

- (SDesc *)getDescriptionFile:(uint32_t)simId {
    if (self.package == nil) {
        @throw [NSException exceptionWithName:@"InvalidOperationException"
                                       reason:@"No package loaded!"
                                     userInfo:nil];
    }
    
    SDesc *sdesc = [SDesc findForSimId:simId inPackage:self.package];
    if (sdesc == nil) {
        sdesc = [[SDesc alloc] init];
        sdesc.simId = simId;
        sdesc.characterDescription.age = 28;
        
        NSArray<id<IPackedFileDescriptor>> *files = [self.package findFiles:MetaData.SIM_DESCRIPTION_FILE];
        uint32_t maxInstance = 0;
        for (id<IPackedFileDescriptor> pfd in files) {
            if (pfd.instance > maxInstance) {
                maxInstance = pfd.instance;
            }
        }
        sdesc.instance = maxInstance + 1;
        
        id<IPackedFileDescriptor> fd = [self.package newDescriptorWithType:MetaData.SIM_DESCRIPTION_FILE
                                                                   subtype:0x0
                                                                     group:self.fileDescriptor.group
                                                                  instance:sdesc.instance];
        [sdesc saveToDescriptor:fd];
    }
    
    return sdesc;
}

#pragma mark - AbstractWrapper Override Methods

- (id<IPackedFileUI>)createDefaultUIHandler {
    // Return the UI handler for Fami files
    // This would need to be implemented based on the UI framework
    return nil; // Placeholder
}

- (void)unserialize:(BinaryReader *)reader {
    self.id = [reader readUInt32];
    self.version = (FamiVersions)[reader readUInt32];
    self.unknown = [reader readUInt32];
    self.lotInstance = [reader readUInt32];
    
    if ((int32_t)self.version >= (int32_t)FamiVersionsBusiness) {
        self.businessLot = [reader readUInt32];
    }
    if ((int32_t)self.version >= (int32_t)FamiVersionsVoyage) {
        self.vacationLot = [reader readUInt32];
    }
    
    self.strInstance = [reader readUInt32];
    self.money = [reader readInt32];
    
    if ((int32_t)self.version >= (int32_t)FamiVersionsCastaway) {
        self.castAwayFoodDecay = [reader readInt32];
    }
    
    self.friends = [reader readUInt32];
    self.flags = [reader readUInt32];
    uint32_t count = [reader readUInt32];
    
    NSMutableArray<NSNumber *> *sims = [NSMutableArray arrayWithCapacity:count];
    for (uint32_t i = 0; i < count; i++) {
        uint32_t simId = [reader readUInt32];
        [sims addObject:@(simId)];
    }
    self.members = [sims copy];
    
    self.albumGUID = [reader readUInt32]; // relations??
    
    if ((int32_t)self.version >= (int32_t)FamiVersionsUniversity) {
        self.subHood = [reader readUInt32];
    }
    if ((int32_t)self.version >= (int32_t)FamiVersionsCastaway) {
        self.castAwayResources = [reader readInt32];
        self.castAwayFood = [reader readInt32];
    }
    
    if ((int32_t)self.version >= (int32_t)FamiVersionsBusiness) {
        self.businessMoney = [reader readInt32];
    }
}

- (void)serialize:(BinaryWriter *)writer {
    [writer writeUInt32:self.id];
    [writer writeUInt32:(uint32_t)self.version];
    [writer writeUInt32:self.unknown];
    [writer writeUInt32:self.lotInstance];
    
    if ((int32_t)self.version >= (int32_t)FamiVersionsBusiness) {
        [writer writeUInt32:self.businessLot];
    }
    if ((int32_t)self.version >= (int32_t)FamiVersionsVoyage) {
        [writer writeUInt32:self.vacationLot];
    }
    
    if ((int32_t)self.version >= (int32_t)FamiVersionsCastaway) {
        [writer writeInt32:self.castAwayResources];
        [writer writeInt32:self.castAwayFood];
        [writer writeInt32:self.castAwayFoodDecay];
    } else {
        [writer writeUInt32:self.strInstance];
        [writer writeInt32:self.money];
    }
    
    [writer writeUInt32:self.friends];
    [writer writeUInt32:self.flags];
    [writer writeUInt32:(uint32_t)self.members.count];
    
    for (NSNumber *simIdNumber in self.members) {
        [writer writeUInt32:[simIdNumber unsignedIntValue]];
    }
    
    [writer writeUInt32:self.albumGUID];
    
    if ((int32_t)self.version >= (int32_t)FamiVersionsUniversity) {
        [writer writeUInt32:self.subHood];
    }
    if ((int32_t)self.version >= (int32_t)FamiVersionsCastaway) {
        [writer writeInt32:self.castAwayResources];
        [writer writeInt32:self.castAwayFood];
        [writer writeInt32:self.castAwayFoodDecay];
    } else if ((int32_t)self.version >= (int32_t)FamiVersionsBusiness) {
        [writer writeInt32:self.businessMoney];
    }
}

#pragma mark - IWrapper Protocol

- (id<IWrapperInfo>)createWrapperInfo {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *imagePath = [bundle pathForResource:@"fami" ofType:@"png"];
    NSImage *image = [[NSImage alloc] initWithContentsOfFile:imagePath];
    
    return [[AbstractWrapperInfo alloc] initWithName:@"FAMi Wrapper"
                                              author:@"Quaxi"
                                         description:@"This File contains Information about one Sim Family."
                                             version:7
                                                icon:image];
}

- (NSString *)getResourceName:(TypeAlias *)ta {
    if (!self.processed) {
        [self processData:self.fileDescriptor package:self.package];
    }
    return self.name;
}

#pragma mark - IFileWrapper Protocol

- (NSArray<NSNumber *> *)assignableTypes {
    return @[@(0x46414D49)];
}

- (NSData *)fileSignature {
    const char bytes[] = {'I', 'M', 'A', 'F'};
    return [NSData dataWithBytes:bytes length:sizeof(bytes)];
}

@end
