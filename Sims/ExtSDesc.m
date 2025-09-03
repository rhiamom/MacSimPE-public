//
//  ExtSDesc.m
//  MacSimpe
//
//  Created by Catherine Gramze on 8/31/25.
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

#import "ExtSDesc.h"
#import "ExtSrel.h"
#import "SimDNA.h"
#import "AbstractWrapperInfo.h"
#import "IPackedFileUI.h"
#import "FileTableBase.h"
#import "TypeRegistry.h"
#import "ISimNames.h"
#import "ILotProvider.h"
#import "IAlias.h"
#import "IPackedFileDescriptor.h"
#import "IPackageFile.h"
#import "MetaData.h"
#import "Helper.h"
#import "BinaryReader.h"
#import "BinaryWriter.h"
#import "PackedFileDescriptors.h"
#import "Serializer.h"

@interface ExtSDesc ()
@property (nonatomic, strong) NSMutableDictionary *relationshipCache; // crmap in C#
@property (nonatomic, assign) BOOL locked;
@property (nonatomic, assign) BOOL nameChanged; // chgname in C#
@property (nonatomic, copy, nullable) NSString *customSimName; // sname in C#
@property (nonatomic, copy, nullable) NSString *customSimFamilyName; // sfname in C#
@end

@implementation ExtSDesc

// MARK: - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        _relationshipCache = [[NSMutableDictionary alloc] init];
        _locked = NO;
        _nameChanged = NO;
    }
    return self;
}

// MARK: - Abstract Wrapper Methods

- (id<IWrapperInfo>)createWrapperInfo {
    // TODO: Load image from resources when resource system is implemented
    return [[AbstractWrapperInfo alloc] initWithName:@"Extended Sim Description Wrapper"
                                              author:@"Quaxi"
                                         description:@"This File contains Settings (like interests, friendships, money, age, gender...) for one Sim."
                                             version:7
                                                icon:nil];
}

- (id<IPackedFileUI>)createDefaultUIHandler {
    // TODO: Return appropriate UI handler when implemented
    // return [[ExtSDescUI alloc] init];
    NSLog(@"TODO: ExtSDescUI not yet implemented");
    return nil;
}

// MARK: - Properties

- (BOOL)isNPC {
    id<IWrapperRegistry> registry = [FileTableBase wrapperRegistry];
    if ([registry respondsToSelector:@selector(simNameProvider)]) {
        TypeRegistry *typeRegistry = (TypeRegistry *)registry;
        id<ISimNames> simNameProvider = typeRegistry.simNameProvider;
        
        if (simNameProvider != nil) {
            id<IAlias> nameAlias = [simNameProvider findName:self.simId];
            if (nameAlias != nil) {
                NSArray *tag = [nameAlias tag];
                if ([tag count] > 4) {
                    return tag[4] != nil;
                }
            }
        }
    }
    return NO;
}

- (BOOL)isTownie {
    return (((self.familyInstance & 0x7f00) == 0x7f00) || self.familyInstance == 0) && !self.isNPC;
}

- (NSString *)characterFileName {
    if (self.isNPC) {
        id<IWrapperRegistry> registry = [FileTableBase wrapperRegistry];
        if ([registry respondsToSelector:@selector(simNameProvider)]) {
            TypeRegistry *typeRegistry = (TypeRegistry *)registry;
            id<ISimNames> simNameProvider = typeRegistry.simNameProvider;
            
            if (simNameProvider != nil) {
                id<IAlias> nameAlias = [simNameProvider findName:self.simId];
                if (nameAlias != nil) {
                    NSArray *tag = [nameAlias tag];
                    if ([tag count] > 4 && tag[4] != nil) {
                        return [tag[4] description];
                    }
                }
            }
        }
    }
    return [super characterFileName];
}

- (NSString *)simFamilyName {
    if (self.customSimFamilyName != nil) {
        return self.customSimFamilyName;
    }
    return [super simFamilyName];
}

- (void)setSimFamilyName:(NSString *)simFamilyName {
    self.nameChanged = YES;
    self.customSimFamilyName = simFamilyName;
}

- (NSString *)simName {
    if (self.customSimName != nil) {
        return self.customSimName;
    }
    return [super simName];
}

- (void)setSimName:(NSString *)simName {
    self.nameChanged = YES;
    self.customSimName = simName;
}

- (BOOL)changed {
    // Check if any cached relationships are changed
    for (ExtSrel *srel in [self.relationshipCache allValues]) {
        if (srel.changed) {
            return YES;
        }
    }
    return [super changed];
}

- (void)setChanged:(BOOL)changed {
    [super setChanged:changed];
    
    // Set changed state for all cached relationships
    for (ExtSrel *srel in [self.relationshipCache allValues]) {
        srel.changed = changed;
    }
}

// MARK: - Serialization

- (void)unserialize:(BinaryReader *)reader {
    if (self.locked) return;
    
    [super unserialize:reader];
    self.nameChanged = NO;
    [self.relationshipCache removeAllObjects];
}

- (void)serialize:(BinaryWriter *)writer {
    if (self.locked) return;
    
    [super serialize:writer];
    
    if (self.nameChanged) {
        [self changeName];
    }
    
    [self saveRelations];
}

// MARK: - Name Management

- (void)changeName {
    if (!self.isNPC) {
        if ([self changeNamesWithFirstName:self.simName familyName:self.simFamilyName]) {
            self.nameChanged = NO;
        }
    }
    
    if (!self.nameChanged) {
        self.customSimName = nil;
        self.customSimFamilyName = nil;
    }
}

- (BOOL)changeNamesWithFirstName:(NSString *)firstName familyName:(NSString *)familyName {
    // TODO: Implement name changing logic when name provider system is ready
    NSLog(@"TODO: Implement name changing logic");
    return YES; // Placeholder
}

// MARK: - Relationship Management

- (BOOL)hasRelationWith:(ExtSDesc *)sDesc {
    NSArray *simInstances = self.relations.simInstances;
    uint32_t targetInstance = sDesc.fileDescriptor.instance;
    
    for (NSNumber *instanceNumber in simInstances) {
        if ([instanceNumber unsignedIntValue] == targetInstance) {
            return YES;
        }
    }
    return NO;
}

- (void)addRelation:(ExtSDesc *)sDesc {
    NSMutableArray *instances = [self.relations.simInstances mutableCopy];
    uint16_t targetInstance = (uint16_t)sDesc.fileDescriptor.instance;
    
    // Check if already exists
    for (NSNumber *instanceNumber in instances) {
        if ([instanceNumber unsignedShortValue] == targetInstance) {
            return; // Already exists
        }
    }
    
    // Add the instance
    [instances addObject:@(targetInstance)];
    self.relations.simInstances = [instances copy];
    self.changed = YES;
}

- (void)removeRelation:(ExtSDesc *)sDesc {
    NSMutableArray *instances = [self.relations.simInstances mutableCopy];
    uint16_t targetInstance = (uint16_t)sDesc.fileDescriptor.instance;
    
    for (NSInteger i = instances.count - 1; i >= 0; i--) {
        NSNumber *instanceNumber = instances[i];
        if ([instanceNumber unsignedShortValue] == targetInstance) {
            [instances removeObjectAtIndex:i];
        }
    }
    
    self.relations.simInstances = [instances copy];
    self.changed = YES;
}

- (uint32_t)getRelationInstance:(ExtSDesc *)sDesc {
    return ((self.fileDescriptor.instance & 0xffff) << 16) | (sDesc.fileDescriptor.instance & 0xffff);
}

+ (ExtSrel *)findRelation:(ExtSDesc *)src destination:(ExtSDesc *)dst {
    return [self findRelation:src source:src destination:dst];
}

+ (ExtSrel *)findRelation:(ExtSDesc *)cache source:(ExtSDesc *)src destination:(ExtSDesc *)dst {
    uint32_t sInst = [src getRelationInstance:dst];
    ExtSrel *srel = [cache getCachedRelation:sInst];
    
    if (srel == nil) {
        id<IPackedFileDescriptor> spfd = [cache.package findFileWithType:[MetaData RELATION_FILE]
                                                                 subtype:0
                                                                   group:cache.fileDescriptor.group
                                                                instance:sInst];
        
        if (spfd != nil) {
            srel = [[ExtSrel alloc] init];
            [srel processData:spfd package:cache.package];
        }
    }
    
    return srel;
}

- (ExtSrel *)findRelation:(ExtSDesc *)sDesc {
    return [[self class] findRelation:self source:self destination:sDesc];
}

- (ExtSrel *)createRelation:(ExtSDesc *)sDesc {
    ExtSrel *srel = [[ExtSrel alloc] init];
    uint32_t inst = [self getRelationInstance:sDesc];
    
    id<IPackedFileDescriptor> descriptor = [self.package newDescriptorWithType:[MetaData RELATION_FILE]
                                                                       subtype:0
                                                                         group:self.fileDescriptor.group
                                                                      instance:inst];
    srel.fileDescriptor = descriptor;
    srel.relationState.isKnown = YES;
    
    return srel;
}

// MARK: - Relationship Cache Management

- (ExtSrel *)getCachedRelation:(uint32_t)instance {
    return [self.relationshipCache objectForKey:@(instance)];
}

- (ExtSrel *)getCachedRelationForSim:(ExtSDesc *)sDesc {
    return [self getCachedRelation:[self getRelationInstance:sDesc]];
}

- (void)addRelationToCache:(ExtSrel *)srel {
    if (srel == nil || srel.fileDescriptor == nil) return;
    
    uint32_t instance = srel.fileDescriptor.instance;
    [self.relationshipCache setObject:srel forKey:@(instance)];
}

- (void)removeRelationFromCache:(ExtSrel *)srel {
    if (srel == nil || srel.fileDescriptor == nil) return;
    
    uint32_t instance = srel.fileDescriptor.instance;
    [self.relationshipCache removeObjectForKey:@(instance)];
}

- (void)saveRelations {
    if (self.locked) return;
    
    PackedFileDescriptors *pfds = [[PackedFileDescriptors alloc] init];
    self.locked = YES;
    
    @try {
        for (ExtSrel *srel in [self.relationshipCache allValues]) {
            if (srel.package != nil) {
                [srel synchronizeUserData];
            } else {
                srel.package = self.package;
                [srel synchronizeUserData];
                [pfds addObject:srel.fileDescriptor];
            }
            
            if (![self isEqual:srel.sourceSim]) {
                if (srel.sourceSim != nil && srel.sourceSim.changed) {
                    [srel.sourceSim synchronizeUserData];
                }
            }
        }
        
        [self.relationshipCache removeAllObjects];
        self.locked = NO;
        
        [self.package beginUpdate];
        @try {
            for (NSInteger i = pfds.count - 1; i >= 0; i--) {
                if (i == 0) [self.package forgetUpdate];
                [self.package addDescriptor:pfds[i] isNew:YES];
            }
        } @finally {
            [self.package endUpdate];
        }
    } @finally {
        self.locked = NO;
    }
}

// MARK: - NSObject Overrides

- (NSUInteger)hash {
    return (NSUInteger)self.simId;
}

- (BOOL)isEqual:(id)object {
    if (object == nil) return NO;
    
    if ([object isKindOfClass:[SDesc class]]) {
        SDesc *s = (SDesc *)object;
        return s.simId == self.simId;
    }
    
    return [super isEqual:object];
}

// MARK: - Description Methods

- (NSString *)descriptionHeader {
    NSMutableArray *list = [[NSMutableArray alloc] init];
    [list addObject:@"GUID"];
    [list addObject:@"Filename"];
    [list addObject:@"Name"];
    [list addObject:@"Household"];
    [list addObject:@"isNPC"];
    [list addObject:@"isTownie"];
    [list addObject:[Serializer serializeTypeHeader:self.characterDescription]];
    [list addObject:[Serializer serializeTypeHeader:self.character]];
    [list addObject:[@"Genetic" stringByAppendingString:[Serializer serializeTypeHeader:self.geneticCharacter]]];
    [list addObject:[Serializer serializeTypeHeader:self.interests]];
    [list addObject:[Serializer serializeTypeHeader:self.skills]];
    [list addObject:@"Version"];
    
    if ((int)self.version >= (int)SDescVersionUniversity) {
        [list addObject:[Serializer serializeTypeHeader:self.university]];
    }
    
    if ((int)self.version >= (int)SDescVersionNightlife) {
        [list addObject:[Serializer serializeTypeHeader:self.nightlife]];
    }
    
    return [Serializer concatHeader:[Serializer convertArray:list]];
}

- (NSString *)description {
    NSMutableArray *list = [[NSMutableArray alloc] init];
    [list addObject:[Serializer property:@"GUID" value:[NSString stringWithFormat:@"0x%08X", self.simId]]];
    [list addObject:[Serializer property:@"Filename" value:self.characterFileName ?: @""]];
    [list addObject:[Serializer property:@"Name" value:[NSString stringWithFormat:@"%@ %@", self.simName ?: @"", self.simFamilyName ?: @""]]];
    [list addObject:[Serializer property:@"Household" value:self.householdName ?: @""]];
    [list addObject:[Serializer property:@"isNPC" value:self.isNPC ? @"true" : @"false"]];
    [list addObject:[Serializer property:@"isTownie" value:self.isTownie ? @"true" : @"false"]];
    [list addObject:[self.characterDescription description]];
    [list addObject:[self.character description]];
    [list addObject:[self.geneticCharacter description]];
    [list addObject:[self.interests description]];
    [list addObject:[self.skills description]];
    [list addObject:[Serializer property:@"Version" value:[NSString stringWithFormat:@"%d", (int)self.version]]];
    
    if ((int)self.version >= (int)SDescVersionUniversity) {
        [list addObject:[self.university description]];
    }
    
    if ((int)self.version >= (int)SDescVersionNightlife) {
        [list addObject:[self.nightlife description]];
    }
    
    return [Serializer concat:[Serializer convertArray:list]];
}

@end

// MARK: - LinkedSDesc Implementation

@implementation LinkedSDesc

@synthesize simDNA = _simDNA;

- (void)unserialize:(BinaryReader *)reader {
    [super unserialize:reader];
    _simDNA = nil; // Reset DNA reference
}

- (SimDNA *)simDNA {
    if (_simDNA == nil) {
        id<IPackedFileDescriptor> pfd = [self.package findFileWithType:[MetaData SDNA]
                                                               subtype:0
                                                                 group:[MetaData LOCAL_GROUP]
                                                              instance:self.fileDescriptor.instance];
        if (pfd != nil) {
            _simDNA = [[SimDNA alloc] init];
            [_simDNA processData:pfd package:self.package sync:YES];
        }
    }
    
    return _simDNA;
}

- (NSArray<id<ILotItem>> *)businessList {
    if ((uint32_t)self.version < (uint32_t)SDescVersionBusiness) {
        return @[];
    }
    
    id<IWrapperRegistry> registry = [FileTableBase wrapperRegistry];
    if ([registry respondsToSelector:@selector(lotProvider)]) {
        TypeRegistry *typeRegistry = (TypeRegistry *)registry;
        id<ILotProvider> lotProvider = typeRegistry.lotProvider;
        
        if (lotProvider != nil) {
            return [lotProvider findLotsOwnedBySim:self.instance];
        }
    }
    
    return @[];
}

- (NSString *)descriptionHeader {
    NSMutableArray *list = [[NSMutableArray alloc] init];
    [list addObject:[super descriptionHeader]];
    
    if (self.simDNA != nil) {
        [list addObject:self.simDNA.descriptionHeader];
    }
    
    if ((int)self.version >= (int)SDescVersionBusiness) {
        [list addObject:[Serializer serializeTypeHeader:self.business]];
    }
    
    if ((int)self.version >= (int)SDescVersionPets) {
        [list addObject:[Serializer serializeTypeHeader:self.pets]];
    }
    
    if ((int)self.version >= (int)SDescVersionVoyage) {
        [list addObject:[Serializer serializeTypeHeader:self.voyage]];
    }
    
    return [Serializer concatHeader:[Serializer convertArray:list]];
}

- (NSString *)description {
    NSMutableArray *list = [[NSMutableArray alloc] init];
    [list addObject:[super description]];
    
    if (self.simDNA != nil) {
        [list addObject:[Serializer subProperty:@"DNA" value:self.simDNA.description]];
    }
    
    if ((int)self.version >= (int)SDescVersionBusiness) {
        [list addObject:[self.business description]];
    }
    
    if ((int)self.version >= (int)SDescVersionPets) {
        [list addObject:[self.pets description]];
    }
    
    if ((int)self.version >= (int)SDescVersionVoyage) {
        [list addObject:[self.voyage description]];
    }
    
    return [Serializer concat:[Serializer convertArray:list]];
}

@end
