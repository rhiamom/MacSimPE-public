//
//  SDesc.h
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

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "AbstractWrapper.h"
#import "ISDesc.h"
#import "FlagBase.h"
#import "MetaData.h"

// Forward declarations
@class BinaryReader, BinaryWriter;
@protocol ISimNames, ISimFamilyNames, ISimDescriptions, IPackageFile, IPackedFileDescriptor;

NS_ASSUME_NONNULL_BEGIN

// MARK: - Enumerations

/**
 * Known versions for SDSC Files
 */
typedef NS_ENUM(NSInteger, SDescVersion) {
    SDescVersionUnknown = 0,
    SDescVersionBaseGame = 0x20,
    SDescVersionUniversity = 0x22,
    SDescVersionNightlife = 0x29,
    SDescVersionBusiness = 0x2a,
    SDescVersionPets = 0x2c,
    SDescVersionCastaway = 0x2d,
    SDescVersionVoyage = 0x2e,
    SDescVersionVoyageB = 0x2f,
    //SDescVersionFreetime = 0x33,
    //SDescVersionApartment = 0x36,
};

/**
 * Job assignments from Text\Live.package
 */
typedef NS_ENUM(uint16_t, JobAssignment) {
    JobAssignmentNothing = 0x00,
    JobAssignmentChef = 0x01,
    JobAssignmentHost = 0x02,
    JobAssignmentServer = 0x03,
    JobAssignmentCashier = 0x04,
    JobAssignmentBartender = 0x05,
    JobAssignmentBarista = 0x06,
    JobAssignmentDJ = 0x07,
    JobAssignmentSellLemonade = 0x08,
    JobAssignmentStylist = 0x09,
    JobAssignmentTidy = 0x0A,
    JobAssignmentRestock = 0x0B,
    JobAssignmentSales = 0x0C,
    JobAssignmentMakeToys = 0x0D,
    JobAssignmentArrangeFlowers = 0x0E,
    JobAssignmentBuildRobots = 0x0F
};

/**
 * Hobby types
 */
/*typedef NS_ENUM(uint16_t, Hobbies) {
    HobbiesCuisine = 0xCC,
    HobbiesArts = 0xCD,
    HobbiesFilm = 0xCE,
    HobbiesSport = 0xCF,
    HobbiesGames = 0xD0,
    HobbiesNature = 0xD1,
    HobbiesTinkering = 0xD2,
    HobbiesFitness = 0xD3,
    HobbiesScience = 0xD4,
    HobbiesMusic = 0xD5,
    HobbiesSecret = 0xD6
};*/

/**
 * Species types
 */
typedef NS_ENUM(uint16_t, SpeciesType) {
    SpeciesTypeHuman = 0,
    SpeciesTypeLargeDog = 1,
    SpeciesTypeSmallDog = 2,
    SpeciesTypeCat = 3
};

// MARK: - Flag Classes

/**
 * Ghost flags
 */
@interface GhostFlags : FlagBase
@property (nonatomic, assign) BOOL isGhost;
@property (nonatomic, assign) BOOL canPassThroughObjects;
@property (nonatomic, assign) BOOL canPassThroughWalls;
@property (nonatomic, assign) BOOL canPassThroughPeople;
@property (nonatomic, assign) BOOL ignoreTraversalCosts;
@end

/**
 * Body flags
 */
@interface BodyFlags : FlagBase
@property (nonatomic, assign) BOOL fat;
@property (nonatomic, assign) BOOL pregnantFull;
@property (nonatomic, assign) BOOL pregnantHalf;
@property (nonatomic, assign) BOOL pregnantHidden;
@property (nonatomic, assign) BOOL fit;
@end

/**
 * Pet traits flags
 */
@interface PetTraits : FlagBase
@property (nonatomic, assign) BOOL gifted;
@property (nonatomic, assign) BOOL doofus;
@property (nonatomic, assign) BOOL hyper;
@property (nonatomic, assign) BOOL lazy;
@property (nonatomic, assign) BOOL independent;
@property (nonatomic, assign) BOOL friendly;
@property (nonatomic, assign) BOOL aggressive;
@property (nonatomic, assign) BOOL cowardly;
@property (nonatomic, assign) BOOL pigpen;
@property (nonatomic, assign) BOOL finicky;
- (void)setTrait:(NSInteger)nr value:(BOOL)value;
- (BOOL)getTrait:(NSInteger)nr;
@end

// MARK: - Data Classes

/**
 * Character description data
 */
@interface CharacterDescription : Serializer
@property (nonatomic, strong) GhostFlags *ghostFlag;
@property (nonatomic, strong) BodyFlags *bodyFlag;
@property (nonatomic, assign) uint16_t autonomyLevel;
@property (nonatomic, assign) uint16_t npcType;
@property (nonatomic, assign) uint16_t motivesStatic;
@property (nonatomic, assign) uint16_t voiceType;
@property (nonatomic, assign) SchoolTypes schoolType;
@property (nonatomic, assign) Grades grade;
@property (nonatomic, assign) int16_t careerPerformance;
@property (nonatomic, assign) Careers career;
@property (nonatomic, assign) uint16_t careerLevel;
@property (nonatomic, assign) ZodiacSigns zodiacSign;
@property (nonatomic, assign) AspirationTypes aspiration;
@property (nonatomic, assign) Gender gender;
@property (nonatomic, assign) LifeSections lifeSection;
@property (nonatomic, assign) uint16_t age;
@property (nonatomic, assign) uint16_t prevAgeDays;
@property (nonatomic, assign) uint16_t ageDuration;
@property (nonatomic, assign) uint16_t blizLifelinePoints;
@property (nonatomic, assign) int16_t lifelinePoints;
@property (nonatomic, assign) uint32_t lifelineScore;
@end

/**
 * Character attributes (personality)
 */
@interface CharacterAttributes : Serializer
@property (nonatomic, assign) uint16_t neat;
@property (nonatomic, assign) uint16_t outgoing;
@property (nonatomic, assign) uint16_t active;
@property (nonatomic, assign) uint16_t playful;
@property (nonatomic, assign) uint16_t nice;
@end

/**
 * Sim decay values (needs)
 */
@interface SimDecay : Serializer
@property (nonatomic, assign) int16_t hunger;
@property (nonatomic, assign) int16_t comfort;
@property (nonatomic, assign) int16_t bladder;
@property (nonatomic, assign) int16_t energy;
@property (nonatomic, assign) int16_t hygiene;
@property (nonatomic, assign) int16_t social;
@property (nonatomic, assign) int16_t fun;
@end

/**
 * Skill attributes
 */
@interface SkillAttributes : Serializer
@property (nonatomic, assign) uint16_t romance;
@property (nonatomic, assign) uint16_t fatness;
@property (nonatomic, assign) uint16_t cooking;
@property (nonatomic, assign) uint16_t mechanical;
@property (nonatomic, assign) uint16_t charisma;
@property (nonatomic, assign) uint16_t body;
@property (nonatomic, assign) uint16_t logic;
@property (nonatomic, assign) uint16_t creativity;
@property (nonatomic, assign) uint16_t cleaning;
@end

/**
 * Interest attributes
 */
@interface InterestAttributes : Serializer
@property (nonatomic, assign) uint16_t politics;
@property (nonatomic, assign) uint16_t money;
@property (nonatomic, assign) uint16_t crime;
@property (nonatomic, assign) uint16_t environment;
@property (nonatomic, assign) uint16_t entertainment;
@property (nonatomic, assign) uint16_t culture;
@property (nonatomic, assign) uint16_t food;
@property (nonatomic, assign) uint16_t health;
@property (nonatomic, assign) uint16_t fashion;
@property (nonatomic, assign) uint16_t sports;
@property (nonatomic, assign) uint16_t paranormal;
@property (nonatomic, assign) uint16_t travel;
@property (nonatomic, assign) uint16_t work;
@property (nonatomic, assign) uint16_t weather;
@property (nonatomic, assign) uint16_t animals;
@property (nonatomic, assign) uint16_t school;
@property (nonatomic, assign) uint16_t toys;
@property (nonatomic, assign) uint16_t scifi;
@property (nonatomic, assign) int16_t femalePreference;
@property (nonatomic, assign) int16_t malePreference;
@end

// MARK: - Forward Declarations
@class SimRelationAttribute, SdscUniversity, SdscNightlife, SdscBusiness;
@class SdscPets, SdscVoyage, SdscFreetime, SdscApartment;

/**
 * Represents a Sim Description (SDSC) file
 */
@interface SDesc : AbstractWrapper <ISDesc>

// MARK: - Core Properties
@property (nonatomic, assign) uint32_t simId;
@property (nonatomic, assign) uint16_t instance;
@property (nonatomic, assign) uint16_t familyInstance;
@property (nonatomic, readonly, assign) SDescVersion version;
@property (nonatomic, assign) uint16_t unlinked;
@property (nonatomic, assign) uint8_t endByte;

// MARK: - Name and Identity
@property (nonatomic, readonly, copy) NSString *simName;
@property (nonatomic, readonly, copy) NSString *simFamilyName;
@property (nonatomic, readonly, copy) NSString *householdName;
@property (nonatomic, readonly, copy, nullable) NSString *characterFileName;
@property (nonatomic, readonly, strong, nullable) NSImage *image;
@property (nonatomic, readonly, assign) BOOL hasImage;
@property (nonatomic, readonly, assign) BOOL availableCharacterData;

// MARK: - Data Components
@property (nonatomic, strong) CharacterDescription *characterDescription;
@property (nonatomic, strong) CharacterAttributes *character;
@property (nonatomic, strong) CharacterAttributes *geneticCharacter;
@property (nonatomic, strong) SimDecay *decay;
@property (nonatomic, strong) SkillAttributes *skills;
@property (nonatomic, strong) InterestAttributes *interests;
@property (nonatomic, strong) SimRelationAttribute *relations;

// MARK: - Expansion Pack Data
@property (nonatomic, strong, nullable) SdscUniversity *university;
@property (nonatomic, strong, nullable) SdscNightlife *nightlife;
@property (nonatomic, strong, nullable) SdscBusiness *business;
@property (nonatomic, strong, nullable) SdscPets *pets;
@property (nonatomic, strong, nullable) SdscVoyage *voyage;
@property (nonatomic, strong, nullable) SdscFreetime *freetime;
@property (nonatomic, strong, nullable) SdscApartment *apartment;

// MARK: - Providers
@property (nonatomic, weak, nullable) id<ISimNames> nameProvider;
@property (nonatomic, weak, nullable) id<ISimFamilyNames> familyNameProvider;
@property (nonatomic, weak, nullable) id<ISimDescriptions> descriptionProvider;

// MARK: - Initialization
- (instancetype)init;
- (instancetype)initWithNameProvider:(nullable id<ISimNames>)nameProvider
                    familyNameProvider:(nullable id<ISimFamilyNames>)familyNameProvider
                   descriptionProvider:(nullable id<ISimDescriptions>)descriptionProvider;

// MARK: - Static Methods
+ (nullable SDesc *)findForSimId:(uint32_t)simId inPackage:(id<IPackageFile>)package;

// MARK: - Name Management
- (BOOL)changeNamesWithFirstName:(NSString *)firstName familyName:(NSString *)familyName;

// MARK: - Provider Management
- (void)setProviders:(id<IWrapperRegistry>)providerRegistry;

// MARK: - File Operations
@property (nonatomic, readonly, strong) NSArray<NSNumber *> *assignableTypes;
@property (nonatomic, readonly, strong) NSData *fileSignature;

@end

/**
 * Sim relationship data
 */
@interface SimRelationAttribute : Serializer
@property (nonatomic, weak) SDesc *parent;
@property (nonatomic, strong) NSArray *simInstances;
- (instancetype)initWithParent:(SDesc *)parent;
- (SDesc *)getSimDescription:(uint16_t)instance;
- (id)getSimRelationships:(uint16_t)instance;
@end

// MARK: - Expansion Pack Data Classes

/**
 * University expansion data
 */
@interface SdscUniversity : Serializer
@property (nonatomic, assign) Majors major;
@property (nonatomic, assign) uint16_t time;
@property (nonatomic, assign) uint16_t semester;
@property (nonatomic, assign) uint16_t effort;
@property (nonatomic, assign) uint16_t grade;
@property (nonatomic, assign) uint16_t onCampus;
@property (nonatomic, assign) uint16_t influence;
- (void)unserialize:(BinaryReader *)reader;
- (void)serialize:(BinaryWriter *)writer;
@end

/**
 * Nightlife expansion data
 */
@interface SdscNightlife : Serializer
@property (nonatomic, assign) SpeciesType species;
@property (nonatomic, assign) uint16_t routeStartSlotOwnerID;
@property (nonatomic, assign) uint16_t attractionTraits1;
@property (nonatomic, assign) uint16_t attractionTraits2;
@property (nonatomic, assign) uint16_t attractionTraits3;
@property (nonatomic, assign) uint16_t attractionTurnOns1;
@property (nonatomic, assign) uint16_t attractionTurnOns2;
@property (nonatomic, assign) uint16_t attractionTurnOns3;
@property (nonatomic, assign) uint16_t attractionTurnOffs1;
@property (nonatomic, assign) uint16_t attractionTurnOffs2;
@property (nonatomic, assign) uint16_t attractionTurnOffs3;
@property (nonatomic, assign) uint16_t countdown;
@property (nonatomic, assign) uint16_t perfumeDuration;
@property (nonatomic, assign) uint16_t dateTimer;
@property (nonatomic, assign) uint16_t dateScore;
@property (nonatomic, assign) uint16_t dateUnlockCounter;
@property (nonatomic, assign) uint16_t lovePotionDuration;
@property (nonatomic, assign) uint16_t aspirationScoreLock;
@property (nonatomic, readonly, assign) BOOL isHuman;
- (void)unserialize:(BinaryReader *)reader version:(SDescVersion)ver;
- (void)serialize:(BinaryWriter *)writer version:(SDescVersion)ver;
@end

/**
 * Business expansion data
 */
@interface SdscBusiness : Serializer
@property (nonatomic, assign) uint16_t lotID;
@property (nonatomic, assign) uint16_t salary;
@property (nonatomic, assign) uint16_t flags;
@property (nonatomic, assign) JobAssignment assignment;
- (void)unserialize:(BinaryReader *)reader;
- (void)serialize:(BinaryWriter *)writer;
@end

/**
 * Pets expansion data
 */
@interface SdscPets : Serializer
@property (nonatomic, strong) PetTraits *petTraits;
- (void)unserialize:(BinaryReader *)reader;
- (void)serialize:(BinaryWriter *)writer;
@end

/**
 * Voyage expansion data
 */
@interface SdscVoyage : Serializer
@property (nonatomic, assign) uint16_t daysLeft;
@property (nonatomic, assign) uint64_t collectiblesPlain;
- (void)unserialize:(BinaryReader *)reader;
- (void)serialize:(BinaryWriter *)writer;
- (void)unserializeMem:(BinaryReader *)reader;
- (void)serializeMem:(BinaryWriter *)writer;
@end

/**
 * Freetime expansion data
 */
@interface SdscFreetime : Serializer
@property (nonatomic, weak) SDesc *parent;
- (instancetype)initWithParent:(SDesc *)parent;
- (void)unserialize:(BinaryReader *)reader;
- (void)serialize:(BinaryWriter *)writer;
@end

/**
 * Apartment expansion data
 */
@interface SdscApartment : Serializer
@property (nonatomic, weak) SDesc *parent;
- (instancetype)initWithParent:(SDesc *)parent;
- (void)unserialize:(BinaryReader *)reader;
- (void)serialize:(BinaryWriter *)writer;
@end

NS_ASSUME_NONNULL_END
