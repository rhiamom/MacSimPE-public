//
//  GeneratableFile.h
//  MacSimpe
//
//  Translated from GeneratableFile.cs
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
#import "ExtractableFile.h"

@class BinaryReader;
@class BinaryWriter;
@class PackedFileDescriptor;

/// Size of the Blocks written to the Filesystem
extern const uint32_t BLOCKSIZE;

/// Extends the Package Files with writing Support
/// Inherits from ExtractableFile -> File -> NSObject and implements IPackageFile
@interface GeneratableFile : ExtractableFile

// MARK: - Initialization

/// Constructor of the Class
/// @param br The BinaryReader representing the Package File
- (instancetype)initWithBinaryReader:(BinaryReader *)br;

/// Constructor of the Class
/// @param filename The filename to load
- (instancetype)initWithFilename:(NSString *)filename;

// MARK: - File Writing Capability

/// Checks if the passed File is writable by the System
/// @param filename The FileName
/// @param closeAfterCheck true if the file should be closed after checking
/// @returns true, if the File is writable
+ (BOOL)canWriteToFile:(NSString *)filename close:(BOOL)closeAfterCheck;

// MARK: - Saving

/// Stores the internal reader to the passed File (build() will be called!)
/// @param filename The Filename you want to save the Package to
/// @remarks This is Experimental and might not work properly
- (void)saveWithFilename:(NSString *)filename;

/// Reload the package from the specified file
/// @param filename The filename to reload from
- (void)reloadFromFile:(NSString *)filename;

// MARK: - Protected Methods

/// Returns the suggested name for a .bak File
/// @param filename the initial filename
/// @returns the suggested Backup Filename
- (NSString *)getBakFileName:(NSString *)filename;

/// Compiles a new Package File from the currently stored Information
/// @param data The data to save
/// @param filename Filename for the Package
- (void)saveData:(NSData *)data toFile:(NSString *)filename;

/// This is used to enable SimPe to add compressed Resources
- (void)prepareCompression;

/// Compiles a new Package File from the currently stored Information
/// @returns The NSData representing the new Package File
- (NSData *)build;

// MARK: - Index and Hole Writing

/// Writes the FileList to the Package File
/// @param writer The BinaryWriter to use
/// @param tmpIndex the index you want to write
/// @param tmpCompressed listing of the compression state for each packed File
- (void)writeFileListWithWriter:(BinaryWriter *)writer
                          index:(NSMutableArray<PackedFileDescriptor *> *)tmpIndex
                     compressed:(NSMutableArray<NSNumber *> *)tmpCompressed;

/// Writes the Index to the Package File
/// @param writer The BinaryWriter to use
/// @param tmpIndex the index you want to write
- (void)saveIndexWithWriter:(BinaryWriter *)writer index:(NSArray<id<IPackedFileDescriptor>> *)tmpIndex;

// MARK: - Factory Methods

/// Creates a new empty GeneratableFile
/// @returns A new GeneratableFile instance
+ (GeneratableFile *)createNew;

@end
