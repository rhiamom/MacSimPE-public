//
//  ObjdWrapper.m
//  MacSimpe
//
//  Created by Catherine Gramze on 9/17/25.
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

#import "ObjdWrapper.h"
#import "BinaryReader.h"
#import "BinaryWriter.h"
#import "Helper.h"
#import "IOpcodeProvider.h"
#import "AbstractWrapperInfo.h"
#import "IPackedFileUI.h"

@implementation ObjdItem

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        _val = 0;
        _position = 0;
    }
    return self;
}

- (instancetype)initWithValue:(uint16_t)val position:(int64_t)position {
    self = [super init];
    if (self) {
        _val = val;
        _position = position;
    }
    return self;
}

@end

@interface Objd ()

@property (nonatomic, strong) NSData *filename;
@property (nonatomic, strong) NSData *reserved01;
@property (nonatomic, strong) NSData *reserved02;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) NSMutableDictionary *attr;
@property (nonatomic, strong) id<IOpcodeProvider> opcodes;
@property (nonatomic, assign) uint16_t ctssid;

@end

@implementation Objd

#pragma mark - Initialization

- (instancetype)initWithOpcodes:(id<IOpcodeProvider>)opcodes {
    self = [super init];
    if (self) {
        _filename = [NSData data];
        _reserved01 = [NSData data];
        _reserved02 = [NSData data];
        _items = [[NSMutableArray alloc] init];
        _attr = [[NSMutableDictionary alloc] init];
        _opcodes = opcodes;
        _type = 1;
        _guid = 0;
        _proxyGuid = 0;
        _originalGuid = 0;
        _ctssid = 0;
    }
    return self;
}

#pragma mark - Property Implementations

- (NSString *)fileName {
    return [Helper dataToString:_filename];
}

- (void)setFileName:(NSString *)fileName {
    _filename = [Helper setLength:[Helper stringToBytes:fileName] length:64];
}

- (uint32_t)simId {
    return self.guid;
}

- (void)setSimId:(uint32_t)simId {
    self.guid = simId;
}

- (uint16_t)ctssId {
    return _ctssid;
}

- (NSMutableDictionary *)attributes {
    return _attr;
}

#pragma mark - Internal GUID Properties

- (uint32_t)internalGUID {
    uint32_t simid = (uint32_t)(([self getAttributeShort:@"guid_2 - Read Only"] << 16) + [self getAttributeShort:@"guid_1 - Read Only"]);
    return simid;
}

- (void)setInternalGUID:(uint32_t)internalGUID {
    uint32_t simid = internalGUID;
    ObjdItem *guid1 = _attr[@"guid_1 - Read Only"];
    if (guid1 == nil) {
        guid1 = [[ObjdItem alloc] init];
    }
    guid1.val = (uint16_t)(simid & 0xffff);
    _attr[@"guid_1 - Read Only"] = guid1;
    
    ObjdItem *guid2 = _attr[@"guid_2 - Read Only"];
    if (guid2 == nil) {
        guid2 = [[ObjdItem alloc] init];
    }
    guid2.val = (uint16_t)((simid >> 16) & 0xffff);
    _attr[@"guid_2 - Read Only"] = guid2;
}

- (uint32_t)internalTemplateGUID {
    uint32_t simid = (uint32_t)(([self getAttributeShort:@"Proxy GUID 2"] << 16) + [self getAttributeShort:@"Proxy GUID 1"]);
    return simid;
}

- (void)setInternalTemplateGUID:(uint32_t)internalTemplateGUID {
    uint32_t simid = internalTemplateGUID;
    ObjdItem *guid1 = _attr[@"Proxy GUID 1"];
    if (guid1 == nil) {
        guid1 = [[ObjdItem alloc] init];
    }
    guid1.val = (uint16_t)(simid & 0xffff);
    _attr[@"Proxy GUID 1"] = guid1;
    
    ObjdItem *guid2 = _attr[@"Proxy GUID 2"];
    if (guid2 == nil) {
        guid2 = [[ObjdItem alloc] init];
    }
    guid2.val = (uint16_t)((simid >> 16) & 0xffff);
    _attr[@"Proxy GUID 2"] = guid2;
}

- (uint32_t)internalOriginalGUID {
    uint32_t simid = (uint32_t)(([self getAttributeShort:@"original guid 2 - Read Only"] << 16) + [self getAttributeShort:@"original guid 1 - Read Only"]);
    return simid;
}

- (void)setInternalOriginalGUID:(uint32_t)internalOriginalGUID {
    uint32_t simid = internalOriginalGUID;
    ObjdItem *guid1 = _attr[@"original guid 1 - Read Only"];
    if (guid1 == nil) {
        guid1 = [[ObjdItem alloc] init];
    }
    guid1.val = (uint16_t)(simid & 0xffff);
    _attr[@"original guid 1 - Read Only"] = guid1;
    
    ObjdItem *guid2 = _attr[@"original guid 2 - Read Only"];
    if (guid2 == nil) {
        guid2 = [[ObjdItem alloc] init];
    }
    guid2.val = (uint16_t)((simid >> 16) & 0xffff);
    _attr[@"original guid 2 - Read Only"] = guid2;
}

#pragma mark - Attribute Access Methods

- (uint16_t)getAttributeShort:(NSString *)name {
    ObjdItem *o = _attr[name];
    if (o == nil) {
        return 0;
    } else {
        return o.val;
    }
}

- (int64_t)getAttributePosition:(NSString *)name {
    ObjdItem *o = _attr[name];
    if (o == nil) {
        return 0;
    } else {
        return o.position;
    }
}

#pragma mark - AbstractWrapper Methods

- (id<IWrapperInfo>)createWrapperInfo {
    return [[AbstractWrapperInfo alloc] initWithName:@"OBJD Wrapper"
                                              author:@"Quaxi"
                                         description:@"---"
                                             version:3];
}

- (id<IPackedFileUI>)createDefaultUIHandler {
    // Return the appropriate UI handler for OBJD files
    // This would need to be implemented based on your UI architecture
    return nil;
}

- (void)unserialize:(BinaryReader *)reader {
    _attr = [[NSMutableDictionary alloc] init];
    _filename = [reader readBytes:0x40];
    int64_t pos = reader.baseStream.position;
    
    if (reader.baseStream.length >= 0x54) {
        [reader.baseStream seekToOffset:0x52 origin:SeekOriginBegin];
        _type = [reader readUInt16];
    } else {
        _type = 0;
    }
    
    if (reader.baseStream.length >= 0x60) {
        [reader.baseStream seekToOffset:0x5C origin:SeekOriginBegin];
        _guid = [reader readUInt32];
    } else {
        _guid = 0;
    }
    
    if (reader.baseStream.length >= 0x7E) {
        [reader.baseStream seekToOffset:0x7A origin:SeekOriginBegin];
        _proxyGuid = [reader readUInt32];
    } else {
        _proxyGuid = 0;
    }
    
    if (reader.baseStream.length >= 0x94) {
        [reader.baseStream seekToOffset:0x92 origin:SeekOriginBegin];
        _ctssid = [reader readUInt16];
    } else {
        _ctssid = 0;
    }
    
    if (reader.baseStream.length >= 0xD0) {
        [reader.baseStream seekToOffset:0xCC origin:SeekOriginBegin];
        _originalGuid = [reader readUInt32];
    } else {
        _originalGuid = 0;
    }
    
    reader.baseStream.position = pos;
    
    NSArray *names = @[];
    if (_opcodes != nil) {
        names = [_opcodes objdDescription:_type];
    }
    
    if (names.count == 0) {
        // Handle case where no opcode descriptions are available
        // This section would mirror the commented-out code from the original
    } else {
        for (NSString *name in names) {
            if (reader.baseStream.position > reader.baseStream.length - 2) {
                break;
            }
            ObjdItem *item = [[ObjdItem alloc] init];
            item.position = reader.baseStream.position;
            item.val = [reader readUInt16];
            NSString *sname = name;
            if ([[name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
                sname = [NSString stringWithFormat:@"0x%@", [Helper hexString:(uint32_t)item.position]];
            }
            _attr[sname] = item;
        }
    }
}

- (void)serialize:(BinaryWriter *)writer {
    [writer writeData:_filename];
    
    NSArray *names = @[];
    if (_opcodes != nil) {
        names = [_opcodes objdDescription:_type];
    }
    
    if (names.count == 0) {
        [writer writeData:_reserved01];
        [writer writeUInt16:[self getAttributeShort:@"guid_1 - Read Only"]];
        [writer writeUInt16:[self getAttributeShort:@"guid_2 - Read Only"]];
        [writer writeData:_reserved02];
    } else {
        for (NSString *name in names) {
            NSString *sname = name;
            if ([[sname stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
                sname = [NSString stringWithFormat:@"0x%@", [Helper hexString:(uint32_t)writer.position]];
            }
            if (_attr[sname] == nil) {
                break;
            }
            [writer writeUInt16:[self getAttributeShort:sname]];
        }
        _ctssid = [self getAttributeShort:@"catalog strings id"];
    }
    
    [writer seekToPosition:0x52];
    [writer writeUInt16:_type];
    
    [writer seekToPosition:0x5C];
    [writer writeUInt32:_guid];
    
    [writer seekToPosition:0x7A];
    [writer writeUInt32:_proxyGuid];
    
    [writer seekToPosition:0x92];
    [writer writeUInt16:_ctssid];
    
    [writer seekToPosition:0xCC];
    [writer writeUInt32:_originalGuid];
}

#pragma mark - IFileWrapper Protocol

- (NSData *)fileSignature {
    return [NSData data]; // OBJD files don't have a specific signature
}

- (NSArray<NSNumber *> *)assignableTypes {
    return @[@(0x4F424A44)]; // 'OBJD' as uint32_t
}

@end
