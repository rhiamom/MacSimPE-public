//
//  FileTableBase.h
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
#import "FileTable.h"

@class FileTableItem;

@protocol IScenegraphFileIndex;
@protocol IWrapperRegistry;
@protocol IProviderRegistry;
@protocol IGroupCache;

// MARK: - FileTableBase

/**
 * Do not use this class directly, use FileTable instead!
 * Base class for file table management
 */
@interface FileTableBase : NSObject

// MARK: - Core File System Properties

/**
 * Returns the FileIndex
 * This will be initialized by the RCOL Factory
 */
@property (class, nonatomic, strong, readonly) NSArray<FileTableItem *> *defaultFolders;

@property (class, nonatomic, strong) id<IScenegraphFileIndex> fileIndex;

/**
 * Returns/Sets a WrapperRegistry (can be null)
 */
@property (class, nonatomic, strong) id<IWrapperRegistry> wrapperRegistry;

/**
 * Returns/Sets a ProviderRegistry (can be null)
 */
@property (class, nonatomic, strong) id<IProviderRegistry> providerRegistry;

/**
 * Returns the Group Cache used to determine local Groups
 */
@property (class, nonatomic, strong) id<IGroupCache> groupCache;

// MARK: - Configuration Methods

/**
 * Builds the default folder configuration
 */
+ (void)buildDefaultFolders;

/**
 * Loads folder configuration from preferences
 */
+ (NSArray<FileTableItem *> *)loadFolderConfiguration;

/**
 * Saves folder configuration to preferences
 */
+ (void)storeFolderConfiguration:(NSArray<FileTableItem *> *)folders;

+ (void)loadPackageFiles;

@end
