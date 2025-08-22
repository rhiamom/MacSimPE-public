//
//  CpfWrapper.h
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
#import "AbstractWrapper.h"
#import "IFileWrapper.h"
#import "IFileWrapperSaveExtension.h"


@class CpfItem, TypeAlias, BinaryReader, BinaryWriter;

/**
 * This is the actual FileWrapper
 * @remarks The wrapper is used to (un)serialize the Data of a file into its Attributes.
 *          So basically it reads a BinaryStream and translates the data into some user-defined Attributes.
 */
@interface Cpf : AbstractWrapper <IFileWrapper, IFileWrapperSaveExtension, IMultiplePackedFileWrapper>

// MARK: - Properties

/**
 * Contains the Filename ID
 */
@property (nonatomic, readonly, strong) NSData *fileId;

/**
 * Returns/Sets the CPF Items
 */
@property (nonatomic, strong) NSArray<CpfItem *> *items;

/**
 * Returns the File Signature
 */
@property (nonatomic, readonly, strong) NSData *fileSignature;

/**
 * Returns a list of File Types this Plugin can process
 */
@property (nonatomic, readonly, strong) NSArray<NSNumber *> *assignableTypes;

// MARK: - Initialization

/**
 * Constructor
 */
- (instancetype)init;

// MARK: - Item Management

/**
 * Add a new CPF Item
 * @param item The item you want to add
 */
- (void)addItem:(CpfItem *)item;

/**
 * Add a new CPF Item
 * @param item The item you want to add
 * @param allowDuplicate YES if you want to add the item even if a similar one already exists
 */
- (void)addItem:(CpfItem *)item allowDuplicate:(BOOL)allowDuplicate;

/**
 * Returns the Item with the given Name or nil if not found
 * @param name The name to search for
 * @return nil or the Item
 */
- (CpfItem *)getItem:(NSString *)name;

/**
 * Returns the Item with the given Name or a new empty item if not found
 * @param name The name to search for
 * @return The Item (never nil)
 */
- (CpfItem *)getSaveItem:(NSString *)name;

// MARK: - IFileWrapper Protocol

/**
 * Returns true if this Plugin can process the given file type
 * @param type The file type to check
 * @return YES if this wrapper can handle the type
 */
- (BOOL)canHandleType:(uint32_t)type;

// MARK: - Memory Management

/**
 * Dispose of resources
 */
- (void)dispose;

@end
