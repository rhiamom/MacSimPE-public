//
//  CRC.m
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


/* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is Classless.Hasher - C#/.NET Hash and Checksum Algorithm Library.
 *
 * The Initial Developer of the Original Code is Classless.net.
 * Portions created by the Initial Developer are Copyright (C) 2004 the Initial
 * Developer. All Rights Reserved.
 *
 * Contributor(s):
 *        Jason Simeone (jay@classless.net)
 *
 * ***** END LICENSE BLOCK ***** */

#import "CRC.h"
#import <math.h>
#import "CRCParameters.h"


static NSMutableDictionary *lookupTables = nil;

@interface CRC ()
@property (nonatomic, strong) CRCParameters *parameters;
@property (nonatomic, assign) NSInteger hashSizeValue;
@property (nonatomic, assign) NSInteger state;
@property (nonatomic, assign) int64_t *lookup;
@property (nonatomic, assign) int64_t checksum;
@property (nonatomic, assign) int64_t registerMask;
@end

@implementation CRC

+ (void)initialize {
    if (self == [CRC class]) {
        lookupTables = [[NSMutableDictionary alloc] init];
        // Pre-build the more popular lookup tables
        CRCParameters *crc32Params = [CRCParameters getParameters:CRCStandardCRC32Reversed];
        [self buildLookup:crc32Params];
    }
}

- (instancetype)initWithParameters:(CRCParameters *)param {
    if (param == nil) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"The CRCParameters cannot be nil."
                                     userInfo:nil];
    }
    
    self = [super init];
    if (self) {
        @synchronized(self) {
            _parameters = param;
            _hashSizeValue = param.order;
            
            [CRC buildLookup:param];
            NSValue *lookupValue = lookupTables[param];
            _lookup = (int64_t *)[lookupValue pointerValue];
            _registerMask = (int64_t)(pow(2, (param.order - 8)) - 1);
            
            [self initialize];
        }
    }
    return self;
}

- (void)dealloc {
    // Note: lookup table is managed statically, don't free here
}

+ (void)buildLookup:(CRCParameters *)param {
    if (lookupTables[param] != nil) {
        // No sense in creating the table twice
        return;
    }
    
    int64_t *table = malloc(256 * sizeof(int64_t));
    int64_t topBit = (int64_t)1 << (param.order - 1);
    int64_t widthMask = (((1LL << (param.order - 1)) - 1) << 1) | 1;
    
    // Build the table
    for (int i = 0; i < 256; i++) {
        table[i] = i;
        
        if (param.reflectInput) {
            table[i] = [self reflect:(int64_t)i numBits:8];
        }
        
        table[i] = table[i] << (param.order - 8);
        
        for (int j = 0; j < 8; j++) {
            if ((table[i] & topBit) != 0) {
                table[i] = (table[i] << 1) ^ param.polynomial;
            } else {
                table[i] <<= 1;
            }
        }
        
        if (param.reflectInput) {
            table[i] = [self reflect:table[i] numBits:param.order];
        }
        
        table[i] &= widthMask;
    }
    
    // Add the new lookup table
    NSValue *tableValue = [NSValue valueWithPointer:table];
    lookupTables[param] = tableValue;
}

- (void)initialize {
    @synchronized(self) {
        _state = 0;
        _checksum = _parameters.initialValue;
        if (_parameters.reflectInput) {
            _checksum = [CRC reflect:_checksum numBits:_parameters.order];
        }
    }
}

- (NSData *)computeHash:(NSData *)data {
    [self initialize];
    const uint8_t *bytes = (const uint8_t *)[data bytes];
    [self hashCore:bytes start:0 size:[data length]];
    return [self hashFinal];
}

- (void)hashCore:(const uint8_t *)array start:(NSInteger)ibStart size:(NSInteger)cbSize {
    @synchronized(self) {
        for (NSInteger i = ibStart; i < (cbSize - ibStart); i++) {
            if (_parameters.reflectInput) {
                _checksum = ((_checksum >> 8) & _registerMask) ^ _lookup[(_checksum ^ array[i]) & 0xFF];
            } else {
                _checksum = (_checksum << 8) ^ _lookup[((_checksum >> (_parameters.order - 8)) ^ array[i]) & 0xFF];
            }
        }
    }
}

- (NSData *)hashFinal {
    @synchronized(self) {
        NSInteger i, shift, numBytes;
        
        _checksum ^= (uint32_t)_parameters.finalXORValue;
        
        numBytes = (NSInteger)_parameters.order / 8;
        if (((NSInteger)_parameters.order - (numBytes * 8)) > 0) {
            numBytes++;
        }
        
        uint8_t *temp = malloc(numBytes * sizeof(uint8_t));
        for (i = (numBytes - 1), shift = 0; i >= 0; i--, shift += 8) {
            temp[i] = (uint8_t)((_checksum >> shift) & 0xFF);
        }
        
        NSData *result = [NSData dataWithBytes:temp length:numBytes];
        free(temp);
        return result;
    }
}

+ (int64_t)reflect:(int64_t)data numBits:(NSInteger)numBits {
    int64_t temp = data;
    
    for (NSInteger i = 0; i < numBits; i++) {
        int64_t bitMask = (int64_t)1 << ((numBits - 1) - i);
        
        if ((temp & (int64_t)1) != 0) {
            data |= bitMask;
        } else {
            data &= ~bitMask;
        }
        
        temp >>= 1;
    }
    
    return data;
}

@end
#import <Foundation/Foundation.h>
