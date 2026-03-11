//
//  OpcodeProvider.m
//  MacSimpe
//
//  Created by Catherine Gramze on 8/19/25.
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

#import "OpcodeProvider.h"
#import "Helper.h"
#import "Registry.h"
#import "FileTable.h"
#import "FileIndex.h"
#import "FileIndexItem.h"
#import "WaitingScreen.h"      // so WaitingScreen is known
#import "ExtObjdWrapper.h"     // declares ExtObjd
#import "Str.h"
#import "StrItem.h"
#import "MetaData.h"
#import "IAlias.h"
#import "Alias.h"
#import "Wait.h"
#import "Localization.h"
#import "PathProvider.h"
#import "PackedFileDescriptor.h"
#import "File.h"
#import "Str.h"
#import "ExtObjdWrapper.h"
#import "PictureWrapper.h"
#import "MetaData.h"
#import "ExpansionItem.h"
#import "File.h"
#import "PackedFile.h"

@implementation OpcodeProvider

- (instancetype)init {
    if (self = [super initWithPackage:nil]) {
        // Arrays will be created as needed
    }
    return self;
}

- (void)loadMemories
{
    self.memories = [[NSMutableDictionary alloc] init];
    
    // Load file index
    [FileTable.fileIndex load];
    
    NSArray<id<IScenegraphFileIndexItem>> *items =
    [[FileTable fileIndex] findFileDiscardingGroupWithType:[MetaData OBJD_FILE]
                                                  instance:0x00000000000041A7];
    
    if (items.count == 0) return;
    
    BOOL wasRunning = WaitingScreen.running;
    [WaitingScreen wait];
    
    ExtObjd *objd = [[ExtObjd alloc] init];
    Str *str = [[Str alloc] init];
    
    NSUInteger count = 0;
    NSString *max = [NSString stringWithFormat:@" / %lu", (unsigned long)items.count];
    
    @try {
        for (id<IScenegraphFileIndexItem> item in items) {
            count++;
            if (count % 137 == 1) {
                [WaitingScreen updateMessage:
                 [NSString stringWithFormat:@"%lu%@", (unsigned long)count, max]];
            }
            
            id<IPackedFileDescriptor> pfd = item.fileDescriptor;
            
            // Parse OBJD
            [objd processData:item];
            
            NSNumber *guid = @(objd.guid);
            if (self.memories[guid] != nil) continue;
            
            NSString *name = @"";
            
            // Try CTSS
            @try {
                PackedFileDescriptor *p = (PackedFileDescriptor *)pfd;
                
                NSArray<id<IScenegraphFileIndexItem>> *sitems =
                [[FileTable fileIndex] findFileWithType:[MetaData CTSS_FILE]
                                                  group:p.group
                                               instance:objd.ctssInstance
                                                package:nil];
                
                if (sitems.count > 0) {
                    [str processData:sitems[0]];
                    
                    StrItemList *items =
                    [str fallbackedLanguageItemsForLanguage:[AppPreferences languageCode]];
                    
                    if (items.count > 0) {
                        StrToken *tok = [items objectAtIndex:0];
                        name = tok.title ?: @"";
                    }
                }
            }
            @catch (__unused NSException *e) {
            }
            
            // Still no name?
            if (name.length == 0)
                name = objd.fileName;
            
            Alias *alias =
            [[Alias alloc] initWithId:objd.guid
                                 name:name
                             template:@"{1}: {name} (0x{id})"];
            
            // Attach metadata
            NSMutableArray *tag = [[NSMutableArray alloc] initWithCapacity:3];
            [tag addObject:pfd];
            [tag addObject:@(objd.type)];
            [tag addObject:[NSNull null]];
            
            // Try preview image
            PictureWrapper *pic = [[PictureWrapper alloc] init];
            NSArray<id<IScenegraphFileIndexItem>> *iitems =
            [FileTable.fileIndex findFileWithType:MetaData.SIM_IMAGE_FILE
                                            group:pfd.group
                                         instance:1
                                          package:nil];
            
            if (iitems.count > 0) {
                [pic processData:iitems[0]];
                NSImage *img = pic.image;
                if (img) {
                    tag[2] = img;
                    [WaitingScreen updateImage:img
                                  message:[NSString stringWithFormat:@"%lu%@", (unsigned long)count, max]];
                }
            }
            
            alias.tag = tag;
            self.memories[guid] = alias;
        }
    }
    @finally {
        if (!wasRunning)
            [WaitingScreen stop];
    }
}

- (void)loadData:(NSMutableArray **)list instance:(uint16_t)instance lang:(uint16_t)lang {
    *list = [[NSMutableArray alloc] init];
    if (self.basePackage == nil) return;
    
    // Find string file and process it
    // Implementation requires Str wrapper class
}

- (void)loadObjdDescription:(uint16_t)type {
    id tmp = nil;
    [self loadData:&tmp instance:0xCC lang:type];
    _objddesc = tmp;
}

- (void)loadDataOwners {
    id tmp = nil;
    [self loadData:&tmp instance:0x84 lang:1];
    _dataowners = tmp;
}

- (void)loadObjf {
    id tmp = nil;
    [self loadData:&tmp instance:0xF5 lang:1];
    _objf = tmp;
}

- (void)loadOperators {
    id tmp = nil;
    [self loadData:&tmp instance:0x88 lang:1];
    _operands = tmp;
}

- (void)loadMotives {
    id tmp = nil;
    [self loadData:&tmp instance:0x86 lang:1];
    _motives = tmp;
}

- (void)loadOpcodes {
    self.names = [[NSMutableArray alloc] init];
    if (self.basePackage == nil) return;
    
    [[FileTable fileIndex] load];
    
    NSArray<id<IScenegraphFileIndexItem>> *items =
    [[FileTable fileIndex] findFileWithType:MetaData.STRING_FILE
                                      group:0x7FE59FD0
                                   instance:0x000000000000008B
                                    package:nil];
    
    if (items == nil || items.count == 0) return;
    
    Str *str = [[Str alloc] init];
    
    for (id<IScenegraphFileIndexItem> item in items) {
        [str processData:item.fileDescriptor package:self.basePackage];
        
        for (StrToken *tok in str.items) {
            if (tok.language.languageId == 1) {
                if (tok.title != nil) [self.names addObject:tok.title];
            }
        }
    }
}

- (void)loadPackage {
    if (self.basePackage != nil) return;
    
    ExpansionItem *bg = [[PathProvider global] expansionForEnum:ExpansionsBaseGame];
    if (bg == nil) return;
    
    NSString *installFolder = bg.realInstallFolder;
    if (installFolder == nil || installFolder.length == 0) {
        installFolder = bg.installFolder;
    }
    if (installFolder == nil || installFolder.length == 0) return;
    
    NSString *path =
    [installFolder stringByAppendingPathComponent:
     @"TSData/Res/Objects/objects.package"];
    
    self.basePackage = [[File alloc] initWithFilename:path];
}

// MARK: - IOpcodeProvider Protocol Implementation

- (NSString *)findName:(uint16_t)opcode {
    if (opcode >= 0x2000) return @"Unknown Semi Global";
    [self loadPackage];
    
    if (opcode >= 0x0100) {
        if (self.basePackage == nil) return @"Unknown Global";
        
        [[FileTable fileIndex] load];
        NSArray<id<IScenegraphFileIndexItem>> *items = [[FileTable fileIndex] findFileWithType:MetaData.BHAV_FILE
                                                                                          group:0x7FD46CD0
                                                                                       instance:(uint64_t)opcode
                                                                                        package:nil];
        
        for (id<IScenegraphFileIndexItem> item in items) {
            if (item.fileDescriptor != nil) {
                id<IPackedFile> pf = [item.package readDescriptor:item.fileDescriptor];
                NSData *data;
                
                PackedFile *packed = (PackedFile *)pf;
                
                if (packed.isCompressed) {
                    data = [packed decompressWithSize:0x40];
                } else {
                    data = packed.data;
                }
                return [Helper dataToString:data];
            }
        }
        return @"Unknown Global";
    }
    
    if (self.names == nil) [self loadOpcodes];
    
    if (opcode < [self.names count]) {
        return self.names[opcode];
    } else {
        return [Localization getString:@"unknown"];
    }
}

- (NSArray *)storedPrimitives {
    [self loadPackage];
    if (self.names == nil) [self loadOpcodes];
    return [self.names copy];
}

- (NSString *)findExpressionOperator:(uint8_t)op {
    [self loadPackage];
    if (self.basePackage == nil) return [Localization getString:@"unk"];
    
    if (self.operands == nil) [self loadOperators];
    
    if (op < [self.operands count]) {
        return [self.operands[op] description];
    } else {
        return [Localization getString:@"unk"];
    }
}

- (NSString *)findExpressionDataOwners:(uint8_t)owner {
    [self loadPackage];
    if (self.basePackage == nil) return [Localization getString:@"unk"];
    
    if (self.dataowners == nil) [self loadDataOwners];
    
    if (owner < [self.dataowners count]) {
        return [self.dataowners[owner] description];
    } else {
        return [Localization getString:@"unk"];
    }
}

- (NSString *)findMotives:(uint16_t)nr {
    [self loadPackage];
    if (self.basePackage == nil) return [Localization getString:@"unk"];
    
    if (self.motives == nil) [self loadMotives];
    
    if (nr < [self.motives count]) {
        return [self.motives[nr] description];
    } else {
        return [Localization getString:@"unk"];
    }
}

- (id<IAlias>)findMemory:(uint32_t)guid {
    if (self.memories == nil) [self loadMemories];
    
    id<IAlias> alias = self.memories[@(guid)];
    if (alias != nil) {
        return alias;
    } else {
        return [[Alias alloc] initWithId:guid name:[Localization getString:@"unknown"]];
    }
}

- (NSDictionary *)storedMemories {
    if (self.memories == nil) [self loadMemories];
    return [self.memories copy];
}

- (id<IScenegraphFileIndexItem>)loadGlobalBHAV:(uint16_t)opcode {
    return [self loadSemiGlobalBHAV:opcode group:0x7FD46CD0];
}

- (id<IScenegraphFileIndexItem>)loadSemiGlobalBHAV:(uint16_t)opcode group:(uint32_t)group {
    [[FileTable fileIndex] load];
    NSArray<id<IScenegraphFileIndexItem>> *items = [[FileTable fileIndex] findFileWithType:MetaData.BHAV_FILE
                                                                                      group:group
                                                                                   instance:opcode
                                                                                    package:nil];
    if ([items count] > 0) return items[0];
    return nil;
}

- (NSArray *)objdDescription:(uint16_t)type {
    [self loadPackage];
    if (self.basePackage == nil) return [[NSArray alloc] init];
    
    [self loadObjdDescription:type];
    if (self.objddesc != nil) return [self.objddesc copy];
    else return [[NSArray alloc] init];
}

- (NSArray *)storedObjfLines {
    [self loadPackage];
    if (self.objf == nil) [self loadObjf];
    return [self.objf copy];
}

- (NSArray *)storedExpressionOperators {
    return [self.operands copy];
}

- (NSArray *)storedDataNames {
    return [self.dataowners copy];
}

- (NSArray *)storedMotives {
    [self loadPackage];
    if (self.motives == nil) [self loadMotives];
    return [self.motives copy];
}

// MARK: - Protected Methods

- (void)onChangedPackage {
    [super onChangedPackage];
    self.names = nil;
}

@end
