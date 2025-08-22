//
//  PackedFileitem.h
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
// ***************************************************************************/

#import <Foundation/Foundation.h>
#import "PackedFileDescriptor.h"

@class Cpf, RefFile, GenericRcol, MaterialDefinition;
@protocol IPackedFileDescriptor, IScenegraphFileIndexItem, IPackageFile;

/**
 * Represents a skin/clothing chain with associated properties
 */
@interface SkinChain : NSObject

// MARK: - Properties

/**
 * The CPF file containing the skin data
 */
@property (nonatomic, strong, readonly) Cpf *cpf;

/**
 * Category of the skin/clothing
 */
@property (nonatomic, readonly, assign) uint32_t category;

/**
 * Age restrictions for the skin/clothing
 */
@property (nonatomic, readonly, assign) uint32_t age;

/**
 * Name of the skin/clothing
 */
@property (nonatomic, readonly, copy) NSString *name;

/**
 * Reference file containing 3D data
 */
@property (nonatomic, readonly, strong) RefFile *referenceFile;

/**
 * Array of TXMT (Texture Material) files
 */
@property (nonatomic, readonly, strong) NSArray<GenericRcol *> *txmts;

/**
 * Array of TXTR (Texture) files
 */
@property (nonatomic, readonly, strong) NSArray<GenericRcol *> *txtrs;

/**
 * Primary TXMT file
 */
@property (nonatomic, readonly, strong) GenericRcol *txmt;

/**
 * Primary TXTR file
 */
@property (nonatomic, readonly, strong) GenericRcol *txtr;

/**
 * Human-readable category names
 */
@property (nonatomic, readonly, copy) NSString *categoryNames;

/**
 * Human-readable age names
 */
@property (nonatomic, readonly, copy) NSString *ageNames;

// MARK: - Initialization

/**
 * Initialize with CPF file
 * @param cpf The CPF file containing skin data
 */
- (instancetype)initWithCpf:(Cpf *)cpf;

// MARK: - Helper Methods

/**
 * Load an RCOL file of specified type
 * @param type The file type to load
 * @param descriptor The file descriptor
 * @return The loaded GenericRcol or nil
 */
- (GenericRcol *)loadRcol:(uint32_t)type descriptor:(id<IPackedFileDescriptor>)descriptor;

/**
 * Load TXTR file associated with a TXMT
 * @param txmt The TXMT file to find texture for
 * @return The associated TXTR file or nil
 */
- (GenericRcol *)loadTXTR:(GenericRcol *)txmt;

@end

/**
 * A Item in a 3IDR File
 */
@interface RefFileItem : PackedFileDescriptor

// MARK: - Properties

/**
 * Parent RefFile
 */
@property (nonatomic, weak) RefFile *parent;

/**
 * Associated skin chain data
 */
@property (nonatomic, strong) SkinChain *skin;

// MARK: - Initialization

/**
 * Initialize with parent RefFile
 * @param parent The parent RefFile
 */
- (instancetype)initWithParent:(RefFile *)parent;

/**
 * Initialize with file descriptor and parent
 * @param descriptor The file descriptor to copy data from
 * @param parent The parent RefFile
 */
- (instancetype)initWithDescriptor:(id<IPackedFileDescriptor>)descriptor parent:(RefFile *)parent;

@end

/**
 * Internal list item for CPF files
 */
@interface CpfListItem : SkinChain

// MARK: - Properties

/**
 * The CPF file
 */
@property (nonatomic, readonly, strong) Cpf *file;

// MARK: - Initialization

/**
 * Initialize with CPF file
 * @param cpf The CPF file
 */
- (instancetype)initWithCpf:(Cpf *)cpf;

@end
