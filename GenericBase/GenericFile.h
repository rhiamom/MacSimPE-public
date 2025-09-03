//
//  GenericFile.h
//  MacSimpe
//
//  Created by Catherine Gramze on 9/3/25.
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

@class BinaryReader, GenericItem, GenericCommon, ImplementedGenericCommon;
@protocol IPackedFileUI, IPackedFileWrapper;

NS_ASSUME_NONNULL_BEGIN

// Forward declaration for block type
@class GenericFile;

/**
 * This delegate is used to register FileHandlers to this generic Handler
 * @remarks
 * Subhandlers are used to tell the Generic Handler which FileTypes it should process.
 * You can make an association between a FileType and a Method, that can create a
 * File Object for that type. Whenever the generic Handler Processes a File it will
 * check its list of registered Subhandlers to select an appropriate one.
 * Unfortunately you can use this Method only with Type-based Assignments opposed to
 * Signature-based ones! For them you must override the core Methods fileSignature(),
 * processData() and createSignatureBasedFileObject().
 */
typedef GenericFile * _Nullable (^CreateFileObjectBlock)(id<IPackedFileWrapper> wrapper);

/**
 * Abstract Class for implementing new generic FileFormats
 */
@interface GenericFile : AbstractWrapper <IFileWrapper, NSFastEnumeration>

// MARK: - Properties

/**
 * Returns the File Attributes
 */
@property (nonatomic, readonly, strong) GenericCommon *attributes;

/**
 * Returns the Number of available FileItems
 */
@property (nonatomic, readonly, assign) NSInteger count;

/**
 * Returns the File Items
 */
@property (nonatomic, readonly, strong, nullable) NSArray<GenericItem *> *items;

/**
 * Returns the File Reader
 */
@property (nonatomic, readonly, strong, nullable) BinaryReader *reader;

/**
 * Returns the List of SubHandlers
 */
@property (nonatomic, readonly, strong) NSMutableDictionary<NSNumber *, CreateFileObjectBlock> *subhandlers;

// MARK: - Initialization

/**
 * Constructor
 */
- (instancetype)init;

// MARK: - Item Management

/**
 * Adds a new Entry to the File
 * @param item The FileItem you want to add
 */
- (void)addItem:(GenericItem *)item;

/**
 * Returns the Item stored at the given Index
 * @param index The Item Number (0-Based)
 * @returns The Entry stored at the given index
 */
- (nullable GenericItem *)getItem:(uint32_t)index;

// MARK: - Subhandler Management

/**
 * Registers a new Type based SubHandler
 * @param type The Type you want to assign a SubHandler to
 * @param block The Block that is used to create the File Object
 * @returns YES, if the handler was registered
 */
- (BOOL)registerType:(uint32_t)type withCreateBlock:(CreateFileObjectBlock)block;

/**
 * If no Handler was registered for the Type, the system tries to find
 * a Signature Based Handler. This Function must return a File Object based on the
 * Signature. By Default this Method returns nil, so you eventually have to override
 * it
 * @param wrapper The PackedFile Wrapper
 * @returns in this implementation always nil
 */
- (nullable GenericFile *)createSignatureBasedFileObject:(id<IPackedFileWrapper>)wrapper;

// MARK: - Abstract Interface (Must be implemented by subclasses)

/**
 * Parses the Header of the File represented by the Reader. This is called when the parsing of the Files
 * starts, and can be used to read Header Data.
 * You also should initialize the items structure (set the length of the Array). If it is not set at this
 * point, the parseFileItem function will never be called!
 */
- (void)parseHeader;

/**
 * Processes the Data stored in the File for one FileItem. This Function is called Count times in a
 * sequence.
 * @param item The FileItem you have to assign the current Data to
 */
- (void)parseFileItem:(GenericItem *)item;

/**
 * Returns the Name for the currently processed FileType
 * @param type The Type ID of the File
 * @returns The Name for the given ID
 */
- (NSString *)getTypeName:(uint32_t)type;

// MARK: - Virtual Methods (Can be overridden by subclasses)

/**
 * Handles some initializing Tasks for the Binary Data before it is used with the BinaryReader.
 * This implementation is a simple Placeholder, so you don't have to generate an empty method in
 * each new class!
 * @remarks Can be used to determine the count of FileItems based on the Size of the Binary Data
 */
- (void)initData;

// MARK: - Internal Methods

/**
 * Preparse some Data Structures for the use with parseData
 */
- (void)prepareData;

/**
 * Handles the Task necessary to Parse a File
 * @remarks
 * First the position of the Reader is set to 0, then the parseHeader implementation is called.
 * If the items Structure is initialized, the parseFileItem() implementation is called for each
 * of the available Items.
 */
- (void)parseData;

@end

NS_ASSUME_NONNULL_END
