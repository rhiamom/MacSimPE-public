//
//  LotProvider.h
//  MacSimpe
//
//  Created by Catherine Gramze on 8/20/25.
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
#import <AppKit/AppKit.h>
#import "Thread.h"
#import "ILotProvider.h"

@protocol IScenegraphFileIndex;
@protocol IScenegraphFileIndexItem;
@protocol IPackageFile;
@protocol IPackedFileDescriptor;

// MARK: - LotItem Class

/**
 * Implementation of ILotItem protocol
 */
@interface LotItem : NSObject <ILotItem>

// MARK: - Properties

/**
 * The lot's name
 */
@property (nonatomic, copy) NSString *name;

/**
 * The lot's image/thumbnail
 */
@property (nonatomic, strong) NSImage *image;

/**
 * The instance ID
 */
@property (nonatomic, assign) uint32_t instance;

/**
 * The owner sim instance
 */
@property (nonatomic, assign) uint32_t owner;

/**
 * Associated tags/metadata
 */
@property (nonatomic, strong) NSMutableArray *tags;

/**
 * Associated file index item
 */
@property (nonatomic, strong) id<IScenegraphFileIndexItem> fileIndexItem;

// MARK: - Initialization

/**
 * Create a lot item
 * @param instance The instance ID
 * @param name The lot name
 * @param image The lot image
 * @param fileIndexItem The associated file index item
 */
- (instancetype)initWithInstance:(uint32_t)instance
                            name:(NSString *)name
                           image:(NSImage *)image
                   fileIndexItem:(id<IScenegraphFileIndexItem>)fileIndexItem;

@end

// MARK: - LotProvider Class

/**
 * Zusammenfassung für LotProvider.
 */
@interface LotProvider : StoppableThread <ILotProvider>

// MARK: - Properties

/**
 * Stored lot content (keyed by instance)
 */
@property (nonatomic, strong) NSMutableDictionary *content;

/**
 * The folder from where the lot information was loaded
 */
@property (nonatomic, strong) NSString *dir;

/**
 * The neighborhood name
 */
@property (nonatomic, strong) NSString *ngbh;

/**
 * File index for lot files
 */
@property (nonatomic, strong) id<IScenegraphFileIndex> lotfi;

/**
 * File index for neighborhood files
 */
@property (nonatomic, strong) id<IScenegraphFileIndex> ngbhfi;

/**
 * Synchronization object
 */
@property (nonatomic, strong) NSObject *sync;

// MARK: - Initialization

/**
 * Creates the List for the specific Folder
 * @param folder The Folder with the lot files
 */
- (instancetype)initWithFolder:(NSString *)folder;

/**
 * Creates the List with empty folder
 */
- (instancetype)init;

// MARK: - Helper Methods

/**
 * Extract instance ID from filename
 * @param filename The filename to parse
 * @returns The extracted instance ID
 */
- (uint32_t)getInstanceFromFilename:(NSString *)filename;

/**
 * Add neighborhoods to file index
 */
- (void)addHoodsToFileIndex;

/**
 * Add lots to file index
 */
- (void)addLotsToFileIndex;

/**
 * Load lots from the configured folder
 */
- (void)loadLotsFromFolder;

@end
