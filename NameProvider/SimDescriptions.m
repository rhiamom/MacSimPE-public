//
//  SimDescriptions.m
//  MacSimpe
//
//  Created by Catherine Gramze on 8/20/25.
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

#import "SimDescriptions.h"
#import "MetaData.h"
#import "LinkedSDesc.h"
#import "TraitAlias.h"
#import "CollectibleAlias.h"
#import "Warning.h"
#import "Helper.h"
#import "IPackageFile.h"
#import "IPackedFileDescriptor.h"
#import "ISDesc.h"
#import "ISimNames.h"
#import "ISimFamilyNames.h"
#import "FileTable.h"
#import "ProviderRegistry.h"
#import "PathProvider.h"
#import "File.h"
#import "Str.h"
#import "StrItemList.h"
#import "Picture.h"
#import "Xml.h"
#import "Localization.h"
#import "Registry.h"

@implementation SimDescriptions

// MARK: - Initialization

- (instancetype)initWithPackage:(id<IPackageFile>)package
                          names:(id<ISimNames>)names
                       famNames:(id<ISimFamilyNames>)famNames {
    self = [super initWithPackage:package];
    if (self) {
        self.names = names;
        self.famNames = famNames;
    }
    return self;
}

- (instancetype)initWithNames:(id<ISimNames>)names famNames:(id<ISimFamilyNames>)famNames {
    return [self initWithPackage:nil names:names famNames:famNames];
}

// MARK: - ISimDescriptions Protocol Implementation

- (NSMutableDictionary *)simGuidMap {
    if (self.bySimId == nil) {
        [self loadDescriptions];
    }
    return self.bySimId;
}

- (NSMutableDictionary *)simInstance {
    if (self.byInstance == nil) {
        [self loadDescriptions];
    }
    return self.byInstance;
}

- (id<ISDesc>)findSim:(uint16_t)instance {
    if (self.byInstance == nil) {
        [self loadDescriptions];
    }
    return [self.byInstance objectForKey:@(instance)];
}

- (id<ISDesc>)findSimById:(uint32_t)simId {
    if (self.bySimId == nil) {
        [self loadDescriptions];
    }
    return [self.bySimId objectForKey:@(simId)];
}

- (uint16_t)getInstance:(uint32_t)simId {
    id<ISDesc> desc = [self findSimById:simId];
    if (desc != nil) {
        return [desc instance];
    } else {
        return 0xffff;
    }
}

- (uint32_t)getSimId:(uint16_t)instance {
    id<ISDesc> desc = [self findSim:instance];
    if (desc != nil) {
        return [desc simId];
    } else {
        return 0xffffffff;
    }
}

- (NSMutableArray *)getHouseholdNames {
    NSString *firstCustom;
    return [self getHouseholdNames:&firstCustom];
}

- (NSMutableArray *)getHouseholdNames:(NSString **)firstCustom {
    NSDictionary *simInstances = [[[FileTable providerRegistry] simDescriptionProvider] simInstance];
    NSMutableArray *list = [[NSMutableArray alloc] init];
    *firstCustom = nil;
    
    for (LinkedSDesc *sdesc in [simInstances allValues]) {
        NSString *householdName = [sdesc householdName];
        if (householdName == nil) {
            householdName = [Localization getString:@"Unknown"];
        }
        
        if (![list containsObject:householdName]) {
            [list addObject:householdName];
            if (*firstCustom == nil && ![sdesc isNPC] && ![sdesc isTownie]) {
                *firstCustom = householdName;
            }
        }
    }
    
    if (*firstCustom == nil) {
        if ([list count] > 0) {
            *firstCustom = [list firstObject];
        } else {
            *firstCustom = [Localization getString:@"Unknown"];
        }
    }
    
    [list sortUsingSelector:@selector(compare:)];
    return list;
}

// MARK: - Loading Methods

- (void)loadDescriptions {
    self.bySimId = [[NSMutableDictionary alloc] init];
    self.byInstance = [[NSMutableDictionary alloc] init];
    BOOL didWarnDoubleGuid = NO;
    
    if (self.basePackage == nil) return;
    
    NSArray<id<IPackedFileDescriptor>> *files = [self.basePackage findFiles:[MetaData SIM_DESCRIPTION_FILE]];
    
    for (id<IPackedFileDescriptor> pfd in files) {
        LinkedSDesc *sdesc = [[LinkedSDesc alloc] init];
        [sdesc processData:pfd package:self.basePackage];
        
        NSNumber *simIdKey = @([sdesc simId]);
        NSNumber *instanceKey = @([sdesc instance]);
        
        if ([self.bySimId objectForKey:simIdKey] != nil || [self.byInstance objectForKey:instanceKey] != nil) {
            if (!didWarnDoubleGuid) {
                NSString *message = [NSString stringWithFormat:@"A Sim was found Twice! The Sim with GUID 0x%@ (inst=0x%@) exists more than once. This could result in Problems during the Gameplay!",
                                   [Helper hexStringUInt:([sdesc simId])],
                                   [Helper hexStringUShort:([sdesc instance])]];
                Warning *warning = [[Warning alloc] initWithMessage:@"A Sim was found Twice!" details:message];
                [Helper exceptionMessage:warning];
                didWarnDoubleGuid = YES;
            }
        }
        
        [self.bySimId setObject:sdesc forKey:simIdKey];
        [self.byInstance setObject:sdesc forKey:instanceKey];
    }
}

// MARK: - Nightlife Turn On/Off Extension

- (void)loadTurnOns {
    if (self.turnOns != nil) return;
    self.turnOns = [[NSMutableDictionary alloc] init];
    
    if ([[PathProvider global] EPInstalled] < 2) return;
    
    NSString *uiTextPath = [NSString pathWithComponents:@[[[PathProvider global] latest].installFolder, @"TSData", @"Res", @"Text", @"UIText.package"]];
    File *pkg = [File loadFromFile:uiTextPath];
    Str *str = [[Str alloc] init];
    id<IPackedFileDescriptor> pfd = [pkg findFile:[MetaData STRING_FILE] subtype:0 group:[MetaData LOCAL_GROUP] instance:0xe1];
    
    if (pfd != nil) {
        [str processData:pfd package:pkg];
        StrItemList *strs = [str fallbackedLanguageItems:[[Registry windowsRegistry] languageCode]];
        
        for (NSInteger i = 0; i < [strs count]; i++) {
            [self.turnOns setObject:[[strs objectAtIndex:i] title] forKey:@(i)];
        }
    }
}

- (NSArray<TraitAlias *> *)getAllTurnOns {
    if (self.turnOns == nil) {
        [self loadTurnOns];
    }
    
    NSMutableArray<TraitAlias *> *aliases = [[NSMutableArray alloc] initWithCapacity:[self.turnOns count]];
    
    for (NSNumber *key in [self.turnOns allKeys]) {
        NSString *name = [self.turnOns objectForKey:key];
        NSInteger k = [key integerValue];
        NSInteger e = k;
        if (e > 0xD) e += 2; // only 14 bits in traits1 (etc)
        
        TraitAlias *alias = [[TraitAlias alloc] initWithId:(uint64_t)pow(2, e) name:name];
        [aliases addObject:alias];
    }
    
    return [aliases copy];
}

- (uint64_t)buildTurnOnIndex:(uint16_t)val1 val2:(uint16_t)val2 val3:(uint16_t)val3 {
    uint64_t res = val1;
    res |= ((uint64_t)val2 << 16);
    res |= ((uint64_t)val3 << 32); // BonVoyage
    return res;
}

- (NSArray<NSNumber *> *)getFromTurnOnIndex:(uint64_t)index {
    NSMutableArray<NSNumber *> *ret = [[NSMutableArray alloc] initWithCapacity:3];
    ret[2] = @((uint16_t)((index >> 32) & 0xFFFF)); // BonVoyage
    ret[1] = @((uint16_t)((index >> 16) & 0xFFFF));
    ret[0] = @((uint16_t)(index & 0xFFFF));
    return [ret copy];
}

- (NSString *)getTurnOnName:(uint16_t)val1 val2:(uint16_t)val2 val3:(uint16_t)val3 {
    if (self.turnOns == nil) {
        [self loadTurnOns];
    }
    
    uint64_t v = [self buildTurnOnIndex:val1 val2:val2 val3:val3];
    NSMutableString *ret = [[NSMutableString alloc] init];
    NSInteger ct = 0;
    
    while (v > 0) {
        uint64_t s = v & 1;
        if (s == 1) {
            NSString *name = [self.turnOns objectForKey:@(ct)];
            if (name == nil) {
                return [Localization getString:@"Unknown"];
            }
            if ([ret length] > 0) {
                [ret appendString:@", "];
            }
            [ret appendString:name];
        }
        v = v >> 1;
        ct++;
    }
    
    return [ret copy];
}

// MARK: - BonVoyage Vacation Collectibles Extension

- (void)loadCollectibles {
    if (self.collectibles != nil) return;
    self.collectibles = [[NSMutableDictionary alloc] init];
    
    if ([[PathProvider global] EPInstalled] < 11) return;
    
    @try {
        NSString *uiTextPath = [NSString pathWithComponents:@[[[PathProvider global] latest].installFolder, @"TSData", @"Res", @"Text", @"UIText.package"]];
        File *pkg = [File loadFromFile:uiTextPath];
        Str *str = [[Str alloc] init];
        id<IPackedFileDescriptor> pfd = [pkg findFile:[MetaData STRING_FILE] subtype:0 group:[MetaData LOCAL_GROUP] instance:0xb7];
        
        if (pfd != nil) {
            [str processData:pfd package:pkg];
            StrItemList *strs = [str fallbackedLanguageItems:[[Registry windowsRegistry] languageCode]];
            
            NSString *uiPackagePath = [NSString pathWithComponents:@[[[PathProvider global] latest].installFolder, @"TSData", @"Res", @"UI", @"ui.package"]];
            pkg = [File loadFromFile:uiPackagePath];
            pfd = [pkg findFile:0 subtype:0 group:0xA99D8A11 instance:0xACDC6300];
            
            if (pfd != nil) {
                Xml *xml = [[Xml alloc] init];
                [xml processData:pfd package:pkg];
                
                NSArray *lines = [[xml text] componentsSeparatedByString:@"\r"];
                Picture *pic = [[Picture alloc] init];
                [[FileTable fileIndex] load];
                
                for (NSString *fullLine in lines) {
                    NSString *line = [[fullLine lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    if ([line hasPrefix:@"<legacy"] && [line containsString:@"enabled\""] && [line containsString:@"tipres="]) {
                        line = [[[line stringByReplacingOccurrencesOfString:@"<legacy" withString:@""]
                                      stringByReplacingOccurrencesOfString:@">" withString:@""]
                                      stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                        
                        NSString *tipres = [SimDescriptions getUIListAttribute:line name:@"tipres"];
                        NSArray *tipresComponents = [tipres componentsSeparatedByString:@","];
                        NSInteger index = [Helper stringToInt32:[tipresComponents objectAtIndex:1] default:0 base:16] & 0xFFFF;
                        NSInteger testNr = (NSInteger)(([Helper stringToInt32:[tipresComponents objectAtIndex:1] default:0 base:16] & 0xFFFF0000) >> 16);
                        
                        if (index > 0 && testNr == 0xb7) {
                            index = [self createCollectibleAlias:strs picture:pic line:line index:index];
                        }
                    }
                }
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"ERROR during Voyage Collectible Image Parsing:\n%@", exception);
        if ([Helper debugMode]) {
            [Helper exceptionMessage:[exception localizedDescription]];
        }
    }
}

- (NSInteger)createCollectibleAlias:(StrItemList *)strs
                            picture:(Picture *)pic
                               line:(NSString *)line
                              index:(NSInteger)index {
    index--;
    NSString *image = [SimDescriptions getUIListAttribute:line name:@"image"];
    NSString *idStr = [SimDescriptions getUIAttribute:line name:@"id"];
    NSInteger nr = [Helper stringToInt32:idStr default:0 base:16] / 2 - 1;
    NSArray *stgi = [image componentsSeparatedByString:@","];
    uint32_t g = [Helper stringToUInt32:[stgi objectAtIndex:0] default:0 base:16];
    uint32_t i = [Helper stringToUInt32:[stgi objectAtIndex:1] default:0 base:16];
    NSString *name = [SimDescriptions getUITextAttribute:line name:@"tiptext"];
    
    if (index < [strs count]) {
        name = [[strs objectAtIndex:index] title];
    }
    
    NSImage *img = [SimDescriptions loadCollectibleIcon:pic group:g instance:i];
    
    CollectibleAlias *alias = [[CollectibleAlias alloc] initWithId:(uint64_t)pow(2, nr)
                                                               number:nr
                                                                 name:name
                                                                image:img];
    [self.collectibles setObject:alias forKey:@(nr)];
    return index;
}

+ (NSImage *)loadCollectibleIcon:(Picture *)pic group:(uint32_t)group instance:(uint32_t)instance {
    NSArray *items = [[FileTable fileIndex] findFileByGroupAndInstance:group instance:instance];
    if ([items count] > 0) {
        [pic processData:[items firstObject]];
        NSImage *originalImage = [pic image];
        
        // Create a new image with 1/4 width
        NSSize originalSize = [originalImage size];
        NSSize newSize = NSMakeSize(originalSize.width / 4, originalSize.height);
        
        NSImage *newImage = [[NSImage alloc] initWithSize:newSize];
        [newImage lockFocus];
        [originalImage drawInRect:NSMakeRect(0, 0, newSize.width, newSize.height)
                         fromRect:NSMakeRect(0, 0, newSize.width, newSize.height)
                        operation:NSCompositingOperationCopy
                         fraction:1.0];
        [newImage unlockFocus];
        
        return newImage;
    }
    return nil;
}

- (NSArray<CollectibleAlias *> *)getAllCollectibles {
    if (self.collectibles == nil) {
        [self loadCollectibles];
    }
    
    NSMutableArray<CollectibleAlias *> *aliases = [[NSMutableArray alloc] initWithCapacity:[self.collectibles count]];
    
    for (NSNumber *key in [self.collectibles allKeys]) {
        [aliases addObject:[self.collectibles objectForKey:key]];
    }
    
    return [aliases copy];
}

- (uint64_t)buildCollectibleIndex:(uint16_t)val1 val2:(uint16_t)val2 val3:(uint16_t)val3 val4:(uint16_t)val4 {
    return (uint32_t)(((((val4 << 16) + val3) << 16) + val2) << 16) + val1;
}

- (NSArray<NSNumber *> *)getFromCollectibleIndex:(uint64_t)index {
    NSMutableArray<NSNumber *> *ret = [[NSMutableArray alloc] initWithCapacity:4];
    ret[3] = @((uint16_t)((index >> 48) & 0xFFFF));
    ret[2] = @((uint16_t)((index >> 32) & 0xFFFF));
    ret[1] = @((uint16_t)((index >> 16) & 0xFFFF));
    ret[0] = @((uint16_t)(index & 0xFFFF));
    return [ret copy];
}

- (NSString *)getCollectibleName:(uint16_t)val1 val2:(uint16_t)val2 val3:(uint16_t)val3 val4:(uint16_t)val4 {
    if (self.collectibles == nil) {
        [self loadCollectibles];
    }
    
    uint64_t v = [self buildCollectibleIndex:val1 val2:val2 val3:val3 val4:val4];
    NSMutableString *ret = [[NSMutableString alloc] init];
    NSInteger ct = 0;
    
    while (v > 0) {
        uint64_t s = v & 1;
        if (s == 1) {
            CollectibleAlias *alias = [self.collectibles objectForKey:@(ct)];
            if (alias == nil) {
                return [Localization getString:@"Unknown"];
            }
            if ([ret length] > 0) {
                [ret appendString:@", "];
            }
            [ret appendString:[alias description]];
        }
        v = v >> 1;
        ct++;
    }
    
    return [ret copy];
}

// MARK: - Utility Methods

+ (NSString *)getUIListAttribute:(NSString *)line name:(NSString *)name {
    NSString *modifiedLine = [NSString stringWithFormat:@" %@ ", line];
    NSString *searchPattern = [NSString stringWithFormat:@" %@={", name];
    NSRange range = [modifiedLine rangeOfString:searchPattern];
    
    if (range.location != NSNotFound) {
        NSString *substring = [modifiedLine substringFromIndex:range.location + range.length];
        NSRange endRange = [substring rangeOfString:@"} "];
        if (endRange.location != NSNotFound) {
            return [substring substringToIndex:endRange.location];
        }
    }
    return @"";
}

+ (NSString *)getUIAttribute:(NSString *)line name:(NSString *)name {
    NSString *modifiedLine = [NSString stringWithFormat:@" %@ ", line];
    NSString *searchPattern = [NSString stringWithFormat:@" %@=", name];
    NSRange range = [modifiedLine rangeOfString:searchPattern];
    
    if (range.location != NSNotFound) {
        NSString *substring = [modifiedLine substringFromIndex:range.location + range.length];
        NSRange endRange = [substring rangeOfString:@" "];
        if (endRange.location != NSNotFound) {
            return [substring substringToIndex:endRange.location];
        }
    }
    return @"";
}

+ (NSString *)getUITextAttribute:(NSString *)line name:(NSString *)name {
    NSString *modifiedLine = [NSString stringWithFormat:@" %@ ", line];
    NSString *searchPattern = [NSString stringWithFormat:@" %@=\"", name];
    NSRange range = [modifiedLine rangeOfString:searchPattern];
    
    if (range.location != NSNotFound) {
        NSString *substring = [modifiedLine substringFromIndex:range.location + range.length];
        NSRange endRange = [substring rangeOfString:@"\" "];
        if (endRange.location != NSNotFound) {
            return [substring substringToIndex:endRange.location];
        }
    }
    return @"";
}

// MARK: - SimCommonPackage Override

- (void)onChangedPackage {
    self.bySimId = nil;
    self.byInstance = nil;
    self.names = nil;
    self.famNames = nil;
}

@end

#import "SimDescriptions.h"
#import "MetaData.h"
#import "LinkedSDesc.h"
#import "TraitAlias.h"
#import "CollectibleAlias.h"
#import "Warning.h"
#import "Helper.h"
#import "IPackageFile.h"
#import "IPackedFileDescriptor.h"
#import "ISDesc.h"
#import "ISimNames.h"
#import "ISimFamilyNames.h"
#import "FileTable.h"
#import "ProviderRegistry.h"
#import "PathProvider.h"
#import "File.h"
#import "Str.h"
#import "StrItemList.h"
#import "Picture.h"
#import "Xml.h"
#import "Localization.h"
#import "Registry.h"

@implementation SimDescriptions

// MARK: - Initialization

- (instancetype)initWithPackage:(id<IPackageFile>)package
                          names:(id<ISimNames>)names
                       famNames:(id<ISimFamilyNames>)famNames {
    self = [super initWithPackage:package];
    if (self) {
        self.names = names;
        self.famNames = famNames;
    }
    return self;
}

- (instancetype)initWithNames:(id<ISimNames>)names famNames:(id<ISimFamilyNames>)famNames {
    return [self initWithPackage:nil names:names famNames:famNames];
}

// MARK: - ISimDescriptions Protocol Implementation

- (NSMutableDictionary *)simGuidMap {
    if (self.bySimId == nil) {
        [self loadDescriptions];
    }
    return self.bySimId;
}

- (NSMutableDictionary *)simInstance {
    if (self.byInstance == nil) {
        [self loadDescriptions];
    }
    return self.byInstance;
}

- (id<ISDesc>)findSim:(uint16_t)instance {
    if (self.byInstance == nil) {
        [self loadDescriptions];
    }
    return [self.byInstance objectForKey:@(instance)];
}

- (id<ISDesc>)findSimById:(uint32_t)simId {
    if (self.bySimId == nil) {
        [self loadDescriptions];
    }
    return [self.bySimId objectForKey:@(simId)];
}

- (uint16_t)getInstance:(uint32_t)simId {
    id<ISDesc> desc = [self findSimById:simId];
    if (desc != nil) {
        return [desc instance];
    } else {
        return 0xffff;
    }
}

- (uint32_t)getSimId:(uint16_t)instance {
    id<ISDesc> desc = [self findSim:instance];
    if (desc != nil) {
        return [desc simId];
    } else {
        return 0xffffffff;
    }
}

- (NSMutableArray *)getHouseholdNames {
    NSString *firstCustom;
    return [self getHouseholdNames:&firstCustom];
}

- (NSMutableArray *)getHouseholdNames:(NSString **)firstCustom {
    NSDictionary *simInstances = [[[FileTable providerRegistry] simDescriptionProvider] simInstance];
    NSMutableArray *list = [[NSMutableArray alloc] init];
    *firstCustom = nil;
    
    for (LinkedSDesc *sdesc in [simInstances allValues]) {
        NSString *householdName = [sdesc householdName];
        if (householdName == nil) {
            householdName = [Localization getString:@"Unknown"];
        }
        
        if (![list containsObject:householdName]) {
            [list addObject:householdName];
            if (*firstCustom == nil && ![sdesc isNPC] && ![sdesc isTownie]) {
                *firstCustom = householdName;
            }
        }
    }
    
    if (*firstCustom == nil) {
        if ([list count] > 0) {
            *firstCustom = [list firstObject];
        } else {
            *firstCustom = [Localization getString:@"Unknown"];
        }
    }
    
    [list sortUsingSelector:@selector(compare:)];
    return list;
}

// MARK: - Loading Methods

- (void)loadDescriptions {
    self.bySimId = [[NSMutableDictionary alloc] init];
    self.byInstance = [[NSMutableDictionary alloc] init];
    BOOL didWarnDoubleGuid = NO;
    
    if (self.basePackage == nil) return;
    
    NSArray<id<IPackedFileDescriptor>> *files = [self.basePackage findFiles:[MetaData SIM_DESCRIPTION_FILE]];
    
    for (id<IPackedFileDescriptor> pfd in files) {
        LinkedSDesc *sdesc = [[LinkedSDesc alloc] init];
        [sdesc processData:pfd package:self.basePackage];
        
        NSNumber *simIdKey = @([sdesc simId]);
        NSNumber *instanceKey = @([sdesc instance]);
        
        if ([self.bySimId objectForKey:simIdKey] != nil || [self.byInstance objectForKey:instanceKey] != nil) {
            if (!didWarnDoubleGuid) {
                NSString *message = [NSString stringWithFormat:@"A Sim was found Twice! The Sim with GUID 0x%@ (inst=0x%@) exists more than once. This could result in Problems during the Gameplay!",
                                   [Helper hexStringUInt:([sdesc simId])],
                                   [Helper hexStringUShort:([sdesc instance])]];
                Warning *warning = [[Warning alloc] initWithMessage:@"A Sim was found Twice!" details:message];
                [Helper exceptionMessage:warning];
                didWarnDoubleGuid = YES;
            }
        }
        
        [self.bySimId setObject:sdesc forKey:simIdKey];
        [self.byInstance setObject:sdesc forKey:instanceKey];
    }
}

// MARK: - Nightlife Turn On/Off Extension

- (void)loadTurnOns {
    if (self.turnOns != nil) return;
    self.turnOns = [[NSMutableDictionary alloc] init];
    
    if ([[PathProvider global] EPInstalled] < 2) return;
    
    NSString *uiTextPath = [NSString pathWithComponents:@[[[PathProvider global] latest].installFolder, @"TSData", @"Res", @"Text", @"UIText.package"]];
    File *pkg = [File loadFromFile:uiTextPath];
    Str *str = [[Str alloc] init];
    id<IPackedFileDescriptor> pfd = [pkg findFile:[MetaData STRING_FILE] subtype:0 group:[MetaData LOCAL_GROUP] instance:0xe1];
    
    if (pfd != nil) {
        [str processData:pfd package:pkg];
        StrItemList *strs = [str fallbackedLanguageItems:[[Registry windowsRegistry] languageCode]];
        
        for (NSInteger i = 0; i < [strs count]; i++) {
            [self.turnOns setObject:[[strs objectAtIndex:i] title] forKey:@(i)];
        }
    }
}

- (NSArray<TraitAlias *> *)getAllTurnOns {
    if (self.turnOns == nil) {
        [self loadTurnOns];
    }
    
    NSMutableArray<TraitAlias *> *aliases = [[NSMutableArray alloc] initWithCapacity:[self.turnOns count]];
    
    for (NSNumber *key in [self.turnOns allKeys]) {
        NSString *name = [self.turnOns objectForKey:key];
        NSInteger k = [key integerValue];
        NSInteger e = k;
        if (e > 0xD) e += 2; // only 14 bits in traits1 (etc)
        
        TraitAlias *alias = [[TraitAlias alloc] initWithId:(uint64_t)pow(2, e) name:name];
        [aliases addObject:alias];
    }
    
    return [aliases copy];
}

- (uint64_t)buildTurnOnIndex:(uint16_t)val1 val2:(uint16_t)val2 val3:(uint16_t)val3 {
    uint64_t res = val1;
    res |= ((uint64_t)val2 << 16);
    res |= ((uint64_t)val3 << 32); // BonVoyage
    return res;
}

- (NSArray<NSNumber *> *)getFromTurnOnIndex:(uint64_t)index {
    NSMutableArray<NSNumber *> *ret = [[NSMutableArray alloc] initWithCapacity:3];
    ret[2] = @((uint16_t)((index >> 32) & 0xFFFF)); // BonVoyage
    ret[1] = @((uint16_t)((index >> 16) & 0xFFFF));
    ret[0] = @((uint16_t)(index & 0xFFFF));
    return [ret copy];
}

- (NSString *)getTurnOnName:(uint16_t)val1 val2:(uint16_t)val2 val3:(uint16_t)val3 {
    if (self.turnOns == nil) {
        [self loadTurnOns];
    }
    
    uint64_t v = [self buildTurnOnIndex:val1 val2:val2 val3:val3];
    NSMutableString *ret = [[NSMutableString alloc] init];
    NSInteger ct = 0;
    
    while (v > 0) {
        uint64_t s = v & 1;
        if (s == 1) {
            NSString *name = [self.turnOns objectForKey:@(ct)];
            if (name == nil) {
                return [Localization getString:@"Unknown"];
            }
            if ([ret length] > 0) {
                [ret appendString:@", "];
            }
            [ret appendString:name];
        }
        v = v >> 1;
        ct++;
    }
    
    return [ret copy];
}

// MARK: - BonVoyage Vacation Collectibles Extension

- (void)loadCollectibles {
    if (self.collectibles != nil) return;
    self.collectibles = [[NSMutableDictionary alloc] init];
    
    if ([[PathProvider global] EPInstalled] < 11) return;
    
    @try {
        NSString *uiTextPath = [NSString pathWithComponents:@[[[PathProvider global] latest].installFolder, @"TSData", @"Res", @"Text", @"UIText.package"]];
        File *pkg = [File loadFromFile:uiTextPath];
        Str *str = [[Str alloc] init];
        id<IPackedFileDescriptor> pfd = [pkg findFile:[MetaData STRING_FILE] subtype:0 group:[MetaData LOCAL_GROUP] instance:0xb7];
        
        if (pfd != nil) {
            [str processData:pfd package:pkg];
            StrItemList *strs = [str fallbackedLanguageItems:[[Registry windowsRegistry] languageCode]];
            
            NSString *uiPackagePath = [NSString pathWithComponents:@[[[PathProvider global] latest].installFolder, @"TSData", @"Res", @"UI", @"ui.package"]];
            pkg = [File loadFromFile:uiPackagePath];
            pfd = [pkg findFile:0 subtype:0 group:0xA99D8A11 instance:0xACDC6300];
            
            if (pfd != nil) {
                Xml *xml = [[Xml alloc] init];
                [xml processData:pfd package:pkg];
                
                NSArray *lines = [[xml text] componentsSeparatedByString:@"\r"];
                Picture *pic = [[Picture alloc] init];
                [[FileTable fileIndex] load];
                
                for (NSString *fullLine in lines) {
                    NSString *line = [[fullLine lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    if ([line hasPrefix:@"<legacy"] && [line containsString:@"enabled\""] && [line containsString:@"tipres="]) {
                        line = [[[line stringByReplacingOccurrencesOfString:@"<legacy" withString:@""]
                                      stringByReplacingOccurrencesOfString:@">" withString:@""]
                                      stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                        
                        NSString *tipres = [SimDescriptions getUIListAttribute:line name:@"tipres"];
                        NSArray *tipresComponents = [tipres componentsSeparatedByString:@","];
                        NSInteger index = [Helper stringToInt32:[tipresComponents objectAtIndex:1] default:0 base:16] & 0xFFFF;
                        NSInteger testNr = (NSInteger)(([Helper stringToInt32:[tipresComponents objectAtIndex:1] default:0 base:16] & 0xFFFF0000) >> 16);
                        
                        if (index > 0 && testNr == 0xb7) {
                            index = [self createCollectibleAlias:strs picture:pic line:line index:index];
                        }
                    }
                }
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"ERROR during Voyage Collectible Image Parsing:\n%@", exception);
        if ([Helper debugMode]) {
            [Helper exceptionMessage:[exception localizedDescription]];
        }
    }
}

- (NSInteger)createCollectibleAlias:(StrItemList *)strs
                            picture:(Picture *)pic
                               line:(NSString *)line
                              index:(NSInteger)index {
    index--;
    NSString *image = [SimDescriptions getUIListAttribute:line name:@"image"];
    NSString *idStr = [SimDescriptions getUIAttribute:line name:@"id"];
    NSInteger nr = [Helper stringToInt32:idStr default:0 base:16] / 2 - 1;
    NSArray *stgi = [image componentsSeparatedByString:@","];
    uint32_t g = [Helper stringToUInt32:[stgi objectAtIndex:0] default:0 base:16];
    uint32_t i = [Helper stringToUInt32:[stgi objectAtIndex:1] default:0 base:16];
    NSString *name = [SimDescriptions getUITextAttribute:line name:@"tiptext"];
    
    if (index < [strs count]) {
        name = [[strs objectAtIndex:index] title];
    }
    
    NSImage *img = [SimDescriptions loadCollectibleIcon:pic group:g instance:i];
    
    CollectibleAlias *alias = [[CollectibleAlias alloc] initWithId:(uint64_t)pow(2, nr)
                                                               number:nr
                                                                 name:name
                                                                image:img];
    [self.collectibles setObject:alias forKey:@(nr)];
    return index;
}

+ (NSImage *)loadCollectibleIcon:(Picture *)pic group:(uint32_t)group instance:(uint32_t)instance {
    NSArray *items = [[FileTable fileIndex] findFileByGroupAndInstance:group instance:instance];
    if ([items count] > 0) {
        [pic processData:[items firstObject]];
        NSImage *originalImage = [pic image];
        
        // Create a new image with 1/4 width
        NSSize originalSize = [originalImage size];
        NSSize newSize = NSMakeSize(originalSize.width / 4, originalSize.height);
        
        NSImage *newImage = [[NSImage alloc] initWithSize:newSize];
        [newImage lockFocus];
        [originalImage drawInRect:NSMakeRect(0, 0, newSize.width, newSize.height)
                         fromRect:NSMakeRect(0, 0, newSize.width, newSize.height)
                        operation:NSCompositingOperationCopy
                         fraction:1.0];
        [newImage unlockFocus];
        
        return newImage;
    }
    return nil;
}

- (NSArray<CollectibleAlias *> *)getAllCollectibles {
    if (self.collectibles == nil) {
        [self loadCollectibles];
    }
    
    NSMutableArray<CollectibleAlias *> *aliases = [[NSMutableArray alloc] initWithCapacity:[self.collectibles count]];
    
    for (NSNumber *key in [self.collectibles allKeys]) {
        [aliases addObject:[self.collectibles objectForKey:key]];
    }
    
    return [aliases copy];
}

- (uint64_t)buildCollectibleIndex:(uint16_t)val1 val2:(uint16_t)val2 val3:(uint16_t)val3 val4:(uint16_t)val4 {
    return (uint32_t)(((((val4 << 16) + val3) << 16) + val2) << 16) + val1;
}

- (NSArray<NSNumber *> *)getFromCollectibleIndex:(uint64_t)index {
    NSMutableArray<NSNumber *> *ret = [[NSMutableArray alloc] initWithCapacity:4];
    ret[3] = @((uint16_t)((index >> 48) & 0xFFFF));
    ret[2] = @((uint16_t)((index >> 32) & 0xFFFF));
    ret[1] = @((uint16_t)((index >> 16) & 0xFFFF));
    ret[0] = @((uint16_t)(index & 0xFFFF));
    return [ret copy];
}

- (NSString *)getCollectibleName:(uint16_t)val1 val2:(uint16_t)val2 val3:(uint16_t)val3 val4:(uint16_t)val4 {
    if (self.collectibles == nil) {
        [self loadCollectibles];
    }
    
    uint64_t v = [self buildCollectibleIndex:val1 val2:val2 val3:val3 val4:val4];
    NSMutableString *ret = [[NSMutableString alloc] init];
    NSInteger ct = 0;
    
    while (v > 0) {
        uint64_t s = v & 1;
        if (s == 1) {
            CollectibleAlias *alias = [self.collectibles objectForKey:@(ct)];
            if (alias == nil) {
                return [Localization getString:@"Unknown"];
            }
            if ([ret length] > 0) {
                [ret appendString:@", "];
            }
            [ret appendString:[alias description]];
        }
        v = v >> 1;
        ct++;
    }
    
    return [ret copy];
}

// MARK: - Utility Methods

+ (NSString *)getUIListAttribute:(NSString *)line name:(NSString *)name {
    NSString *modifiedLine = [NSString stringWithFormat:@" %@ ", line];
    NSString *searchPattern = [NSString stringWithFormat:@" %@={", name];
    NSRange range = [modifiedLine rangeOfString:searchPattern];
    
    if (range.location != NSNotFound) {
        NSString *substring = [modifiedLine substringFromIndex:range.location + range.length];
        NSRange endRange = [substring rangeOfString:@"} "];
        if (endRange.location != NSNotFound) {
            return [substring substringToIndex:endRange.location];
        }
    }
    return @"";
}

+ (NSString *)getUIAttribute:(NSString *)line name:(NSString *)name {
    NSString *modifiedLine = [NSString stringWithFormat:@" %@ ", line];
    NSString *searchPattern = [NSString stringWithFormat:@" %@=", name];
    NSRange range = [modifiedLine rangeOfString:searchPattern];
    
    if (range.location != NSNotFound) {
        NSString *substring = [modifiedLine substringFromIndex:range.location + range.length];
        NSRange endRange = [substring rangeOfString:@" "];
        if (endRange.location != NSNotFound) {
            return [substring substringToIndex:endRange.location];
        }
    }
    return @"";
}

+ (NSString *)getUITextAttribute:(NSString *)line name:(NSString *)name {
    NSString *modifiedLine = [NSString stringWithFormat:@" %@ ", line];
    NSString *searchPattern = [NSString stringWithFormat:@" %@=\"", name];
    NSRange range = [modifiedLine rangeOfString:searchPattern];
    
    if (range.location != NSNotFound) {
        NSString *substring = [modifiedLine substringFromIndex:range.location + range.length];
        NSRange endRange = [substring rangeOfString:@"\" "];
        if (endRange.location != NSNotFound) {
            return [substring substringToIndex:endRange.location];
        }
    }
    return @"";
}

// MARK: - SimCommonPackage Override

- (void)onChangedPackage {
    self.bySimId = nil;
    self.byInstance = nil;
    self.names = nil;
    self.famNames = nil;
}

@end
