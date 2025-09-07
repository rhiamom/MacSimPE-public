//
//  StrListViewer.h
//  MacSimpe
//
//  Created by Catherine Gramze on 9/3/25.
//
//***************************************************************************
//*   Copyright (C) 2005 by Peter L Jones                                   *
//*   pljones@users.sf.net                                                  *
//*                                                                         *
//*   Objective-C translation Copyright (C) 2025 by GramzeSweatShop         *
//*   rhiamom@mac.com                                                       *
//*                                                                         *
//*   This program is free software; you can redistribute it and/or modify  *
//*   it under the terms of the GNU General Public License as published by  *
//*   the Free Software Foundation; either version 2 of the License, or     *
//*   (at your option) any later version.                                   *
//*                                                                         *
//*   This program is distributed in the hope that it will be useful,       *
//*   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
//*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
//*   GNU General Public License for more details.                          *
//*                                                                         *
//*   You should have received a copy of the GNU General Public License     *
//*   along with this program; if not, write to the                         *
//*   Free Software Foundation, Inc.,                                       *
//*   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
// ***************************************************************************/

#import <Cocoa/Cocoa.h>

// Forward declarations
@class StrWrapper;
@class StrLanguage;
@class StrItemList;
@class StrToken;

/**
 * Summary description for StrListViewer.
 * Provides a dual-pane view for browsing string resources by language
 */
@interface StrListViewer : NSView <NSOutlineViewDataSource, NSOutlineViewDelegate, NSTableViewDataSource, NSTableViewDelegate>

// MARK: - UI Components

@property (nonatomic, strong) IBOutlet NSOutlineView *treeView1;
@property (nonatomic, strong) IBOutlet NSSplitView *splitView;
@property (nonatomic, strong) IBOutlet NSTableView *listView1;
@property (nonatomic, strong) IBOutlet NSTableColumn *colLine;
@property (nonatomic, strong) IBOutlet NSTableColumn *colTitle;
@property (nonatomic, strong) IBOutlet NSTableColumn *colDesc;

// MARK: - Context Menus

@property (nonatomic, strong) NSMenu *cmLangList;
@property (nonatomic, strong) NSMenuItem *menuItem1;  // Copy
@property (nonatomic, strong) NSMenuItem *menuItem2;  // Paste
@property (nonatomic, strong) NSMenuItem *menuItem3;  // Set all to these
@property (nonatomic, strong) NSMenuItem *menuItem7;  // Paste As...
@property (nonatomic, strong) NSMenuItem *menuItem8;  // Add
@property (nonatomic, strong) NSMenuItem *menuItem9;  // Delete

@property (nonatomic, strong) NSMenu *cmStrList;
@property (nonatomic, strong) NSMenuItem *menuItem4;   // Copy
@property (nonatomic, strong) NSMenuItem *menuItem5;   // Paste
@property (nonatomic, strong) NSMenuItem *menuItem6;   // Set in all languages
@property (nonatomic, strong) NSMenuItem *menuItem10;  // Edit
@property (nonatomic, strong) NSMenuItem *menuItem11;  // Add
@property (nonatomic, strong) NSMenuItem *menuItem12;  // Delete

// MARK: - Data Properties

/**
 * The Str wrapper handling the packed file data
 */
@property (nonatomic, strong) StrWrapper *wrapper;

/**
 * Currently selected language
 */
@property (nonatomic, strong) StrLanguage *currentLang;

/**
 * Array of languages for the outline view
 */
@property (nonatomic, strong) NSArray<StrLanguage *> *languages;

/**
 * Current string items for the selected language
 */
@property (nonatomic, strong) StrItemList *currentItems;

// MARK: - Initialization

- (instancetype)init;
- (instancetype)initWithFrame:(NSRect)frameRect;

// MARK: - Public Methods

/**
 * Updates the GUI with new string wrapper data
 * @param wrp The Str wrapper containing the data to display
 */
- (void)updateGUI:(StrWrapper *)wrp;

// MARK: - Private Methods

- (void)setupUI;
- (void)setupContextMenus;

// MARK: - Action Methods

- (IBAction)menuCopyLanguage:(id)sender;
- (IBAction)menuPasteLanguage:(id)sender;
- (IBAction)menuPasteAsLanguage:(id)sender;
- (IBAction)menuSetAllToThese:(id)sender;
- (IBAction)menuAddLanguage:(id)sender;
- (IBAction)menuDeleteLanguage:(id)sender;

- (IBAction)menuEditString:(id)sender;
- (IBAction)menuCopyString:(id)sender;
- (IBAction)menuPasteString:(id)sender;
- (IBAction)menuSetInAllLanguages:(id)sender;
- (IBAction)menuAddString:(id)sender;
- (IBAction)menuDeleteString:(id)sender;

@end
#ifndef StrListViewer_h
#define StrListViewer_h


#endif /* StrListViewer_h */
