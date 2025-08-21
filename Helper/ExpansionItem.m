//
//  ExpansionItem.m
//  MacSimpe
//
//  Created by Catherine Gramze on 8/2/25.
//
// ***************************************************************************
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

#import "ExpansionItem.h"
#import "PathProvider.h"
#import "CaseInvariantArrayList.h"
#import "ExceptionForm.h"



@interface ExpansionItem ()
@property (nonatomic, strong) IniRegistry *profilesIni;
@end

// MARK: - ExpansionItemFlags Implementation

@implementation ExpansionItemFlags

- (instancetype)initWithValue:(NSInteger)value {
    self = [super initWithValue:(uint16_t)value];
    return self;
}

- (BOOL)regularExpansion {
    return [self getBit:0];
}

- (BOOL)stuffPack {
    return [self getBit:1];
}

- (BOOL)luaFolders {
    return [self getBit:2];
}

- (BOOL)loadWantText {
    return [self getBit:3];
}

- (BOOL)simStory {
    return [self getBit:4];
}

- (BOOL)fullObjectsPackage {
    return ![self getBit:5];
}

- (ExpansionClasses)expansionClass {
    if (self.regularExpansion) return ExpansionClassesExpansionPack;
    if (self.stuffPack) return ExpansionClassesStuffPack;
    return ExpansionClassesBaseGame;
}

@end

// MARK: - NeighborhoodPath Implementation

@implementation NeighborhoodPath

- (instancetype)initWithName:(NSString *)name
                        path:(NSString *)path
                   expansion:(ExpansionItem *)expansion
                   isDefault:(BOOL)isDefault {
    self = [super init];
    if (self) {
        _label = [name copy];
        _path = [path copy];
        _expansion = expansion;
        _isDefault = isDefault;
    }
    return self;
}

- (NSUInteger)hash {
    if (self.expansion == nil) return 0;
    return (NSUInteger)self.expansion.version;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[NeighborhoodPath class]]) {
        NeighborhoodPath *other = (NeighborhoodPath *)object;
        NSString *thisPath = [Helper compareableFileName:self.path];
        NSString *otherPath = [Helper compareableFileName:other.path];
        return [thisPath isEqualToString:otherPath];
    }
    return [super isEqual:object];
}

@end

// MARK: - NeighborhoodPaths Implementation

@implementation NeighborhoodPaths
@end

// MARK: - ExpansionItem Implementation

@implementation ExpansionItem

- (instancetype)initWithXmlRegistryKey:(XmlRegistryKey *)key {
    self = [super init];
    if (self) {
        _fileTableFolders = [[CaseInvariantArrayList alloc] init];
        _preObjectFileTableFolders = [[CaseInvariantArrayList alloc] init];
        
        _shortName = @"Unk.";
        _shorterName = @"Unknown";
        _longName = @"The Sims 2 - Unknown";
        _nameListNumber = @"0";
        
        if (key != nil) {
            _name = key.name;
            
            // Get localized registry key
            NSString *currentLanguage = [[NSLocale currentLocale] localeIdentifier];
            XmlRegistryKey *lang = [key openSubKey:[currentLanguage lowercaseString] create:NO];
            if (lang == nil) {
                NSString *twoLetterCode = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
                lang = [key openSubKey:[twoLetterCode lowercaseString] create:NO];
            }
            
            _version = (NSInteger)[key getValue:@"Version" defaultValue:@(0)];
            _runtimeVersion = (NSInteger)[key getValue:@"PreferedRuntimeVersion" defaultValue:@(_version)];
            _expansion = (Expansions)(1 << _version);
            
            NSInteger registryIndex = -1;
            id regKeyValue = [key getValue:@"RegKey" defaultValue:nil];
            if ([regKeyValue isKindOfClass:[NSString class]]) {
                // On macOS, we'll store registry-like data in user defaults or plist files
                _registryKey = @{@"path": regKeyValue};
            } else if ([regKeyValue isKindOfClass:[CaseInvariantArrayList class]]) {
                CaseInvariantArrayList *regKeys = (CaseInvariantArrayList *)regKeyValue;
                if (regKeys.count > 0) {
                    NSString *regPath = [regKeys objectAtIndex:0];
                    _registryKey = @{@"path": regPath};
                    registryIndex = 0;
                }
            }
            
            if (_registryKey == nil) registryIndex = -1;
            
            id installSuffixValue = [key getValue:@"InstallSuffix" defaultValue:nil];
            if ([installSuffixValue isKindOfClass:[NSString class]]) {
                _installSuffix = (NSString *)installSuffixValue;
            } else if ([installSuffixValue isKindOfClass:[CaseInvariantArrayList class]] &&
                      registryIndex >= 0 &&
                      registryIndex < [(CaseInvariantArrayList *)installSuffixValue count]) {
                _installSuffix = [(CaseInvariantArrayList *)installSuffixValue objectAtIndex:registryIndex];
            }
            
            _exeName = [key getValue:@"ExeName" defaultValue:@"Sims2.exe"];
            _flag = [[ExpansionItemFlags alloc] initWithValue:(NSInteger)[key getValue:@"Flag" defaultValue:@(0)]];
            _censorFileName = [key getValue:@"Censor" defaultValue:@""];
            _group = (NSInteger)[key getValue:@"Group" defaultValue:@(1)];
            _objectsFolder = [key getValue:@"ObjectsFolder"
                               defaultValue:[NSString stringWithFormat:@"TSData%@Res%@Objects",
                                           [Helper pathSeparator], [Helper pathSeparator]]];
            
            _simNameDeepSearch = [key getValue:@"SimNameDeepSearch"
                                  defaultValue:[[CaseInvariantArrayList alloc] init]];
            _saveGames = [key getValue:@"SaveGameLocationsForGroup"
                          defaultValue:[[CaseInvariantArrayList alloc] init]];
            
            if ([_saveGames count] == 0) {
                [_saveGames addObject:[PathProvider simSavegameFolder]];
            }
            
            CaseInvariantArrayList *fileTableFoldersValue = [key getValue:@"FileTableFolders"
                                                              defaultValue:[[CaseInvariantArrayList alloc] init]];
            if ([fileTableFoldersValue count] == 0) {
                [self setDefaultFileTableFolders];
            } else {
                for (NSString *folder in fileTableFoldersValue) {
                    [self addFileTableFolder:folder];
                }
            }
            
            CaseInvariantArrayList *additionalFileTableFoldersValue = [key getValue:@"AdditionalFileTableFolders"
                                                                      defaultValue:[[CaseInvariantArrayList alloc] init]];
            for (NSString *folder in additionalFileTableFoldersValue) {
                [self addFileTableFolder:folder];
            }
            
            NSLog(@"%@", [self description]);
            
            _nameListNumber = [key getValue:@"namelistnr" defaultValue:@"0"];
            NSString *displayName = _name;
            
            if (lang != nil) {
                _shortName = [lang getValue:@"short" defaultValue:_name];
                _shorterName = [lang getValue:@"name" defaultValue:_shortName];
                if (_registryKey != nil) {
                    displayName = _registryKey[@"DisplayName"] ?: _shorterName;
                }
                _longName = [lang getValue:@"long" defaultValue:displayName];
            } else {
                // Check resource files, then try default language, then set to defaults
                if (lang == nil) {
                    lang = [key openSubKey:@"en" create:NO];
                }
                
                _shortName = [Localization getString:[NSString stringWithFormat:@"EP SNAME %ld", (long)_version]];
                _shorterName = _shortName;
                
                if ([_shortName isEqualToString:[NSString stringWithFormat:@"EP SNAME %ld", (long)_version]] && lang != nil) {
                    _shortName = [lang getValue:@"short" defaultValue:_name];
                    _shorterName = [lang getValue:@"name" defaultValue:_shortName];
                }
                
                if ([_shortName isEqualToString:[NSString stringWithFormat:@"EP SNAME %ld", (long)_version]]) {
                    _shortName = _name;
                }
                
                if (_registryKey != nil) {
                    displayName = _registryKey[@"DisplayName"] ?: _shorterName;
                }
                
                _longName = [Localization getString:[NSString stringWithFormat:@"EP NAME %ld", (long)_version]];
                if ([_longName isEqualToString:[NSString stringWithFormat:@"EP NAME %ld", (long)_version]] && lang != nil) {
                    _longName = [lang getValue:@"long" defaultValue:displayName];
                }
                
                if ([_longName isEqualToString:[NSString stringWithFormat:@"EP NAME %ld", (long)_version]]) {
                    _longName = displayName;
                }
            }
        } else {
            _name = @"NULL";
            _flag = [[ExpansionItemFlags alloc] initWithValue:0];
            _censorFileName = @"";
            _exeName = @"";
            _expansion = (Expansions)0;
            _version = -1;
            _runtimeVersion = -1;
            _simNameDeepSearch = [[CaseInvariantArrayList alloc] init];
            _saveGames = [[CaseInvariantArrayList alloc] init];
            [_saveGames addObject:[PathProvider simSavegameFolder]];
            
            [self setDefaultFileTableFolders];
            _objectsFolder = [NSString stringWithFormat:@"TSData%@Res%@Objects",
                             [Helper pathSeparator], [Helper pathSeparator]];
            _group = 0;
        }
        
        [self buildGroupList];
        _shortNameId = [self getShortName];
    }
    return self;
}

// MARK: - File Table Management

- (void)setDefaultFileTableFolders {
    if ([self.preObjectFileTableFolders count] == 0) {
        if (self.flag.expansionClass == ExpansionClassesBaseGame) {
            NSString *catalogBinsPath = [NSString stringWithFormat:@"!TSData%@Res%@Catalog%@Bins",
                                       [Helper pathSeparator], [Helper pathSeparator], [Helper pathSeparator]];
            [self addFileTableFolder:catalogBinsPath];
        }
    }
    
    if ([self.fileTableFolders count] == 0) {
        NSString *pathSep = [Helper pathSeparator];
        
        if (self.flag.expansionClass == ExpansionClassesBaseGame) {
            [self addFileTableFolder:[NSString stringWithFormat:@"TSData%@Res%@Sims3D", pathSep, pathSep]];
        } else {
            [self addFileTableFolder:[NSString stringWithFormat:@"TSData%@Res%@3D", pathSep, pathSep]];
        }
        
        [self addFileTableFolder:[NSString stringWithFormat:@"TSData%@Res%@Catalog%@Materials", pathSep, pathSep, pathSep]];
        [self addFileTableFolder:[NSString stringWithFormat:@"TSData%@Res%@Catalog%@Skins", pathSep, pathSep, pathSep]];
        [self addFileTableFolder:[NSString stringWithFormat:@"TSData%@Res%@Catalog%@Patterns", pathSep, pathSep, pathSep]];
        [self addFileTableFolder:[NSString stringWithFormat:@"TSData%@Res%@Catalog%@CANHObjects", pathSep, pathSep, pathSep]];
        [self addFileTableFolder:[NSString stringWithFormat:@"TSData%@Res%@Wants", pathSep, pathSep]];
        [self addFileTableFolder:[NSString stringWithFormat:@"TSData%@Res%@UI", pathSep, pathSep]];
    }
}

- (void)addFileTableFolder:(NSString *)folder {
    if ([folder hasPrefix:@"!"]) {
        [self addFileTableFolder:[folder substringFromIndex:1] toList:self.preObjectFileTableFolders];
    } else if (![self.fileTableFolders containsObject:folder]) {
        [self addFileTableFolder:folder toList:self.fileTableFolders];
    }
}

- (void)addFileTableFolder:(NSString *)folder toList:(CaseInvariantArrayList *)list {
    BOOL insertAtBeginning = NO;
    if ([folder hasPrefix:@"<"]) {
        folder = [folder substringFromIndex:1];
        insertAtBeginning = YES;
    }
    
    if (![list containsObject:folder]) {
        if (insertAtBeginning) {
            [list insertObject:folder atIndex:0];
        } else {
            [list addObject:folder];
        }
    }
}

// MARK: - Group Management

- (void)buildGroupList {
    NSMutableArray<NSNumber *> *groupList = [[NSMutableArray alloc] init];
    
    for (NSInteger i = 0; i < [PathProvider groupCount]; i++) {
        long long groupValue = 1LL << i;
        if ([self shareOneGroupWithGroup:groupValue]) {
            [groupList addObject:@(groupValue)];
        }
    }
    
    self.groups = [groupList copy];
}

- (BOOL)shareOneGroupWithExpansion:(ExpansionItem *)expansion {
    return (expansion.group & self.group) != 0;
}

- (BOOL)shareOneGroupWithGroup:(long long)group {
    return (group & self.group) != 0;
}

// MARK: - Path Management

- (void)addNeighborhoodPaths:(NeighborhoodPaths *)neighborhoods {
    for (NSString *saveGamePath in self.saveGames) {
        NSString *neighborhoodsPath = [[self getRealPath:saveGamePath] stringByAppendingPathComponent:@"Neighborhoods"];

        if ([[NSFileManager defaultManager] fileExistsAtPath:neighborhoodsPath]) {
            NeighborhoodPath *neighborhoodPathObj = [[NeighborhoodPath alloc]
                initWithName:@""
                        path:neighborhoodsPath
                   expansion:self
                   isDefault:YES];

            if (![neighborhoods containsObject:neighborhoodPathObj]) {
                [neighborhoods addObject:neighborhoodPathObj];
            }
        }
    }
}

- (void)addSaveGamePaths:(CaseInvariantArrayList *)realSaveGames {
    for (NSString *saveGamePath in self.saveGames) {
        NSString *realPath = [self getRealPath:saveGamePath];
        if ([[NSFileManager defaultManager] fileExistsAtPath:realPath]) {
            [realSaveGames addObject:realPath];
        }
    }
}

- (NSString *)getRealPath:(NSString *)path {
    path = [path stringByReplacingOccurrencesOfString:@"{MyDocuments}" withString:[PathProvider personalFolder]];
    path = [path stringByReplacingOccurrencesOfString:@"{DisplayName}" withString:self.displayName];
    path = [path stringByReplacingOccurrencesOfString:@"{UserSaveGame}" withString:[PathProvider simSavegameFolder]];
    return path;
}

// MARK: - Computed Properties

- (NSString *)displayName {
    return [PathProvider displayedName];
}

- (NSString *)censorFile {
    return [[PathProvider simSavegameFolder] stringByAppendingPathComponent:
           [@"Config" stringByAppendingPathComponent:self.censorFileName]];
}

- (BOOL)exists {
    return self.registryKey != nil;
}

- (NSString *)applicationPath {
    @try {
        return [self.installFolder stringByAppendingPathComponent:
               [@"TSBin" stringByAppendingPathComponent:self.exeName]];
    } @catch (NSException *exception) {
        return @"";
    }
}

- (NSString *)objectsSubFolder {
    return self.objectsFolder;
}

- (NSString *)idKey {
    return [self.exeName stringByDeletingPathExtension];
}

- (NSString *)shortId {
    return self.shortNameId;
}

- (NSString *)nameShort {
    return self.shortName;
}

- (NSString *)nameSortNumber {
    return self.nameListNumber;
}

- (NSString *)nameShorter {
    return self.shorterName;
}

- (NSString *)realInstallFolder {
    if (!self.exists) return @"";
    
    @try {
        NSString *installDir = self.registryKey[@"Install Dir"];
        if (installDir == nil) {
            return @"";
        } else if (self.installSuffix != nil && [self.installSuffix length] > 0) {
            return [[Helper toLongPathName:installDir] stringByAppendingPathComponent:self.installSuffix];
        } else {
            return [Helper toLongPathName:installDir];
        }
    } @catch (NSException *exception) {
        return @"";
    }
}

- (NSString *)installFolder {
    return self.realInstallFolder;
}

- (void)setInstallFolder:(NSString *)installFolder {
    // no-op on macOS; install location is fixed
}

// MARK: - Private Methods

- (NSString *)getShortName {
    NSString *result = [[[self.idKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
                        uppercaseString]
                       stringByReplacingOccurrencesOfString:@"SIMS2" withString:@""];
    
    if ([result isEqualToString:@""]) {
        return @"Game";
    }
    return result;
}

// MARK: - NSObject Overrides

- (NSString *)description {
    NSString *description = [NSString stringWithFormat:@"%@: %ld=%lu, %@, %@, %ld",
                            self.name,
                            (long)self.version,
                            (unsigned long)self.expansion,
                            self.exeName,
                            self.flag,
                            (long)self.flag.expansionClass];
    
    if (self.registryKey != nil) {
        description = [description stringByAppendingFormat:@", %@", self.registryKey[@"path"] ?: @""];
    }
    
    return description;
}

// MARK: - Comparison

- (NSComparisonResult)compare:(ExpansionItem *)other {
    if (other == nil) return NSOrderedSame;
    
    if (self.version < other.version) return NSOrderedAscending;
    if (self.version > other.version) return NSOrderedDescending;
    return NSOrderedSame;
}

@end
