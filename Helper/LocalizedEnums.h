//
//  LocalizedEnums.h
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

#import <Foundation/Foundation.h>
#import "MetaData.h"

/**
 * Localized Version of the RelationshipTypes Enum
 */
@interface LocalizedRelationshipTypes : NSObject

// MARK: - Properties

/**
 * Contains the enum value
 */
@property (nonatomic, assign) RelationshipTypes data;

// MARK: - Initialization

/**
 * Constructor
 * @param data The Value of the Enum
 */
- (instancetype)initWithType:(RelationshipTypes)data;

/**
 * Create from ushort value
 * @param value The numeric value
 */
- (instancetype)initWithUShort:(uint16_t)value;

// MARK: - Conversion Methods

/**
 * Convert to RelationshipTypes enum
 */
- (RelationshipTypes)relationshipType;

/**
 * Convert to ushort value
 */
- (uint16_t)ushortValue;

/**
 * Create from RelationshipTypes enum
 * @param relationshipType The enum value
 */
+ (instancetype)localizedTypeWithRelationshipType:(RelationshipTypes)relationshipType;

/**
 * Create from ushort value
 * @param value The numeric value
 */
+ (instancetype)localizedTypeWithUShort:(uint16_t)value;

// MARK: - Display Methods

/**
 * Returns the localized display name
 */
- (NSString *)displayName;

/**
 * Class method to get display name for a type
 * @param relationshipType The relationship type
 */
+ (NSString *)displayNameForType:(RelationshipTypes)relationshipType;

// MARK: - NSObject Overrides

- (NSString *)description;
- (BOOL)isEqual:(id)object;
- (NSUInteger)hash;

// MARK: - Comparison Methods

/**
 * Compare with RelationshipTypes enum
 */
- (BOOL)isEqualToRelationshipType:(RelationshipTypes)relationshipType;

/**
 * Compare with another LocalizedRelationshipTypes
 */
- (BOOL)isEqualToLocalizedType:(LocalizedRelationshipTypes *)other;

@end
