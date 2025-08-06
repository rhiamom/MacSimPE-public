//
//  MetaData.h
//  MacSimpe
//
//  Created by Catherine Gramze on 7/25/25.
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
// ***************************************************************************

#import "TypeAlias.h"
#import <Foundation/Foundation.h>


// MARK: - Core Enumerations

typedef NS_ENUM(uint32_t, DataTypes) {
    DataTypesUInteger = 0xEB61E4F7,
    DataTypesString = 0x0B8BEA18,
    DataTypesSingle = 0xABC78708,
    DataTypesBoolean = 0xCBA908E1,
    DataTypesInteger = 0x0C264712
};

typedef NS_ENUM(uint32_t, IndexTypes) {
    ptLongFileIndex,
    ptShortFileIndex
};

typedef NS_ENUM(uint32_t, ChildAge) {
    ChildAgeBaby = 0x20,
    ChildAgeToddler = 0x01,
    ChildAgeChild = 0x02,
    ChildAgeTeen = 0x04,
    ChildAgeAdult = 0x08,
    ChildAgeElder = 0x10,
    ChildAgeYoungAdult = 0x40
};

typedef NS_ENUM(uint16_t, ChildStatus) {
    ChildStatusBaby = 0x01,
    ChildStatusToddler = 0x02,
    ChildStatusChild = 0x03,
    ChildStatusTeen = 0x10,
    ChildStatusAdult = 0x13,
    ChildStatusElder = 0x33,
    ChildStatusYoungAdult = 0x40
};

typedef NS_ENUM(uint16_t, ChildFamily) {
    ChildFamilyParent = 0x01,
    ChildFamilyChild = 0x02,
    ChildFamilySibling = 0x03,
    ChildFamilyGrandparent = 0x04,
    ChildFamilyGrandchild = 0x05,
    ChildFamilySpouses = 0x09,
    ChildFamilyChildInlaw = 0x0A,
    ChildFamilyParentInlaw = 0x0B,
    ChildFamilySiblingInlaw = 0x0C
};

typedef NS_ENUM(uint16_t, SimGender) {
    SimGenderFemale = 0x01,
    SimGenderMale = 0x02,
    SimGenderUnknown = 0xFFFF
};

typedef NS_OPTIONS(uint32_t, SkinCategories) {
    SkinCategoriesCasual1 = 0x01,
    SkinCategoriesCasual2 = 0x02,
    SkinCategoriesCasual3 = 0x04,
    SkinCategoriesEveryday = 0x07, // Casual1 | Casual2 | Casual3
    SkinCategoriesSwimmwear = 0x08,
    SkinCategoriesPj = 0x10,
    SkinCategoriesFormal = 0x20,
    SkinCategoriesUndies = 0x40,
    SkinCategoriesSkin = 0x80,
    SkinCategoriesPregnant = 0x100,
    SkinCategoriesActivewear = 0x200,
    SkinCategoriesTryOn = 0x400,
    SkinCategoriesNakedOverlay = 0x800,
    SkinCategoriesOuterwear = 0x1000
};

typedef NS_ENUM(uint32_t, SchoolTypes) {
    SchoolTypesUnknown = 0x00000000,
    SchoolTypesPublic = 0xD06788B5,
    SchoolTypesPrivate = 0xCC8F4C11
};

typedef NS_ENUM(uint16_t, Grades) {
    GradesUnknown = 0x00,
    GradesF = 0x01,
    GradesDMinus = 0x02,
    GradesD = 0x03,
    GradesDPlus = 0x04,
    GradesCMinus = 0x05,
    GradesC = 0x06,
    GradesCPlus = 0x07,
    GradesBMinus = 0x08,
    GradesB = 0x09,
    GradesBPlus = 0x0A,
    GradesAMinus = 0x0B,
    GradesA = 0x0C,
    GradesAPlus = 0x0D
};

typedef NS_ENUM(uint8_t, Languages) {
    LanguagesUnknown = 0x00,
    LanguagesEnglish = 0x01,
    LanguagesEnglishUk = 0x02,
    LanguagesFrench = 0x03,
    LanguagesGerman = 0x04,
    LanguagesItalian = 0x05,
    LanguagesSpanish = 0x06,
    LanguagesDutch = 0x07,
    LanguagesDanish = 0x08,
    LanguagesSwedish = 0x09,
    LanguagesNorwegian = 0x0A,
    LanguagesFinnish = 0x0B,
    LanguagesHebrew = 0x0C,
    LanguagesRussian = 0x0D,
    LanguagesPortuguese = 0x0E,
    LanguagesJapanese = 0x0F,
    LanguagesPolish = 0x10,
    LanguagesSimplifiedChinese = 0x11,
    LanguagesTraditionalChinese = 0x12,
    LanguagesThai = 0x13,
    LanguagesKorean = 0x14,
    LanguagesCzech = 0x1A,
    LanguagesBrazilian = 0x23
};

typedef NS_ENUM(uint16_t, FormatCode) {
    FormatCodeNormal = 0xFFFD
};

typedef NS_ENUM(uint16_t, AspirationTypes) {
    AspirationTypesNothing = 0x00,
    AspirationTypesRomance = 0x01,
    AspirationTypesFamily = 0x02,
    AspirationTypesFortune = 0x04,
    AspirationTypesReputation = 0x10,
    AspirationTypesKnowledge = 0x20,
    AspirationTypesGrowup = 0x40,
    AspirationTypesFun = 0x80,
    AspirationTypesChees = 0x100
};

typedef NS_ENUM(uint8_t, RelationshipStateBits) {
    RelationshipStateBitsCrush = 0x00,
    RelationshipStateBitsLove = 0x01,
    RelationshipStateBitsEngaged = 0x02,
    RelationshipStateBitsMarried = 0x03,
    RelationshipStateBitsFriends = 0x04,
    RelationshipStateBitsBuddies = 0x05,
    RelationshipStateBitsSteady = 0x06,
    RelationshipStateBitsEnemy = 0x07,
    RelationshipStateBitsFamily = 0x0E,
    RelationshipStateBitsKnown = 0x0F
};

typedef NS_ENUM(uint8_t, UIFlags2Names) {
    UIFlags2NamesBestFriendForever = 0x00
};

typedef NS_ENUM(uint16_t, ZodiacSigns) {
    ZodiacSignsAries = 0x01,
    ZodiacSignsTaurus = 0x02,
    ZodiacSignsGemini = 0x03,
    ZodiacSignsCancer = 0x04,
    ZodiacSignsLeo = 0x05,
    ZodiacSignsVirgo = 0x06,
    ZodiacSignsLibra = 0x07,
    ZodiacSignsScorpio = 0x08,
    ZodiacSignsSagittarius = 0x09,
    ZodiacSignsCapricorn = 0x0A,
    ZodiacSignsAquarius = 0x0B,
    ZodiacSignsPisces = 0x0C
};

typedef NS_ENUM(uint32_t, Majors) {
    MajorsUnset = 0,
    MajorsUnknown = 0xFFFFFFFF,
    MajorsArt = 0x2E9CF007,
    MajorsBiology = 0x4E9CF02B,
    MajorsDrama = 0x4E9CF04D,
    MajorsEconomics = 0xEE9CF044,
    MajorsHistory = 0x2E9CF074,
    MajorsLiterature = 0xCE9CF085,
    MajorsMathematics = 0xEE9CF08D,
    MajorsPhilosophy = 0x2E9CF057,
    MajorsPhysics = 0xAE9CF063,
    MajorsPoliticalScience = 0x4E9CF06D,
    MajorsPsychology = 0xCE9CF07C,
    MajorsUndeclared = 0x8E97BF1D
};

typedef NS_ENUM(uint32_t, FamilyTieTypes) {
    FamilyTieTypesMyMotherIs = 0x00,
    FamilyTieTypesMyFatherIs = 0x01,
    FamilyTieTypesImMarriedTo = 0x02,
    FamilyTieTypesMySiblingIs = 0x03,
    FamilyTieTypesMyChildIs = 0x04
};

typedef NS_ENUM(uint32_t, RelationshipTypes) {
    RelationshipTypesUnsetUnknown = 0x00,
    RelationshipTypesParent = 0x01,
    RelationshipTypesChild = 0x02,
    RelationshipTypesSibling = 0x03,
    RelationshipTypesGradparent = 0x04,
    RelationshipTypesGrandchild = 0x05,
    RelationshipTypesNiceNephew = 0x07,
    RelationshipTypesAunt = 0x06,
    RelationshipTypesCousin = 0x08,
    RelationshipTypesSpouses = 0x09
};

typedef NS_ENUM(uint16_t, LifeSections) {
    LifeSectionsUnknown = 0x00,
    LifeSectionsBaby = 0x01,
    LifeSectionsToddler = 0x02,
    LifeSectionsChild = 0x03,
    LifeSectionsTeen = 0x10,
    LifeSectionsAdult = 0x13,
    LifeSectionsElder = 0x33,
    LifeSectionsYoungAdult = 0x40
};

typedef NS_ENUM(uint16_t, Gender) {
    GenderMale = 0x00,
    GenderFemale = 0x01
};

typedef NS_ENUM(uint32_t, Careers) {
    CareersUnknown = 0xFFFFFFFF,
    CareersUnemployed = 0x00000000,
    CareersMilitary = 0x6C9EBD32,
    CareersPolitics = 0x2C945B14,
    CareersScience = 0x0C9EBD47,
    CareersMedical = 0x0C7761FD,
    CareersAthletic = 0x2C89E95F,
    CareersEconomy = 0x45196555,
    CareersLawEnforcement = 0xAC9EBCE3,
    CareersCulinary = 0xEC9EBD5F,
    CareersSlacker = 0xEC77620B,
    CareersCriminal = 0x6C9EBD0E
    // Add more careers as needed
};

typedef NS_ENUM(int32_t, NeighborhoodSlots) {
    NeighborhoodSlotsSims = 0,
    NeighborhoodSlotsSimsIntern = 1,
    NeighborhoodSlotsFamilies = 2,
    NeighborhoodSlotsFamiliesIntern = 3,
    NeighborhoodSlotsLots = 4,
    NeighborhoodSlotsLotsIntern = 5
};

typedef NS_ENUM(uint32_t, TextureOverlayTypes) {
    TextureOverlayTypesBeard = 0x00,
    TextureOverlayTypesEyeBrow = 0x01,
    TextureOverlayTypesLipstick = 0x02,
    TextureOverlayTypesEye = 0x03,
    TextureOverlayTypesMask = 0x04,
    TextureOverlayTypesGlasses = 0x05,
    TextureOverlayTypesBlush = 0x06,
    TextureOverlayTypesEyeShadow = 0x07
};

typedef NS_ENUM(uint8_t, ObjRoomSortBits) {
    ObjRoomSortBitsKitchen = 0x00,
    ObjRoomSortBitsBedroom = 0x01,
    ObjRoomSortBitsBathroom = 0x02,
    ObjRoomSortBitsLivingRoom = 0x03,
    ObjRoomSortBitsOutside = 0x04,
    ObjRoomSortBitsDiningRoom = 0x05,
    ObjRoomSortBitsMisc = 0x06,
    ObjRoomSortBitsStudy = 0x07,
    ObjRoomSortBitsKids = 0x08
};

typedef NS_ENUM(uint8_t, ObjFunctionSortBits) {
    ObjFunctionSortBitsSeating = 0x00,
    ObjFunctionSortBitsSurfaces = 0x01,
    ObjFunctionSortBitsAppliances = 0x02,
    ObjFunctionSortBitsElectronics = 0x03,
    ObjFunctionSortBitsPlumbing = 0x04,
    ObjFunctionSortBitsDecorative = 0x05,
    ObjFunctionSortBitsGeneral = 0x06,
    ObjFunctionSortBitsLighting = 0x07,
    ObjFunctionSortBitsHobbies = 0x08,
    ObjFunctionSortBitsAspirationRewards = 0x0A,
    ObjFunctionSortBitsCareerRewards = 0x0B
};

typedef NS_ENUM(uint16_t, ObjectTypes) {
    ObjectTypesUnknown = 0x0000,
    ObjectTypesPerson = 0x0002,
    ObjectTypesNormal = 0x0004,
    ObjectTypesArchitecturalSupport = 0x0005,
    ObjectTypesSimType = 0x0007,
    ObjectTypesDoor = 0x0008,
    ObjectTypesWindow = 0x0009,
    ObjectTypesStairs = 0x000A,
    ObjectTypesModularStairs = 0x000B,
    ObjectTypesModularStairsPortal = 0x000C,
    ObjectTypesVehicle = 0x000D,
    ObjectTypesOutfit = 0x000E,
    ObjectTypesMemory = 0x000F,
    ObjectTypesTemplate = 0x0010,
    ObjectTypesTiles = 0x0013
};

typedef NS_ENUM(uint16_t, ExpansionPack) {
    ExpansionPackBaseGame = 0x00,
    ExpansionPackUniversity = 0x01,
    ExpansionPackNightlife = 0x02,
    ExpansionPackBusiness = 0x03,
    ExpansionPackFamilyFunStuff = 0x04,
    ExpansionPackGlamourLife = 0x05,
    ExpansionPackPets = 0x06,
    ExpansionPackSeasons = 0x07,
    ExpansionPackBonVoyage = 0x0A
};

@interface MetaData : NSObject

// MARK: - Core Constants
+ (uint32_t)DIRECTORY_FILE;
+ (uint16_t)COMPRESS_SIGNATURE;
+ (uint32_t)RELATION_FILE;
+ (uint32_t)STRING_FILE;
+ (uint32_t)PIE_STRING_FILE;
+ (uint32_t)SIM_DESCRIPTION_FILE;
+ (uint32_t)SIM_IMAGE_FILE;
+ (uint32_t)FAMILY_TIES_FILE;
+ (uint32_t)BHAV_FILE;
+ (uint32_t)GLOB_FILE;
+ (uint32_t)OBJD_FILE;
+ (uint32_t)CTSS_FILE;
+ (uint32_t)NAME_MAP;
+ (uint32_t)GLUA;
+ (uint32_t)OLUA;
+ (uint32_t)MEMORIES;
+ (uint32_t)SDNA;
+ (uint32_t)GZPS;
+ (uint32_t)XWNT;
+ (uint32_t)REF_FILE;
+ (uint32_t)IDNO;
+ (uint32_t)HOUS;
+ (uint32_t)SLOT;
+ (uint32_t)GMND;
+ (uint32_t)TXMT;
+ (uint32_t)TXTR;
+ (uint32_t)LIFO;
+ (uint32_t)SHPE;
+ (uint32_t)CRES;
+ (uint32_t)GMDC;
+ (uint32_t)MMAT;
+ (uint32_t)BINX;
+ (uint32_t)XSTN;
+ (uint32_t)XMOL;
+ (uint32_t)XHTN;
+ (uint32_t)AGED;
+ (uint32_t)FCRG;
+ (uint32_t)FCNT;
+ (uint32_t)FCMD;
+ (uint32_t)FCAR;
+ (uint32_t)XPBO;
+ (uint32_t)XOBJ;
+ (uint32_t)XROF;
+ (uint32_t)XFLR;
+ (uint32_t)XFNC;
+ (uint32_t)XNGB;
+ (uint32_t)ANIM;
+ (uint32_t)LDIR;
+ (uint32_t)LAMB;
+ (uint32_t)LPNT;
+ (uint32_t)LSPT;
+ (uint32_t)CUSTOM_GROUP;
+ (uint32_t)GLOBAL_GROUP;
+ (uint32_t)LOCAL_GROUP;

// MARK: - Static Methods
+ (NSArray<NSNumber *> *)rcolList;
+ (NSArray<NSNumber *> *)compressionCandidates;
+ (NSArray<NSNumber *> *)cachedFileTypes;
+ (ChildAge)ageTranslation:(LifeSections)age;
+ (TypeAlias *)findTypeAlias:(uint32_t)pfdType;

// MARK: - Semi-Global Methods
+ (uint32_t)semiGlobalID:(NSString *)sgname;
+ (NSString *)semiGlobalName:(uint32_t)sgid;
+ (NSString *)findSemiGlobal:(NSString *)name;

// MARK: - CEP String Constants
+ (NSString *)GMND_PACKAGE;
+ (NSString *)MMAT_PACKAGE;
+ (NSString *)ZCEP_FOLDER;
+ (NSString *)CTLG_FOLDER;

@end
