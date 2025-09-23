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
#import "Helper.h"

// MARK: - LocalizedRelationshipTypes Implementation

@implementation LocalizedRelationshipTypes

- (instancetype)initWithType:(RelationshipTypes)data {
    if (self = [super init]) {
        _data = data;
    }
    return self;
}

- (instancetype)initWithUShort:(uint16_t)value {
    return [self initWithType:(RelationshipTypes)value];
}

+ (instancetype)localizedWithType:(RelationshipTypes)data {
    return [[self alloc] initWithType:data];
}

+ (instancetype)localizedWithUShort:(uint16_t)value {
    return [[self alloc] initWithUShort:value];
}

- (RelationshipTypes)relationshipType {
    return self.data;
}

- (uint16_t)ushortValue {
    return (uint16_t)self.data;
}

- (BOOL)isEqualToType:(RelationshipTypes)type {
    return self.data == type;
}

- (BOOL)isEqualToLocalized:(LocalizedRelationshipTypes *)other {
    if (!other) return NO;
    return self.data == other.data;
}

+ (NSString *)stringForRelationshipType:(RelationshipTypes)relationshipType {
    switch (relationshipType) {
        case RelationshipTypesUnsetUnknown:
            return @"Unset_Unknown";
        case RelationshipTypesParent:
            return @"Parent";
        case RelationshipTypesChild:
            return @"Child";
        case RelationshipTypesSibling:
            return @"Sibling";
        case RelationshipTypesGrandparent:
            return @"Gradparent"; // Note: keeping original typo from C# source
        case RelationshipTypesGrandchild:
            return @"Grandchild";
        case RelationshipTypesNiceNephew:
            return @"Nice_Nephew";
        case RelationshipTypesAunt:
            return @"Aunt";
        case RelationshipTypesCousin:
            return @"Cousin";
        case RelationshipTypesSpouses:
            return @"Spouses";
        default:
            return [NSString stringWithFormat:@"Unknown_%d", (int)relationshipType];
    }
}

- (NSString *)description {
    NSString *enumString = [LocalizedRelationshipTypes stringForRelationshipType:self.data];
    NSString *key = [NSString stringWithFormat:@"RT_%@", enumString];
    NSString *localized = [Localization getString:key];
    return localized ?: enumString;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[LocalizedRelationshipTypes class]]) {
        return NO;
    }
    return [self isEqualToLocalized:(LocalizedRelationshipTypes *)object];
}

- (NSUInteger)hash {
    return (NSUInteger)self.data;
}

@end

// MARK: - LocalizedGrades Implementation

@implementation LocalizedGrades

- (instancetype)initWithGrade:(Grades)data {
    if (self = [super init]) {
        _data = data;
    }
    return self;
}

- (instancetype)initWithUShort:(uint16_t)value {
    return [self initWithGrade:(Grades)value];
}

+ (instancetype)localizedWithGrade:(Grades)data {
    return [[self alloc] initWithGrade:data];
}

+ (instancetype)localizedWithUShort:(uint16_t)value {
    return [[self alloc] initWithUShort:value];
}

- (Grades)grade {
    return self.data;
}

- (uint16_t)ushortValue {
    return (uint16_t)self.data;
}

+ (NSString *)stringForGrade:(Grades)grade {
    switch (grade) {
        case GradesUnknown:
            return @"Unknown";
        case GradesF:
            return @"F";
        case GradesDMinus:
            return @"DMinus";
        case GradesD:
            return @"D";
        case GradesDPlus:
            return @"DPlus";
        case GradesCMinus:
            return @"CMinus";
        case GradesC:
            return @"C";
        case GradesCPlus:
            return @"CPlus";
        case GradesBMinus:
            return @"BMinus";
        case GradesB:
            return @"B";
        case GradesBPlus:
            return @"BPlus";
        case GradesAMinus:
            return @"AMinus";
        case GradesA:
            return @"A";
        case GradesAPlus:
            return @"APlus";
        default:
            return [NSString stringWithFormat:@"Unknown_%d", (int)grade];
    }
}

- (NSString *)description {
    NSString *enumString = [LocalizedGrades stringForGrade:self.data];
    NSString *key = [NSString stringWithFormat:@"Grade_%@", enumString];
    NSString *localized = [Localization getString:key];
    return localized ?: enumString;
}

@end

// MARK: - LocalizedSchoolType Implementation

@implementation LocalizedSchoolType

- (instancetype)initWithSchoolType:(SchoolTypes)data {
    if (self = [super init]) {
        _data = data;
    }
    return self;
}

- (instancetype)initWithUInt:(uint32_t)value {
    return [self initWithSchoolType:(SchoolTypes)value];
}

+ (instancetype)localizedWithSchoolType:(SchoolTypes)data {
    return [[self alloc] initWithSchoolType:data];
}

+ (instancetype)localizedWithUInt:(uint32_t)value {
    return [[self alloc] initWithUInt:value];
}

- (SchoolTypes)schoolType {
    return self.data;
}

- (uint32_t)uintValue {
    return (uint32_t)self.data;
}

+ (NSString *)stringForSchoolType:(SchoolTypes)schoolType {
    switch (schoolType) {
        default:
            return [NSString stringWithFormat:@"SchoolType_%d", (int)schoolType];
    }
}

- (NSString *)description {
    NSString *enumString = [LocalizedSchoolType stringForSchoolType:self.data];
    NSString *localized = [Localization getString:enumString];
    return localized ?: enumString;
}

@end

// MARK: - LocalizedAspirationTypes Implementation

@implementation LocalizedAspirationTypes

- (instancetype)initWithType:(AspirationTypes)data {
    if (self = [super init]) {
        _data = data;
    }
    return self;
}

- (instancetype)initWithUShort:(uint16_t)value {
    return [self initWithType:(AspirationTypes)value];
}

+ (instancetype)localizedWithType:(AspirationTypes)data {
    return [[self alloc] initWithType:data];
}

+ (instancetype)localizedWithUShort:(uint16_t)value {
    return [[self alloc] initWithUShort:value];
}

- (AspirationTypes)aspirationType {
    return self.data;
}

- (uint16_t)ushortValue {
    return (uint16_t)self.data;
}

+ (NSString *)stringForAspirationType:(AspirationTypes)aspirationType {
    switch (aspirationType) {
        case AspirationTypesNothing:
            return @"Nothing";
        case AspirationTypesRomance:
            return @"Romance";
        case AspirationTypesFamily:
            return @"Family";
        case AspirationTypesFortune:
            return @"Fortune";
        case AspirationTypesReputation:
            return @"Reputation";
        case AspirationTypesKnowledge:
            return @"Knowledge";
        case AspirationTypesGrowup:
            return @"Growup";
        case AspirationTypesFun:
            return @"Fun";
        case AspirationTypesChees:
            return @"Chees";
        default:
            return [NSString stringWithFormat:@"Unknown_%d", (int)aspirationType];
    }
}

- (NSString *)description {
    NSString *enumString = [LocalizedAspirationTypes stringForAspirationType:self.data];
    NSString *key = [NSString stringWithFormat:@"SimPe.Data.MetaData.AspirationTypes.%@", enumString];
    NSString *localized = [Localization getString:key];
    return localized ?: enumString;
}

@end

// MARK: - LocalizedZodiacSignes Implementation

@implementation LocalizedZodiacSignes

- (instancetype)initWithSign:(ZodiacSigns)data {
    if (self = [super init]) {
        _data = data;
    }
    return self;
}

- (instancetype)initWithUShort:(uint16_t)value {
    return [self initWithSign:(ZodiacSigns)value];
}

+ (instancetype)localizedWithSign:(ZodiacSigns)data {
    return [[self alloc] initWithSign:data];
}

+ (instancetype)localizedWithUShort:(uint16_t)value {
    return [[self alloc] initWithUShort:value];
}

- (ZodiacSigns)zodiacSign {
    return self.data;
}

- (uint16_t)ushortValue {
    return (uint16_t)self.data;
}

+ (NSString *)stringForZodiacSign:(ZodiacSigns)zodiacSign {
    switch (zodiacSign) {
        case ZodiacSignsAries:
            return @"Aries";
        case ZodiacSignsTaurus:
            return @"Taurus";
        case ZodiacSignsGemini:
            return @"Gemini";
        case ZodiacSignsCancer:
            return @"Cancer";
        case ZodiacSignsLeo:
            return @"Leo";
        case ZodiacSignsVirgo:
            return @"Virgo";
        case ZodiacSignsLibra:
            return @"Libra";
        case ZodiacSignsScorpio:
            return @"Scorpio";
        case ZodiacSignsSagittarius:
            return @"Sagittarius";
        case ZodiacSignsCapricorn:
            return @"Capricorn";
        case ZodiacSignsAquarius:
            return @"Aquarius";
        case ZodiacSignsPisces:
            return @"Pisces";
        default:
            return [NSString stringWithFormat:@"Unknown_%d", (int)zodiacSign];
    }
}

- (NSString *)description {
    NSString *enumString = [LocalizedZodiacSignes stringForZodiacSign:self.data];
    NSString *localized = [Localization getString:enumString];
    return localized ?: enumString;
}

@end

// MARK: - LocalizedLifeSections Implementation

@implementation LocalizedLifeSections

- (instancetype)initWithSection:(LifeSections)data {
    if (self = [super init]) {
        _data = data;
    }
    return self;
}

- (instancetype)initWithUShort:(uint16_t)value {
    return [self initWithSection:(LifeSections)value];
}

+ (instancetype)localizedWithSection:(LifeSections)data {
    return [[self alloc] initWithSection:data];
}

+ (instancetype)localizedWithUShort:(uint16_t)value {
    return [[self alloc] initWithUShort:value];
}

- (LifeSections)lifeSection {
    return self.data;
}

- (uint16_t)ushortValue {
    return (uint16_t)self.data;
}

+ (NSString *)stringForLifeSection:(LifeSections)lifeSection {
    switch (lifeSection) {
        case LifeSectionsUnknown:
            return @"Unknown";
        case LifeSectionsBaby:
            return @"Baby";
        case LifeSectionsToddler:
            return @"Toddler";
        case LifeSectionsChild:
            return @"Child";
        case LifeSectionsTeen:
            return @"Teen";
        case LifeSectionsAdult:
            return @"Adult";
        case LifeSectionsElder:
            return @"Elder";
        case LifeSectionsYoungAdult:
            return @"YoungAdult";
        default:
            return [NSString stringWithFormat:@"Unknown_%d", (int)lifeSection];
    }
}

- (NSString *)description {
    NSString *enumString = [LocalizedLifeSections stringForLifeSection:self.data];
    NSString *localized = [Localization getString:enumString];
    return localized ?: enumString;
}

@end

// MARK: - LocalizedCareers Implementation

@implementation LocalizedCareers

- (instancetype)initWithCareer:(Careers)data {
    if (self = [super init]) {
        _data = data;
    }
    return self;
}

- (instancetype)initWithUInt:(uint32_t)value {
    return [self initWithCareer:(Careers)value];
}

+ (instancetype)localizedWithCareer:(Careers)data {
    return [[self alloc] initWithCareer:data];
}

+ (instancetype)localizedWithUInt:(uint32_t)value {
    return [[self alloc] initWithUInt:value];
}

- (Careers)career {
    return self.data;
}

- (uint32_t)uintValue {
    return (uint32_t)self.data;
}

+ (NSString *)stringForCareer:(Careers)career {
    switch (career) {
        case CareersUnknown:
            return @"Unknown";
        case CareersUnemployed:
            return @"Unemployed";
        case CareersMilitary:
            return @"Military";
        case CareersPolitics:
            return @"Politics";
        case CareersScience:
            return @"Science";
        case CareersMedical:
            return @"Medical";
        case CareersAthletic:
            return @"Athletic";
        case CareersEconomy:
            return @"Economy";
        default:
            return [NSString stringWithFormat:@"Career_%d", (int)career];
    }
}

- (NSString *)description {
    NSString *enumString = [LocalizedCareers stringForCareer:self.data];
    NSString *localized = [Localization getString:enumString];
    return localized ?: enumString;
}

@end

// MARK: - LocalizedFamilyTieTypes Implementation

@implementation LocalizedFamilyTieTypes

- (instancetype)initWithType:(FamilyTieTypes)data {
    if (self = [super init]) {
        _data = data;
    }
    return self;
}

- (instancetype)initWithUInt:(uint32_t)value {
    return [self initWithType:(FamilyTieTypes)value];
}

+ (instancetype)localizedWithType:(FamilyTieTypes)data {
    return [[self alloc] initWithType:data];
}

+ (instancetype)localizedWithUInt:(uint32_t)value {
    return [[self alloc] initWithUInt:value];
}

- (FamilyTieTypes)familyTieType {
    return self.data;
}

- (uint32_t)uintValue {
    return (uint32_t)self.data;
}

+ (NSString *)stringForFamilyTieType:(FamilyTieTypes)familyTieType {
    switch (familyTieType) {
        case FamilyTieTypesMyMotherIs:
            return @"MyMotherIs";
        case FamilyTieTypesMyFatherIs:
            return @"MyFatherIs";
        case FamilyTieTypesImMarriedTo:
            return @"ImMarriedTo";
        case FamilyTieTypesMySiblingIs:
            return @"MySiblingIs";
        case FamilyTieTypesMyChildIs:
            return @"MyChildIs";
        default:
            return [NSString stringWithFormat:@"Unknown_%d", (int)familyTieType];
    }
}

- (NSString *)description {
    NSString *enumString = [LocalizedFamilyTieTypes stringForFamilyTieType:self.data];
    if (Helper.startedGui == ExecutableDefault) {
        NSString *key = [NSString stringWithFormat:@"SimPe.Data.MetaData.FamilyTieTypes.%@", enumString];
        NSString *localized = [Localization getString:key];
        return localized ?: enumString;
    } else {
        NSString *localized = [Localization getString:enumString];
        return localized ?: enumString;
    }
}

@end
