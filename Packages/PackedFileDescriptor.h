//
//  PackedFileDescriptor.h
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
#import "PackedFileDescriptorSimple.h"
#import "IPackedFileDescriptor.h"
#import "TypeAlias.h"

@protocol IPackageHeader;
@class BinaryReader;
@class PackedFile;

// Use the existing PackedFileChanged typedef if it exists, or check if we need a different name

@interface PackedFileDescriptor : PackedFileDescriptorSimple <IPackedFileDescriptor>

// MARK: - Properties

/// Location of the File within the Package
@property (nonatomic, assign) uint32_t offset;

/// Size of the compressed File
@property (nonatomic, assign) int size;

/// Returns the Size of the File (considering UserData)
@property (nonatomic, readonly) int fileSize;

/// Returns the size stored in the index
@property (nonatomic, readonly) int indexedSize;

/// Returns the Long Instance (Combination of SubType and Instance)
@property (nonatomic, assign) uint64_t longInstance;

/// The proposed Filename
@property (nonatomic, strong) NSString *filename;

/// Returns the Export Filename
@property (nonatomic, readonly) NSString *exportFileName;

/// The proposed FilePath
@property (nonatomic, strong) NSString *path;

/// Tag for arbitrary data
@property (nonatomic, strong) id tag;

// MARK: - User Data Extensions

/// true if this file should be marked as deleted
@property (nonatomic, assign) BOOL markForDelete;

/// Returns/sets if this File should be Recompressed during the next Save Operation
@property (nonatomic, assign) BOOL markForReCompress;

/// Returns true if the Resource was Compressed
@property (nonatomic, assign) BOOL wasCompressed;

/// Returns true, if Userdata is available
@property (nonatomic, readonly) BOOL hasUserdata;

/// contains alternative Userdata
@property (nonatomic, strong) NSData *userData;

/// Returns true if this File was changed since the last Save
@property (nonatomic, assign) BOOL changed;

/// true, if this Descriptor is Invalid
@property (nonatomic, readonly) BOOL invalid;

/// Used during saving Operations to quickly determine the uncompressed Size
@property (nonatomic, strong) PackedFile *fldata;

// MARK: - Initialization

- (instancetype)init;

// MARK: - IPackedFileDescriptor Protocol Methods

- (id<IPackedFileDescriptor>)clone;

// MARK: - Methods

- (NSString *)generateXmlMetaInfo;
- (NSString *)toResListString;
- (NSString *)exceptionString;

// MARK: - Compare Methods

- (BOOL)sameAs:(id)obj;
- (BOOL)isEqual:(id)object;

// MARK: - User Data Management

- (void)setUserData:(NSData *)data fire:(BOOL)fire;

// MARK: - Validation

- (void)markInvalid;

// MARK: - Update Management

- (void)beginUpdate;
- (void)endUpdate;

// MARK: - Loading

- (void)loadFromStream:(id<IPackageHeader>)header reader:(BinaryReader *)reader;

// MARK: - Event Blocks

/// Called whenever the content represented by this descriptor was changed (internal)
@property (nonatomic, copy) void (^packageInternalUserDataChange)(id<IPackedFileDescriptor> descriptor);

/// Called whenever the content represented by this descriptor was changed (public)
@property (nonatomic, copy) void (^changedUserData)(id<IPackedFileDescriptor> descriptor);

/// Called whenever the content represented by this descriptor was changed (always fires)
@property (nonatomic, copy) void (^changedData)(id<IPackedFileDescriptor> descriptor);

/// Called whenever the Descriptor gets invalid
@property (nonatomic, copy) void (^closed)(id<IPackedFileDescriptor> descriptor);

/// Triggered whenever the Content of the Descriptor was changed
@property (nonatomic, copy) void (^descriptionChanged)(void);

/// Triggered whenever the Descriptor gets Marked for Deletion
@property (nonatomic, copy) void (^deleted)(void);

@end
