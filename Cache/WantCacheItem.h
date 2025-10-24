//
//  WantCacheItem.h
//  MacSimpe
//
//  Created by Catherine Gramze on 9/23/25.
//
// ***************************************************************************
// *   Copyright (C) 2005 by Ambertation                                     *
// *   quaxi@ambertation.de                                                  *
// *                                                                         *
// *   Objective-C translation Copyright (C) 2025                            *
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
#import <AppKit/AppKit.h>
#import "ICacheItem.h"

@class BinaryReader, BinaryWriter;
@protocol IPackedFileDescriptor;

NS_ASSUME_NONNULL_BEGIN

/**
 * Contains one ObjectCacheItem
 */
@interface WantCacheItem : NSObject <ICacheItem>

// MARK: - Constants

/**
 * The current Version
 */
@property (class, nonatomic, readonly, assign) uint8_t VERSION;

// MARK: - Properties

/**
 * Returns the Version
 */
@property (nonatomic, readonly, assign) uint8_t version;

/**
 * Returns an (unitialized) FileDescriptor
 */
@property (nonatomic, strong) id<IPackedFileDescriptor> fileDescriptor;

/**
 * Returns the GUID
 */
@property (nonatomic, assign) uint32_t guid;

/**
 * Returns the Folder
 */
@property (nonatomic, copy) NSString *folder;

/**
 * Returns the Score
 */
@property (nonatomic, assign) int32_t score;

/**
 * Returns the Influence
 */
@property (nonatomic, assign) int32_t influence;

/**
 * Returns the Object Type
 */
@property (nonatomic, copy) NSString *objectType;

/**
 * Returns the Name
 */
@property (nonatomic, copy) NSString *name;

/**
 * Returns the Icon/Thumbnail image
 */
@property (nonatomic, strong, nullable) NSImage *icon;

// MARK: - Initialization

/**
 * Constructor
 */
- (instancetype)init;

// MARK: - ICacheItem Protocol Methods

/**
 * Load data from BinaryReader
 * @param reader The BinaryReader to read from
 */
- (void)load:(BinaryReader *)reader;

/**
 * Save data to BinaryWriter
 * @param writer The BinaryWriter to write to
 */
- (void)save:(BinaryWriter *)writer;

// MARK: - NSObject Overrides

/**
 * String representation of the cache item
 */
- (NSString *)description;

@end

NS_ASSUME_NONNULL_END
