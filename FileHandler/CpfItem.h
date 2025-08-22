//
//  CpfItem.h
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
#import "MetaData.h"

@class BinaryReader, BinaryWriter;

/**
 * An Item stored in a CPF File
 */
@interface CpfItem : NSObject

// MARK: - Properties

/**
 * The data type of this item
 */
@property (nonatomic, assign) DataTypes datatype;

/**
 * The name of this item (as string)
 */
@property (nonatomic, copy) NSString *name;

/**
 * The name as raw byte data
 */
@property (nonatomic, strong) NSData *plainName;

/**
 * The raw value data
 */
@property (nonatomic, strong) NSData *value;

/**
 * The value as a string representation
 */
@property (nonatomic, copy) NSString *stringValue;

/**
 * The value as an unsigned integer
 */
@property (nonatomic, assign) uint32_t uintegerValue;

/**
 * The value as a signed integer
 */
@property (nonatomic, assign) int32_t integerValue;

/**
 * The value as a single-precision float
 */
@property (nonatomic, assign) float singleValue;

/**
 * The value as a boolean
 */
@property (nonatomic, assign) BOOL booleanValue;

/**
 * Returns value as an object of the defined type
 */
@property (nonatomic, readonly, strong) id objectValue;

// MARK: - Initialization

/**
 * Constructor
 */
- (instancetype)init;

// MARK: - Serialization

/**
 * Unserializes a BinaryStream into the attributes of this instance
 * @param reader The stream that contains the file data
 */
- (void)unserialize:(BinaryReader *)reader;

/**
 * Stores the data in a stream
 * @param writer The stream to write data to
 */
- (void)serialize:(BinaryWriter *)writer;

// MARK: - Memory Management

/**
 * Dispose of resources
 */
- (void)dispose;

@end
