//
//  FileIndexItem.h
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
// ***************************************************************************

#import <Foundation/Foundation.h>
#import "IScenegraphFileIndexItem.h"

@protocol IPackedFileDescriptor;
@protocol IPackageFile;

/**
 * This is a Item describing the File
 */
@interface FileIndexItem : NSObject <IScenegraphFileIndexItem>

// MARK: - IScenegraphFileIndexItem Protocol Conformance
@property (nonatomic, strong) id<IScenegraphFileIndexItem> resource;
@property (nonatomic, readonly) uint32_t type;
@property (nonatomic, readonly) uint32_t group;
@property (nonatomic, readonly) uint32_t instance;
@property (nonatomic, readonly) uint64_t longInstance;
@property (nonatomic, readonly, copy) NSString *filename;

// MARK: - File Properties
/**
 * The Descriptor of that File
 * Contains the original Group (can be 0xffffffff)
 */
@property (nonatomic, strong) id<IPackedFileDescriptor> fileDescriptor;

/**
 * The package the File is stored in
 */
@property (nonatomic, strong, readonly) id<IPackageFile> package;

/**
 * Get the Local Group value used for this Package
 */
@property (nonatomic, readonly) uint32_t localGroup;

@property (nonatomic, readonly, copy) NSString *fiiDescription;

// MARK: - Initialization
- (instancetype)initWithDescriptor:(id<IPackedFileDescriptor>)descriptor
                           package:(id<IPackageFile>)package;

// MARK: - Methods
/**
 * The Descriptor of that File, with a real Group value
 * Contains the local Group (can never be 0xffffffff)
 */
- (id<IPackedFileDescriptor>)getLocalFileDescriptor;

/**
 * Returns a String that can identify this Instance
 */
- (NSString *)getLongHashCode;

/**
 * Return the suggested local Group for the passed package
 */
+ (uint32_t)getLocalGroup:(id<IPackageFile>)package;

/**
 * Return the suggested local Group for the passed filename
 */
+ (uint32_t)getLocalGroupForFilename:(NSString *)filename;

@end

// MARK: - FileIndexItems

/**
 * Typesafe Array for FileIndexItem Objects
 */
@interface FileIndexItems : NSMutableArray

- (FileIndexItem *)objectAtIndexedSubscript:(NSUInteger)index;
- (void)setObject:(FileIndexItem *)object atIndexedSubscript:(NSUInteger)index;

- (NSInteger)addItem:(FileIndexItem *)item;
- (void)insertItem:(FileIndexItem *)item atIndex:(NSUInteger)index;
- (void)removeItem:(FileIndexItem *)item;
- (BOOL)containsItem:(FileIndexItem *)item;
- (void)sortItems;

@property (nonatomic, readonly) NSInteger length;

@end
