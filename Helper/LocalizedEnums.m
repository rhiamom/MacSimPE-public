//
//  LocalizedEnums.m
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
// ***************************************************************************/

#import "LocalizedEnums.h"
#import "Localization.h"

@implementation LocalizedRelationshipTypes

// MARK: - Initialization

- (instancetype)initWithType:(RelationshipTypes)data {
    self = [super init];
    if (self) {
        _data = data;
    }
    return self;
}

- (instancetype)initWithUShort:(uint16_t)value {
    return [self initWithType:(RelationshipTypes)value];
}

// MARK: - Conversion Methods

- (RelationshipTypes)relationshipType {
    return self.data;
}

- (uint16_t)ushortValue {
    return (uint16_t)self.data;
}

+ (instancetype)localizedTypeWithRelationshipType:(RelationshipTypes)relationshipType {
    return [[self alloc] initWithType:relationshipType];
}

+ (instancetype)localizedTypeWithUShort:(uint16_t)value {
    return [[self alloc] initWithUShort:value];
}

// MARK: - Display Methods

- (NSString *)displayName {
    return [LocalizedRelationshipTypes displayNameForType:self.data];
}

+ (NSString *)displayNameForType:(RelationshipTypes)relationshipType {
    NSString *enumName = [self stringForRelationshipType:relationshipType];
    NSString *localizationKey = [NSString stringWithFormat:@"RT_%@", enumName];
    
    Localization *manager = [Localization shared];
    NSString *localizedString = [manager getString:localizationKey];
    
    if (localizedString != nil) {
        return localizedString;
    } else {
        return enumName;
    }
}

+ (NSString *)stringForRelationshipType:(RelationshipTypes)relationshipType {
    switch (relationshipType) {
        case RelationshipTypesUnsetUnknown:
            return @"Unset_Unknown";
        case RelationshipTypesAunt:
            return @"Aunt";
        case RelationshipTypesChild:
            return @"Child";
        case RelationshipTypesCousin:
            return @"Cousin";
        case RelationshipTypesGrandchild:
            return @"Grandchild";
        case RelationshipTypesGrandparent:
            return @"Gradparent"; // Note: keeping original typo from C# source
        case RelationshipTypesNiceNephew:
            return @"Nice_Nephew";
        case RelationshipTypesParent:
            return @"Parent";
        case RelationshipTypesSibling:
            return @"Sibling";
        case RelationshipTypesSpouses:
            return @"Spouses";
        default:
            return [NSString stringWithFormat:@"Unknown_%d", (int)relationshipType];
    }
}

// MARK: - NSObject Overrides

- (NSString *)description {
    return [self displayName];
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[LocalizedRelationshipTypes class]]) {
        return NO;
    }
    
    LocalizedRelationshipTypes *other = (LocalizedRelationshipTypes *)object;
    return self.data == other.data;
}

- (NSUInteger)hash {
    return (NSUInteger)self.data;
}

// MARK: - Comparison Methods

- (BOOL)isEqualToRelationshipType:(RelationshipTypes)relationshipType {
    return self.data == relationshipType;
}

- (BOOL)isEqualToLocalizedType:(LocalizedRelationshipTypes *)other {
    if (other == nil) {
        return NO;
    }
    return self.data == other.data;
}

@end
