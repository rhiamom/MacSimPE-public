//
//  PackedFileForm.h
//  MacSimpe
//
//  Created by Catherine Gramze on 8/22/25.
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
@protocol IFileWrapperSaveExtension, IPackedFileDescriptor;
@class TypeAlias, RefFile, RefFileItem, SkinChain, GenericRcol, MipMap, ImageData;

/**
 * 3D Referencing File Editor - AppKit version of RefFileForm
 * Manages file references with type/group/instance properties
 */
@interface RefFileForm : NSWindowController

// MARK: - UI Components
@property (nonatomic, strong) IBOutlet NSScrollView *wrapperScrollView;
@property (nonatomic, strong) IBOutlet NSView *wrapperPanel;
@property (nonatomic, strong) IBOutlet NSImageView *imageView;
@property (nonatomic, strong) IBOutlet NSButton *packageButton;
@property (nonatomic, strong) IBOutlet NSButton *chooseFileButton;
@property (nonatomic, strong) IBOutlet NSButton *upButton;
@property (nonatomic, strong) IBOutlet NSButton *downButton;
@property (nonatomic, strong) IBOutlet NSButton *commitAllButton;

// File Properties Group
@property (nonatomic, strong) IBOutlet NSBox *filePropertiesBox;
@property (nonatomic, strong) IBOutlet NSView *propertiesPanel;
@property (nonatomic, strong) IBOutlet NSTextField *typeTextField;
@property (nonatomic, strong) IBOutlet NSTextField *subtypeTextField;
@property (nonatomic, strong) IBOutlet NSTextField *groupTextField;
@property (nonatomic, strong) IBOutlet NSTextField *instanceTextField;
@property (nonatomic, strong) IBOutlet NSPopUpButton *typesPopUpButton;
@property (nonatomic, strong) IBOutlet NSButton *addButton;
@property (nonatomic, strong) IBOutlet NSButton *deleteButton;
@property (nonatomic, strong) IBOutlet NSButton *changeButton;

// File List
@property (nonatomic, strong) IBOutlet NSTableView *fileListTableView;
@property (nonatomic, strong) IBOutlet NSScrollView *fileListScrollView;

// Header
@property (nonatomic, strong) IBOutlet NSView *headerPanel;
@property (nonatomic, strong) IBOutlet NSTextField *titleLabel;

// MARK: - Data Management
/**
 * Stores the currently active Wrapper
 */
@property (nonatomic, strong) id<IFileWrapperSaveExtension> wrapper;

/**
 * Array of file descriptors for the table view
 */
@property (nonatomic, strong) NSMutableArray<id<IPackedFileDescriptor>> *fileDescriptors;

/**
 * Flag to prevent recursive updates during text field changes
 */
@property (nonatomic, assign) BOOL isUpdatingFields;

// MARK: - Initialization
- (instancetype)init;
- (instancetype)initWithWrapper:(id<IFileWrapperSaveExtension>)wrapper;

// MARK: - UI Setup
- (void)setupUI;
- (void)setupConstraints;
- (void)setupTableView;
- (void)loadTypeAliases;

// MARK: - Actions
- (IBAction)selectType:(id)sender;
- (IBAction)typeTextChanged:(id)sender;
- (IBAction)autoChange:(id)sender;
- (IBAction)selectFile:(id)sender;
- (IBAction)changeFile:(id)sender;
- (IBAction)deleteFile:(id)sender;
- (IBAction)addFile:(id)sender;
- (IBAction)commitAll:(id)sender;
- (IBAction)moveUp:(id)sender;
- (IBAction)moveDown:(id)sender;
- (IBAction)chooseFile:(id)sender;
- (IBAction)showPackageSelector:(id)sender;

// MARK: - Utility Methods
- (void)updateButtonStates;
- (void)updateImageForSelectedFile;
- (void)reloadFileList;

@end

// MARK: - Table View Data Source Protocol Extension
@interface RefFileForm (TableViewDataSource) <NSTableViewDataSource, NSTableViewDelegate>
@end
