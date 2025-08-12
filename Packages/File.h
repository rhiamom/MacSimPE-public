///
//  File.h
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
// ***************************************************************************

#import <Foundation/Foundation.h>
#import "IPackageFile.h"

NS_ASSUME_NONNULL_BEGIN

// Forward declarations
@class BinaryReader;
@class HeaderData;
@class PackedFileDescriptor;
@class HoleIndexItem;
@class PackedFile;
@class PackedFileDescriptors;
@class GeneratableFile;
@class CompressedFileList;
@protocol IPackedFileDescriptor;
@protocol IPackedFile;
@protocol IPackageHeader;

/**
 * Was the package opened by using a Filename?
 */
typedef NS_ENUM(uint8_t, PackageBaseType) {
    PackageBaseTypeStream = 0x00,
    PackageBaseTypeFilename = 0x01
};

/**
 * Header of a .package File
 */
@interface File : NSObject <IPackageFile>

// MARK: - Constants

/**
 * The Type ID for CompressedFile Lists
 */
extern const uint32_t FILELIST_TYPE;

// MARK: - Properties
/**
 * The Binary reader that has opened the .Package file
 */
@property (nonatomic, readonly, nullable) BinaryReader *reader;

/**
 * true if you want to keep the FileHandle
 */
@property (nonatomic, assign) BOOL persistent;

/**
 * The Structural Data of the Header
 */
@property (nonatomic, strong, readonly) id<IPackageHeader> header;
/**
 * True if the User has changed a PackedFile
 */
@property (nonatomic, readonly) BOOL hasUserChanges;

/**
 * Returns or Changes the stored Fileindex
 */
@property (nonatomic, strong) PackedFileDescriptors *index;

/**
 * Returns or Changes the stored Filelist
 */
@property (nonatomic, strong, nullable) PackedFileDescriptor *fileList;

/**
 * Returns the FileListFile
 */
@property (nonatomic, readonly, nullable) CompressedFileList *fileListFile;

/**
 * The Name of the current File
 */
@property (nonatomic, strong, nullable) NSString *fileName;

/**
 * Returns the FileName of the Current Package for saving
 */
@property (nonatomic, readonly) NSString *saveFileName;

/**
 * Returns the hash Group Value for this File
 */
@property (nonatomic, readonly) uint32_t fileGroupHash;

/**
 * Returns the next free offset in the File
 */
@property (nonatomic, readonly) long long nextFreeOffset;

/**
 * true if the Compressed State for this package was loaded
 */
@property (nonatomic, readonly) BOOL loadedCompressedState;

// Manual property storage for events
@property (nonatomic, copy) void (^addedResource)(void);
@property (nonatomic, copy) void (^endedUpdate)(void);
@property (nonatomic, copy) void (^indexChanged)(void);
@property (nonatomic, copy) void (^removedResource)(void);
@property (nonatomic, copy) void (^savedIndex)(void);


// MARK: - Initialization

/**
 * Creates the Header Datastructure from a BinaryReader
 */
- (instancetype)initWithBinaryReader:(nullable BinaryReader *)br;

/**
 * Creates a new Object based on the given File
 */
- (instancetype)initWithFilename:(NSString *)filename;

// MARK: - Reader Management

- (void)reloadReader;
- (void)openReader;
- (void)closeReader;

// MARK: - File Operations

/**
 * Opens the Package File represented by a Stream
 */
- (void)openByStream:(nullable BinaryReader *)br;

/**
 * Reload the Data from the File
 */
- (void)reloadFromFile:(NSString *)filename;

- (void)reload;

- (void)clearFileIndex;

// MARK: - Stream Locking

- (void)lockStream;
- (void)unlockStream;

// MARK: - File Index Management

/**
 * Creates a new File descriptor
 */
- (id<IPackedFileDescriptor>)newDescriptorWithType:(uint32_t)type
                                           subtype:(uint32_t)subtype
                                             group:(uint32_t)group
                                          instance:(uint32_t)instance;

/**
 * Adds a new Descriptor to the Index
 */
- (void)addDescriptor:(id<IPackedFileDescriptor>)pfd;

/**
 * Adds a new Descriptor to the Index with type, subtype, group, instance
 */
- (id<IPackedFileDescriptor>)addDescriptorWithType:(uint32_t)type
                                           subtype:(uint32_t)subtype
                                             group:(uint32_t)group
                                          instance:(uint32_t)instance;

/**
 * Adds a new Descriptor to the Index
 */
- (void)addIsNewDescriptor:(id<IPackedFileDescriptor>)pfd isNew:(BOOL)isNew;

/**
 * Adds a list of Descriptors to the Index
 */
- (void)addDescriptors:(NSArray<id<IPackedFileDescriptor>> *)pfds;

/**
 * Removes the described File from the Index
 */
- (void)removeDescriptor:(id<IPackedFileDescriptor>)pfd;

/**
 * Removes all FileDescriptors that are marked for Deletion
 */
- (void)removeMarked;

/**
 * Returns the FileIndexItem for the given File
 */
- (nullable id<IPackedFileDescriptor>)getFileIndex:(uint32_t)item;

/**
 * Copies the FileDescriptors from the passed Package to this one
 */
- (void)copyDescriptors:(id<IPackageFile>)package;

// MARK: - Hole Index Management

/**
 * Returns the HoleIndexItem for the given File
 */
- (nullable HoleIndexItem *)getHoleIndex:(uint32_t)item;

// MARK: - File Reading

/**
 * Reads the File specified by the given itemIndex
 */
- (id<IPackedFile>)readAtIndex:(uint32_t)item;

/**
 * Reads a File specified by a FileIndexItem
 */
- (id<IPackedFile>)readDescriptor:(id<IPackedFileDescriptor>)pfd;

/**
 * Returns the Stream that holds the given Resource
 */
- (id<IPackedFile>)getStream:(id<IPackedFileDescriptor>)pfd;

// MARK: - File Search

/**
 * Returns a List of all Files matching the passed type
 */
- (NSArray<id<IPackedFileDescriptor>> *)findFiles:(uint32_t)type;

/**
 * Returns a List of all Files matching the passed group
 */
- (NSArray<id<IPackedFileDescriptor>> *)findFilesByGroup:(uint32_t)group;

/**
 * Returns all Files that could contain a RCOL with the passed Filename
 */
- (NSArray<id<IPackedFileDescriptor>> *)findFileByName:(NSString *)filename;

/**
 * Returns all Files that could contain a RCOL with the passed Filename and type
 */
- (NSArray<id<IPackedFileDescriptor>> *)findFileByName:(NSString *)filename type:(uint32_t)type;

/**
 * Returns files matching the specified parameters
 */
- (NSArray<id<IPackedFileDescriptor>> *)findFileWithSubtype:(uint32_t)subtype instance:(uint32_t)instance;

/**
 * Returns files matching the specified parameters
 */
- (NSArray<id<IPackedFileDescriptor>> *)findFileWithType:(uint32_t)type subtype:(uint32_t)subtype instance:(uint32_t)instance;

/**
 * Returns the first File matching the specified parameters
 */
- (nullable id<IPackedFileDescriptor>)findFileWithType:(uint32_t)type subtype:(uint32_t)subtype group:(uint32_t)group instance:(uint32_t)instance;

/**
 * Returns the first File matching the passed descriptor
 */
- (nullable id<IPackedFileDescriptor>)findFileMatchingDescriptor:(id<IPackedFileDescriptor>)pfd;

/**
 * Returns the exact File matching if it exists in the fileindex
 */
- (nullable id<IPackedFileDescriptor>)findExactFile:(id<IPackedFileDescriptor>)pfd;

/**
 * Returns the first File matching exactly
 */
- (nullable id<IPackedFileDescriptor>)findExactFileWithType:(uint32_t)type subtype:(uint32_t)subtype group:(uint32_t)group instance:(uint32_t)instance offset:(uint32_t)offset;

// MARK: - Compressed State Management

/**
 * Reads the Compressed State for the package
 */
- (void)loadCompressedState;

// MARK: - Cloning

/**
 * Create a Clone of this Package File
 */
- (id<IPackageFile>)clone;

// MARK: - Update Management

- (void)beginUpdate;
- (void)forgetUpdate;
- (void)endUpdate;

// MARK: - File Management

- (void)close;
- (void)closeWithTotal:(BOOL)total;

// MARK: - Saving (virtual methods - to be overridden)

- (void)save;
- (void)saveToFile:(NSString *)filename;

// MARK: - String Utilities

- (NSString *)charArrayToString:(NSArray<NSNumber *> *)array;

// MARK: - Static Factory Methods

/**
 * Create a new GeneratableFile
 */
+ (GeneratableFile *)loadFromFile:(NSString *)filename;

/**
 * Create a new GeneratableFile
 */
+ (GeneratableFile *)loadFromFile:(NSString *)filename sync:(BOOL)sync;

/**
 * Create a new File from stream
 */
+ (GeneratableFile *)loadFromStream:(nullable BinaryReader *)br;

/**
 * Creates a new Empty Package File
 */
+ (GeneratableFile *)createNew;

// MARK: - Events (to be implemented as needed)

- (void)resourceChanged:(id<IPackedFileDescriptor>)descriptor;

// These would typically be implemented as delegate patterns or notification center in Objective-C
// For now, marking as comments for future implementation

// @property (nonatomic, weak, nullable) id<PackageFileDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
