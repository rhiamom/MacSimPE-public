//
//  IPackageFile.h
//  MacSimpe
//
//  Created by Catherine Gramze on 7/25/25.
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

@protocol IPackedFileDescriptor;
@protocol IPackageHeader;
@protocol IPackedFile;
@class BinaryReader;
@class PackedFileDescriptors;

/**
 * Interface for PackageFile Classes
 */
@protocol IPackageFile <NSObject>

#pragma mark - Properties

/**
 * Returns the File Reader
 */
@property (nonatomic, readonly) BinaryReader *reader;

/**
 * Set/returns the Persistent state of this Package
 * @remarks If persistent the FileHandle won't be closed!
 */
@property (nonatomic, assign) BOOL persistent;

/**
 * Returns or Changes the stored Fileindex
 */
@property (nonatomic, readonly) PackedFileDescriptors *index;

/**
 * The Structural Data of the Header
 */
@property (nonatomic, readonly) id<IPackageHeader> header;

/**
 * True if the User has changed a PackedFile
 */
@property (nonatomic, readonly) BOOL hasUserChanges;

/**
 * Returns the FileName of the Current Package
 * @remarks Can be null if a Memory stream was opened as package
 */
@property (nonatomic, readonly) NSString *fileName;

/**
 * Returns the FileName of the Current Package
 * @remarks Will never return null
 */
@property (nonatomic, readonly) NSString *saveFileName;

/**
 * Returns the hash Group Value for this File
 */
@property (nonatomic, readonly) uint32_t fileGroupHash;

#pragma mark - Methods

/**
 * Create a Clone of this Package File
 * @returns the new Package File
 */
- (id<IPackageFile>)clone;

#pragma mark - FileIndex Handling

/**
 * Returns the FileIndexItem for the given File
 * @param index Number of the File within the FileIndex (0-Based)
 * @returns The FileIndexItem for this Entry, or null if the index was over limit
 */
- (id<IPackedFileDescriptor>)getFileIndex:(uint32_t)index;

/**
 * Removes the described File from the Index
 * @param pfd A Packed File Descriptor
 */
- (void)remove:(id<IPackedFileDescriptor>)pfd;

/**
 * Removes all FileDescriptors that are marked for Deletion
 */
- (void)removeMarked;

/**
 * Adds a list of Descriptors to the Index
 * @param pfds Array of Descriptors
 */
- (void)addDescriptors:(NSArray<id<IPackedFileDescriptor>> *)pfds;

/**
 * Adds a new Descriptor to the Index
 * @param type The Type of the new File
 * @param subtype The SubType/classID/ResourceID of the new File
 * @param group The Group for the File
 * @param instance The Instance of the File
 * @returns The created PackedFileDescriptor
 */
- (id<IPackedFileDescriptor>)addWithType:(uint32_t)type
                                 subtype:(uint32_t)subtype
                                   group:(uint32_t)group
                                instance:(uint32_t)instance;

/**
 * Adds a new Descriptor to the Index
 * @param pfd The PackedFile Descriptor
 */
- (void)addDescriptor:(id<IPackedFileDescriptor>)pfd;

/**
 * Adds a new Descriptor to the Index
 * @param pfd The PackedFile Descriptor
 * @param isNew true, if offset should be set a unique Value
 */
- (void)addDescriptor:(id<IPackedFileDescriptor>)pfd isNew:(BOOL)isNew;

/**
 * Copies the FileDescriptors from the passed Package to this one. The Method creates
 * a Clone for each Descriptor, and read its Userdata from the original package.
 * @param package The package that should get copied into this one
 */
- (void)copyDescriptors:(id<IPackageFile>)package;

/**
 * Creates a new File descriptor
 * @param type The Type of the new File
 * @param subtype The SubType/classID/ResourceID of the new File
 * @param group The Group for the File
 * @param instance The Instance of the File
 * @returns the new File descriptor
 */
- (id<IPackedFileDescriptor>)newDescriptorWithType:(uint32_t)type
                                            subtype:(uint32_t)subtype
                                              group:(uint32_t)group
                                           instance:(uint32_t)instance;

#pragma mark - Find Files

/**
 * Returns all Files that could contain a RCOL with the passed Filename
 * @param filename The Filename you are looking for
 * @returns Array of matching Files
 */
- (NSArray<id<IPackedFileDescriptor>> *)findFile:(NSString *)filename;

/**
 * Returns all Files that could contain a RCOL with the passed Filename
 * @param filename The Filename you are looking for
 * @param type The type to filter by
 * @returns Array of matching Files
 */
- (NSArray<id<IPackedFileDescriptor>> *)findFileByName:(NSString *)filename type:(uint32_t)type;

/**
 * Returns a List of all Files matching the passed type
 * @param type Type you want to look for
 * @returns An Array of Files
 */
- (NSArray<id<IPackedFileDescriptor>> *)findFiles:(uint32_t)type;

/**
 * Returns Files matching subtype and instance
 * @param subtype SubType you want to look for
 * @param instance Instance you want to look for
 * @returns Array of descriptors for matching Files
 */
- (NSArray<id<IPackedFileDescriptor>> *)findFileWithSubtype:(uint32_t)subtype
                                                   instance:(uint32_t)instance;

/**
 * Returns Files matching type, subtype and instance
 * @param type Type you want to look for
 * @param subtype SubType you want to look for
 * @param instance Instance you want to look for
 * @returns Array of descriptors for matching Files
 */
- (NSArray<id<IPackedFileDescriptor>> *)findFileWithType:(uint32_t)type
                                                 subtype:(uint32_t)subtype
                                                instance:(uint32_t)instance;

/**
 * Returns the first File matching the descriptor
 * @param pfd Descriptor you want to look for
 * @returns The descriptor for the matching File or null
 */
- (id<IPackedFileDescriptor>)findFileWithDescriptor:(id<IPackedFileDescriptor>)pfd;

/**
 * Returns the first File matching
 * @param type Type you want to look for
 * @param subtype SubType you want to look for
 * @param group Group you want to look for
 * @param instance Instance you want to look for
 * @returns The descriptor for the matching File or null
 */
- (id<IPackedFileDescriptor>)findFileWithType:(uint32_t)type
                                      subtype:(uint32_t)subtype
                                        group:(uint32_t)group
                                     instance:(uint32_t)instance;

/**
 * Returns the first File exactly matching the descriptor
 * @param pfd Descriptor you want to look for
 * @returns The descriptor for the matching File or null
 */
- (id<IPackedFileDescriptor>)findExactFile:(id<IPackedFileDescriptor>)pfd;

/**
 * Returns the first File exactly matching
 * @param type Type you want to look for
 * @param subtype SubType you want to look for
 * @param group Group you want to look for
 * @param instance Instance you want to look for
 * @param offset Offset you want to look for
 * @returns The descriptor for the matching File or null
 */
- (id<IPackedFileDescriptor>)findExactFileWithType:(uint32_t)type
                                           subtype:(uint32_t)subtype
                                             group:(uint32_t)group
                                          instance:(uint32_t)instance
                                            offset:(uint32_t)offset;

/**
 * Returns a List of all Files matching the passed group
 * @param group Group you want to look for
 * @returns An Array of Files
 */
- (NSArray<id<IPackedFileDescriptor>> *)findFilesByGroup:(uint32_t)group;

#pragma mark - File Handling

/**
 * Reads the File specified by the given itemIndex
 * @param item the itemIndex for the File
 * @returns The plain Content of the File
 */
- (id<IPackedFile>)read:(uint32_t)item;

/**
 * Reads a File specified by a FileIndexItem
 * @param pfd The PackedFileDescriptor
 * @returns The plain Content of the File
 */
- (id<IPackedFile>)readDescriptor:(id<IPackedFileDescriptor>)pfd;

/**
 * Returns the Stream that holds the given Resource
 * @param pfd The PackedFileDescriptor
 * @returns The PackedFile containing Stream Infos
 */
- (id<IPackedFile>)getStream:(id<IPackedFileDescriptor>)pfd;

#pragma mark - File Operations

/**
 * Close this Instance, leaving the FileDescriptors valid
 */
- (void)close;

/**
 * Close this Instance
 * @param total true, if the FileDescriptors should be marked invalid
 */
- (void)closeWithTotal:(BOOL)total;

- (void)save;
- (void)saveWithFilename:(NSString *)filename;

#pragma mark - Events

/**
 * Defers DescriptionChanged and ChangedData for all stored Descriptors
 * until endUpdate is called
 */
- (void)beginUpdate;

/**
 * Makes the package forget all pending Updates!
 */
- (void)forgetUpdate;

/**
 * Executes Events Deferred by beginUpdate
 */
- (void)endUpdate;

// Events as block properties
@property (nonatomic, copy) void (^endedUpdate)(void);
@property (nonatomic, copy) void (^addedResource)(void);
@property (nonatomic, copy) void (^removedResource)(void);
@property (nonatomic, copy) void (^indexChanged)(void);
@property (nonatomic, copy) void (^savedIndex)(void);

@end
