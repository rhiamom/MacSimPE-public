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
#import "MetaData.h"
#import "IAlias.h"
#import "Alias.h"
#import "Wait.h"
#import "Localization.h"
#import "PathProvider.h"
#import "File.h"

@implementation OpcodeProvider

- (instancetype)init {
    if (self = [super initWithPackage:nil]) {
        // Arrays will be created as needed
    }
    return self;
}

- (void)loadMemories {
    self.memories = [[NSMutableDictionary alloc] init];
    
    Registry *reg = [Helper windowsRegistry];
    NSMutableArray *list = [[NSMutableArray alloc] init];
    
    // Implementation would need ExtObjd and Str wrapper classes
    // This is a complex method that loads memory information from object files
    // Leaving as stub for now since it requires many other translated classes
}

- (void)loadData:(NSMutableArray **)list instance:(uint16_t)instance lang:(uint16_t)lang {
    *list = [[NSMutableArray alloc] init];
    if (self.basePackage == nil) return;
    
    // Find string file and process it
    // Implementation requires Str wrapper class
}

- (void)loadObjdDescription:(uint16_t)type {
    [self loadData:&_objddesc instance:0xCC lang:type];
}

- (void)loadDataOwners {
    [self loadData:&_dataowners instance:0x84 lang:1];
}

- (void)loadObjf {
    [self loadData:&_objf instance:0xF5 lang:1];
}

- (void)loadOperators {
    [self loadData:&_operands instance:0x88 lang:1];
}

- (void)loadMotives {
    [self loadData:&_motives instance:0x86 lang:1];
}

- (void)loadOpcodes {
    self.names = [[NSMutableArray alloc] init];
    if (self.basePackage == nil) return;
    
    [[FileTable fileIndex] load];
    NSArray<id<IScenegraphFileIndexItem>> *items = [[FileTable fileIndex] findFileWithType:STRING_FILE
                                                                                      group:0x7FE59FD0
                                                                                   instance:0x000000000000008B
                                                                                    package:nil];
    
    // Process string files to extract opcode names
    // Implementation requires Str wrapper class
}

- (void)loadPackage {
    if (self.basePackage == nil) {
        Registry *reg = [Helper windowsRegistry];
        NSString *installFolder = [[PathProvider global] getExpansion:ExpansionsBaseGame].installFolder;
        NSString *file = [installFolder stringByAppendingPathComponent:@"TSData/Res/Objects/objects.package"];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:file]) {
            self.basePackage = [File loadFromFile:file];
        } else {
            self.basePackage = nil;
        }
    }
}

// MARK: - IOpcodeProvider Protocol Implementation

- (NSString *)findName:(uint16_t)opcode {
    if (opcode >= 0x2000) return @"Unknown Semi Global";
    [self loadPackage];
    
    if (opcode >= 0x0100) {
        if (self.basePackage == nil) return @"Unknown Global";
        
        [[FileTable fileIndex] load];
        NSArray<id<IScenegraphFileIndexItem>> *items = [[FileTable fileIndex] findFileWithType:BHAV_FILE
                                                                                          group:0x7FD46CD0
                                                                                       instance:(uint64_t)opcode
                                                                                        package:nil];
        
        for (id<IScenegraphFileIndexItem> item in items) {
            if (item.fileDescriptor != nil) {
                id<IPackedFile> pf = [item.package readDescriptor:item.fileDescriptor];
                NSData *data;
                if (pf.isCompressed) {
                    data = [pf decompress:0x40];
                } else {
                    data = pf.data;
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
    NSArray<id<IScenegraphFileIndexItem>> *items = [[FileTable fileIndex] findFileWithType:BHAV_FILE
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
