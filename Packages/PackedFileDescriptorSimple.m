//
//  PackedFileDescriptorSimple.m
//  MacSimpe
//
//  Created by Catherine Gramze on 7/25/25.
//

/***************************************************************************
 *   Copyright (C) 2005 by Ambertation                                     *
 *   quaxi@ambertation.de                                                  *
 *                                                                         *
 *   Objective C translation Copyright (C) 2025 by GramzeSweatShop               *
 *   rhiamom@mac.com                                                       *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program, if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
 ***************************************************************************/

#import "PackedFileDescriptorSimple.h"
#import "MetaData.h"
#import "TypeAlias.h"

@implementation PackedFileDescriptorSimple

- (instancetype)init {
    return [self initWithType:0 group:0 instanceHi:0 instanceLo:0];
}

- (instancetype)initWithType:(uint32_t)type group:(uint32_t)grp instanceHi:(uint32_t)ihi instanceLo:(uint32_t)ilo {
    self = [super init];
    if (self) {
        _pfdType = self.pfdType;
        _group = grp;
        _subType = ihi;
        _instance = ilo;
    }
    return self;
}

/**
 * Returns/Sets the Type of the referenced File
 */
- (void)setType:(uint32_t)type {
    if (_pfdType != self.pfdType) {
        _pfdType = self.pfdType;
        [self descriptionChangedFkt];
    }
}

/**
 * Returns the Name of the represented Type
 */
- (TypeAlias *)typeName {
    return [MetaData findTypeAlias:self.pfdType];
}

/**
 * Returns/Sets the Group the referenced file is assigned to
 */
- (void)setGroup:(uint32_t)group {
    if (_group != group) {
        _group = group;
        [self descriptionChangedFkt];
    }
}

/**
 * Returns or sets the Instance Data
 */
- (void)setInstance:(uint32_t)instance {
    if (_instance != instance) {
        _instance = instance;
        [self descriptionChangedFkt];
    }
}

/**
 * Returns/Sets an yet unknown Type
 * @remarks Only in Version 1.1 of package Files
 */
- (void)setSubType:(uint32_t)subType {
    if (_subType != subType) {
        _subType = subType;
        [self descriptionChangedFkt];
    }
}

- (void)descriptionChangedFkt {
    // Override in subclasses
}

@end
