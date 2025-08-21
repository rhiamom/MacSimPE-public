//
//  CRCParameters.m
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

#import "CRCParameters.h"

@implementation CRCParameters

- (instancetype)initWithOrder:(NSInteger)order
                   polynomial:(int64_t)polynomial
                 initialValue:(int64_t)initialValue
                finalXORValue:(int64_t)finalXORValue
                 reflectInput:(BOOL)reflectInput {
    self = [super init];
    if (self) {
        self.order = order;
        self.polynomial = polynomial;
        self.initialValue = initialValue;
        self.finalXORValue = finalXORValue;
        self.reflectInput = reflectInput;
    }
    return self;
}

- (void)setOrder:(NSInteger)order {
    if (((order % 8) != 0) || (order < 8) || (order > 64)) {
        @throw [NSException exceptionWithName:NSRangeException
                                       reason:[NSString stringWithFormat:@"CRC Order must represent full bytes and be between 8 and 64. Value: %ld", (long)order]
                                     userInfo:nil];
    } else {
        _order = order;
    }
}

- (NSUInteger)hash {
    NSString *temp = [NSString stringWithFormat:@"%lld:%ld:%@",
                      (long long)self.polynomial,
                      (long)self.order,
                      self.reflectInput ? @"YES" : @"NO"];
    return [temp hash];
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[CRCParameters class]]) {
        return NO;
    }
    
    CRCParameters *other = (CRCParameters *)object;
    return (self.order == other.order &&
            self.polynomial == other.polynomial &&
            self.initialValue == other.initialValue &&
            self.finalXORValue == other.finalXORValue &&
            self.reflectInput == other.reflectInput);
}

- (id)copyWithZone:(NSZone *)zone {
    return [[CRCParameters alloc] initWithOrder:self.order
                                     polynomial:self.polynomial
                                   initialValue:self.initialValue
                                  finalXORValue:self.finalXORValue
                                   reflectInput:self.reflectInput];
}

+ (CRCParameters *)getParameters:(CRCStandard)standard {
    CRCParameters *temp;
    
    switch (standard) {
        case CRCStandardCRC8:
            temp = [[CRCParameters alloc] initWithOrder:8 polynomial:0xE0 initialValue:0 finalXORValue:0 reflectInput:NO];
            break;
        case CRCStandardCRC8Reversed:
            temp = [[CRCParameters alloc] initWithOrder:8 polynomial:0x07 initialValue:0 finalXORValue:0 reflectInput:YES];
            break;
        case CRCStandardCRC16:
            temp = [[CRCParameters alloc] initWithOrder:16 polynomial:0x8005 initialValue:0 finalXORValue:0 reflectInput:NO];
            break;
        case CRCStandardCRC16Reversed:
            temp = [[CRCParameters alloc] initWithOrder:16 polynomial:0xA001 initialValue:0 finalXORValue:0 reflectInput:YES];
            break;
        case CRCStandardCRC16CCITT:
            temp = [[CRCParameters alloc] initWithOrder:16 polynomial:0x1021 initialValue:0xFFFF finalXORValue:0 reflectInput:NO];
            break;
        case CRCStandardCRC16CCITTReversed:
            temp = [[CRCParameters alloc] initWithOrder:16 polynomial:0x8408 initialValue:0 finalXORValue:0 reflectInput:YES];
            break;
        case CRCStandardCRC16ARC:
            temp = [[CRCParameters alloc] initWithOrder:16 polynomial:0x8005 initialValue:0 finalXORValue:0 reflectInput:YES];
            break;
        case CRCStandardCRC16ZMODEM:
            temp = [[CRCParameters alloc] initWithOrder:16 polynomial:0x1021 initialValue:0 finalXORValue:0 reflectInput:NO];
            break;
        case CRCStandardCRC24:
            temp = [[CRCParameters alloc] initWithOrder:24 polynomial:0x1864CFB initialValue:0xB704CE finalXORValue:0 reflectInput:NO];
            break;
        case CRCStandardCRC32:
            temp = [[CRCParameters alloc] initWithOrder:32 polynomial:0xEDB88320 initialValue:0xFFFFFFFF finalXORValue:0xFFFFFFFF reflectInput:NO];
            break;
        case CRCStandardCRC32Reversed:
            temp = [[CRCParameters alloc] initWithOrder:32 polynomial:0x04C11DB7 initialValue:0xFFFFFFFF finalXORValue:0xFFFFFFFF reflectInput:YES];
            break;
        case CRCStandardCRC32JAMCRC:
            temp = [[CRCParameters alloc] initWithOrder:32 polynomial:0x04C11DB7 initialValue:0xFFFFFFFF finalXORValue:0 reflectInput:YES];
            break;
        case CRCStandardCRC32BZIP2:
            temp = [[CRCParameters alloc] initWithOrder:32 polynomial:0x04C11DB7 initialValue:0xFFFFFFFF finalXORValue:0xFFFFFFFF reflectInput:NO];
            break;
        default:
            temp = [[CRCParameters alloc] initWithOrder:32 polynomial:0x04C11DB7 initialValue:0xFFFFFFFF finalXORValue:0xFFFFFFFF reflectInput:YES];
            break;
    }
    
    return temp;
}

@end
#import <Foundation/Foundation.h>
