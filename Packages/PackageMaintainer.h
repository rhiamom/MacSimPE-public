//
//  PackageMaintainer.h
//  MacSimpe
//
//  Created by Catherine Gramze on 7/28/25.
//
/***************************************************************************
 *   Copyright (C) 2005 by Ambertation                                     *
 *   quaxi@ambertation.de                                                  *
 *                                                                         *
 *   Objective-C translation Copyright (C) 2025 by GramzeSweatShop        *
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
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
 ***************************************************************************/

#import <Foundation/Foundation.h>

@class GeneratableFile;
@protocol IScenegraphFileIndex;

/// Maintains a list of all opened packages
@interface PackageMaintainer : NSObject

/// Returns the active package maintainer
@property (class, nonatomic, readonly) PackageMaintainer *maintainer;

/// Set or get the FileIndex used to hold loaded packages
@property (nonatomic, strong) id<IScenegraphFileIndex> fileIndex;

/// Remove a given package from the maintainer
/// @param pkg The package to remove
- (void)removePackage:(GeneratableFile *)pkg;

/// Remove a given package from the maintainer by filename
/// @param filename The filename of the package to remove
- (void)removePackageWithFilename:(NSString *)filename;

/// Remove all packages in a given folder path
/// @param folder The folder path
- (void)removePackagesInPath:(NSString *)folder;

/// Synchronize the file index with the given package
/// @param pkg The package to sync
- (void)syncFileIndex:(GeneratableFile *)pkg;

/// Checks if the package on the passed filename is already maintained here
/// @param filename The filename to check
/// @return YES if the package is already maintained
- (BOOL)containsPackageWithFilename:(NSString *)filename;

/// Load a package file from the maintainer
/// @param filename The name of the package
/// @param sync True if the package should be synchronized with the filesystem before it is returned
/// @return An instance of GeneratableFile for the given filename
/// @discussion If the package was loaded once in this session, this method will return an instance to the last loaded version. Otherwise it will create a new instance.
- (GeneratableFile *)loadPackageFromFile:(NSString *)filename sync:(BOOL)sync;

@end

