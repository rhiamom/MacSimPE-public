//
//  CpfUI.h
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
// ***************************************************************************

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "IPackedFileUI.h"

@class Cpf, CpfItem, IPackageFile, IFileWrapper, IFileWrapperSaveExtension;

/**
 * Preview execution callback type
 */
typedef void (^ExecutePreviewBlock)(Cpf *cpf, IPackageFile *package);

/**
 * UI Handler for a CPF Wrapper
 * This view controller integrates with ResourceViewManager to display CPF file contents
 */
@interface CpfUI : NSViewController <IPackedFileUI>

// MARK: - UI Elements
@property (nonatomic, weak) IBOutlet NSTableView *itemsTableView;
@property (nonatomic, weak) IBOutlet NSPopUpButton *dataTypePopUp;
@property (nonatomic, weak) IBOutlet NSTextField *nameTextField;
@property (nonatomic, weak) IBOutlet NSTextField *valueTextField;
@property (nonatomic, weak) IBOutlet NSButton *addButton;
@property (nonatomic, weak) IBOutlet NSButton *removeButton;
@property (nonatomic, weak) IBOutlet NSButton *previewButton;

// MARK: - Properties
@property (nonatomic, strong) Cpf *wrapper;
@property (nonatomic, strong) IFileWrapperSaveExtension *saveWrapper;
@property (nonatomic, strong) NSMutableArray<CpfItem *> *items;
@property (nonatomic, copy) ExecutePreviewBlock executePreview;
@property (nonatomic, assign) BOOL changeEnabled;

// MARK: - Initialization

/**
 * Initialize with preview function
 * @param executePreview Optional preview execution block
 */
- (instancetype)initWithExecutePreview:(ExecutePreviewBlock)executePreview;

/**
 * Initialize with wrapper (for ResourceViewManager integration)
 * @param wrapper The wrapper to display
 */
- (instancetype)initWithWrapper:(id<IFileWrapper>)wrapper;

// MARK: - Actions
- (IBAction)addItem:(id)sender;
- (IBAction)removeItem:(id)sender;
- (IBAction)previewItem:(id)sender;
- (IBAction)dataTypeChanged:(id)sender;
- (IBAction)nameChanged:(id)sender;
- (IBAction)valueChanged:(id)sender;

// MARK: - Table View Management
- (void)refreshTableView;
- (void)updateSelectedItem;

@end
