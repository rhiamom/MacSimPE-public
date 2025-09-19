//
//  cExtension.m
//  MacSimpe
//
//  Created by Catherine Gramze on 9/18/25.
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
//
//  cExtension.m
//  MacSimpe
//
//  Created by Translation Tool on 9/18/25.
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

#import "cExtension.h"
#import "Vectors.h"
#import "Quaternion.h"
#import "BinaryReader.h"
#import "BinaryWriter.h"
#import "RcolWrapper.h"
#import "Helper.h"

// MARK: - ExtensionItem Implementation

@implementation ExtensionItem

@synthesize typecode = _typecode;
@synthesize name = _name;
@synthesize value = _value;
@synthesize single = _single;
@synthesize translation = _translation;
@synthesize string = _string;
@synthesize items = _items;
@synthesize rotation = _rotation;
@synthesize data = _data;

// MARK: - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        _name = @"";
        _translation = [[Vector3f alloc] init];
        _single = 0.0f;
        _items = [[NSMutableArray alloc] init];
        _rotation = [[Quaternion alloc] init];
        _data = [[NSData alloc] init];
        _string = @"";
        _value = 0;
        _typecode = ItemTypesValue;
    }
    return self;
}

// MARK: - Serialization

- (void)unserialize:(BinaryReader *)reader {
    _typecode = (ItemTypes)[reader readByte];
    _name = [reader readString];
    
    switch (_typecode) {
        case ItemTypesValue: {
            _value = [reader readInt32];
            break;
        }
        case ItemTypesFloat: {
            _single = [reader readSingle];
            break;
        }
        case ItemTypesTranslation: {
            [_translation unserialize:reader];
            break;
        }
        case ItemTypesString: {
            _string = [reader readString];
            break;
        }
        case ItemTypesArray: {
            uint32_t count = [reader readUInt32];
            _items = [[NSMutableArray alloc] initWithCapacity:count];
            for (uint32_t i = 0; i < count; i++) {
                ExtensionItem *item = [[ExtensionItem alloc] init];
                [item unserialize:reader];
                [_items addObject:item];
            }
            break;
        }
        case ItemTypesRotation: {
            [_rotation unserialize:reader];
            break;
        }
        case ItemTypesBinary: {
            int32_t len = [reader readInt32];
            _data = [reader readBytes:len];
            break;
        }
        default: {
            NSString *message = [NSString stringWithFormat:
                                 @"Unknown Extension Item 0x%@\n\nPosition: 0x%@",
                                 [Helper hexStringByte:(uint8_t)_typecode],
                                 [Helper hexStringUInt64:[reader position]]];
            @throw [NSException exceptionWithName:@"UnknownExtensionItemException"
                                           reason:message
                                         userInfo:nil];
        }
    }
}

- (void)serialize:(BinaryWriter *)writer {
    [writer writeUInt8:(uint8_t)_typecode];
    [writer writeString:_name];
    
    switch (_typecode) {
        case ItemTypesValue: {
            [writer writeInt32:_value];
            break;
        }
        case ItemTypesFloat: {
            [writer writeFloat:_single];
            break;
        }
        case ItemTypesTranslation: {
            [_translation serialize:writer];
            break;
        }
        case ItemTypesString: {
            [writer writeString:_string];
            break;
        }
        case ItemTypesArray: {
            [writer writeUInt32:(uint32_t)_items.count];
            for (ExtensionItem *item in _items) {
                [item serialize:writer];
            }
            break;
        }
        case ItemTypesRotation: {
            [_rotation serialize:writer];
            break;
        }
        case ItemTypesBinary: {
            [writer writeInt32:(int32_t)_data.length];
            [writer writeData:_data];
            break;
        }
        default: {
            NSString *message = [NSString stringWithFormat:
                                 @"Unknown Extension Item 0x%@", [Helper hexStringByte:(uint8_t)_typecode]];
            @throw [NSException exceptionWithName:@"UnknownExtensionItemException"
                                           reason:message
                                         userInfo:nil];
        }
    }
}

// MARK: - String Representation

- (NSString *)description {
    NSString *typeString;
    switch (_typecode) {
        case ItemTypesValue: typeString = @"Value"; break;
        case ItemTypesFloat: typeString = @"Float"; break;
        case ItemTypesTranslation: typeString = @"Translation"; break;
        case ItemTypesString: typeString = @"String"; break;
        case ItemTypesArray: typeString = @"Array"; break;
        case ItemTypesRotation: typeString = @"Rotation"; break;
        case ItemTypesBinary: typeString = @"Binary"; break;
        default: typeString = @"Unknown"; break;
    }
    
    NSString *name = [NSString stringWithFormat:@"%@ = (%@) ", _name, typeString];
    
    switch (_typecode) {
        case ItemTypesValue: {
            name = [name stringByAppendingString:[NSString stringWithFormat:@"%d", _value]];
            break;
        }
        case ItemTypesFloat: {
            name = [name stringByAppendingString:[NSString stringWithFormat:@"%f", _single]];
            break;
        }
        case ItemTypesTranslation: {
            name = [name stringByAppendingString:[_translation description]];
            break;
        }
        case ItemTypesString: {
            name = [name stringByAppendingString:_string];
            break;
        }
        case ItemTypesArray: {
            name = [name stringByAppendingString:[NSString stringWithFormat:@"%lu items",
                                                  (unsigned long)_items.count]];
            break;
        }
        case ItemTypesRotation: {
            name = [name stringByAppendingString:[_rotation description]];
            break;
        }
        case ItemTypesBinary: {
            name = [name stringByAppendingString:[Helper bytesToHexList:_data]];
            break;
        }
    }
    
    return name;
}

@end

// MARK: - Extension Implementation

@implementation Extension {
    NSData *_data;
}

@synthesize typeCode = _typeCode;
@synthesize varName = _varName;
@synthesize items = _items;

// MARK: - Initialization

- (instancetype)initWithParent:(Rcol *)parent {
    self = [super initWithParent:parent];
    if (self) {
        _items = [[NSMutableArray alloc] init];
        self.version = 0x03;
        _typeCode = 0x07;
        _data = [[NSData alloc] init];
        _varName = @"";
    }
    return self;
}

// MARK: - IRcolBlock Protocol Methods

- (void)unserialize:(BinaryReader *)reader {
    [self unserialize:reader version:0];
}

- (void)unserialize:(BinaryReader *)reader version:(uint32_t)ver {
    self.version = [reader readUInt32];
    _typeCode = [reader readByte];
    
    if (_typeCode < 0x07) {
        NSInteger sz = 16;
        if ((_typeCode != 0x03) || (ver == 4)) {
            sz += 15;
        }
        if ((_typeCode <= 0x03) && (self.version == 3)) {
            if (ver == 5) {
                sz = 31;
            } else {
                sz = 15;
            }
        }
        if ((_typeCode <= 0x03) && (ver == 4)) {
            sz = 31;
        }
        
        _items = [[NSMutableArray alloc] initWithCapacity:1];
        ExtensionItem *ei = [[ExtensionItem alloc] init];
        ei.typecode = ItemTypesBinary;
        ei.data = [reader readBytes:(int32_t)sz];
        [_items addObject:ei];
    } else {
        _varName = [reader readString];
        
        uint32_t count = [reader readUInt32];
        _items = [[NSMutableArray alloc] initWithCapacity:count];
        for (uint32_t i = 0; i < count; i++) {
            ExtensionItem *item = [[ExtensionItem alloc] init];
            [item unserialize:reader];
            [_items addObject:item];
        }
    }
}

- (void)serialize:(BinaryWriter *)writer {
    [self serialize:writer version:0];
}

- (void)serialize:(BinaryWriter *)writer version:(uint32_t)ver {
    [writer writeUInt32:self.version];
    [writer writeUInt8:_typeCode];
    
    if (_typeCode < 0x07) {
        NSInteger sz = 16;
        if ((_typeCode != 0x03) || (ver == 4)) {
            sz += 15;
        }
        if ((_typeCode <= 0x03) && (self.version == 3)) {
            if (ver == 5) {
                sz = 31;
            } else {
                sz = 15;
            }
        }
        if ((_typeCode <= 0x03) && (ver == 4)) {
            sz = 31;
        }
        
        if (_items.count > 0) {
            _data = _items[0].data;
        }
        
        _data = [Helper setLength:_data length:sz];
        [writer writeData:_data];
    } else {
        [writer writeString:_varName];
        
        [writer writeUInt32:(uint32_t)_items.count];
        for (ExtensionItem *item in _items) {
            [item serialize:writer];
        }
    }
}

- (void)initTabPage {
    // Use the base class tab page functionality
    [super initTabPage];
}

- (NSString *)registerInListing:(NSMutableDictionary *)listing {
    // Implementation would depend on how registration works in the system
    return _varName;
}

- (void)addToTabControl:(NSTabView *)tabView {
    NSTabViewItem *tabItem = self.tabPage;
    if (tabItem != nil) {
        [tabView addTabViewItem:tabItem];
    }
}

// MARK: - Memory Management

- (void)dispose {
    [super dispose];
}

@end
