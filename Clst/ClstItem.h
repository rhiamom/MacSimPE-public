//
//  ClstItem.h
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

#import "MetaData.h"

@protocol IPackedFileDescriptor;
@class TypeAlias;
@class BinaryReader;
@class BinaryWriter;

/**
 * An Item stored in a CPF File
 */
@interface ClstItem : NSObject

// MARK: - Properties

@property (nonatomic, assign) uint32_t type;
@property (nonatomic, assign) uint32_t group;
@property (nonatomic, assign) uint32_t instance;
@property (nonatomic, assign) uint32_t subType;
@property (nonatomic, assign) uint32_t uncompressedSize;

@property (nonatomic, assign, readonly) IndexTypes format;
@property (nonatomic, strong, readonly) TypeAlias *typeName;

// MARK: - Initialization

/**
 * Constructor with format only
 */
- (instancetype)initWithFormat:(IndexTypes)format;

/**
 * Constructor with packed file descriptor and format
 */
- (instancetype)initWithPackedFileDescriptor:(id<IPackedFileDescriptor>)pfd
                                      format:(IndexTypes)format;

- (instancetype)initWithIndexType:(IndexTypes)indexType;

// MARK: - Serialization

/**
 * Unserializes a BinaryReader into the Attributes of this Instance
 */
- (void)unserialize:(BinaryReader *)reader;

/**
 * Serializes the attributes of this instance to a BinaryWriter
 */
- (void)serialize:(BinaryWriter *)writer withFormat:(IndexTypes)format;


// MARK: - Equality and Comparison

- (BOOL)isEqual:(id)object;
- (NSUInteger)hash;

@end
