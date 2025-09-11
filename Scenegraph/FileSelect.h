//
//  FileSelect.h
//  MacSimpe
//
//  Created by Catherine Gramze on 9/9/25.
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

#import <Cocoa/Cocoa.h>

// Forward declarations
@protocol IPackedFileDescriptor;
@class Cpf;

NS_ASSUME_NONNULL_BEGIN

/**
 * File selection dialog for choosing skins in SimPE
 * Displays male and female skins organized by age and category
 */
@interface FileSelect : NSWindowController <NSOutlineViewDataSource, NSOutlineViewDelegate>

// MARK: - IBOutlets

@property (nonatomic, weak) IBOutlet NSButton *useButton;
@property (nonatomic, weak) IBOutlet NSTabView *tabControl;
@property (nonatomic, weak) IBOutlet NSImageView *pictureBox;
@property (nonatomic, weak) IBOutlet NSTextField *nameLabel;
@property (nonatomic, weak) IBOutlet NSOutlineView *femaleTreeView;
@property (nonatomic, weak) IBOutlet NSOutlineView *maleTreeView;

// MARK: - Properties

/**
 * Whether the user confirmed the selection
 */
@property (nonatomic, assign) BOOL userConfirmed;

/**
 * The currently selected tree node
 */
@property (nonatomic, strong, nullable) id selectedNode;

/**
 * Category mapping data structure
 */
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSMutableDictionary *> *categoryMap;

/**
 * Root nodes for female tree
 */
@property (nonatomic, strong) NSMutableArray *femaleRootNodes;

/**
 * Root nodes for male tree
 */
@property (nonatomic, strong) NSMutableArray *maleRootNodes;

// MARK: - Class Methods

/**
 * Execute the file selection dialog
 * @return The selected file descriptor, or nil if cancelled
 */
+ (nullable id<IPackedFileDescriptor>)execute;


// MARK: - Initialization

/**
 * Initialize with default nib
 */
- (instancetype)init;

// MARK: - IBActions

/**
 * Handle use button click
 */
- (IBAction)useButtonClicked:(id)sender;

// MARK: - Private Methods

/**
 * Create category nodes for the specified tree view and gender
 * @param treeNodes The array to populate with root nodes
 * @param gender The gender identifier (1 for female, 2 for male)
 */
- (void)createCategoryNodes:(NSMutableArray *)treeNodes forGender:(uint32_t)gender;

/**
 * Fill category nodes with actual skin data
 */
- (void)fillCategoryNodes;

/**
 * Handle tree view selection change
 * @param outlineView The outline view that changed selection
 */
- (void)handleSelectionChange:(NSOutlineView *)outlineView;

- (NSString *)stringForAge:(uint32_t)age;

- (NSString *)stringForSkinCategory:(uint32_t)category;

@end

/**
 * Tree node class for organizing skin data
 */
@interface SkinTreeNode : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong, nullable) Cpf *skinData;
@property (nonatomic, strong) NSMutableArray<SkinTreeNode *> *children;
@property (nonatomic, weak, nullable) SkinTreeNode *parent;

- (instancetype)initWithTitle:(NSString *)title;
- (instancetype)initWithTitle:(NSString *)title skinData:(nullable Cpf *)skinData;
- (void)addChild:(SkinTreeNode *)child;
- (BOOL)isLeaf;

@end

NS_ASSUME_NONNULL_END
