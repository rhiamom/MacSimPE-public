//
//  StreamHelper.h
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

#import <Foundation/Foundation.h>

@class BinaryReader, BinaryWriter;

/**
 * Some useful Methods to Read Data
 */
@interface StreamHelper : NSObject

/**
 * Reads a string from the Stream, that is 32-Bit Length Encoded
 * @param reader The BinaryReader to read from
 * @return The string read from the stream
 */
+ (NSString *)readString:(BinaryReader *)reader;

/**
 * Writes a 32-Bit Length Encoded String
 * @param writer The BinaryWriter to write to
 * @param string The string to write
 */
+ (void)writeString:(BinaryWriter *)writer string:(NSString *)string;

/**
 * Reads a 0-terminated string
 * @param reader The BinaryReader to read from
 * @return The null-terminated string read from the stream
 */
+ (NSString *)readPChar:(BinaryReader *)reader;

/**
 * Writes a 0-terminated string
 * @param writer The BinaryWriter to write to
 * @param string The string to write (will be null-terminated)
 */
+ (void)writePChar:(BinaryWriter *)writer string:(NSString *)string;

@end
