//
//  NmapWrapper.m
//  MacSimpe
//
//  Created by Catherine Gramze on 8/24/25.
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

#import "NmapWrapper.h"
#import "NmapItem.h"
#import "NmapUI.h"
#import "BinaryReader.h"
#import "BinaryWriter.h"
#import "Helper.h"
#import "MetaData.h"
#import "AbstractWrapperInfo.h"
#import "IPackedFileDescriptor.h"
#import "IProviderRegistry.h"
#import "IPackedFileUI.h"
#import "IWrapperInfo.h"

@implementation Nmap

// MARK: - Initialization

- (instancetype)initWithProvider:(id<IProviderRegistry>)provider {
    self = [super init];
    if (self) {
        _provider = provider;
        _items = [[NSArray alloc] init];
    }
    return self;
}

// MARK: - Search Methods

- (NSArray<id<IPackedFileDescriptor>> *)findFiles:(NSString *)start {
    NSString *startLower = [[start stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
    NSMutableArray<id<IPackedFileDescriptor>> *matchingItems = [[NSMutableArray alloc] init];
    
    for (id<IPackedFileDescriptor> pfd in _items) {
        NSString *filenameLower = [[[pfd filename] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
        if ([filenameLower hasPrefix:startLower]) {
            [matchingItems addObject:pfd];
        }
    }
    
    return [matchingItems copy];
}

// MARK: - IWrapper Methods

- (BOOL)checkVersion:(uint32_t)version {
    return YES;
}

// MARK: - AbstractWrapper Methods

- (id<IPackedFileUI>)createDefaultUIHandler {
    return [[NmapUI alloc] init];
}

- (id<IWrapperInfo>)createWrapperInfo {
    // Note: Image loading will need to be adapted for Objective-C/AppKit
    return [[AbstractWrapperInfo alloc] initWithName:@"Name Map Wrapper"
                                              author:@"Quaxi"
                                         description:@"---"
                                             version:4
                                               image:nil]; // TODO: Load from bundle resources
}

- (void)unserialize:(BinaryReader *)reader {
    uint32_t itemCount = [reader readUInt32];
    NSMutableArray<id<IPackedFileDescriptor>> *newItems = [[NSMutableArray alloc] initWithCapacity:itemCount];
    
    for (uint32_t i = 0; i < itemCount; i++) {
        NmapItem *pfd = [[NmapItem alloc] initWithParent:self];
        pfd.group = [reader readUInt32];
        pfd.instance = [reader readUInt32];
        
        uint32_t len = [reader readUInt32];
        NSData *filenameData = [reader readBytes:(NSInteger)len];
        pfd.filename = [Helper dataToString:filenameData];
        
        [newItems addObject:pfd];
    }
    
    _items = [newItems copy];
}

- (void)serialize:(BinaryWriter *)writer {
    [writer writeUInt32:(uint32_t)_items.count];
    
    for (id<IPackedFileDescriptor> pfd in _items) {
        [writer writeUInt32:pfd.group];
        [writer writeUInt32:pfd.instance];
        
        [writer writeUInt32:(uint32_t)pfd.filename.length];
        NSData *filenameData = [Helper stringToBytes:pfd.filename length:0];
        [writer writeData:filenameData];
    }
}

// MARK: - IFileWrapper Methods

- (NSData *)fileSignature {
    return [[NSData alloc] init]; // Empty signature
}

- (NSArray<NSNumber *> *)assignableTypes {
    return @[@([MetaData NAME_MAP])]; // handles the NMAP File
}

@end

#import "NmapWrapper.h"
#import "NmapItem.h"
#import "NmapUI.h"
#import "BinaryReader.h"
#import "BinaryWriter.h"
#import "Helper.h"
#import "MetaData.h"
#import "AbstractWrapperInfo.h"
#import "IPackedFileDescriptor.h"
#import "IProviderRegistry.h"
#import "IPackedFileUI.h"
#import "IWrapperInfo.h"

@implementation Nmap

// MARK: - Initialization

- (instancetype)initWithProvider:(id<IProviderRegistry>)provider {
    self = [super init];
    if (self) {
        _provider = provider;
        _items = [[NSArray alloc] init];
    }
    return self;
}

// MARK: - Search Methods

- (NSArray<id<IPackedFileDescriptor>> *)findFiles:(NSString *)start {
    NSString *startLower = [[start stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
    NSMutableArray<id<IPackedFileDescriptor>> *matchingItems = [[NSMutableArray alloc] init];
    
    for (id<IPackedFileDescriptor> pfd in _items) {
        NSString *filenameLower = [[[pfd filename] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
        if ([filenameLower hasPrefix:startLower]) {
            [matchingItems addObject:pfd];
        }
    }
    
    return [matchingItems copy];
}

// MARK: - IWrapper Methods

- (BOOL)checkVersion:(uint32_t)version {
    return YES;
}

// MARK: - AbstractWrapper Methods

- (id<IPackedFileUI>)createDefaultUIHandler {
    return [[NmapUI alloc] init];
}

- (id<IWrapperInfo>)createWrapperInfo {
    // Note: Image loading will need to be adapted for Objective-C/AppKit
    return [[AbstractWrapperInfo alloc] initWithName:@"Name Map Wrapper"
                                              author:@"Quaxi"
                                         description:@"---"
                                             version:4
                                               image:nil]; // TODO: Load from bundle resources
}

- (void)unserialize:(BinaryReader *)reader {
    uint32_t itemCount = [reader readUInt32];
    NSMutableArray<id<IPackedFileDescriptor>> *newItems = [[NSMutableArray alloc] initWithCapacity:itemCount];
    
    for (uint32_t i = 0; i < itemCount; i++) {
        NmapItem *pfd = [[NmapItem alloc] initWithParent:self];
        pfd.group = [reader readUInt32];
        pfd.instance = [reader readUInt32];
        
        uint32_t len = [reader readUInt32];
        NSData *filenameData = [reader readBytes:(NSInteger)len];
        pfd.filename = [Helper dataToString:filenameData];
        
        [newItems addObject:pfd];
    }
    
    _items = [newItems copy];
}

- (void)serialize:(BinaryWriter *)writer {
    [writer writeUInt32:(uint32_t)_items.count];
    
    for (id<IPackedFileDescriptor> pfd in _items) {
        [writer writeUInt32:pfd.group];
        [writer writeUInt32:pfd.instance];
        
        [writer writeUInt32:(uint32_t)pfd.filename.length];
        NSData *filenameData = [Helper stringToBytes:pfd.filename length:0];
        [writer writeData:filenameData];
    }
}

// MARK: - IFileWrapper Methods

- (NSData *)fileSignature {
    return [[NSData alloc] init]; // Empty signature
}

- (NSArray<NSNumber *> *)assignableTypes {
    return @[@([MetaData NAME_MAP])]; // handles the NMAP File
}

@end
