//
//  RcolWrapper.h
//  MacSimpe
//
//  Created by Catherine Gramze on 8/8/25.
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

#import <Foundation/Foundation.h>
#import "AbstractWrapper.h"
#import "IFileWrapper.h"
#import "IFileWrapperSaveExtension.h"


@protocol IPackedFileDescriptor;
@protocol IRcolBlock;
@protocol IProviderRegistry;
@protocol IWrapperRegistry;
@protocol IPackedFileUI;
@class BinaryReader;
@class BinaryWriter;
@class TypeAlias;
@class IWrapperInfo;

/**
 * This is the actual FileWrapper
 * @remarks The wrapper is used to (un)serialize the Data of a file into its Attributes.
 * So Basically it reads a BinaryStream and translates the data into some user-defined Attributes.
 */
@interface Rcol : AbstractWrapper <IFileWrapper, IFileWrapperSaveExtension, IMultiplePackedFileWrapper>

// MARK: - Properties

/**
 * Referenced files in the RCOL
 */
@property (nonatomic, strong) NSArray<id<IPackedFileDescriptor>> *referencedFiles;

/**
 * Blocks contained in the RCOL
 */
@property (nonatomic, strong) NSArray<id<IRcolBlock>> *blocks;

/**
 * Number of referenced files
 */
@property (nonatomic, readonly) uint32_t count;

/**
 * Whether this RCOL is corrupted/invalid
 */
@property (nonatomic, readonly) BOOL duff;

/**
 * The provider registry
 */
@property (nonatomic, strong, readonly) id<IProviderRegistry> provider;

/**
 * Filename of the First Block (or an empty string)
 */
@property (nonatomic, strong) NSString *fileName;

/**
 * Fast loading mode
 */
@property (nonatomic, assign) BOOL fast;

// MARK: - Class Properties

/**
 * Token registry for RCOL blocks
 */
@property (class, nonatomic, strong, readonly) NSMutableDictionary *tokens;

/**
 * List of assemblies to search for tokens
 */
@property (class, nonatomic, strong, readonly) NSMutableArray *tokenAssemblies;

// MARK: - Events

/**
 * Event fired when tab page changes
 */
@property (nonatomic, copy) void (^tabPageChangedBlock)(id sender);

// MARK: - Initialization

/**
 * Constructor with provider and fast mode
 */
- (instancetype)initWithProvider:(id<IProviderRegistry>)provider fast:(BOOL)fast;

/**
 * Default constructor
 */
- (instancetype)init;

// MARK: - Token Management

/**
 * Loads all Tokens in the assemblies given in the TokenAssemblies List
 */
+ (void)loadTokens;

/**
 * Creates the Token list for the given bundle
 */
+ (void)loadTokensFromBundle:(NSBundle *)bundle;

// MARK: - Block Operations

/**
 * Read a RCOL Block
 * @param blockId expected ID
 * @param reader the reader
 * @returns The read block or nil
 */
- (id<IRcolBlock>)readBlockWithId:(uint32_t)blockId reader:(BinaryReader *)reader;

/**
 * Write a RCOL Block
 * @param block The content of the Block
 * @param writer the writer
 */
- (void)writeBlock:(id<IRcolBlock>)block writer:(BinaryWriter *)writer;

// MARK: - Event Management

/**
 * Clear all TabPageChanged event handlers
 */
- (void)clearTabPageChanged;

/**
 * Child tab page changed handler
 */
- (void)childTabPageChanged:(id)sender;

@end
