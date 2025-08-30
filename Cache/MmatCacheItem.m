//
//  MmatCacheItem.m
//  MacSimpe
//
//  Created by Catherine Gramze on 8/28/25.
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

#import "MmatCacheItem.h"
#import "BinaryReader.h"
#import "BinaryWriter.h"
#import "PackedFileDescriptor.h"
#import "IPackedFileDescriptor.h"
#import "CacheException.h"

// MARK: - Constants

const uint8_t MMAT_CACHE_ITEM_VERSION = 1;

@interface MmatCacheItem ()
@property (nonatomic, assign) uint8_t version;
@property (nonatomic, strong) PackedFileDescriptor *pfd;
@end

@implementation MmatCacheItem

// MARK: - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        _version = MMAT_CACHE_ITEM_VERSION;
        _modelName = @"";
        _family = @"";
        _defaultMaterial = NO;
        _pfd = [[PackedFileDescriptor alloc] init];
    }
    return self;
}

// MARK: - Properties

- (id<IPackedFileDescriptor>)fileDescriptor {
    self.pfd.tag = self;
    return self.pfd;
}

- (void)setFileDescriptor:(id<IPackedFileDescriptor>)fileDescriptor {
    if ([fileDescriptor isKindOfClass:[PackedFileDescriptor class]]) {
        self.pfd = (PackedFileDescriptor *)fileDescriptor;
    } else {
        // If it's not a PackedFileDescriptor, create one and copy the properties
        self.pfd = [[PackedFileDescriptor alloc] init];
        self.pfd.type = fileDescriptor.type;
        self.pfd.group = fileDescriptor.group;
        self.pfd.longInstance = fileDescriptor.longInstance;
        self.pfd.filename = fileDescriptor.filename;
        self.pfd.tag = fileDescriptor.tag;
    }
}

// MARK: - ICacheItem Protocol

- (void)load:(BinaryReader *)reader {
    self.version = [reader readUInt8];
    if (self.version > MMAT_CACHE_ITEM_VERSION) {
        @throw [[CacheException alloc] initWithMessage:@"Unknown CacheItem Version."
                                               details:nil
                                               version:self.version];
    }
    
    self.modelName = [reader readString];
    self.family = [reader readString];
    self.defaultMaterial = [reader readBoolean];
    
    self.pfd = [[PackedFileDescriptor alloc] init];
    self.pfd.type = [reader readUInt32];
    self.pfd.group = [reader readUInt32];
    self.pfd.longInstance = [reader readUInt64];
}

- (void)save:(BinaryWriter *)writer {
    self.version = MMAT_CACHE_ITEM_VERSION;
    [writer writeUInt8:self.version];
    [writer writeString:self.modelName];
    [writer writeString:self.family];
    [writer writeBoolean:self.defaultMaterial];
    [writer writeUInt32:self.pfd.type];
    [writer writeUInt32:self.pfd.group];
    [writer writeUInt64:self.pfd.longInstance];
}

// MARK: - String Representation

- (NSString *)description {
    return [NSString stringWithFormat:@"modelname=%@, family=%@", self.modelName, self.family];
}

@end
