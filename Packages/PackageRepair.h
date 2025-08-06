//
//  PackageRepair.h
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
#import "MetaData.h"

@protocol IPackageFile;
@protocol IPackageHeader;
@class HeaderIndex;
@class GeneratableFile;
@class BinaryReader;


// MARK: - Index Details

@interface IndexDetails : NSObject

// MARK: - Properties

/**
 * Returns the Identifier of the File
 * This value should be DBPF
 */
@property (nonatomic, strong, readonly) NSString *identifier;

/**
 * Returns the Overall Version of this Package
 */
@property (nonatomic, strong, readonly) NSString *version;

   //Returns or Sets the Type of the Package

@property (nonatomic, assign) IndexTypes indexType;

/**
 * This is misused in SimPE as a Unique Creator ID
 */
@property (nonatomic, assign, readonly) uint32_t ident;

// MARK: - Initialization

- (instancetype)initWithPackageHeader:(id<IPackageHeader>)header;

@end

// MARK: - Index Details Advanced

@interface IndexDetailsAdvanced : IndexDetails

// MARK: - Advanced Properties

@property (nonatomic, strong, readonly) NSString *indexOffset;
@property (nonatomic, strong, readonly) NSString *indexSize;
@property (nonatomic, assign, readonly) NSInteger resourceCount;
@property (nonatomic, strong, readonly) NSString *indexVersion;
@property (nonatomic, strong, readonly) NSString *indexItemSize;

/**
 * Returns the Major Version of The Packages FileFormat
 * This value should be 1
 */
@property (nonatomic, assign, readonly) NSInteger majorVersion;

/**
 * Returns the Minor Version of The Packages FileFormat
 * This value should be 0 or 1
 */
@property (nonatomic, assign, readonly) NSInteger minorVersion;

@end

// MARK: - Package Repair

/**
 * This offers some Repair Methods for .packages
 */
@interface PackageRepair : NSObject

// MARK: - Properties

@property (nonatomic, strong, readonly) IndexDetails *indexDetails;
@property (nonatomic, strong, readonly) IndexDetailsAdvanced *indexDetailsAdvanced;
@property (nonatomic, strong, readonly) GeneratableFile *package;

// MARK: - Initialization

- (instancetype)initWithPackageFile:(id<IPackageFile>)packageFile;

// MARK: - Repair Methods

/**
 * Returns the Offset of the ResourceIndex in the current package
 */
- (HeaderIndex *)findIndexOffset;

/**
 * Uses the provided index data to repair the package
 */
- (void)useIndexData:(HeaderIndex *)headerIndex;

@end
