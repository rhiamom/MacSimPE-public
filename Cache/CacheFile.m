//
//  CacheFile.m
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

#import "CacheFile.h"
#import "CacheContainers.h"
#import "CacheContainer.h"
#import "BinaryReader.h"
#import "BinaryWriter.h"
#import "FileStream.h"
#import "Helper.h"
#import "CacheException.h"

// MARK: - Constants

const uint64_t CACHE_FILE_SIGNATURE = 0x45506d6953;
const uint8_t CACHE_FILE_VERSION = 1;

@interface CacheFile ()
@property (nonatomic, assign) uint8_t version;
@property (nonatomic, copy, nullable) NSString *fileName;
@property (nonatomic, strong) CacheContainers *containers;
@end

@implementation CacheFile

// MARK: - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        _version = CACHE_FILE_VERSION;
        _containers = [[CacheContainers alloc] init];
        _defaultType = ContainerTypeNone;
    }
    return self;
}

// MARK: - File Operations

- (void)load:(NSString *)filename {
    [self load:filename withProgress:NO];
}

- (void)load:(NSString *)filename withProgress:(BOOL)withProgress {
    self.fileName = filename;
    [self.containers removeAllObjects];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filename]) {
        return;
    }
    
    FileStream *fileStream = [[FileStream alloc] initWithPath:filename mode:NSStreamModeRead];
    @try {
        [fileStream open];
        BinaryReader *reader = [[BinaryReader alloc] initWithStream:fileStream];
        
        @try {
            uint64_t sig = [reader readUInt64];
            if (sig != CACHE_FILE_SIGNATURE) {
                NSString *hexSig = [Helper hexString:sig];
                @throw [[CacheException alloc] initWithMessage:[NSString stringWithFormat:@"Unknown Cache File Signature (%@)", hexSig]
                                                      filename:filename
                                                       version:0];
            }
            
            self.version = [reader readUInt8];
            if (self.version > CACHE_FILE_VERSION) {
                @throw [[CacheException alloc] initWithMessage:@"Unable to read Cache"
                                                      filename:filename
                                                       version:self.version];
            }
            
            int32_t count = [reader readInt32];
            // TODO: Implement progress tracking if needed
            // if (withProgress) Wait.MaxProgress = count;
            
            for (int32_t i = 0; i < count; i++) {
                CacheContainer *cc = [[CacheContainer alloc] initWithType:self.defaultType];
                [cc load:reader];
                [self.containers addObject:cc];
                
                // TODO: Implement progress tracking and event processing if needed
                // if (withProgress) Wait.Progress = i;
                // if (i % 10 == 0) [NSApplication.sharedApplication processEvents];
            }
        }
        @finally {
            [reader close];
        }
    }
    @finally {
        [fileStream close];
    }
}

- (void)save {
    if (self.fileName) {
        [self save:self.fileName];
    }
}

- (void)save:(NSString *)filename {
    self.fileName = filename;
    self.version = CACHE_FILE_VERSION;
    
    FileStream *fileStream = [[FileStream alloc] initWithPath:filename mode:NSStreamModeWrite];
    @try {
        [self cleanUp];
        
        [fileStream open];
        [fileStream seekToBeginning];
        [fileStream truncateAtOffset:0];
        
        BinaryWriter *writer = [[BinaryWriter alloc] initWithStream:fileStream];
        
        [writer writeUInt64:CACHE_FILE_SIGNATURE];
        [writer writeUInt8:self.version];
        
        [writer writeInt32:(int32_t)self.containers.count];
        NSMutableArray<NSNumber *> *offsets = [[NSMutableArray alloc] init];
        
        // Prepare the Index
        for (NSUInteger i = 0; i < self.containers.count; i++) {
            [offsets addObject:@([fileStream offsetInFile])];
            [self.containers[i] save:writer offset:-1];
        }
        
        // Write the Data
        for (NSUInteger i = 0; i < self.containers.count; i++) {
            long offset = [fileStream offsetInFile];
            [fileStream seekToFileOffset:[offsets[i] longLongValue]];
            [self.containers[i] save:writer offset:(int32_t)offset];
        }
    }
    @finally {
        [fileStream close];
    }
}

// MARK: - Container Management

- (CacheContainer *)useContainer:(ContainerType)containerType fileName:(NSString * _Nullable)name {
    if (name == nil) {
        name = @"";
    }
    name = [[name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString];
    
    CacheContainer *mycc = nil;
    for (CacheContainer *cc in self.containers) {
        if (cc.type == containerType && cc.valid && [cc.fileName isEqualToString:name]) {
            mycc = cc;
            break;
        }
    }
    
    if (mycc == nil) {
        mycc = [[CacheContainer alloc] initWithType:containerType];
        mycc.fileName = name;
        [self.containers addObject:mycc];
    }
    
    return mycc;
}

- (void)cleanUp {
    for (NSInteger i = (NSInteger)self.containers.count - 1; i >= 0; i--) {
        if (!self.containers[i].valid) {
            [self.containers removeObjectAtIndex:i];
        }
    }
}

// MARK: - Memory Management

- (void)dispose {
    for (CacheContainer *cc in self.containers) {
        [cc dispose];
    }
    [self.containers removeAllObjects];
}

- (void)dealloc {
    [self dispose];
}

@end
