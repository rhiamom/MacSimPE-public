//
//  PackedFileWrapper.h
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
#import "AbstractWrapper.h"
#import "IFileWrapper.h"
#import "IFileWrapperSaveExtension.h"

@protocol IPackedFileDescriptor;
@class BinaryReader, BinaryWriter, MetaData;

/**
 * This is the actual FileWrapper for 3D Reference Files
 * @remarks The wrapper is used to (un)serialize the Data of a file into its Attributes.
 *          So basically it reads a BinaryStream and translates the data into some user-defined Attributes.
 */
@interface RefFile : AbstractWrapper <IFileWrapper, IFileWrapperSaveExtension>

// MARK: - Properties

/**
 * List of Stored References
 */
@property (nonatomic, strong) NSArray<id<IPackedFileDescriptor>> *items;

/**
 * ID of the File
 */
@property (nonatomic, readonly, assign) uint32_t fileId;

/**
 * Type of the File
 */
@property (nonatomic, readonly, assign) IndexTypes indexType;

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

@end

/**
 * Individual item within a RefFile
 */
@interface RefFileItem : NSObject <IPackedFileDescriptor>

/**
 * Reference to the parent RefFile
 */
@property (nonatomic, weak) RefFile *parent;

/**
 * File type
 */
@property (nonatomic, assign) uint32_t type;

/**
 * File group
 */
@property (nonatomic, assign) uint32_t group;

/**
 * File instance
 */
@property (nonatomic, assign) uint32_t instance;

/**
 * File subtype
 */
@property (nonatomic, assign) uint32_t subType;

/**
 * Initialize with parent RefFile
 * @param parent The parent RefFile
 */
- (instancetype)initWithParent:(RefFile *)parent;

@end
