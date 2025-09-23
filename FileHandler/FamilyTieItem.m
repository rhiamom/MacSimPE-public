//
//  FamilyTieItem.m
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

#import "FamilyTieItem.h"
#import "SDescWrapper.h"
#import "FamilyTiesWrapper.h"
#import "Helper.h"
#import "LocalizedEnums.h"
#import "IPackedFileDescriptor.h"
#import "IPackageFile.h"
#import "ISimNames.h"

// MARK: - FamilyTieCommon Implementation

@interface FamilyTieCommon ()
@property (nonatomic, assign) uint16_t simInstance;
@property (nonatomic, strong, nullable) SDesc *sdesc;
@end

@implementation FamilyTieCommon

#pragma mark - Initialization

- (instancetype)initWithSimInstance:(uint16_t)simInstance famt:(FamilyTies *)famt {
    if (self = [super init]) {
        _simInstance = simInstance;
        _famt = famt;
        _sdesc = nil;
    }
    return self;
}

#pragma mark - Properties

- (uint16_t)instance {
    return self.simInstance;
}

- (void)setInstance:(uint16_t)instance {
    if (self.simInstance != instance) {
        self.sdesc = nil;
    }
    self.simInstance = instance;
}

- (NSString *)simName {
    [self loadSDesc];
    return self.sdesc.simName;
}

- (SDesc *)simDescription {
    [self loadSDesc];
    return self.sdesc;
}

- (NSString *)simFamilyName {
    [self loadSDesc];
    return self.sdesc.simFamilyName;
}

#pragma mark - Private Methods

/**
 * Loads the Description File for a Sim
 */
- (void)loadSDesc {
    if (self.sdesc == nil) {
        self.sdesc = [[SDesc alloc] initWithNameProvider:self.famt.nameProvider
                                      familyNameProvider:nil
                                     descriptionProvider:nil];
        
        @try {
            id<IPackedFileDescriptor> pfd = [self.famt.package findFileWithType:MetaData.SIM_DESCRIPTION_FILE
                                                                        subtype:0
                                                                          group:self.famt.fileDescriptor.group
                                                                       instance:self.simInstance];
            [self.sdesc processData:pfd package:self.famt.package];
        } @catch (NSException *exception) {
            // Ignore exception
        }
    }
}

#pragma mark - NSObject

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ %@ (0x%@)",
            self.simName,
            self.simFamilyName,
            [Helper hexString:self.simInstance]];
}

@end

// MARK: - FamilyTieSim Implementation

@implementation FamilyTieSim

#pragma mark - Initialization

- (instancetype)initWithSimInstance:(uint16_t)simInstance
                               ties:(NSArray<FamilyTieItem *> *)ties
                               famt:(FamilyTies *)famt {
    if (self = [super initWithSimInstance:simInstance famt:famt]) {
        _ties = ties ?: @[];
        _blockDelimiter = 0x00000001;
    }
    return self;
}

#pragma mark - Tie Management

- (nullable FamilyTieItem *)findTie:(nullable SDesc *)sdsc {
    if (sdsc == nil) {
        return nil;
    }
    
    for (FamilyTieItem *tie in self.ties) {
        if (tie.instance == sdsc.instance) {
            return tie;
        }
    }
    
    return nil;
}

- (FamilyTieItem *)createTie:(SDesc *)sdsc type:(FamilyTieTypes)type {
    FamilyTieItem *tie = [self findTie:sdsc];
    if (tie == nil) {
        tie = [[FamilyTieItem alloc] initWithType:type
                                      simInstance:sdsc.instance
                                             famt:self.famt];
        self.ties = [Helper addToArray:self.ties item:tie];
    }
    tie.type = type;
    return tie;
}

- (BOOL)removeTie:(FamilyTieItem *)fti {
    NSUInteger originalCount = self.ties.count;
    self.ties = [Helper deleteFromArray:self.ties item:fti];
    return (self.ties.count < originalCount);
}

@end

// MARK: - FamilyTieItem Implementation

@implementation FamilyTieItem

#pragma mark - Initialization

- (instancetype)initWithType:(FamilyTieTypes)type
                 simInstance:(uint16_t)simInstance
                        famt:(FamilyTies *)famt {
    if (self = [super initWithSimInstance:simInstance famt:famt]) {
        _type = type;
    }
    return self;
}

#pragma mark - NSObject

- (NSString *)description {
    LocalizedFamilyTieTypes *localizedType = [[LocalizedFamilyTieTypes alloc] initWithType:self.type];
    return [NSString stringWithFormat:@"%@: %@",
            [localizedType description],
            [super description]];
}

@end
