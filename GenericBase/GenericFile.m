//
//  GenericFile.m
//  MacSimpe
//
//  Created by Catherine Gramze on 9/3/25.
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

#import "Generic.h"
#import "GenericFile.h"
#import "GenericFileItem.h"
#import "GenericCommon.h"
#import "BinaryReader.h"
#import "GenericUIBase.h"
#import "IPackedFileUI.h"
#import "Stream.h"

@implementation GenericFile {
    BinaryReader *_reader;
    NSMutableArray<GenericItem *> *_items;
    GenericCommon *_attributes;
    NSMutableDictionary<NSNumber *, CreateFileObjectBlock> *_subhandlers;
    NSUInteger _currentEnumerationIndex;  // For NSFastEnumeration
}

// MARK: - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        _attributes = [[ImplementedGenericCommon alloc] init];
        _subhandlers = [[NSMutableDictionary alloc] init];
        _items = nil;
        _reader = nil;
        _currentEnumerationIndex = 0;
    }
    return self;
}

// MARK: - Properties

- (GenericCommon *)attributes {
    return _attributes;
}

- (NSInteger)count {
    if (_items != nil) {
        return (NSInteger)_items.count;
    } else {
        return 0;
    }
}

- (NSArray<GenericItem *> *)items {
    return [_items copy];
}

- (BinaryReader *)reader {
    return _reader;
}

- (NSMutableDictionary<NSNumber *, CreateFileObjectBlock> *)subhandlers {
    return _subhandlers;
}

// MARK: - Item Management

- (void)addItem:(GenericItem *)item {
    if (_items == nil) {
        _items = [[NSMutableArray alloc] init];
    }
    [_items addObject:item];
}

- (GenericItem *)getItem:(uint32_t)index {
    if (_items != nil && index < _items.count) {
        return _items[index];
    }
    return nil;
}

// MARK: - Subhandler Management

- (BOOL)registerType:(uint32_t)type withCreateBlock:(CreateFileObjectBlock)block {
    NSNumber *typeKey = @(type);
    if ([_subhandlers objectForKey:typeKey] != nil) {
        return NO;
    }
    
    [_subhandlers setObject:block forKey:typeKey];
    return YES;
}

- (GenericFile *)createSignatureBasedFileObject:(id<IPackedFileWrapper>)wrapper {
    // Default implementation returns nil
    // Subclasses should override this method if they support signature-based file objects
    return nil;
}

// MARK: - Virtual Methods

- (void)initData {
    // Default implementation does nothing
    // Subclasses can override this method for initialization tasks
}

// MARK: - Internal Methods

- (void)prepareData {
    _items = nil;
}

- (void)parseData {
    [self prepareData];
    [_reader seekToPosition:0];
    [self parseHeader];
    
    for (NSInteger i = 0; i < self.count; i++) {
        if (_items == nil) {
            _items = [[NSMutableArray alloc] init];
        }
        
        // Ensure we have enough items
        while (_items.count <= i) {
            [_items addObject:[[GenericItem alloc] init]];
        }
        
        [self parseFileItem:_items[i]];
    }
}

// MARK: - Abstract Methods (Must be implemented by subclasses)

- (void)parseHeader {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void)parseFileItem:(GenericItem *)item {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (NSString *)getTypeName:(uint32_t)type {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

// MARK: - AbstractWrapper Methods

- (id<IPackedFileUI>)createDefaultUIHandler {
    return [[Generic alloc] init];
}

- (void)unserialize:(BinaryReader *)reader {
    _reader = reader;
    [self prepareData];
    [self initData];
    
    @try {
        [self parseData];
    } @catch (NSException *exception) {
        NSLog(@"Error parsing generic file: %@", exception.reason);
        // Continue execution rather than crashing
    }
}

// MARK: - IFileWrapper Protocol

- (NSArray<NSNumber *> *)assignableTypes {
    return [_subhandlers.allKeys copy];
}

- (NSData *)fileSignature {
    // Default implementation returns empty data
    // Subclasses can override this for signature-based file detection
    return [NSData data];
}

// MARK: - NSFastEnumeration Protocol

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                  objects:(id __unsafe_unretained [])buffer
                                    count:(NSUInteger)len {
    
    if (state->state == 0) {
        // First time called
        state->mutationsPtr = &state->extra[0];
        state->state = 1;
        _currentEnumerationIndex = 0;
    }
    
    NSUInteger count = 0;
    if (_items != nil) {
        while (_currentEnumerationIndex < _items.count && count < len) {
            buffer[count] = _items[_currentEnumerationIndex];
            _currentEnumerationIndex++;
            count++;
        }
    }
    
    state->itemsPtr = buffer;
    return count;
}

// MARK: - Memory Management

- (void)dealloc {
    _reader = nil;
    _items = nil;
    _attributes = nil;
    _subhandlers = nil;
}

@end
#import <Foundation/Foundation.h>
