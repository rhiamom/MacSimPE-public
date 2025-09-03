//
//  SDesc.m
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

#import "SDescWrapper.h"
#import "BinaryReader.h"
#import "BinaryWriter.h"
#import "MemoryStream.h"
#import "Helper.h"
#import "Localization.h"
#import "IPackedFileDescriptor.h"
#import "IPackageFile.h"
#import "IWrapperInfo.h"
#import "AbstractWrapperInfo.h"
#import "MetaData.h"
#import "FileTable.h"
#import "ExtSDesc.h"

// MARK: - GhostFlags Implementation

@implementation GhostFlags

- (instancetype)initWithValue:(uint16_t)flags {
    return [super initWithValue:flags];
}

- (instancetype)init {
    return [super init];
}

- (BOOL)isGhost {
    return [self getBit:0];
}

- (void)setIsGhost:(BOOL)isGhost {
    [self setBit:0 value:isGhost];
}

- (BOOL)canPassThroughObjects {
    return [self getBit:1];
}

- (void)setCanPassThroughObjects:(BOOL)canPassThroughObjects {
    [self setBit:1 value:canPassThroughObjects];
}

- (BOOL)canPassThroughWalls {
    return [self getBit:2];
}

- (void)setCanPassThroughWalls:(BOOL)canPassThroughWalls {
    [self setBit:2 value:canPassThroughWalls];
}

- (BOOL)canPassThroughPeople {
    return [self getBit:3];
}

- (void)setCanPassThroughPeople:(BOOL)canPassThroughPeople {
    [self setBit:3 value:canPassThroughPeople];
}

- (BOOL)ignoreTraversalCosts {
    return [self getBit:4];
}

- (void)setIgnoreTraversalCosts:(BOOL)ignoreTraversalCosts {
    [self setBit:4 value:ignoreTraversalCosts];
}

@end

// MARK: - BodyFlags Implementation

@implementation BodyFlags

- (instancetype)initWithValue:(uint16_t)flags {
    return [super initWithValue:flags];
}

- (instancetype)init {
    return [super init];
}

- (BOOL)fat {
    return [self getBit:0];
}

- (void)setFat:(BOOL)fat {
    [self setBit:0 value:fat];
}

- (BOOL)pregnantFull {
    return [self getBit:1];
}

- (void)setPregnantFull:(BOOL)pregnantFull {
    [self setBit:1 value:pregnantFull];
}

- (BOOL)pregnantHalf {
    return [self getBit:2];
}

- (void)setPregnantHalf:(BOOL)pregnantHalf {
    [self setBit:2 value:pregnantHalf];
}

- (BOOL)pregnantHidden {
    return [self getBit:3];
}

- (void)setPregnantHidden:(BOOL)pregnantHidden {
    [self setBit:3 value:pregnantHidden];
}

- (BOOL)fit {
    return [self getBit:4];
}

- (void)setFit:(BOOL)fit {
    [self setBit:4 value:fit];
}

@end

// MARK: - PetTraits Implementation

@implementation PetTraits

- (instancetype)initWithValue:(uint16_t)flags {
    return [super initWithValue:flags];
}

- (instancetype)init {
    return [super init];
}

- (void)setTrait:(NSInteger)nr value:(BOOL)val {
    [self setBit:(uint8_t)MIN(MAX(nr, 0), 9) value:val];
}

- (BOOL)getTrait:(NSInteger)nr {
    return [self getBit:(uint8_t)MIN(MAX(nr, 0), 9)];
}

- (BOOL)gifted {
    return [self getBit:0];
}

- (void)setGifted:(BOOL)gifted {
    [self setBit:0 value:gifted];
}

- (BOOL)doofus {
    return [self getBit:1];
}

- (void)setDoofus:(BOOL)doofus {
    [self setBit:1 value:doofus];
}

- (BOOL)hyper {
    return [self getBit:2];
}

- (void)setHyper:(BOOL)hyper {
    [self setBit:2 value:hyper];
}

- (BOOL)lazy {
    return [self getBit:3];
}

- (void)setLazy:(BOOL)lazy {
    [self setBit:3 value:lazy];
}

- (BOOL)independant {
    return [self getBit:4];
}

- (void)setIndependant:(BOOL)independant {
    [self setBit:4 value:independant];
}

- (BOOL)friendly {
    return [self getBit:5];
}

- (void)setFriendly:(BOOL)friendly {
    [self setBit:5 value:friendly];
}

- (BOOL)aggressive {
    return [self getBit:6];
}

- (void)setAggressive:(BOOL)aggressive {
    [self setBit:6 value:aggressive];
}

- (BOOL)cowardly {
    return [self getBit:7];
}

- (void)setCowardly:(BOOL)cowardly {
    [self setBit:7 value:cowardly];
}

- (BOOL)pigpen {
    return [self getBit:8];
}

- (void)setPigpen:(BOOL)pigpen {
    [self setBit:8 value:pigpen];
}

- (BOOL)finicky {
    return [self getBit:9];
}

- (void)setFinicky:(BOOL)finicky {
    [self setBit:9 value:finicky];
}

@end

// MARK: - CharacterDescription Implementation

@implementation CharacterDescription

@synthesize blizLifelinePoints = _blizLifelinePoints;
@synthesize lifelinePoints = _lifelinePoints;
@synthesize lifelineScore = _lifelineScore;

- (instancetype)init {
    self = [super init];
    if (self) {
        _ghostFlag = [[GhostFlags alloc] init];
        _bodyFlag = [[BodyFlags alloc] init];
    }
    return self;
}

- (uint16_t)blizLifelinePoints {
    return MIN(1200, (uint32_t)_blizLifelinePoints);
}

- (void)setBlizLifelinePoints:(uint16_t)blizLifelinePoints {
    _blizLifelinePoints = MIN(1200, (uint32_t)blizLifelinePoints);
}

- (int16_t)lifelinePoints {
    return MIN(600, (int32_t)_lifelinePoints);
}

- (void)setLifelinePoints:(int16_t)lifelinePoints {
    _lifelinePoints = MIN(600, (int32_t)lifelinePoints);
}

- (uint32_t)lifelineScore {
    return (uint32_t)(_lifelineScore * 10);
}

- (void)setLifelineScore:(uint32_t)lifelineScore {
    _lifelineScore = MIN(INT16_MAX, lifelineScore / 10);
}

@end

// MARK: - CharacterAttributes Implementation

@implementation CharacterAttributes
// For CharacterAttributes class, add:
@synthesize neat = _neat;
@synthesize outgoing = _outgoing;
@synthesize active = _active;
@synthesize playful = _playful;
@synthesize nice = _nice;

- (uint16_t)neat {
    return MIN(1000, (uint32_t)_neat);
}

- (void)setNeat:(uint16_t)neat {
    _neat = MIN(1000, (uint32_t)neat);
}

- (uint16_t)outgoing {
    return MIN(1000, (uint32_t)_outgoing);
}

- (void)setOutgoing:(uint16_t)outgoing {
    _outgoing = MIN(1000, (uint32_t)outgoing);
}

- (uint16_t)active {
    return MIN(1000, (uint32_t)_active);
}

- (void)setActive:(uint16_t)active {
    _active = MIN(1000, (uint32_t)active);
}

- (uint16_t)playful {
    return MIN(1000, (uint32_t)_playful);
}

- (void)setPlayful:(uint16_t)playful {
    _playful = MIN(1000, (uint32_t)playful);
}

- (uint16_t)nice {
    return MIN(1000, (uint32_t)_nice);
}

- (void)setNice:(uint16_t)nice {
    _nice = MIN(1000, (uint32_t)nice);
}

@end

// MARK: - SimDecay Implementation

@implementation SimDecay

- (void)setHunger:(int16_t)hunger {
    _hunger = MIN(1000, MAX(-1000, hunger));
}

- (void)setComfort:(int16_t)comfort {
    _comfort = MIN(1000, MAX(-1000, comfort));
}

- (void)setBladder:(int16_t)bladder {
    _bladder = MIN(1000, MAX(-1000, bladder));
}

- (void)setEnergy:(int16_t)energy {
    _energy = MIN(1000, MAX(-1000, energy));
}

- (void)setHygiene:(int16_t)hygiene {
    _hygiene = MIN(1000, MAX(-1000, hygiene));
}

- (void)setSocial:(int16_t)social {
    _social = MIN(1000, MAX(-1000, social));
}

- (void)setFun:(int16_t)fun {
    _fun = MIN(1000, MAX(-1000, fun));
}

@end

// MARK: - SkillAttributes Implementation

@implementation SkillAttributes

@synthesize romance = _romance;
@synthesize fatness = _fatness;
@synthesize cooking = _cooking;
@synthesize mechanical = _mechanical;
@synthesize charisma = _charisma;
@synthesize body = _body;
@synthesize logic = _logic;
@synthesize creativity = _creativity;
@synthesize cleaning = _cleaning;


- (uint16_t)romance {
    return MIN(1000, (uint32_t)_romance);
}

- (void)setRomance:(uint16_t)romance {
    _romance = MIN(1000, (uint32_t)romance);
}

- (uint16_t)fatness {
    return MIN(1000, (uint32_t)_fatness);
}

- (void)setFatness:(uint16_t)fatness {
    _fatness = MIN(1000, (uint32_t)fatness);
}

- (uint16_t)cooking {
    return MIN(1000, (uint32_t)_cooking);
}

- (void)setCooking:(uint16_t)cooking {
    _cooking = MIN(1000, (uint32_t)cooking);
}

- (uint16_t)mechanical {
    return MIN(1000, (uint32_t)_mechanical);
}

- (void)setMechanical:(uint16_t)mechanical {
    _mechanical = MIN(1000, (uint32_t)mechanical);
}

- (uint16_t)charisma {
    return MIN(1000, (uint32_t)_charisma);
}

- (void)setCharisma:(uint16_t)charisma {
    _charisma = MIN(1000, (uint32_t)charisma);
}

- (uint16_t)body {
    return MIN(1000, (uint32_t)_body);
}

- (void)setBody:(uint16_t)body {
    _body = MIN(1000, (uint32_t)body);
}

- (uint16_t)logic {
    return MIN(1000, (uint32_t)_logic);
}

- (void)setLogic:(uint16_t)logic {
    _logic = MIN(1000, (uint32_t)logic);
}

- (uint16_t)creativity {
    return MIN(1000, (uint32_t)_creativity);
}

- (void)setCreativity:(uint16_t)creativity {
    _creativity = MIN(1000, (uint32_t)creativity);
}

- (uint16_t)cleaning {
    return MIN(1000, (uint32_t)_cleaning);
}

- (void)setCleaning:(uint16_t)cleaning {
    _cleaning = MIN(1000, (uint32_t)cleaning);
}

@end

// MARK: - InterestAttributes Implementation

@implementation InterestAttributes
@synthesize politics = _politics;
@synthesize money = _money;
@synthesize crime = _crime;
@synthesize environment = _environment;
@synthesize culture = _culture;
@synthesize entertainment = _entertainment;
@synthesize food = _food;
@synthesize health = _health;
@synthesize fashion = _fashion;
@synthesize sports = _sports;
@synthesize paranormal =_paranormal;
@synthesize travel = _travel;
@synthesize work = _work;
@synthesize weather = _weather;
@synthesize animals = _animals;
@synthesize school = _school;
@synthesize toys = _toys;
@synthesize scifi = _scifi;

- (uint16_t)politics {
    return MIN(1000, (uint32_t)_politics);
}

- (void)setPolitics:(uint16_t)politics {
    _politics = MIN(1000, (uint32_t)politics);
}

- (uint16_t)money {
    return MIN(1000, (uint32_t)_money);
}

- (void)setMoney:(uint16_t)money {
    _money = MIN(1000, (uint32_t)money);
}

- (uint16_t)crime {
    return MIN(1000, (uint32_t)_crime);
}

- (void)setCrime:(uint16_t)crime {
    _crime = MIN(1000, (uint32_t)crime);
}

- (uint16_t)environment {
    return MIN(1000, (uint32_t)_environment);
}

- (void)setEnvironment:(uint16_t)environment {
    _environment = MIN(1000, (uint32_t)environment);
}

- (uint16_t)entertainment {
    return MIN(1000, (uint32_t)_entertainment);
}

- (void)setEntertainment:(uint16_t)entertainment {
    _entertainment = MIN(1000, (uint32_t)entertainment);
}

- (uint16_t)culture {
    return MIN(1000, (uint32_t)_culture);
}

- (void)setCulture:(uint16_t)culture {
    _culture = MIN(1000, (uint32_t)culture);
}

- (uint16_t)food {
    return MIN(1000, (uint32_t)_food);
}

- (void)setFood:(uint16_t)food {
    _food = MIN(1000, (uint32_t)food);
}

- (uint16_t)health {
    return MIN(1000, (uint32_t)_health);
}

- (void)setHealth:(uint16_t)health {
    _health = MIN(1000, (uint32_t)health);
}

- (uint16_t)fashion {
    return MIN(1000, (uint32_t)_fashion);
}

- (void)setFashion:(uint16_t)fashion {
    _fashion = MIN(1000, (uint32_t)fashion);
}

- (uint16_t)sports {
    return MIN(1000, (uint32_t)_sports);
}

- (void)setSports:(uint16_t)sports {
    _sports = MIN(1000, (uint32_t)sports);
}

- (uint16_t)paranormal {
    return MIN(1000, (uint32_t)_paranormal);
}

- (void)setParanormal:(uint16_t)paranormal {
    _paranormal = MIN(1000, (uint32_t)paranormal);
}

- (uint16_t)travel {
    return MIN(1000, (uint32_t)_travel);
}

- (void)setTravel:(uint16_t)travel {
    _travel = MIN(1000, (uint32_t)travel);
}

- (uint16_t)work {
    return MIN(1000, (uint32_t)_work);
}

- (void)setWork:(uint16_t)work {
    _work = MIN(1000, (uint32_t)work);
}

- (uint16_t)weather {
    return MIN(1000, (uint32_t)_weather);
}

- (void)setWeather:(uint16_t)weather {
    _weather = MIN(1000, (uint32_t)weather);
}

- (uint16_t)animals {
    return MIN(1000, (uint32_t)_animals);
}

- (void)setAnimals:(uint16_t)animals {
    _animals = MIN(1000, (uint32_t)animals);
}

- (uint16_t)school {
    return MIN(1000, (uint32_t)_school);
}

- (void)setSchool:(uint16_t)school {
    _school = MIN(1000, (uint32_t)school);
}

- (uint16_t)toys {
    return MIN(1000, (uint32_t)_toys);
}

- (void)setToys:(uint16_t)toys {
    _toys = MIN(1000, (uint32_t)toys);
}

- (uint16_t)scifi {
    return MIN(1000, (uint32_t)_scifi);
}

- (void)setScifi:(uint16_t)scifi {
    _scifi = MIN(1000, (uint32_t)scifi);
}

- (void)setFemalePreference:(int16_t)femalePreference {
    _femalePreference = MAX(-1000, MIN(1000, femalePreference));
}

- (void)setMalePreference:(int16_t)malePreference {
    _malePreference = MAX(-1000, MIN(1000, malePreference));
}

@end

// MARK: - SimRelationAttribute Implementation

@implementation SimRelationAttribute

@synthesize parent = _parent;

- (instancetype)initWithParent:(SDesc *)parent {
    self = [super init];
    if (self) {
        _parent = parent;
        _simInstances = @[];
    }
    return self;
}

- (SDesc *)getSimDescription:(uint16_t)instance {
    if (instance == _parent.fileDescriptor.instance) {
        return nil;
    }
    
    id<IPackedFileDescriptor> pfd = [_parent.package findFileWithType:SIM_DESCRIPTION_FILE
                                                              subtype:0
                                                                group:_parent.fileDescriptor.group
                                                             instance:instance];
    
    SDesc *sdesc = [[SDesc alloc] initWithNameProvider:_parent.nameProvider
                                  familyNameProvider:_parent.familyNameProvider
                                descriptionProvider:_parent.descriptionProvider];
    if (pfd != nil) {
        [sdesc processData:pfd package:_parent.package];
    }
    
    return sdesc;
}

// Note: SimRelations and SRel classes would need to be implemented separately
- (id)getSimRelationships:(uint16_t)instance {
    if (instance == _parent.fileDescriptor.instance) {
        return nil;
    }
    
    // Implementation would require SimRelations and SRel classes
    return nil;
}

@end

// MARK: - SdscUniversity Implementation

@implementation SdscUniversity
@synthesize major = _major;
@synthesize time = _time;
@synthesize semester = _semester;

- (instancetype)init {
    self = [super init];
    if (self) {
        _major = MajorsUndeclared;
        _time = 72;
        _semester = 1;
    }
    return self;
}

- (void)unserialize:(BinaryReader *)reader {
    [reader seekToPosition:0x014];
    _effort = [reader readUInt16];
    
    [reader seekToPosition:0x0b2];
    _grade = [reader readUInt16];
    
    [reader seekToPosition:0x160];
    _major = (Majors)[reader readUInt32];
    _time = [reader readUInt16];
    [reader skipBytes:2];
    _semester = [reader readUInt16];
    _onCampus = [reader readUInt16];
    [reader skipBytes:4];
    _influence = [reader readUInt16];
}

- (void)serialize:(BinaryWriter *)writer {
    [writer seekToPosition:0x014];
    [writer writeUInt16:_effort];
    
    [writer seekToPosition:0x0b2];
    [writer writeUInt16:_grade];
    
    [writer seekToPosition:0x160];
    [writer writeUInt32:(uint32_t)_major];
    [writer writeUInt16:_time];
    [writer skipBytes:2];
    [writer writeUInt16:_semester];
    [writer writeUInt16:_onCampus];
    [writer skipBytes:4];
    [writer writeUInt16:_influence];
}

@end

// MARK: - SdscNightlife Implementation

@implementation SdscNightlife

- (instancetype)init {
    self = [super init];
    if (self) {
        _species = SpeciesTypeHuman;
        _attractionTurnOffs3 = 0;
        _attractionTurnOns3 = 0;
        _attractionTraits3 = 0;
        _attractionTurnOffs1 = 0;
        _attractionTurnOffs2 = 0;
        _attractionTurnOns1 = 0;
        _attractionTurnOns2 = 0;
        _attractionTraits1 = 0;
        _attractionTraits2 = 0;
    }
    return self;
}

- (BOOL)isHuman {
    return !(_species == SpeciesTypeCat ||
             _species == SpeciesTypeSmallDog ||
             _species == SpeciesTypeLargeDog);
}

- (void)unserialize:(BinaryReader *)reader version:(SDescVersion)ver {
    [reader seekToPosition:0x172];
    _routeStartSlotOwnerID = [reader readUInt16];
    
    _attractionTraits1 = [reader readUInt16];
    _attractionTraits2 = [reader readUInt16];
    
    _attractionTurnOns1 = [reader readUInt16];
    _attractionTurnOns2 = [reader readUInt16];
    
    _attractionTurnOffs1 = [reader readUInt16];
    _attractionTurnOffs2 = [reader readUInt16];
    
    _species = (SpeciesType)[reader readUInt16];
    _countdown = [reader readUInt16];
    _perfumeDuration = [reader readUInt16];
    
    _dateTimer = [reader readUInt16];
    _dateScore = [reader readUInt16];
    _dateUnlockCounter = [reader readUInt16];
    
    _lovePotionDuration = [reader readUInt16];
    _aspirationScoreLock = [reader readUInt16];
    
    if ((NSInteger)ver >= (NSInteger)SDescVersionVoyage) {
        [reader seekToPosition:0x19e];
        
        _attractionTurnOns3 = [reader readUInt16];
        _attractionTurnOffs3 = [reader readUInt16];
        _attractionTraits3 = [reader readUInt16];
    }
}

- (void)serialize:(BinaryWriter *)writer version:(SDescVersion)ver {
    [writer seekToPosition:0x172];
    [writer writeUInt16:_routeStartSlotOwnerID];
    
    [writer writeUInt16:_attractionTraits1];
    [writer writeUInt16:_attractionTraits2];
    
    [writer writeUInt16:_attractionTurnOns1];
    [writer writeUInt16:_attractionTurnOns2];
    
    [writer writeUInt16:_attractionTurnOffs1];
    [writer writeUInt16:_attractionTurnOffs2];
    
    [writer writeUInt16:(uint16_t)_species];
    [writer writeUInt16:_countdown];
    [writer writeUInt16:_perfumeDuration];
    
    [writer writeUInt16:_dateTimer];
    [writer writeUInt16:_dateScore];
    [writer writeUInt16:_dateUnlockCounter];
    
    [writer writeUInt16:_lovePotionDuration];
    [writer writeUInt16:_aspirationScoreLock];
    
    if ((NSInteger)ver >= (NSInteger)SDescVersionVoyage) {
        [writer seekToPosition:0x19e];
        
        [writer writeUInt16:_attractionTurnOns3];
        [writer writeUInt16:_attractionTurnOffs3];
        [writer writeUInt16:_attractionTraits3];
    }
}

@end

// MARK: - SdscBusiness Implementation

@implementation SdscBusiness

- (void)unserialize:(BinaryReader *)reader {
    [reader seekToPosition:0x192];
    _lotID = [reader readUInt16];
    _salary = [reader readUInt16];
    _flags = [reader readUInt16];
    _assignment = (JobAssignment)[reader readUInt16];
}

- (void)serialize:(BinaryWriter *)writer {
    [writer seekToPosition:0x192];
    [writer writeUInt16:_lotID];
    [writer writeUInt16:_salary];
    [writer writeUInt16:_flags];
    [writer writeUInt16:(uint16_t)_assignment];
}

@end

// MARK: - SdscPets Implementation

@implementation SdscPets

- (instancetype)init {
    self = [super init];
    if (self) {
        _petTraits = [[PetTraits alloc] initWithValue:0];
    }
    return self;
}

- (void)unserialize:(BinaryReader *)reader {
    [reader seekToPosition:0x19A];
    _petTraits.value = [reader readUInt16];
}

- (void)serialize:(BinaryWriter *)writer {
    [writer seekToPosition:0x19A];
    [writer writeUInt16:_petTraits.value];
}

@end

// MARK: - SdscVoyage Implementation

@implementation SdscVoyage

- (instancetype)init {
    self = [super init];
    if (self) {
        _daysLeft = 0;
        _collectiblesPlain = 0;
    }
    return self;
}

- (void)unserialize:(BinaryReader *)reader {
    [reader seekToPosition:0x19C];
    _daysLeft = [reader readUInt16];
}

- (void)serialize:(BinaryWriter *)writer {
    [writer seekToPosition:0x19C];
    [writer writeUInt16:_daysLeft];
}

- (void)unserializeMem:(BinaryReader *)reader {
    _collectiblesPlain = 0;
    if ([reader remainingBytes] >= 8) {
        _collectiblesPlain = [reader readUInt64];
    }
}

- (void)serializeMem:(BinaryWriter *)writer {
    [writer writeUInt64:_collectiblesPlain];
}

@end

// MARK: - SdscFreetime Implementation

@implementation SdscFreetime

- (instancetype)initWithParent:(SDesc *)parent {
    self = [super init];
    if (self) {
        _parent = parent;
    }
    return self;
}

- (void)unserialize:(BinaryReader *)reader {
    // Implementation would depend on the specific structure of Freetime data
}

- (void)serialize:(BinaryWriter *)writer {
    // Implementation would depend on the specific structure of Freetime data
}

@end

// MARK: - SdscApartment Implementation

@implementation SdscApartment

- (instancetype)initWithParent:(SDesc *)parent {
    self = [super init];
    if (self) {
        _parent = parent;
    }
    return self;
}

- (void)unserialize:(BinaryReader *)reader {
    // Implementation would depend on the specific structure of Apartment data
}

- (void)serialize:(BinaryWriter *)writer {
    // Implementation would depend on the specific structure of Apartment data
}

@end

// MARK: - SDesc Implementation

@implementation SDesc

+ (NSArray *)addonCarriers {
    static NSArray *_addonCarriers = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *path = [[Helper simPeDataPath] stringByAppendingPathComponent:@"additional_careers.xml"];
        _addonCarriers = [NSArray array]; // Load from XML would go here
    });
    // Continue from where your implementation left off:

        return _addonCarriers;
    }

    // MARK: - Initialization

    - (instancetype)init {
        return [self initWithNameProvider:nil familyNameProvider:nil descriptionProvider:nil];
    }

    - (instancetype)initWithNameProvider:(id<ISimNames>)nameProvider
                        familyNameProvider:(id<ISimFamilyNames>)familyNameProvider
                       descriptionProvider:(id<ISimDescriptions>)descriptionProvider {
        self = [super init];
        if (self) {
            _nameProvider = nameProvider;
            _familyNameProvider = familyNameProvider;
            _descriptionProvider = descriptionProvider;
            
            // Initialize data components
            _characterDescription = [[CharacterDescription alloc] init];
            _character = [[CharacterAttributes alloc] init];
            _geneticCharacter = [[CharacterAttributes alloc] init];
            _decay = [[SimDecay alloc] init];
            _skills = [[SkillAttributes alloc] init];
            _interests = [[InterestAttributes alloc] init];
            _relations = [[SimRelationAttribute alloc] initWithParent:self];
            
            // Initialize expansion pack data to nil (loaded as needed)
            _university = nil;
            _nightlife = nil;
            _business = nil;
            _pets = nil;
            _voyage = nil;
            _freetime = nil;
            _apartment = nil;
            
            _simId = 0;
            _instance = 0;
            _familyInstance = 0;
            _unlinked = 0;
            _endByte = 0;
        }
        return self;
    }

    // MARK: - Static Methods

    + (SDesc *)findForSimId:(uint32_t)simId inPackage:(id<IPackageFile>)package {
        // Search through all SDSC files in the package for matching sim ID
        NSArray<id<IPackedFileDescriptor>> *sdescs = [package findFiles:[MetaData SIM_DESCRIPTION_FILE]];
        
        for (id<IPackedFileDescriptor> pfd in sdescs) {
            SDesc *sdesc = [[SDesc alloc] init];
            id<IPackedFile> file = [package readDescriptor:pfd];
            [sdesc processData:pfd package:package file:file catchExceptions:YES];
            
            if (sdesc.simId == simId) {
                return sdesc;
            }
        }
        
        return nil;
    }

    // MARK: - Name Properties

    - (NSString *)simName {
        if (_nameProvider) {
            return [_nameProvider simName:_instance];
        }
        return @"---";
    }

    - (NSString *)simFamilyName {
        if (_familyNameProvider) {
            return [_familyNameProvider simFamilyName:_familyInstance];
        }
        return @"---";
    }

    - (NSString *)householdName {
        if (_familyNameProvider) {
            return [_familyNameProvider householdName:_familyInstance];
        }
        return @"---";
    }

    - (NSString *)characterFileName {
        // Implementation depends on your character file system
        return nil;
    }

    // MARK: - Image Properties

    - (NSImage *)image {
        // Implementation would depend on your image loading system
        return nil;
    }

    - (BOOL)hasImage {
        return [self image] != nil;
    }

    - (BOOL)availableCharacterData {
        return _characterDescription != nil;
    }

    // MARK: - Version Property

    - (SDescVersion)version {
        // Determine version based on available expansion data
        if (_apartment) return SDescVersionVoyageB; // Assuming latest
        if (_voyage) return SDescVersionVoyage;
        if (_pets) return SDescVersionPets;
        if (_business) return SDescVersionBusiness;
        if (_nightlife) return SDescVersionNightlife;
        if (_university) return SDescVersionUniversity;
        return SDescVersionBaseGame;
    }

    // MARK: - Name Management

    - (BOOL)changeNamesWithFirstName:(NSString *)firstName familyName:(NSString *)familyName {
        // Implementation would depend on your name management system
        return NO;
    }

    // MARK: - Provider Management

    - (void)setProviders:(id<IWrapperRegistry>)providerRegistry {
        // Implementation would set up providers from registry
    }

    // MARK: - File Operations

    - (NSArray<NSNumber *> *)assignableTypes {
        return @[@([MetaData SIM_DESCRIPTION_FILE])];
    }

    - (NSData *)fileSignature {
        // Return signature data for SDSC files
        return [@"SDSC" dataUsingEncoding:NSASCIIStringEncoding];
    }

    // MARK: - AbstractWrapper Overrides

    - (void)unserialize:(BinaryReader *)reader {
        // Read basic SDSC structure
        [reader seekToPosition:0x00];
        
        // Read header
        uint32_t signature = [reader readUInt32]; // Should be 'SDSC'
        uint32_t version = [reader readUInt32];
        
        // Read sim identification
        _simId = [reader readUInt32];
        _instance = [reader readUInt16];
        _familyInstance = [reader readUInt16];
        _unlinked = [reader readUInt16];
        
        // Read character description data
        [self readCharacterDescription:reader];
        
        // Read character attributes (personality)
        [self readCharacterAttributes:reader];
        
        // Read genetic character attributes
        [self readGeneticCharacterAttributes:reader];
        
        // Read needs/decay values
        [self readSimDecay:reader];
        
        // Read skills
        [self readSkillAttributes:reader];
        
        // Read interests
        [self readInterestAttributes:reader];
        
        // Read relations
        [self readRelations:reader];
        
        // Read expansion pack data based on version
        [self readExpansionData:reader version:(SDescVersion)version];
        
        // Read end byte
        _endByte = [reader readByte];
    }

    - (id<IPackedFileUI>)createDefaultUIHandler {
        // Would return appropriate UI handler for SDSC files
        return nil;
    }

    // MARK: - Private Reading Methods

    - (void)readCharacterDescription:(BinaryReader *)reader {
        // Read character description data at specific offsets
        [reader seekToPosition:0x40]; // Example offset
        
        _characterDescription.ghostFlag.value = [reader readUInt16];
        _characterDescription.bodyFlag.value = [reader readUInt16];
        _characterDescription.autonomyLevel = [reader readUInt16];
        _characterDescription.npcType = [reader readUInt16];
        _characterDescription.motivesStatic = [reader readUInt16];
        _characterDescription.voiceType = [reader readUInt16];
        _characterDescription.schoolType = (SchoolTypes)[reader readUInt32];
        _characterDescription.grade = (Grades)[reader readUInt16];
        _characterDescription.careerPerformance = [reader readInt16];
        _characterDescription.career = (Careers)[reader readUInt32];
        _characterDescription.careerLevel = [reader readUInt16];
        _characterDescription.zodiacSign = (ZodiacSigns)[reader readUInt16];
        _characterDescription.aspiration = (AspirationTypes)[reader readUInt16];
        _characterDescription.gender = (Gender)[reader readUInt16];
        _characterDescription.lifeSection = (LifeSections)[reader readUInt16];
        _characterDescription.age = [reader readUInt16];
        _characterDescription.prevAgeDays = [reader readUInt16];
        _characterDescription.ageDuration = [reader readUInt16];
        _characterDescription.blizLifelinePoints = [reader readUInt16];
        _characterDescription.lifelinePoints = [reader readInt16];
        _characterDescription.lifelineScore = [reader readUInt32];
    }

    - (void)readCharacterAttributes:(BinaryReader *)reader {
        _character.neat = [reader readUInt16];
        _character.outgoing = [reader readUInt16];
        _character.active = [reader readUInt16];
        _character.playful = [reader readUInt16];
        _character.nice = [reader readUInt16];
    }

    - (void)readGeneticCharacterAttributes:(BinaryReader *)reader {
        _geneticCharacter.neat = [reader readUInt16];
        _geneticCharacter.outgoing = [reader readUInt16];
        _geneticCharacter.active = [reader readUInt16];
        _geneticCharacter.playful = [reader readUInt16];
        _geneticCharacter.nice = [reader readUInt16];
    }

    - (void)readSimDecay:(BinaryReader *)reader {
        _decay.hunger = [reader readInt16];
        _decay.comfort = [reader readInt16];
        _decay.bladder = [reader readInt16];
        _decay.energy = [reader readInt16];
        _decay.hygiene = [reader readInt16];
        _decay.social = [reader readInt16];
        _decay.fun = [reader readInt16];
    }

    - (void)readSkillAttributes:(BinaryReader *)reader {
        _skills.romance = [reader readUInt16];
        _skills.fatness = [reader readUInt16];
        _skills.cooking = [reader readUInt16];
        _skills.mechanical = [reader readUInt16];
        _skills.charisma = [reader readUInt16];
        _skills.body = [reader readUInt16];
        _skills.logic = [reader readUInt16];
        _skills.creativity = [reader readUInt16];
        _skills.cleaning = [reader readUInt16];
    }

    - (void)readInterestAttributes:(BinaryReader *)reader {
        _interests.politics = [reader readUInt16];
        _interests.money = [reader readUInt16];
        _interests.crime = [reader readUInt16];
        _interests.environment = [reader readUInt16];
        _interests.entertainment = [reader readUInt16];
        _interests.culture = [reader readUInt16];
        _interests.food = [reader readUInt16];
        _interests.health = [reader readUInt16];
        _interests.fashion = [reader readUInt16];
        _interests.sports = [reader readUInt16];
        _interests.paranormal = [reader readUInt16];
        _interests.travel = [reader readUInt16];
        _interests.work = [reader readUInt16];
        _interests.weather = [reader readUInt16];
        _interests.animals = [reader readUInt16];
        _interests.school = [reader readUInt16];
        _interests.toys = [reader readUInt16];
        _interests.scifi = [reader readUInt16];
        _interests.femalePreference = [reader readInt16];
        _interests.malePreference = [reader readInt16];
    }

    - (void)readRelations:(BinaryReader *)reader {
        // Read relationship data - implementation depends on structure
        // This would read the array of sim relationships
    }

    - (void)readExpansionData:(BinaryReader *)reader version:(SDescVersion)version {
        // Load expansion pack data based on version
        if (version >= SDescVersionUniversity) {
            _university = [[SdscUniversity alloc] init];
            [_university unserialize:reader];
        }
        
        if (version >= SDescVersionNightlife) {
            _nightlife = [[SdscNightlife alloc] init];
            [_nightlife unserialize:reader version:version];
        }
        
        if (version >= SDescVersionBusiness) {
            _business = [[SdscBusiness alloc] init];
            [_business unserialize:reader];
        }
        
        if (version >= SDescVersionPets) {
            _pets = [[SdscPets alloc] init];
            [_pets unserialize:reader];
        }
        
        if (version >= SDescVersionVoyage) {
            _voyage = [[SdscVoyage alloc] init];
            [_voyage unserialize:reader];
        }
        
        // Add other expansion packs as needed
    }

    @end
