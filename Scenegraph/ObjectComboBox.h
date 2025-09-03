//
//  ObjectComboBox.h
//  MacSimpe
//
//  Created by Catherine Gramze on 8/30/25.
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

#import <AppKit/AppKit.h>

// Forward declarations
@class MemoryCacheFile, MemoryCacheItem, StaticAlias;
@protocol IAlias;

NS_ASSUME_NONNULL_BEGIN

/**
 * Specialized combo box for displaying cached game objects with filtering options
 */
@interface ObjectComboBox : NSView

// MARK: - Properties

/**
 * Returns the MemoryObject Cache
 */
@property (class, nonatomic, strong, readonly) MemoryCacheFile *objectCache;

/**
 * The underlying combo box control
 */
@property (nonatomic, strong, readonly) NSComboBox *comboBox;

/**
 * Filter properties
 */
@property (nonatomic, assign) BOOL showInventory;
@property (nonatomic, assign) BOOL showTokens;
@property (nonatomic, assign) BOOL showMemories;
@property (nonatomic, assign) BOOL showJobData;
@property (nonatomic, assign) BOOL showAspiration;
@property (nonatomic, assign) BOOL showBadge;
@property (nonatomic, assign) BOOL showSkill;

/**
 * Selection properties
 */
@property (nonatomic, assign) uint32_t selectedGuid;
@property (nonatomic, strong, nullable) MemoryCacheItem *selectedItem;

/**
 * Whether the combo box has been loaded
 */
@property (nonatomic, readonly, assign) BOOL loaded;

// MARK: - Initialization

/**
 * Initialize the ObjectComboBox
 */
- (instancetype)initWithFrame:(NSRect)frameRect;

// MARK: - Content Management

/**
 * Reload the combo box content based on current filter settings
 */
- (void)reload;

// MARK: - Events

/**
 * Event fired when the selected object changes
 */
@property (nonatomic, copy, nullable) void (^selectedObjectChanged)(ObjectComboBox *sender);

@end

NS_ASSUME_NONNULL_END
