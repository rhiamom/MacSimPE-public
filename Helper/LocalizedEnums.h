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

#import <Foundation/Foundation.h>
#import "MetaData.h"

NS_ASSUME_NONNULL_BEGIN

// MARK: - LocalizedRelationshipTypes

/**
 * Localized Version of the RelationshipTypes Enum
 */
@interface LocalizedRelationshipTypes : NSObject

@property (nonatomic, readonly, assign) RelationshipTypes data;

- (instancetype)initWithType:(RelationshipTypes)data;
- (instancetype)initWithUShort:(uint16_t)value;

+ (instancetype)localizedWithType:(RelationshipTypes)data;
+ (instancetype)localizedWithUShort:(uint16_t)value;

- (RelationshipTypes)relationshipType;
- (uint16_t)ushortValue;

- (BOOL)isEqualToType:(RelationshipTypes)type;
- (BOOL)isEqualToLocalized:(LocalizedRelationshipTypes *)other;

- (NSString *)description;

@end

// MARK: - LocalizedGrades

/**
 * Localized Version of the Grades Enum
 */
@interface LocalizedGrades : NSObject

@property (nonatomic, readonly, assign) Grades data;

- (instancetype)initWithGrade:(Grades)data;
- (instancetype)initWithUShort:(uint16_t)value;

+ (instancetype)localizedWithGrade:(Grades)data;
+ (instancetype)localizedWithUShort:(uint16_t)value;

- (Grades)grade;
- (uint16_t)ushortValue;

- (NSString *)description;

@end

// MARK: - LocalizedSchoolType

/**
 * Localized Version of the SchoolTypes Enum
 */
@interface LocalizedSchoolType : NSObject

@property (nonatomic, readonly, assign) SchoolTypes data;

- (instancetype)initWithSchoolType:(SchoolTypes)data;
- (instancetype)initWithUInt:(uint32_t)value;

+ (instancetype)localizedWithSchoolType:(SchoolTypes)data;
+ (instancetype)localizedWithUInt:(uint32_t)value;

- (SchoolTypes)schoolType;
- (uint32_t)uintValue;

- (NSString *)description;

@end

// MARK: - LocalizedAspirationTypes

/**
 * Localized Version of the AspirationTypes Enum
 */
@interface LocalizedAspirationTypes : NSObject

@property (nonatomic, readonly, assign) AspirationTypes data;

- (instancetype)initWithType:(AspirationTypes)data;
- (instancetype)initWithUShort:(uint16_t)value;

+ (instancetype)localizedWithType:(AspirationTypes)data;
+ (instancetype)localizedWithUShort:(uint16_t)value;

- (AspirationTypes)aspirationType;
- (uint16_t)ushortValue;

- (NSString *)description;

@end

// MARK: - LocalizedZodiacSignes

/**
 * Localized Version of the ZodiacSignes Enum
 */
@interface LocalizedZodiacSignes : NSObject

@property (nonatomic, readonly, assign) ZodiacSigns data;

- (instancetype)initWithSign:(ZodiacSigns)data;
- (instancetype)initWithUShort:(uint16_t)value;

+ (instancetype)localizedWithSign:(ZodiacSigns)data;
+ (instancetype)localizedWithUShort:(uint16_t)value;

- (ZodiacSigns)zodiacSign;
- (uint16_t)ushortValue;

- (NSString *)description;

@end

// MARK: - LocalizedLifeSections

/**
 * Localized Version of the LifeSections Enum
 */
@interface LocalizedLifeSections : NSObject

@property (nonatomic, readonly, assign) LifeSections data;

- (instancetype)initWithSection:(LifeSections)data;
- (instancetype)initWithUShort:(uint16_t)value;

+ (instancetype)localizedWithSection:(LifeSections)data;
+ (instancetype)localizedWithUShort:(uint16_t)value;

- (LifeSections)lifeSection;
- (uint16_t)ushortValue;

- (NSString *)description;

@end

// MARK: - LocalizedCareers

/**
 * Localized Version of the Careers Enum
 */
@interface LocalizedCareers : NSObject

@property (nonatomic, readonly, assign) Careers data;

- (instancetype)initWithCareer:(Careers)data;
- (instancetype)initWithUInt:(uint32_t)value;

+ (instancetype)localizedWithCareer:(Careers)data;
+ (instancetype)localizedWithUInt:(uint32_t)value;

- (Careers)career;
- (uint32_t)uintValue;

- (NSString *)description;

@end

// MARK: - LocalizedFamilyTieTypes

/**
 * Localized Version of the FamilyTieTypes Enum
 */
@interface LocalizedFamilyTieTypes : NSObject

@property (nonatomic, readonly, assign) FamilyTieTypes data;

- (instancetype)initWithType:(FamilyTieTypes)data;
- (instancetype)initWithUInt:(uint32_t)value;

+ (instancetype)localizedWithType:(FamilyTieTypes)data;
+ (instancetype)localizedWithUInt:(uint32_t)value;

- (FamilyTieTypes)familyTieType;
- (uint32_t)uintValue;

- (NSString *)description;

@end

NS_ASSUME_NONNULL_END
