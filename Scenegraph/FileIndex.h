//
//  FileIndex.h
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
#import "IScenegraphFileIndex.h"
#import "Thread.h"

@class FileTableItem;
@class FileIndexItem;
@protocol IPackageFile;
@protocol IPackedFileDescriptor;
@protocol IScenegraphFileIndexItem;

// MARK: - Notifications

extern NSString * const FileIndexDidLoadNotification;

// MARK: - FileIndex

/**
 * This class contains a Index of all found Files
 */
@interface FileIndex : StoppableThread <IScenegraphFileIndex>

// MARK: - Properties

/**
 * true if you want to have duplicate TGI's available
 */
@property (nonatomic, assign) BOOL duplicates;

/**
 * Returns true if the FileIndex has been loaded
 */
@property (nonatomic, readonly) BOOL loaded;

/**
 * Returns the List of all Folders this FileIndex is processing
 */
@property (nonatomic, strong) NSMutableArray<FileTableItem *> *baseFolders;

// MARK: - Static Properties

/**
 * Contains a Mapping from a Filename to a local Group
 */
@property (class, nonatomic, strong, readonly) NSMutableDictionary<NSString *, NSNumber *> *localGroupMap;

/**
 * Contains a Listing of all alternate Groups SimPE should check if the first try was no success
 */
@property (class, nonatomic, strong, readonly) NSMutableArray<NSNumber *> *alternativeGroups;

// MARK: - Initialization

/**
 * Create a new Instance
 * Same as a call to initWithFolders:nil
 */
- (instancetype)init;

/**
 * Create a new Instance
 * @param folders The Folders where you want to look for packages, nil for the default Set
 * The Default set is read from the Folder.xml File
 */
- (instancetype)initWithFolders:(NSMutableArray<FileTableItem *> *)folders;

// MARK: - Static Methods

/**
 * Return the suggested local Group for the passed package
 */
+ (uint32_t)getLocalGroup:(id<IPackageFile>)package;

/**
 * Return the suggested local Group for the passed filename
 */
+ (uint32_t)getLocalGroupForFilename:(NSString *)filename;

// MARK: - Loading

/**
 * Load the FileIndex if it has not previously been loaded and not in LocalMode
 * Use forceReload to reload if previously load (for example, because the files changed) or to override LocalMode.
 */
- (void)load;

/**
 * Load the FileIndex whether or not it has previously been loaded or in LocalMode
 * Use load to only load if not yet loaded and not in LocalMode.
 */
- (void)forceReload;

// MARK: - State Management

/**
 * Stores the current State of the FileIndex.
 * You can revert to the last stored state by calling restoreLastState
 */
- (void)storeCurrentState;

/**
 * Restores the last stored state (if one is available)
 */
- (void)restoreLastState;

// MARK: - Adding Content

/**
 * Add all Files stored in all the packages found in the passed Folder
 */
- (void)addIndexFromFolder:(FileTableItem *)item;

/**
 * Add all Files stored in all the packages found in the passed Folder
 */
- (void)addIndexFromFolderPath:(NSString *)path;

/**
 * Add all Files stored in the passed package
 */
- (void)addIndexFromPackageFile:(NSString *)filename;

/**
 * Add all Files stored in the passed package
 */
- (void)addIndexFromPackage:(id<IPackageFile>)package;

/**
 * Add all Files stored in the passed package
 */
- (void)addIndexFromPackage:(id<IPackageFile>)package overwrite:(BOOL)overwrite;

/**
 * Add all Files stored in the passed package for specific type
 */
- (void)addTypesIndexFromPackage:(id<IPackageFile>)package
                            type:(uint32_t)type
                       overwrite:(BOOL)overwrite;

/**
 * Add a FileDescriptor to the Index
 */
- (void)addIndexFromDescriptor:(id<IPackedFileDescriptor>)descriptor
                       package:(id<IPackageFile>)package;

/**
 * Add a FileDescriptor to the Index
 */
- (void)addIndexFromDescriptor:(id<IPackedFileDescriptor>)descriptor
                       package:(id<IPackageFile>)package
                    localGroup:(uint32_t)localGroup;

// MARK: - Removing Content

/**
 * Removes an Item from the Table
 */
- (void)removeItem:(id<IScenegraphFileIndexItem>)item;

/**
 * Make sure the FileTable is empty
 */
- (void)clear;

/**
 * Remove the trace of a Package from the FileTable
 */
- (void)closePackage:(id<IPackageFile>)package;

/**
 * Clear Table and close all assigned Packages
 */
- (void)closeAssignedPackages;

// MARK: - File Finding

/**
 * Returns all matching FileIndexItems
 */
- (NSArray<id<IScenegraphFileIndexItem>> *)findFile:(id<IPackedFileDescriptor>)descriptor
                                            package:(id<IPackageFile>)package;

/**
 * Returns all matching FileIndexItems for the passed type
 */
- (NSArray<id<IScenegraphFileIndexItem>> *)findFileWithType:(uint32_t)type
                                                    noLocal:(BOOL)noLocal;

/**
 * Returns all matching FileIndexItems for the passed type and group
 */
- (NSArray<id<IScenegraphFileIndexItem>> *)findFileWithType:(uint32_t)type
                                                      group:(uint32_t)group;

/**
 * Returns all matching FileIndexItems for the passed type, group and instance
 */
- (NSArray<id<IScenegraphFileIndexItem>> *)findFileWithType:(uint32_t)type
                                                      group:(uint32_t)group
                                                   instance:(uint64_t)instance
                                                    package:(id<IPackageFile>)package;

/**
 * Returns all matching FileIndexItems while Ignoring the Group
 */
- (NSArray<id<IScenegraphFileIndexItem>> *)findFileDiscardingGroup:(id<IPackedFileDescriptor>)descriptor;

/**
 * Returns all matching FileIndexItems for the passed type and instance (ignoring group)
 */
- (NSArray<id<IScenegraphFileIndexItem>> *)findFileDiscardingGroupWithType:(uint32_t)type
                                                                   instance:(uint64_t)instance;

/**
 * Returns all matching FileIndexItems discarding high instance
 */
- (NSArray<id<IScenegraphFileIndexItem>> *)findFileDiscardingHighInstanceWithType:(uint32_t)type
                                                                             group:(uint32_t)group
                                                                          instance:(uint32_t)instance
                                                                           package:(id<IPackageFile>)package;

/**
 * Return all matching FileIndexItems (by Instance)
 */
- (NSArray<id<IScenegraphFileIndexItem>> *)findFileByInstance:(uint64_t)instance;

/**
 * Return all matching FileIndexItems (by Group and Instance)
 */
- (NSArray<id<IScenegraphFileIndexItem>> *)findFileByGroup:(uint32_t)group
                                                  instance:(uint64_t)instance;

/**
 * Return all matching FileIndexItems (by Group)
 */
- (NSArray<id<IScenegraphFileIndexItem>> *)findFileByGroup:(uint32_t)group;

/**
 * Looks for a File based on the Filename
 */
- (id<IScenegraphFileIndexItem>)findFileByName:(NSString *)filename
                                          type:(uint32_t)type
                                      defGroup:(uint32_t)defGroup
                                    beTolerant:(BOOL)beTolerant;

/**
 * Looks for a File based on the FileDescriptor
 */
- (id<IScenegraphFileIndexItem>)findSingleFile:(id<IPackedFileDescriptor>)descriptor
                                       package:(id<IPackageFile>)package
                                    beTolerant:(BOOL)beTolerant;

// MARK: - Utility Methods

/**
 * Sort the Files in this type ascending by instance value
 */
- (NSArray<id<IScenegraphFileIndexItem>> *)sort:(NSArray<id<IScenegraphFileIndexItem>> *)files;

/**
 * Creates a new FileIndexItem
 */
- (id<IScenegraphFileIndexItem>)createFileIndexItem:(id<IPackedFileDescriptor>)descriptor
                                            package:(id<IPackageFile>)package;

/**
 * Creates a new FileIndex
 */
- (id<IScenegraphFileIndex>)createFileIndex:(NSArray<id<IPackedFileDescriptor>> *)descriptors
                                    package:(id<IPackageFile>)package;

/**
 * Update list of added filenames
 */
- (void)updateListOfAddedFilenames;

// MARK: - Debug Methods

#ifdef DEBUG
/**
 * Just for Debugging
 */
@property (nonatomic, readonly) NSMutableArray<NSString *> *storedFiles;

/**
 * Write content to console (debug)
 */
- (void)writeContentToConsole;
#endif

@end
