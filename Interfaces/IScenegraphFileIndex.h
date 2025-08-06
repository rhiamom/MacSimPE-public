//
//  IScenegraphFileIndex.h
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

@class FileTableItem;
@protocol IPackageFile;
@protocol IPackedFileDescriptor; 
@protocol IScenegraphFileIndexItem;

// MARK: - Notifications

extern NSString * const ScenegraphFileIndexDidLoadNotification;

/**
 * This is a Index over all Files found in all Packages
 */
@protocol IScenegraphFileIndex <NSObject>

// MARK: - Properties

/**
 * Returns the List of all Folders this FileIndex is processing
 */
@property (nonatomic, strong) NSMutableArray<FileTableItem *> *baseFolders;

/**
 * Returns true, if the FileTable is Loaded
 */
@property (nonatomic, readonly) BOOL loaded;

// MARK: - Core Management

/**
 * Creates a clone of this Object
 */
- (id<IScenegraphFileIndex>)clone;

/**
 * Make sure the FileTable is empty
 */
- (void)clear;

/**
 * Forces a Reload of the FileIndex
 * Use load if you want to make sure that the FileIndex is available,
 * use forceReload if you want to reload the FileIndex (for example, because the Files changed)
 */
- (void)forceReload;

/**
 * Load the FileIndex if it is not available yet
 * Use load if you want to make sure that the FileIndex is available,
 * use forceReload if you want to reload the FileIndex (for example, because the Files changed)
 */
- (void)load;

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
- (void)addIndexFromFolderPath:(NSString *)path;

/**
 * Add all Files stored in the passed package
 * Updates the WaitingScreen Message
 */
- (void)addIndexFromPackageFile:(NSString *)filename;

/**
 * Add all Files stored in the passed package
 */
- (void)addIndexFromPackage:(id<IPackageFile>)package;

/**
 * Add all Files stored in the passed package
 * @param package The package File
 * @param overwrite true, if the file should be added even if it already a Part of the FileIndex
 */
- (void)addIndexFromPackage:(id<IPackageFile>)package overwrite:(BOOL)overwrite;

/**
 * Add all Files stored in the passed package for specific type
 * @param package The package File
 * @param type Resources of this Type will get added
 * @param overwrite true, if an existing Instance of that File should be overwritten
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
 * @param descriptor The Descriptor
 * @param package The File
 * @param localGroup use this group as replacement for 0xffffffff
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
 * Remove the trace of a Package from the FileTable
 */
- (void)closePackage:(id<IPackageFile>)package;

/**
 * Clears the FileTable, and Closes all packages it did refer to
 */
- (void)closeAssignedPackages;

// MARK: - File Finding

/**
 * Return all matching FileIndexItems
 */
- (NSArray<id<IScenegraphFileIndexItem>> *)findFile:(id<IPackedFileDescriptor>)descriptor
                                            package:(id<IPackageFile>)package;

/**
 * Returns all matching FileIndexItems for the passed type
 * @param type the Type of the Files
 * @param noLocal true, if you don't want to get local Files (group=0xffffffff) returned
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
 * Returns all matching FileIndexItems for the passed type, group and instance (discarding high instance)
 */
- (NSArray<id<IScenegraphFileIndexItem>> *)findFileDiscardingHighInstanceWithType:(uint32_t)type
                                                                             group:(uint32_t)group
                                                                          instance:(uint32_t)instance
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
 * @param filename The name of the File (applies only to Scenegraph Resources)
 * @param type The Type of the File you are looking for
 * @param defGroup If the Filename has no group Hash, use this one
 * @param beTolerant set true if you want to enable a fallback Algorithm in case of the precise Search failing
 * @returns The first matching File or nil if none
 */
- (id<IScenegraphFileIndexItem>)findFileByName:(NSString *)filename
                                          type:(uint32_t)type
                                      defGroup:(uint32_t)defGroup
                                    beTolerant:(BOOL)beTolerant;

/**
 * Looks for a File based on the FileDescriptor
 * @param descriptor The FileDescriptor
 * @param package The package to search in
 * @param beTolerant set true if you want to enable a fallback Algorithm in case of the precise Search failing
 * @returns The first matching File or nil if none
 */
- (id<IScenegraphFileIndexItem>)findSingleFile:(id<IPackedFileDescriptor>)descriptor
                                       package:(id<IPackageFile>)package
                                    beTolerant:(BOOL)beTolerant;

/**
 * Sort the Files in this type ascending by instance value
 */
- (NSArray<id<IScenegraphFileIndexItem>> *)sort:(NSArray<id<IScenegraphFileIndexItem>> *)files;

// MARK: - Factory Methods

/**
 * Creates a new FileIndexItem
 */
- (id<IScenegraphFileIndexItem>)createFileIndexItem:(id<IPackedFileDescriptor>)descriptor
                                            package:(id<IPackageFile>)package;

// MARK: - FileTable Children

/**
 * True, if this Package was already added to the FileTable (or one of its Children)
 */
- (BOOL)containsPackage:(id<IPackageFile>)package;

/**
 * True, if this File was already added to the FileTable (or one of its Children)
 */
- (BOOL)contains:(NSString *)filename;

/**
 * True if the Path was already added as a whole to the FileTable (or one of its Children)
 */
- (BOOL)containsPath:(NSString *)path;

/**
 * Creates a new FileIndex, adds it as a Child, and returns the new Instance
 * @returns A new, empty FileIndex
 */
- (id<IScenegraphFileIndex>)addNewChild;

/**
 * Add a new FileIndex as a Child.
 * @param child The Child Index
 * @note Make sure, that you do not create circular dependencies! When
 * searching Resources, all Child FileTables will get searched too, so
 * keep the list small, otherwise you might increase search time!
 */
- (void)addChild:(id<IScenegraphFileIndex>)child;

/**
 * Remove all Children from this Instance
 */
- (void)clearChildren;

/**
 * Remove the passed Child from the list of Children
 */
- (void)removeChild:(id<IScenegraphFileIndex>)child;

// MARK: - Utility Methods

/**
 * Used to Debug the FileTable
 */
- (void)writeContentToConsole;

/**
 * Recreates the List of added Filenames
 */
- (void)updateListOfAddedFilenames;

@end
