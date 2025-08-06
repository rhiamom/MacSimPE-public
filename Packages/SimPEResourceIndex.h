//
//  ResourceIndex.h
//  MacSimpe
//
//  Created by Catherine Gramze on 7/30/25.
//
//
//  ResourceIndex.h
//  MacSimpe
//
//  Created by Catherine Gramze on 7/30/25.
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

@protocol IPackageFile;
@protocol IPackedFileDescriptor;
@class PackedFileDescriptors;

/**
 * This class contains an Index of all found Files
 * Hashtable (FileType) contains a Hashtable (Group) of Hashtables (Instance) of ArrayLists (colliding Files)
 */
@interface ResourceIndex : NSObject

// MARK: - Properties

/**
 * Returns the next free offset in the File
 */
@property (nonatomic, assign, readonly) uint32_t nextFreeOffset;

/**
 * Indicates if this is a flat index (no hierarchical structure)
 */
@property (nonatomic, assign, readonly) BOOL flat;

/**
 * Returns the count of all indexed files
 */
@property (nonatomic, assign, readonly) NSInteger count;

// MARK: - Initialization

/**
 * Create a new Instance
 * Same as calling initWithPackageFile:flat:capacity: with flat=NO
 */
- (instancetype)initWithPackageFile:(id<IPackageFile>)packageFile capacity:(NSInteger)capacity;

/**
 * Create a new Instance
 */
- (instancetype)initWithPackageFile:(id<IPackageFile>)packageFile
                               flat:(BOOL)flat
                           capacity:(NSInteger)capacity;

// MARK: - Index Management

/**
 * Creates a clone of this Object
 */
- (ResourceIndex *)clone;

/**
 * Return a flat list of all stored pfds
 */
- (PackedFileDescriptors *)flatten;

/**
 * Clear the index
 */
- (void)clear;

/**
 * Clear the index with option to preserve pfds
 */
- (void)clearWithFull:(BOOL)full;

// MARK: - Finding Files

/**
 * Returns all matching FileIndexItems
 */
- (PackedFileDescriptors *)findFile:(id<IPackedFileDescriptor>)pfd;

/**
 * Returns all matching FileIndexItems for the passed type
 */
- (PackedFileDescriptors *)findFileByType:(uint32_t)type;

/**
 * Returns all matching FileIndexItems for type and group
 */
- (PackedFileDescriptors *)findFileByType:(uint32_t)type group:(uint32_t)group;

/**
 * Returns all matching FileIndexItems for type, group, and instance
 */
- (PackedFileDescriptors *)findFileByType:(uint32_t)type
                                    group:(uint32_t)group
                                 instance:(uint64_t)instance;

/**
 * Returns all matching FileIndexItems for type, group, subtype, and instance
 */
- (PackedFileDescriptors *)findFileByType:(uint32_t)type
                                    group:(uint32_t)group
                                  subtype:(uint32_t)subtype
                                 instance:(uint32_t)instance;

/**
 * Returns all matching FileIndexItems while ignoring the Group
 */
- (PackedFileDescriptors *)findFileDiscardingGroup:(id<IPackedFileDescriptor>)pfd;

/**
 * Returns all matching FileIndexItems while ignoring the Group
 */
- (PackedFileDescriptors *)findFileDiscardingGroupByType:(uint32_t)type
                                                instance:(uint64_t)instance;

/**
 * Return all matching FileIndexItems by Instance
 */
- (PackedFileDescriptors *)findFileByInstance:(uint64_t)instance;

/**
 * Return all matching FileIndexItems by subtype and instance
 */
- (PackedFileDescriptors *)findFileBySubtype:(uint32_t)subtype
                                    instance:(uint32_t)instance;

/**
 * Return all matching FileIndexItems by type and instance
 */
- (PackedFileDescriptors *)findFileByType:(uint32_t)type
                                 instance:(uint64_t)instance;

/**
 * Return all matching FileIndexItems by type, subtype, and instance
 */
- (PackedFileDescriptors *)findFileByType:(uint32_t)type
                                  subtype:(uint32_t)subtype
                                 instance:(uint32_t)instance;

/**
 * Return all matching FileIndexItems by group and instance
 */
- (PackedFileDescriptors *)findFileByGroup:(uint32_t)group
                                  instance:(uint64_t)instance;

/**
 * Return all matching FileIndexItems by group
 */
- (PackedFileDescriptors *)findFileByGroup:(uint32_t)group;

/**
 * Looks for a File based on the FileDescriptor
 */
- (id<IPackedFileDescriptor>)findSingleFile:(id<IPackedFileDescriptor>)pfd
                                 beTolerant:(BOOL)beTolerant;

// MARK: - Internal Methods (for package management)

/**
 * Add a FileDescriptor to the Index
 */
- (void)addIndexFromPfd:(id<IPackedFileDescriptor>)pfd;

/**
 * Add FileDescriptors to the Index
 */
- (void)addIndexFromPfds:(PackedFileDescriptors *)pfds;

/**
 * Removes an Item from the Table
 */
- (void)removeItem:(id<IPackedFileDescriptor>)pfd;

/**
 * Removes items marked for deletion
 */
- (PackedFileDescriptors *)removeDeleteMarkedItems;

/**
 * Remove changed items (internal use)
 */
- (void)removeChanged:(id<IPackedFileDescriptor>)pfd;

@end
#ifndef ResourceIndex_h
#define ResourceIndex_h


#endif /* ResourceIndex_h */
