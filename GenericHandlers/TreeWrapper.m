//
//  TreeWrapper.m
//  MacSimpe
//
//  Created by Catherine Gramze on 7/26/25.
//
/***************************************************************************
 *   Copyright (C) 2005 by Ambertation                                                                                                    *
 *   quaxi@ambertation.de                                                                                                               *
 *                                                                         *
 *   Swift translation Copyright (C) 2025 by GramzeSweatShop                                                              *
 *   rhiamom@mac.com                                                                                                                          *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify                                                 *
 *   it under the terms of the GNU General Public License as published by                                             *
 *   the Free Software Foundation; either version 2 of the License, or                                                     *
 *   (at your option) any later version.                                                                                                        *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,                                                             *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of                                            *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the                                    *
 *   GNU General Public License for more details.                                                                                   *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License                                              *
 *   along with this program, if not, write to the                                                                                        *
 *   Free Software Foundation, Inc.,                                                                                                         *
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.                                                          *
 *****************************************************************************************************************/

#import "Tree.h"
#import "IPackedFileWrapper.h"
#import "IWrapperInfo.h"
#import "AbstractWrapperInfo.h"
#import "GenericItem.h"
#import "Helper.h"
#import "BinaryReader.h"

@implementation Tree

- (instancetype)init {
    self = [super init];
    if (self) {
        // Register TREE file type (0x54524545)
        [self registerType:0x54524545 withCreator:^Generic *(id<IPackedFileWrapper> wrapper) {
            return [self createSTRFile:wrapper];
        }];
    }
    return self;
}

/**
 * Creates a STR File Reader
 * @param wrapper The wrapper containing the file data
 * @return The Reader in a generic Format
 */
- (Generic *)createSTRFile:(id<IPackedFileWrapper>)wrapper {
    return self;
}

#pragma mark - IWrapper Methods

- (id<IWrapperInfo>)createWrapperInfo {
    return [[AbstractWrapperInfo alloc] initWithName:@"TREE Wrapper"
                                              author:@"Quaxi"
                                         description:@"---"
                                             version:1];
}

#pragma mark - Generic.File Methods

- (void)parseHeader {
    NSString *filename = [Helper dataToString:[self.reader readBytes:0x40]];
    uint32_t version = [self.reader readUInt32];
    uint32_t unknown_0 = [self.reader readUInt32];
    uint32_t header = [self.reader readUInt32];
    uint32_t unknown_1 = [self.reader readUInt32];
    uint32_t unknown_2 = [self.reader readUInt32];
    uint32_t unknown_3 = [self.reader readUInt32];
    uint32_t unknown_4 = [self.reader readUInt32];
    uint32_t count = [self.reader readUInt32];
    // uint32_t unknown_5 = [self.reader readUInt32];
    
    self.items = [[NSMutableArray alloc] initWithCapacity:count];
    for (uint32_t i = 0; i < count; i++) {
        [self.items addObject:[[GenericItem alloc] init]];
    }
}

- (void)parseFileItem:(GenericItem *)item {
    item.properties[@"Zero1"] = @([self.reader readUInt32]);
    item.properties[@"Zero2"] = @([self.reader readUInt32]);
    item.properties[@"Block1"] = @([self.reader readUInt16]);
    item.properties[@"Block2"] = @([self.reader readUInt16]);
    item.properties[@"Block3"] = @([self.reader readUInt16]);
    item.properties[@"Block4"] = @([self.reader readUInt16]);
    item.properties[@"Block5"] = @([self.reader readUInt16]);
    item.properties[@"Block6"] = @([self.reader readUInt16]);
    item.properties[@"Block7"] = @([self.reader readUInt16]);
    item.properties[@"Block8"] = @([self.reader readUInt16]);
    item.properties[@"Block9"] = @([self.reader readUInt16]);
    
    // item.properties[@"Zero3"] = @([self.reader readUInt32]);
    
    uint8_t len = [self.reader readByte];
    item.properties[@"Name"] = [Helper dataToString:[self.reader readBytes:len]];
}

- (NSString *)getTypeName:(uint32_t)type {
    return [NSString stringWithFormat:@"Experimental TREE Viewer (%lu Items)",
            (unsigned long)self.items.count];
}

@end
