//
//  IPackedFileDescriptorBasic.h
//  MacSimpe
//
//  Created by Catherine Gramze on 7/25/25.
//
/***************************************************************************
 *   Copyright (C) 2005 by Ambertation                                     *
 *   quaxi@ambertation.de                                                  *
 *                                                                         *
 *   Swift translation Copyright (C) 2025 by GramzeSweatShop               *
 *   rhiamom@mac.com                                                       *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program, if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
 ***************************************************************************/

#import <Foundation/Foundation.h>

@class TypeAlias;

/**
 * Interface for PackedFile Descriptors
 */
@protocol IPackedFileDescriptorBasic <NSObject>

/**
 * Returns the Offset within the Package File
 */
@property (nonatomic, readonly) uint32_t offset;

/**
 * Returns the Size of the referenced File
 * @remarks This must return either the size stored in the Index or the Size of the Userdata (if defined)
 */
@property (nonatomic, readonly) int32_t size;

/**
 * Returns the Size of the File as stored in the Index
 * @remarks This must return the size of the File as it was stored in the Fileindex,
 * even if the Size did change! (it is used during the IncrementalBuild Method of a Package File!)
 * If the file is new, this value must return 0.
 */
@property (nonatomic, readonly) int32_t indexedSize;

/**
 * Returns the Type of the referenced File
 */
@property (nonatomic, assign) uint32_t type;

/**
 * Returns the Name of the represented Type
 */
@property (nonatomic, readonly) TypeAlias *typeName;

/**
 * Returns the Group the referenced file is assigned to
 */
@property (nonatomic, assign) uint32_t group;

/**
 * Returns the Instance Data
 */
@property (nonatomic, assign) uint32_t instance;

/**
 * Returns the Long Instance
 * @remarks Combination of SubType and Instance
 */
@property (nonatomic, assign) uint64_t longInstance;

/**
 * Returns an yet unknown Type
 * @remarks Only in Version 1.1 of package Files
 */
@property (nonatomic, assign) uint32_t subType;

/**
 * Returns or Sets the Filename
 * @remarks This is mostly of interest when you extract packedFiles
 */
@property (nonatomic, strong) NSString *filename;

/**
 * Returns the Filename that should be used when you create a single exported File
 */
@property (nonatomic, readonly) NSString *exportFileName;

/**
 * Returns or Sets the File Path
 * @remarks This is mostly of interest when you extract packedFiles
 */
@property (nonatomic, strong) NSString *path;

/**
 * Returns true if this File was changed since the last Save
 */
@property (nonatomic, assign) BOOL changed;

/**
 * Returns true, if Userdata is available
 * @remarks This happens when a user assigns new Data
 */
@property (nonatomic, readonly) BOOL hasUserdata;

/**
 * Puts Userdefined Data into the File. Setting this Property will fire a ChangedUserData Event.
 */
@property (nonatomic, strong) NSData *userData;

/**
 * Returns/sets if this file should be kept in the Index for the next Save
 */
@property (nonatomic, assign) BOOL markForDelete;

/**
 * Returns/sets if this File should be Recompressed during the next Save Operation
 */
@property (nonatomic, assign) BOOL markForReCompress;

/**
 * Returns true if the Resource was Compressed
 */
@property (nonatomic, readonly) BOOL wasCompressed;

/**
 * additional Data
 */
@property (nonatomic, strong) id tag;

/**
 * true, if this Descriptor is Invalid
 */
@property (nonatomic, readonly) BOOL invalid;

/**
 * Returns the Name of this Descriptor as used in Exception Messages
 */
@property (nonatomic, readonly) NSString *exceptionString;

/**
 * Generates MetInformations about a Packed File
 * @returns A String representing the Description as XML output
 */
- (NSString *)generateXmlMetaInfo;

/**
 * Same Equals, except this Version is also checking the Offset
 * @param obj The Object to compare to
 * @returns true if the TGI Values are the same
 */
- (BOOL)sameAs:(id)obj;

/**
 * Close this Descriptor (make it invalid)
 */
- (void)markInvalid;

/**
 * Defers DescriptionChanged and ChangedData until endUpdate is called
 */
- (void)beginUpdate;

/**
 * Executes Events Deferred by beginUpdate
 */
- (void)endUpdate;

@end
