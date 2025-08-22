//
//  StreamHelper.m
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

#import "StreamHelper.h"
#import "BinaryReader.h"
#import "BinaryWriter.h"
#import "Helper.h"

@implementation StreamHelper

+ (NSString *)readString:(BinaryReader *)reader {
    int32_t count = [reader readInt32];
    NSData *data = [reader readBytes:count];
    return [Helper dataToString:data];
}

+ (void)writeString:(BinaryWriter *)writer string:(NSString *)string {
    if (string.length > 0) {
        [writer writeUInt32:(uint32_t)string.length];
        NSData *data = [Helper stringToBytes:string length:string.length];
        [writer writeData:data];
    } else {
        [writer writeUInt32:0];
    }
}

+ (NSString *)readPChar:(BinaryReader *)reader {
    char byte = [reader readChar];
    NSMutableString *result = [[NSMutableString alloc] init];
    
    while (byte != 0 && [reader.baseStream position] <= [reader.baseStream length]) {
        [result appendFormat:@"%c", byte];
        byte = [reader readChar];
    }
    
    return [result copy];
}

+ (void)writePChar:(BinaryWriter *)writer string:(NSString *)string {
    for (NSUInteger i = 0; i < string.length; i++) {
        unichar character = [string characterAtIndex:i];
        uint8_t charByte = (uint8_t)character;
        [writer writeByte:charByte];
    }
    [writer writeByte:0]; // null terminator
}

@end
