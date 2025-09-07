//
//  StrForm.h
//  MacSimpe
//
//  Created by Catherine Gramze on 9/3/25.
//
// ***************************************************************************
// *   Copyright (C) 2005 by Peter L Jones                                   *
// *   pljones@users.sf.net                                                  *
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

#import <Cocoa/Cocoa.h>
#import "IPackedFileUI.h"

@protocol IFileWrapper;
@class StrWrapper, StrLanguage, StrToken;

NS_ASSUME_NONNULL_BEGIN

/**
 * String Resource Editor Form
 * Provides interface for editing STR files containing localized text strings
 */
@interface StrForm : NSViewController <IPackedFileUI>

// MARK: - UI Components

/**
 * Main container view for the entire interface
 */
@property (nonatomic, strong) IBOutlet NSView *strPanel;

/**
 * Header panel with banner and file name display
 */
@property (nonatomic, strong) IBOutlet NSView *headerPanel;

/**
 * Banner label showing "Text Resource Editor"
 */
@property (nonatomic, strong) IBOutlet NSTextField *bannerLabel;

/**
 * Label showing the current STR file name
 */
@property (nonatomic, strong) IBOutlet NSTextField *fileNameLabel;

/**
 * Format display label
 */
@property (nonatomic, strong) IBOutlet NSTextField *formatLabel;

/**
 * Format value text field (read-only)
 */
@property (nonatomic, strong) IBOutlet NSTextField *formatTextField;

/**
 * Language selection label
 */
@property (nonatomic, strong) IBOutlet NSTextField *languageLabel;

/**
 * Language selection combo box
 */
@property (nonatomic, strong) IBOutlet NSComboBox *languageComboBox;

/**
 * Main content group box containing string editing interface
 */
@property (nonatomic, strong) IBOutlet NSBox *contentGroupBox;

/**
 * Split view dividing string list from string editor
 */
@property (nonatomic, strong) IBOutlet NSSplitView *mainSplitView;

/**
 * Left panel containing the string list
 */
@property (nonatomic, strong) IBOutlet NSView *listPanel;

/**
 * List box showing all strings in current language
 */
@property (nonatomic, strong) IBOutlet NSTableView *stringsTableView;

/**
 * Array controller for strings table
 */
@property (nonatomic, strong) IBOutlet NSArrayController *stringsArrayController;

/**
 * Right panel containing string editing controls
 */
@property (nonatomic, strong) IBOutlet NSView *editPanel;

/**
 * Group box for string editing
 */
@property (nonatomic, strong) IBOutlet NSBox *stringEditGroupBox;

/**
 * Value label
 */
@property (nonatomic, strong) IBOutlet NSTextField *valueLabel;

/**
 * Value text view for editing string value
 */
@property (nonatomic, strong) IBOutlet NSTextView *valueTextView;

/**
 * Value scroll view container
 */
@property (nonatomic, strong) IBOutlet NSScrollView *valueScrollView;

/**
 * Description label
 */
@property (nonatomic, strong) IBOutlet NSTextField *descriptionLabel;

/**
 * Description text view for editing string description
 */
@property (nonatomic, strong) IBOutlet NSTextView *descriptionTextView;

/**
 * Description scroll view container
 */
@property (nonatomic, strong) IBOutlet NSScrollView *descriptionScrollView;

/**
 * Button panel for string actions
 */
@property (nonatomic, strong) IBOutlet NSView *buttonPanel;

/**
 * Add new string button
 */
@property (nonatomic, strong) IBOutlet NSButton *addButton;

/**
 * Delete current string button
 */
@property (nonatomic, strong) IBOutlet NSButton *deleteButton;

/**
 * Commit current changes button
 */
@property (nonatomic, strong) IBOutlet NSButton *commitButton;

/**
 * Add to all languages button
 */
@property (nonatomic, strong) IBOutlet NSButton *addToAllButton;

/**
 * Change in all languages button
 */
@property (nonatomic, strong) IBOutlet NSButton *changeAllButton;

/**
 * Delete in all languages button
 */
@property (nonatomic, strong) IBOutlet NSButton *deleteAllButton;

/**
 * Top-level action buttons
 */
@property (nonatomic, strong) IBOutlet NSButton *clearButton;
@property (nonatomic, strong) IBOutlet NSButton *commitFileButton;

#if DEBUG
/**
 * Create text file button (debug only)
 */
@property (nonatomic, strong) IBOutlet NSButton *createTextFileButton;
#endif

/**
 * Enable all languages button
 */
@property (nonatomic, strong) IBOutlet NSButton *enableAllLanguagesButton;

// MARK: - Properties

/**
 * The STR wrapper being edited
 */
@property (nonatomic, strong, nullable) StrWrapper *wrapper;

/**
 * Array of strings for current language (for table display)
 */
@property (nonatomic, strong) NSMutableArray<StrToken *> *currentLanguageStrings;

/**
 * Flag to prevent infinite update loops during programmatic changes
 */
@property (nonatomic, assign) BOOL isUpdatingUI;

/**
 * Currently selected string index
 */
@property (nonatomic, assign) NSInteger selectedStringIndex;

// MARK: - Initialization

/**
 * Initialize the StrForm
 */
- (instancetype)init;

// MARK: - IPackedFileUI Protocol

/**
 * Returns the main panel that will be displayed within SimPE
 */
@property (nonatomic, readonly) NSView *guiHandle;

/**
 * Called when the panel is going to be displayed - updates UI with wrapper data
 * @param wrapper The STR wrapper to display/edit
 */
- (void)updateGUI:(id<IFileWrapper>)wrapper;

// MARK: - UI Actions

/**
 * Language selection changed
 */
- (IBAction)languageChanged:(nullable id)sender;

/**
 * String selection changed in table
 */
- (IBAction)stringSelectionChanged:(id)sender;

/**
 * Text changed in value or description field
 */
- (IBAction)textChanged:(id)sender;

/**
 * Add new string to current language
 */
- (IBAction)addString:(id)sender;

/**
 * Delete current string from current language
 */
- (IBAction)deleteString:(id)sender;

/**
 * Commit changes to current string
 */
- (IBAction)commitChanges:(nullable id)sender;

/**
 * Add current string to all languages
 */
- (IBAction)addToAllLanguages:(id)sender;

/**
 * Change current string in all languages
 */
- (IBAction)changeInAllLanguages:(id)sender;

/**
 * Delete current string from all languages
 */
- (IBAction)deleteInAllLanguages:(id)sender;

/**
 * Clear all strings and reset languages
 */
- (IBAction)clearStrings:(id)sender;

/**
 * Commit all changes to file
 */
- (IBAction)commitFile:(id)sender;

#if DEBUG
/**
 * Create text file with string list (debug only)
 */
- (IBAction)createTextFile:(id)sender;
#endif

/**
 * Enable all languages
 */
- (IBAction)enableAllLanguages:(id)sender;

// MARK: - Private Methods

/**
 * Setup the UI components and initial state
 */
- (void)setupUI;

/**
 * Update the language combo box with available languages
 */
- (void)updateLanguageList;

/**
 * Update the strings table for current language
 */
- (void)updateStringsList;

/**
 * Update the string editing fields with selected string data
 */
- (void)updateStringEditFields;

/**
 * Update button states based on current selection
 */
- (void)updateButtonStates;

/**
 * Save any pending changes before switching contexts
 */
- (void)savePendingChanges;


@end

NS_ASSUME_NONNULL_END
