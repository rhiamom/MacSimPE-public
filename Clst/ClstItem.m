//
//  ClstItem.m
//  MacSimpe
//
//  Created by Catherine Gramze on 7/28/25.
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

#import "ClstItem.h"
#import "IPackedFileDescriptor.h"
#import "TypeAlias.h"
#import "MetaData.h"
#import "BinaryReader.h"
#import "BinaryWriter.h"
#import "Helper.h"

@interface ClstItem ()
@property (nonatomic, assign, readwrite) IndexTypes format;
@end

@implementation ClstItem

// MARK: - Initialization

- (instancetype)initWithFormat:(IndexTypes)format {
    return [self initWithPackedFileDescriptor:nil format:format];
}

- (instancetype)initWithPackedFileDescriptor:(id<IPackedFileDescriptor>)pfd
                                      format:(IndexTypes)format {
    self = [super init];
    if (self) {
        _format = format;
        
        if (pfd != nil) {
            self.type = [pfd type];
            self.instance = [pfd instance];
            self.subType = [pfd subtype];
            self.group = [pfd group];
        }
    }
    return self;
}

// MARK: - Properties

- (TypeAlias *)typeName {
    return [MetaData findTypeAlias:self.type];
}

// MARK: - Serialization

- (void)unserialize:(BinaryReader *)reader {
    self.type = [reader readUInt32];
    self.group = [reader readUInt32];
    self.instance = [reader readUInt32];
    
    if (self.format == ptLongFileIndex) {
        self.subType = [reader readUInt32];
    } else {
        self.subType = 0;
    }
    
    self.uncompressedSize = [reader readUInt32];
}

- (void)serialize:(BinaryWriter *)writer withFormat:(IndexTypes)format {
    self.format = format;
    
    [writer writeUInt32:self.type];
    [writer writeUInt32:self.group];
    [writer writeUInt32:self.instance];
    
    if (format == ptLongFileIndex) {
        [writer writeUInt32:self.subType];
    }
    
    [writer writeUInt32:self.uncompressedSize];
}

// MARK: - Equality and Comparison

- (NSUInteger)hash {
    return (NSUInteger)((self.type | self.instance) - (self.type & self.instance));
}

- (BOOL)isEqual:(id)object {
    if (object == nil) {
        return NO;
    }
    
    if ([object isKindOfClass:[ClstItem class]]) {
        ClstItem *ci = (ClstItem *)object;
        
        BOOL subTypeMatches = (ci.subType == self.subType ||
                              ci.format == ptShortFileIndex ||
                              self.format == ptShortFileIndex);
        
        return (ci.group == self.group &&
                ci.instance == self.instance &&
                ci.type == self.type &&
                subTypeMatches);
    }
    else if ([object conformsToProtocol:@protocol(IPackedFileDescriptor)]) {
        id<IPackedFileDescriptor> ci = (id<IPackedFileDescriptor>)object;
        
        BOOL subTypeMatches = ([ci subtype] == self.subType ||
                              self.format == ptShortFileIndex);
        
        return ([ci group] == self.group &&
                [ci instance] == self.instance &&
                [ci type] == self.type &&
                subTypeMatches);
    }
    else {
        return [super isEqual:object];
    }
}

// MARK: - Description

- (NSString *)description {
    NSMutableString *name = [NSMutableString string];
    
    [name appendFormat:@"%@: 0x%@", self.typeName, [Helper hexString:self.type]];
    
    if (self.format == ptLongFileIndex) {
        [name appendFormat:@" - 0x%@", [Helper hexString:self.subType]];
    }
    
    [name appendFormat:@" - 0x%@ - 0x%@",
        [Helper hexString:self.group],
        [Helper hexString:self.instance]];
    
    [name appendFormat:@" = 0x%@ byte", [Helper hexString:self.uncompressedSize]];
    
    return [name copy];
}

@end
