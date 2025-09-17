//
//  ObjdWrapper.h
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

//
//  Objd.h
//  MacSimpe
//
//  Created by [Your Name] on [Date]
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
#import "AbstractWrapper.h"
#import "IFileWrapper.h"
#import "IFileWrapperSaveExtension.h"

@class BinaryReader, BinaryWriter;
@protocol IOpcodeProvider, IPackedFileUI, IWrapperInfo;

NS_ASSUME_NONNULL_BEGIN

/**
 * Helper class for OBJD attribute items
 */
@interface ObjdItem : NSObject

// MARK: - Properties

/**
 * The value of the item
 */
@property (nonatomic, assign) uint16_t val;

/**
 * The position in the file stream where this item is located
 */
@property (nonatomic, assign) int64_t position;

// MARK: - Initialization

/**
 * Create a new ObjdItem
 */
- (instancetype)init;

/**
 * Create a new ObjdItem with value and position
 * @param val The value
 * @param position The position in the stream
 */
- (instancetype)initWithValue:(uint16_t)val position:(int64_t)position;

@end

/**
 * Represents a PackedFile in OBJD Format
 */
@interface Objd : AbstractWrapper <IFileWrapper, IFileWrapperSaveExtension>

// MARK: - Properties

/**
 * Returns/Sets the Name of a File
 */
@property (nonatomic, copy) NSString *fileName;

/**
 * Returns the GUID of the Object
 */
@property (nonatomic, assign) uint32_t guid;

/**
 * Returns the GUID of the Object (alias for guid)
 */
@property (nonatomic, assign) uint32_t simId;

/**
 * Returns the GUID of the Proxy Object
 */
@property (nonatomic, assign) uint32_t proxyGuid;

/**
 * Returns the GUID of the Original Object
 */
@property (nonatomic, assign) uint32_t originalGuid;

/**
 * Returns the Instance of the assigned Catalog Description
 */
@property (nonatomic, readonly, assign) uint16_t ctssId;

/**
 * Returns / Sets the Type of an Object
 */
@property (nonatomic, assign) uint16_t type;

/**
 * Returns the Attributes dictionary
 */
@property (nonatomic, readonly, strong) NSMutableDictionary *attributes;

// MARK: - Initialization

/**
 * Constructor
 * @param opcodes The opcode provider needed for OBJD processing
 */
- (instancetype)initWithOpcodes:(id<IOpcodeProvider>)opcodes;

// MARK: - Attribute Access Methods

/**
 * Returns a stored Attribute as Unsigned short Value
 * @param name The name of the attribute
 * @return The attribute value as uint16_t
 */
- (uint16_t)getAttributeShort:(NSString *)name;

/**
 * Returns the position of the Attribute in the Stream
 * @param name Name of the Attribute
 * @return The position in the stream
 */
- (int64_t)getAttributePosition:(NSString *)name;

// MARK: - IFileWrapper Protocol

/**
 * Returns the Signature that can be used to identify Files processable with this Plugin
 */
@property (nonatomic, readonly, strong) NSData *fileSignature;

/**
 * Returns a list of File Types this Plugin can process
 */
@property (nonatomic, readonly, strong) NSArray<NSNumber *> *assignableTypes;

@end

NS_ASSUME_NONNULL_END
