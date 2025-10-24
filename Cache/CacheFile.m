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
#import "CacheLists.h"
#import "CacheContainer.h"
#import "BinaryReader.h"
#import "BinaryWriter.h"
#import "FileStream.h"
#import "Helper.h"
#import "CacheException.h"
#import "StreamMaintainer.h"

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

- (void)load:(NSString *)filename withProgress:(BOOL)withProgress {
    _fileName = [filename copy];
    [self.containers removeAllObjects];
    
    // Check if file exists
    if (![[NSFileManager defaultManager] fileExistsAtPath:filename]) {
        return;
    }
    
    // Use StreamFactory to get a FileStream for reading
    StreamItem *streamItem = [StreamFactory useStream:filename fileAccess:@"Read"];
    @try {
        if (streamItem.streamState == StreamStateRemoved) {
            @throw [NSException exceptionWithName:@"CacheException"
                                           reason:[NSString stringWithFormat:@"File not found: %@", filename]
                                         userInfo:nil];
        }
        
        // Create BinaryReader with the FileStream
        BinaryReader *reader = [[BinaryReader alloc] initWithStream:streamItem.fileStream];
        
        @try {
            // Read and verify cache file signature
            uint64_t signature = [reader readUInt64];
            if (signature != CACHE_FILE_SIGNATURE) {
                @throw [NSException exceptionWithName:@"CacheException"
                                               reason:[NSString stringWithFormat:@"Unknown Cache File Signature (%llx)", signature]
                                             userInfo:@{@"filename": filename, @"version": @0}];
            }
            
            // Read and verify version
            uint8_t fileVersion = [reader readByte];
            if (fileVersion > CACHE_FILE_VERSION) {
                @throw [NSException exceptionWithName:@"CacheException"
                                               reason:@"Unable to read Cache"
                                             userInfo:@{@"filename": filename, @"version": @(fileVersion)}];
            }
            
            // Set internal version
            _version = fileVersion;
            
            // Read container count and load containers
            int32_t count = [reader readInt32];
            for (int32_t i = 0; i < count; i++) {
                CacheContainer *container = [[CacheContainer alloc] initWithType:self.defaultType];
                [container load:reader];
                [self.containers addCacheContainer:container];
                
                // Progress handling could be added here if needed
                // if (withProgress && i % 10 == 0) { /* update progress */ }
            }
            
        } @finally {
            [reader close];
        }
        
    } @finally {
        [streamItem close];
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
    
    // Use StreamFactory to get a FileStream for writing
    StreamItem *streamItem = [StreamFactory useStreamCreate:filename fileAccess:@"Write" create:YES];
    @try {
        [self cleanUp];
        
        if (streamItem.streamState == StreamStateRemoved) {
            @throw [NSException exceptionWithName:@"CacheException"
                                           reason:@"Unable to create or open file for writing"
                                         userInfo:nil];
        }
        // Create BinaryWriter with the FileStream
        BinaryWriter *writer = [[BinaryWriter alloc] initWithFileStream:streamItem.fileStream];
        
        // Seek to beginning and truncate (equivalent to C# SetLength(0))
        [writer seekToPosition:0];
        
        // Write cache file signature
        [writer writeUInt64:CACHE_FILE_SIGNATURE];
        
        // Write version
        [writer writeUInt8:self.version];
        
        // Write container count
        [writer writeInt32:(int32_t)self.containers.count];
        
        // Prepare the Index - first pass (equivalent to C# Save(writer, -1))
        NSMutableArray<NSNumber *> *offsets = [[NSMutableArray alloc] init];
        for (NSUInteger i = 0; i < self.containers.count; i++) {
            [offsets addObject:@(writer.position)];
            [self.containers[i] save:writer offset:-1];
        }
        
        // Write the Data - second pass (equivalent to C# Save(writer, offset))
        for (NSUInteger i = 0; i < self.containers.count; i++) {
            int64_t currentOffset = writer.position;
            [writer seekToPosition:offsets[i].longLongValue];
            [self.containers[i] save:writer offset:(int32_t)currentOffset];
        }
        
        [writer flush];
        [writer close];
        
    } @catch (NSException *exception) {
        // Re-throw the exception
        @throw exception;
    } @finally {
        // Always close the stream
        [streamItem close];
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

 //MARK: ICacheTestFile implementation

- (void)load:(NSString *)fileName {
    // Call the more detailed load method with progress disabled
    [self load:fileName withProgress:NO];
}

@end
