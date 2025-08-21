//
//  ClstWrapper.h
//  MacSimpe
//
//  Created by Catherine Gramze on 7/27/25.
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
#import "MetaData.h"

// Forward declarations
@protocol IPackedFileDescriptor;
@protocol IPackageFile;
@class ClstItem;

/**
 * This is the actual FileWrapper for Compressed File Lists
 */
@interface CompressedFileList : AbstractWrapper <IFileWrapper, IFileWrapperSaveExtension>

// MARK: - Properties

/**
 * Returns or Sets the type of the Index
 */
@property (nonatomic, assign) IndexTypes indexType;

/**
 * Contains all available Items
 */
@property (nonatomic, strong) NSMutableArray<ClstItem *> *items;

// MARK: - Initialization

/**
 * Constructor
 */
- (instancetype)init;

/**
 * Constructor
 * @param type Size of the Package Index
 */
- (instancetype)initWithIndexType:(IndexTypes)type;

/**
 * Constructor, Initializes the Object with Data from the File
 * @param pfd The PackedFileDescriptor
 * @param package The Package File
 */
- (instancetype)initWithDescriptor:(id<IPackedFileDescriptor>)pfd package:(id<IPackageFile>)package;

// MARK: - Methods

/**
 * Returns the Number of the File matching the passed Descriptor
 * @param pfd A PackedFileDescriptor
 * @return -1 if none was found or the index number of the first matching file
 */
- (NSInteger)findFile:(id<IPackedFileDescriptor>)pfd;

/**
 * Clears all items
 */
- (void)clear;

/**
 * Adds a new File to the Items
 * @param item the new File
 */
- (void)add:(ClstItem *)item;

@end
