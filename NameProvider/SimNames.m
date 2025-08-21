//
//  SimNames.m
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

#import "SimNames.h"
#import "MetaData.h"
#import "ExtObjd.h"
#import "Str.h"
#import "Picture.h"
#import "Alias.h"
#import "IPackageFile.h"
#import "IPackedFileDescriptor.h"
#import "IAlias.h"
#import "IOpcodeProvider.h"
#import "IScenegraphFileIndex.h"
#import "IScenegraphFileIndexItem.h"
#import "File.h"
#import "FileTable.h"
#import "FileIndex.h"
#import "FileTableItem.h"
#import "PathProvider.h"
#import "ExpansionItem.h"
#import "Helper.h"
#import "Registry.h"
#import "Wait.h"
#import "WaitingScreen.h"
#import "Localization.h"

@implementation SimNames

// MARK: - Initialization

- (instancetype)initWithFolder:(NSString *)folder opcodes:(id<IOpcodeProvider>)opcodes {
    self = [super init];
    if (self) {
        self.baseFolder = folder;
        self.opcodes = opcodes;
        self.sync = [[NSObject alloc] init];
        
        // Setup character file index
        NSMutableArray *folders = [[NSMutableArray alloc] init];
        NSArray *expansions = [[PathProvider global] expansions];
        for (ExpansionItem *ei in expansions) {
            if (![ei exists]) continue;
            
            NSArray *simNameDeepSearch = [ei simNameDeepSearch];
            for (NSString *s in simNameDeepSearch) {
                NSString *path = [NSString pathWithComponents:@[[[PathProvider global] latest].installFolder, s]];
                if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
                    path = [NSString pathWithComponents:@[[ei installFolder], s]];
                }
                if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                    FileTableItem *item = [[FileTableItem alloc] initWithPath:path];
                    [folders addObject:item];
                }
            }
        }
        
        self.characterfi = [[FileIndex alloc] initWithFolders:folders];
    }
    return self;
}

- (instancetype)initWithOpcodes:(id<IOpcodeProvider>)opcodes {
    return [self initWithFolder:@"" opcodes:opcodes];
}

// MARK: - ISimNames Protocol Implementation

- (NSString *)baseFolder {
    return self.dir;
}

- (void)setBaseFolder:(NSString *)baseFolder {
    if (![self.dir isEqualToString:baseFolder]) {
        [self waitForEnd];
        self.names = nil;
    }
    self.dir = baseFolder;
}

- (NSMutableDictionary *)storedData {
    if (self.names == nil) {
        [self loadSimsFromFolder];
    }
    return self.names;
}

- (void)setStoredData:(NSMutableDictionary *)storedData {
    self.names = storedData;
}

- (id<IAlias>)findName:(uint32_t)simId {
    if (self.names == nil) {
        [self loadSimsFromFolder];
    }
    
    id<IAlias> alias = [self.names objectForKey:@(simId)];
    if (alias != nil) {
        return alias;
    } else {
        return [[Alias alloc] initWithId:simId name:[Localization getString:@"unknown"]];
    }
}

// MARK: - Loading Methods

- (void)loadSimsFromFolder {
    [self waitForEnd];
    
    self.names = [[NSMutableDictionary alloc] init];
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.dir]) return;
    
    if ([[Registry windowsRegistry] deepSimScan] && [Helper startedGui] != ExecutableClassic) {
        [[FileTable fileIndex] load];
    }
    
    [self executeThread:ThreadPriorityHigh name:@"Sim Name Provider" sync:YES events:YES];
}

// MARK: - Sim Processing Methods

- (Alias *)addSimFromPackage:(id<IPackageFile>)packageFile
                    objdpfd:(id<IPackedFileDescriptor>)objdpfd
                    counter:(NSInteger *)ct
                       step:(NSInteger)step {
    
    ExtObjd *objd = [[ExtObjd alloc] init];
    [objd processData:objdpfd package:packageFile];
    
    return [self addSim:objd counter:ct step:step npc:NO];
}

- (Alias *)addSim:(ExtObjd *)objd counter:(NSInteger *)ct step:(NSInteger)step npc:(BOOL)npc {
    id<IPackageFile> packageFile = [objd package];
    BOOL hasAgeData = [[packageFile findFiles:0xAC598EAC] count] > 0; // has Age Data
    
    NSMutableArray *tags = [[NSMutableArray alloc] initWithCapacity:5];
    tags[0] = [packageFile fileName] ?: @"";
    tags[1] = [NSNull null]; // thumbnail placeholder
    tags[2] = [Localization getString:@"Unknown"];
    tags[3] = @(hasAgeData);
    tags[4] = [NSNull null];
    
    // Set stuff for NPCs
    if (npc) {
        tags[4] = tags[0];
        tags[0] = @"";
        tags[2] = [NSString stringWithFormat:@"%@ (NPC)", tags[2]];
    }
    
    Alias *alias = nil;
    
    // Find string resource
    id<IPackedFileDescriptor> strPfd = [packageFile findFile:[MetaData CTSS_FILE]
                                                      subtype:0
                                                        group:[[objd fileDescriptor] group]
                                                     instance:[objd CTSSInstance]];
    
    if (strPfd != nil) {
        Str *str = [[Str alloc] init];
        [str processData:strPfd package:packageFile];
        StrItemList *items = [str fallbackedLanguageItems:[[Registry windowsRegistry] languageCode]];
        
        if ([items length] > 0) {
#if DEBUG
            alias = [[Alias alloc] initWithId:[objd guid] name:[[items objectAtIndex:0] title] nameFormat:@"{name} {2} (0x{id})"];
#else
            alias = [[Alias alloc] initWithId:[objd guid] name:[[items objectAtIndex:0] title] nameFormat:@"{name} {2} (0x{id})"];
#endif
            if ([items length] > 2) {
                tags[2] = [[items objectAtIndex:2] title];
            }
        }
    }
    
    if (alias != nil) {
        // Find picture resource
        NSArray *picList = [packageFile findFiles:[MetaData SIM_IMAGE_FILE]];
        for (id<IPackedFileDescriptor> pfd in picList) {
            if ([pfd group] != [[objd fileDescriptor] group]) continue;
            if ([pfd instance] < 0x200) {
                Picture *pic = [[Picture alloc] init];
                [pic processData:pfd package:packageFile];
                tags[1] = [pic image];
                break;
            }
        }
        
        [alias setTag:[tags copy]];
        
        // Update progress
        (*ct)++;
        if ((*ct) % step == 1) {
            [Wait setMessage:[alias description]];
            [Wait setProgress:*ct];
        }
        
        // Set stuff for NPCs
        if (npc) {
            NSMutableArray *mutableTags = [tags mutableCopy];
            mutableTags[2] = [NSString stringWithFormat:@"%@ (NPC)", mutableTags[2]];
            [alias setTag:[mutableTags copy]];
        }
        
        if (self.names == nil) return nil;
        if (![self.names objectForKey:@([objd guid])]) {
            [self.names setObject:alias forKey:@([objd guid])];
        }
    }
    
    return alias;
}

// MARK: - File Scanning Methods

- (void)scanFileTable {
    if ([Helper startedGui] == ExecutableClassic) return;
    if ([[Registry windowsRegistry] deepSimTemplateScan]) {
        [self.characterfi load];
    }
    
    [[FileTable fileIndex] addChild:self.characterfi];
    @try {
        [self scanFileTable:0x80];
    }
    @finally {
        [[FileTable fileIndex] removeChild:self.characterfi];
    }
}

- (void)scanFileTable:(uint32_t)instance {
    if ([Helper startedGui] == ExecutableClassic) return;
    
    NSArray *items = [[FileTable fileIndex] findFileDiscardingGroup:[MetaData OBJD_FILE] instance:instance];
    [Wait setMaxProgress:[items count]];
    NSInteger ct = 0;
    NSInteger step = MAX(2, [Wait maxProgress] / 100);
    
    for (id<IScenegraphFileIndexItem> item in items) {
        if ([self haveToStop]) break;
        
        ExtObjd *objd = [[ExtObjd alloc] init];
        [objd processData:item];
        
        if ([objd type] == ObjectTypesPerson || [objd type] == ObjectTypesTemplate) {
            [self addSim:objd counter:&ct step:step npc:YES];
        }
    }
}

// MARK: - StoppableThread Override

- (void)startThread {
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.dir error:nil];
    NSMutableArray *packageFiles = [[NSMutableArray alloc] init];
    
    for (NSString *file in files) {
        if ([[file pathExtension].lowercaseString isEqualToString:@"package"]) {
            [packageFiles addObject:[self.dir stringByAppendingPathComponent:file]];
        }
    }
    
    if ([Helper startedGui] == ExecutableClassic) {
        [WaitingScreen wait];
    } else {
        [Wait subStart:[packageFiles count]];
    }
    
    @try {
        BOOL breaked = NO;
        NSInteger ct = 0;
        NSInteger step = MAX(2, [Wait maxProgress] / 100);
        
        for (NSString *filePath in packageFiles) {
            if ([self haveToStop]) {
                breaked = YES;
                break;
            }
            
            File *packageFile = nil;
            @try {
                packageFile = [File loadFromFile:filePath];
            }
            @catch (NSException *exception) {
                break;
            }
            
            NSArray *objdList = [packageFile findFiles:[MetaData OBJD_FILE]];
            if ([objdList count] > 0) {
                [self addSimFromPackage:packageFile objdpfd:[objdList firstObject] counter:&ct step:step];
            }
        }
        
        if (!breaked) {
            [self scanFileTable];
        }
    }
    @catch (NSException *exception) {
        [Helper exceptionMessage:exception.localizedDescription];
    }
    @finally {
        if ([Helper startedGui] == ExecutableClassic) {
            [WaitingScreen stop];
        } else {
            [Wait subStop];
        }
    }
}

@end
