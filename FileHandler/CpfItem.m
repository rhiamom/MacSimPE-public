//
//  CpfItem.m
//  MacSimpe
//
//  Created by Catherine Gramze on 8/22/25.
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

#import "CpfItem.h"
#import "BinaryReader.h"
#import "BinaryWriter.h"
#import "Helper.h"
#import "MemoryStream.h"

@implementation CpfItem {
    NSMutableData *_nameData;
    NSMutableData *_valueData;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _nameData = [[NSMutableData alloc] init];
        _valueData = [[NSMutableData alloc] init];
        _datatype = DataTypesString;
    }
    return self;
}

#pragma mark - Name Properties

- (NSString *)name {
    return [Helper dataToString:_nameData];
}

- (void)setName:(NSString *)name {
    _nameData = [[Helper stringToBytes:name length:0] mutableCopy];
}

- (NSData *)plainName {
    return [_nameData copy];
}

- (void)setPlainName:(NSData *)plainName {
    _nameData = [plainName mutableCopy];
}

#pragma mark - Value Properties

- (NSData *)value {
    return [_valueData copy];
}

- (void)setValue:(NSData *)value {
    _valueData = [value mutableCopy];
}

- (NSString *)stringValue {
    switch (_datatype) {
        case DataTypesSingle:
            return [NSString stringWithFormat:@"%f", [self asSingle]];
            
        case DataTypesInteger:
        case DataTypesUInteger:
            return [NSString stringWithFormat:@"0x%@", [Helper hexString:[self asInteger]]];
            
        case DataTypesString:
            return [self asString];
            
        default:
            return @"";
    }
}

- (void)setStringValue:(NSString *)stringValue {
    _datatype = DataTypesString;
    _valueData = [[Helper stringToBytes:stringValue length:0] mutableCopy];
}

- (uint32_t)uintegerValue {
    switch (_datatype) {
        case DataTypesSingle:
            return (uint32_t)[self asSingle];
            
        case DataTypesInteger:
        case DataTypesUInteger:
            return [self asUInteger];
            
        case DataTypesString: {
            NSString *str = [self asString];
            return (uint32_t)[str integerValue];
        }
            
        default:
            return 0;
    }
}

- (void)setUintegerValue:(uint32_t)uintegerValue {
    _datatype = DataTypesUInteger;
    MemoryStream *stream = [[MemoryStream alloc] init];
    BinaryWriter *writer = [[BinaryWriter alloc] initWithStream:stream];
    [writer writeUInt32:uintegerValue];
    _valueData = [stream.data mutableCopy];
}

- (int32_t)integerValue {
    switch (_datatype) {
        case DataTypesSingle:
            return (int32_t)[self asSingle];
            
        case DataTypesInteger:
        case DataTypesUInteger:
            return [self asInteger];
            
        case DataTypesString: {
            NSString *str = [self asString];
            return (int32_t)[str integerValue];
        }
            
        default:
            return 0;
    }
}

- (void)setIntegerValue:(int32_t)integerValue {
    _datatype = DataTypesInteger;
    MemoryStream *stream = [[MemoryStream alloc] init];
    BinaryWriter *writer = [[BinaryWriter alloc] initWithStream:stream];
    [writer writeInt32:integerValue];
    _valueData = [stream.data mutableCopy];
}

- (float)singleValue {
    switch (_datatype) {
        case DataTypesSingle:
            return [self asSingle];
            
        case DataTypesInteger:
        case DataTypesUInteger:
            return (float)[self asInteger];
            
        case DataTypesString: {
            NSString *str = [self asString];
            return [str floatValue];
        }
            
        default:
            return 0.0f;
    }
}

- (void)setSingleValue:(float)singleValue {
    _datatype = DataTypesSingle;
    MemoryStream *stream = [[MemoryStream alloc] init];
    BinaryWriter *writer = [[BinaryWriter alloc] initWithStream:stream];
    [writer writeSingle:singleValue];
    _valueData = [stream.data mutableCopy];
}

- (BOOL)booleanValue {
    switch (_datatype) {
        case DataTypesSingle:
            return ([self asSingle] != 0.0f);
            
        case DataTypesInteger:
        case DataTypesUInteger:
            return ([self asInteger] != 0);
            
        case DataTypesString: {
            NSString *str = [self asString];
            return ([str integerValue] != 0);
        }
            
        case DataTypesBoolean:
            return [self asBoolean];
            
        default:
            return NO;
    }
}

- (void)setBooleanValue:(BOOL)booleanValue {
    _datatype = DataTypesBoolean;
    MemoryStream *stream = [[MemoryStream alloc] init];
    BinaryWriter *writer = [[BinaryWriter alloc] initWithStream:stream];
    [writer writeBoolean:booleanValue];
    _valueData = [stream.data mutableCopy];
}

- (id)objectValue {
    switch (_datatype) {
        case DataTypesUInteger:
            return @([self uintegerValue]);
            
        case DataTypesInteger:
            return @([self integerValue]);
            
        case DataTypesSingle:
            return @([self singleValue]);
            
        case DataTypesBoolean:
            return @([self booleanValue]);
            
        default:
            return [self stringValue];
    }
}

#pragma mark - Internal Value Interpretation

- (int32_t)asInteger {
    @try {
        MemoryStream *stream = [[MemoryStream alloc] initWithData:_valueData];
        BinaryReader *reader = [[BinaryReader alloc] initWithStream:stream];
        return [reader readInt32];
    }
    @catch (NSException *exception) {
        return 0;
    }
}

- (uint32_t)asUInteger {
    @try {
        MemoryStream *stream = [[MemoryStream alloc] initWithData:_valueData];
        BinaryReader *reader = [[BinaryReader alloc] initWithStream:stream];
        return [reader readUInt32];
    }
    @catch (NSException *exception) {
        return 0;
    }
}

- (BOOL)asBoolean {
    if (_valueData.length < 1) {
        return NO;
    }
    const uint8_t *bytes = (const uint8_t *)_valueData.bytes;
    return (bytes[0] == 1);
}

- (NSString *)asString {
    @try {
        MemoryStream *stream = [[MemoryStream alloc] initWithData:_valueData];
        BinaryReader *reader = [[BinaryReader alloc] initWithStream:stream];
        NSMutableString *result = [[NSMutableString alloc] init];
        
        while ([stream position] < [stream length]) {
            char character = [reader readChar];
            if (character == 0) break;
            [result appendFormat:@"%c", character];
        }
        
        return [result copy];
    }
    @catch (NSException *exception) {
        return @"";
    }
}

- (float)asSingle {
    @try {
        MemoryStream *stream = [[MemoryStream alloc] initWithData:_valueData];
        BinaryReader *reader = [[BinaryReader alloc] initWithStream:stream];
        return [reader readSingle];
    }
    @catch (NSException *exception) {
        return 0.0f;
    }
}

#pragma mark - Serialization

- (void)unserialize:(BinaryReader *)reader {
    // Load datatype
    _datatype = (DataTypes)[reader readUInt32];
    
    // Load the name
    int32_t nameLength = [reader readInt32];
    _nameData = [[reader readBytes:nameLength] mutableCopy];
    
    // Load value
    int32_t valueLength;
    switch (_datatype) {
        case DataTypesString: {
            valueLength = [reader readInt32];
            break;
        }
        case DataTypesBoolean: {
            valueLength = 1;
            break;
        }
        default: {
            valueLength = 4;
            break;
        }
    }
    
    _valueData = [[reader readBytes:valueLength] mutableCopy];
}

- (void)serialize:(BinaryWriter *)writer {
    // Store datatype
    [writer writeUInt32:(uint32_t)_datatype];
    
    // Store the name
    [writer writeUInt32:(uint32_t)_nameData.length];
    [writer writeData:_nameData];
    
    // Store the value
    switch (_datatype) {
        case DataTypesString: {
            [writer writeUInt32:(uint32_t)_valueData.length];
            [writer writeData:_valueData];
            break;
        }
        default: {
            [writer writeData:_valueData];
            break;
        }
    }
}

#pragma mark - NSObject Overrides

- (NSString *)description {
    NSMutableString *description = [[NSMutableString alloc] init];
    
    NSString *datatypeString;
    switch (_datatype) {
        case DataTypesString:
            datatypeString = @"String";
            break;
        case DataTypesInteger:
            datatypeString = @"Integer";
            break;
        case DataTypesUInteger:
            datatypeString = @"UInteger";
            break;
        case DataTypesSingle:
            datatypeString = @"Single";
            break;
        case DataTypesBoolean:
            datatypeString = @"Boolean";
            break;
        default:
            datatypeString = [NSString stringWithFormat:@"%d", (int)_datatype];
            break;
    }
    
    [description appendFormat:@"%@ (%@) = ", self.name, datatypeString];
    
    switch (_datatype) {
        case DataTypesUInteger:
        case DataTypesInteger: {
            [description appendFormat:@"0x%@", [Helper hexString:self.uintegerValue]];
            break;
        }
        default: {
            id objValue = self.objectValue;
            if (objValue) {
                [description appendString:[objValue description]];
            }
            break;
        }
    }
    
    return [description copy];
}

#pragma mark - Memory Management

- (void)dispose {
    [_valueData setLength:0];
    _valueData = nil;
    [_nameData setLength:0];
    _nameData = nil;
}

@end
