//
//  StrForm.m
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

#import "StrForm.h"
#import "StrWrapper.h"
#import "StrItem.h"
#import "Helper.h"
#import "Localization.h"
#import "IFileWrapper.h"
#import "ExceptionForm.h"

@interface StrForm () <NSTableViewDataSource, NSTableViewDelegate, NSComboBoxDataSource, NSComboBoxDelegate, NSTextViewDelegate>

@end

@implementation StrForm

// MARK: - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        self.currentLanguageStrings = [[NSMutableArray alloc] init];
        self.selectedStringIndex = -1;
        self.isUpdatingUI = NO;
        [self setupUI];
    }
    return self;
}

- (void)loadView {
    // Load from nib/storyboard or create programmatically
    // This would typically be handled by Interface Builder
    self.view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 896, 366)];
    [self createUIComponents];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

// MARK: - UI Setup

- (void)createUIComponents {
    // Create main container
    self.strPanel = [[NSView alloc] initWithFrame:self.view.bounds];
    self.strPanel.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [self.view addSubview:self.strPanel];
    
    // Create header panel
    self.headerPanel = [[NSView alloc] initWithFrame:NSMakeRect(0, self.view.bounds.size.height - 32, self.view.bounds.size.width, 32)];
    self.headerPanel.autoresizingMask = NSViewWidthSizable | NSViewMinYMargin;
    [self.strPanel addSubview:self.headerPanel];
    
    // Banner label
    self.bannerLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(8, 8, 200, 19)];
    self.bannerLabel.stringValue = @"Text Resource Editor";
    self.bannerLabel.font = [NSFont boldSystemFontOfSize:13];
    self.bannerLabel.editable = NO;
    self.bannerLabel.selectable = NO;
    self.bannerLabel.bordered = NO;
    self.bannerLabel.backgroundColor = [NSColor clearColor];
    [self.headerPanel addSubview:self.bannerLabel];
    
    // File name label
    self.fileNameLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(220, 8, 200, 19)];
    self.fileNameLabel.stringValue = @"no File";
    self.fileNameLabel.font = [NSFont systemFontOfSize:11];
    self.fileNameLabel.editable = NO;
    self.fileNameLabel.selectable = NO;
    self.fileNameLabel.bordered = NO;
    self.fileNameLabel.backgroundColor = [NSColor clearColor];
    [self.headerPanel addSubview:self.fileNameLabel];
    
    // Format controls
    self.formatLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(8, 40, 80, 17)];
    self.formatLabel.stringValue = @"Format:";
    self.formatLabel.font = [NSFont boldSystemFontOfSize:11];
    self.formatLabel.editable = NO;
    self.formatLabel.selectable = NO;
    self.formatLabel.bordered = NO;
    self.formatLabel.backgroundColor = [NSColor clearColor];
    [self.strPanel addSubview:self.formatLabel];
    
    self.formatTextField = [[NSTextField alloc] initWithFrame:NSMakeRect(88, 40, 88, 20)];
    self.formatTextField.editable = NO;
    [self.strPanel addSubview:self.formatTextField];
    
    // Language controls
    self.languageLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(8, 64, 80, 17)];
    self.languageLabel.stringValue = @"Language:";
    self.languageLabel.font = [NSFont boldSystemFontOfSize:11];
    self.languageLabel.editable = NO;
    self.languageLabel.selectable = NO;
    self.languageLabel.bordered = NO;
    self.languageLabel.backgroundColor = [NSColor clearColor];
    [self.strPanel addSubview:self.languageLabel];
    
    self.languageComboBox = [[NSComboBox alloc] initWithFrame:NSMakeRect(88, 64, 304, 21)];
    self.languageComboBox.dataSource = self;
    self.languageComboBox.delegate = self;
    self.languageComboBox.target = self;
    self.languageComboBox.action = @selector(languageChanged:);
    [self.strPanel addSubview:self.languageComboBox];
    
    // Main content group
    self.contentGroupBox = [[NSBox alloc] initWithFrame:NSMakeRect(16, 16, 840, 232)];
    self.contentGroupBox.title = @"Strings";
    self.contentGroupBox.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [self.strPanel addSubview:self.contentGroupBox];
    
    // Split view
    NSRect contentRect = NSInsetRect(self.contentGroupBox.bounds, 8, 20);
    self.mainSplitView = [[NSSplitView alloc] initWithFrame:contentRect];
    self.mainSplitView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    self.mainSplitView.vertical = YES;
    [self.contentGroupBox addSubview:self.mainSplitView];
    
    // Left panel (string list)
    self.listPanel = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 260, contentRect.size.height)];
    [self.mainSplitView addSubview:self.listPanel];
    
    // Strings table
    NSScrollView *stringsScrollView = [[NSScrollView alloc] initWithFrame:NSInsetRect(self.listPanel.bounds, 8, 8)];
    stringsScrollView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    stringsScrollView.hasVerticalScroller = YES;
    stringsScrollView.hasHorizontalScroller = YES;
    
    self.stringsTableView = [[NSTableView alloc] initWithFrame:stringsScrollView.bounds];
    self.stringsTableView.dataSource = self;
    self.stringsTableView.delegate = self;
    self.stringsTableView.target = self;
    self.stringsTableView.action = @selector(stringSelectionChanged:);
    
    // Add table column
    NSTableColumn *stringColumn = [[NSTableColumn alloc] initWithIdentifier:@"string"];
    stringColumn.title = @"Strings";
    stringColumn.width = 240;
    [self.stringsTableView addTableColumn:stringColumn];
    
    stringsScrollView.documentView = self.stringsTableView;
    [self.listPanel addSubview:stringsScrollView];
    
    // Right panel (string editor)
    self.editPanel = [[NSView alloc] initWithFrame:NSMakeRect(264, 0, 560, contentRect.size.height)];
    [self.mainSplitView addSubview:self.editPanel];
    
    // String edit group box
    self.stringEditGroupBox = [[NSBox alloc] initWithFrame:NSInsetRect(self.editPanel.bounds, 4, 4)];
    self.stringEditGroupBox.title = @"";
    self.stringEditGroupBox.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [self.editPanel addSubview:self.stringEditGroupBox];
    
    [self createEditingControls];
    [self createActionButtons];
    [self createTopLevelButtons];
}

- (void)createEditingControls {
    NSRect editRect = NSInsetRect(self.stringEditGroupBox.bounds, 16, 20);
    
    // Value label and text view
    self.valueLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(editRect.origin.x, editRect.origin.y + editRect.size.height - 20, 80, 17)];
    self.valueLabel.stringValue = @"Value:";
    self.valueLabel.editable = NO;
    self.valueLabel.selectable = NO;
    self.valueLabel.bordered = NO;
    self.valueLabel.backgroundColor = [NSColor clearColor];
    [self.stringEditGroupBox addSubview:self.valueLabel];
    
    self.valueScrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(editRect.origin.x, editRect.origin.y + editRect.size.height - 76, editRect.size.width, 56)];
    self.valueScrollView.autoresizingMask = NSViewWidthSizable;
    self.valueScrollView.hasVerticalScroller = YES;
    self.valueScrollView.hasHorizontalScroller = YES;
    
    self.valueTextView = [[NSTextView alloc] init];
    self.valueTextView.delegate = self;
    self.valueTextView.richText = NO;
    self.valueScrollView.documentView = self.valueTextView;
    [self.stringEditGroupBox addSubview:self.valueScrollView];
    
    // Description label and text view
    self.descriptionLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(editRect.origin.x, editRect.origin.y + editRect.size.height - 100, 80, 17)];
    self.descriptionLabel.stringValue = @"Description:";
    self.descriptionLabel.editable = NO;
    self.descriptionLabel.selectable = NO;
    self.descriptionLabel.bordered = NO;
    self.descriptionLabel.backgroundColor = [NSColor clearColor];
    [self.stringEditGroupBox addSubview:self.descriptionLabel];
    
    self.descriptionScrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(editRect.origin.x, editRect.origin.y + 16, editRect.size.width, 48)];
    self.descriptionScrollView.autoresizingMask = NSViewWidthSizable;
    self.descriptionScrollView.hasVerticalScroller = YES;
    self.descriptionScrollView.hasHorizontalScroller = YES;
    
    self.descriptionTextView = [[NSTextView alloc] init];
    self.descriptionTextView.delegate = self;
    self.descriptionTextView.richText = NO;
    self.descriptionScrollView.documentView = self.descriptionTextView;
    [self.stringEditGroupBox addSubview:self.descriptionScrollView];
}

- (void)createActionButtons {
    NSRect editRect = NSInsetRect(self.stringEditGroupBox.bounds, 16, 20);
    
    // Button panel
    self.buttonPanel = [[NSView alloc] initWithFrame:NSMakeRect(editRect.origin.x, editRect.origin.y - 20, editRect.size.width, 40)];
    [self.stringEditGroupBox addSubview:self.buttonPanel];
    
    // Add button
    self.addButton = [[NSButton alloc] initWithFrame:NSMakeRect(editRect.size.width - 200, 16, 28, 17)];
    [self.addButton setTitle:@"add"];
    [self.addButton setTarget:self];
    [self.addButton setAction:@selector(addString:)];
    [self.addButton setButtonType:NSButtonTypeMomentaryPushIn];
    [self.addButton setBordered:NO];
    [self.addButton.cell setAttributedTitle:[[NSAttributedString alloc] initWithString:@"add" attributes:@{NSForegroundColorAttributeName: [NSColor linkColor], NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)}]];
    [self.buttonPanel addSubview:self.addButton];
    
    // Delete button
    self.deleteButton = [[NSButton alloc] initWithFrame:NSMakeRect(editRect.size.width - 200, 0, 44, 17)];
    [self.deleteButton setTitle:@"delete"];
    [self.deleteButton setTarget:self];
    [self.deleteButton setAction:@selector(deleteString:)];
    [self.deleteButton setButtonType:NSButtonTypeMomentaryPushIn];
    [self.deleteButton setBordered:NO];
    [self.deleteButton.cell setAttributedTitle:[[NSAttributedString alloc] initWithString:@"delete" attributes:@{NSForegroundColorAttributeName: [NSColor linkColor], NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)}]];
    [self.buttonPanel addSubview:self.deleteButton];
    
    // Commit button
    self.commitButton = [[NSButton alloc] initWithFrame:NSMakeRect(editRect.size.width - 150, 16, 50, 17)];
    [self.commitButton setTitle:@"change"];
    [self.commitButton setTarget:self];
    [self.commitButton setAction:@selector(commitChanges:)];
    [self.commitButton setButtonType:NSButtonTypeMomentaryPushIn];
    [self.commitButton setBordered:NO];
    [self.commitButton.cell setAttributedTitle:[[NSAttributedString alloc] initWithString:@"change" attributes:@{NSForegroundColorAttributeName: [NSColor linkColor], NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)}]];
    [self.commitButton setEnabled:NO];
    [self.buttonPanel addSubview:self.commitButton];
    
    // Add to all button
    self.addToAllButton = [[NSButton alloc] initWithFrame:NSMakeRect(editRect.size.width - 100, 0, 64, 17)];
    [self.addToAllButton setTitle:@"add to all"];
    [self.addToAllButton setTarget:self];
    [self.addToAllButton setAction:@selector(addToAllLanguages:)];
    [self.addToAllButton setButtonType:NSButtonTypeMomentaryPushIn];
    [self.addToAllButton setBordered:NO];
    [self.addToAllButton.cell setAttributedTitle:[[NSAttributedString alloc] initWithString:@"add to all" attributes:@{NSForegroundColorAttributeName: [NSColor linkColor], NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)}]];
    [self.buttonPanel addSubview:self.addToAllButton];
    
    // Change all button
    self.changeAllButton = [[NSButton alloc] initWithFrame:NSMakeRect(editRect.size.width - 50, 0, 85, 17)];
    [self.changeAllButton setTitle:@"change in all"];
    [self.changeAllButton setTarget:self];
    [self.changeAllButton setAction:@selector(changeInAllLanguages:)];
    [self.changeAllButton setButtonType:NSButtonTypeMomentaryPushIn];
    [self.changeAllButton setBordered:NO];
    [self.changeAllButton.cell setAttributedTitle:[[NSAttributedString alloc] initWithString:@"change in all" attributes:@{NSForegroundColorAttributeName: [NSColor linkColor], NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)}]];
    [self.changeAllButton setEnabled:NO];
    [self.buttonPanel addSubview:self.changeAllButton];
    
    // Delete all button
    self.deleteAllButton = [[NSButton alloc] initWithFrame:NSMakeRect(editRect.size.width + 50, 0, 79, 17)];
    [self.deleteAllButton setTitle:@"delete in all"];
    [self.deleteAllButton setTarget:self];
    [self.deleteAllButton setAction:@selector(deleteInAllLanguages:)];
    [self.deleteAllButton setButtonType:NSButtonTypeMomentaryPushIn];
    [self.deleteAllButton setBordered:NO];
    [self.deleteAllButton.cell setAttributedTitle:[[NSAttributedString alloc] initWithString:@"delete in all" attributes:@{NSForegroundColorAttributeName: [NSColor linkColor], NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)}]];
    [self.buttonPanel addSubview:self.deleteAllButton];
}

- (void)createTopLevelButtons {
    // Clear button
    self.clearButton = [[NSButton alloc] initWithFrame:NSMakeRect(688, 64, 75, 23)];
    [self.clearButton setTitle:@"Clear"];
    [self.clearButton setTarget:self];
    [self.clearButton setAction:@selector(clearStrings:)];
    [self.strPanel addSubview:self.clearButton];
    
    // Commit file button
    self.commitFileButton = [[NSButton alloc] initWithFrame:NSMakeRect(768, 64, 88, 23)];
    [self.commitFileButton setTitle:@"Commit"];
    [self.commitFileButton setTarget:self];
    [self.commitFileButton setAction:@selector(commitFile:)];
    [self.strPanel addSubview:self.commitFileButton];
    
#if DEBUG
    // Create text file button (debug only)
    self.createTextFileButton = [[NSButton alloc] initWithFrame:NSMakeRect(289, 40, 103, 17)];
    [self.createTextFileButton setTitle:@"create Text File"];
    [self.createTextFileButton setTarget:self];
    [self.createTextFileButton setAction:@selector(createTextFile:)];
    [self.createTextFileButton setButtonType:NSButtonTypeMomentaryPushIn];
    [self.createTextFileButton setBordered:NO];
    [self.createTextFileButton.cell setAttributedTitle:[[NSAttributedString alloc] initWithString:@"create Text File" attributes:@{NSForegroundColorAttributeName: [NSColor linkColor], NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)}]];
    [self.strPanel addSubview:self.createTextFileButton];
#endif
    
    // Enable all languages button
    self.enableAllLanguagesButton = [[NSButton alloc] initWithFrame:NSMakeRect(400, 60, 135, 17)];
    [self.enableAllLanguagesButton setTitle:@"enable all languages"];
    [self.enableAllLanguagesButton setTarget:self];
    [self.enableAllLanguagesButton setAction:@selector(enableAllLanguages:)];
    [self.enableAllLanguagesButton setButtonType:NSButtonTypeMomentaryPushIn];
    [self.enableAllLanguagesButton setBordered:NO];
    [self.enableAllLanguagesButton.cell setAttributedTitle:[[NSAttributedString alloc] initWithString:@"enable all languages" attributes:@{NSForegroundColorAttributeName: [NSColor linkColor], NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)}]];
    [self.strPanel addSubview:self.enableAllLanguagesButton];
}

- (void)setupUI {
    [self updateButtonStates];
    
    // Set initial text view properties
    self.valueTextView.string = @"";
    self.descriptionTextView.string = @"";
    
    // Configure table view
    self.stringsTableView.allowsMultipleSelection = NO;
    self.stringsTableView.allowsEmptySelection = YES;
    
    // Configure split view
    [self.mainSplitView setPosition:261 ofDividerAtIndex:0];
}

// MARK: - IPackedFileUI Protocol

- (NSView *)guiHandle {
    return self.strPanel;
}

- (void)updateGUI:(id<IFileWrapper>)wrapper {
    self.wrapper = (StrWrapper *)wrapper;
    self.isUpdatingUI = YES;
    
    // Update file name display
    self.fileNameLabel.stringValue = self.wrapper.fileName ?: @"no File";
    
    // Update format display
    self.formatTextField.stringValue = [NSString stringWithFormat:@"0x%@", [Helper hexStringWithPadding:(NSUInteger)self.wrapper.format padding:4]];
    
    // Clear current selection
    [self.currentLanguageStrings removeAllObjects];
    
    // Disable action buttons initially
    self.commitButton.enabled = NO;
    self.changeAllButton.enabled = NO;
    
    // Clear text fields
    self.valueTextView.string = @"";
    self.descriptionTextView.string = @"";
    self.stringEditGroupBox.title = @"";
    
    // Update language list
    [self updateLanguageList];
    
    self.isUpdatingUI = NO;
}

// MARK: - UI Updates

- (void)updateLanguageList {
    [self.languageComboBox removeAllItems];
    
    if (!self.wrapper || !self.wrapper.languages) {
        return;
    }
    
    // Add languages to combo box
    for (StrLanguage *language in self.wrapper.languages) {
        [self.languageComboBox addItemWithObjectValue:language];
    }
    
    // Select first language if available
    if (self.languageComboBox.numberOfItems > 0) {
        [self.languageComboBox selectItemAtIndex:0];
        [self languageChanged:self.languageComboBox];
    }
}

- (void)updateStringsList {
    [self.currentLanguageStrings removeAllObjects];
    
    if (!self.wrapper || self.languageComboBox.indexOfSelectedItem < 0) {
        [self.stringsTableView reloadData];
        return;
    }
    
    StrLanguage *selectedLanguage = [self.wrapper.languages objectAtIndex:(NSUInteger)self.languageComboBox.indexOfSelectedItem];
    if (selectedLanguage) {
        NSArray<StrToken *> *languageItems = [self.wrapper languageItemsForStrLanguage:selectedLanguage];
        [self.currentLanguageStrings addObjectsFromArray:languageItems];
    }
    
    [self.stringsTableView reloadData];
}

- (void)updateStringEditFields {
    if (self.isUpdatingUI) return;
    
    NSInteger selectedRow = self.stringsTableView.selectedRow;
    if (selectedRow < 0 || selectedRow >= self.currentLanguageStrings.count) {
        self.valueTextView.string = @"";
        self.descriptionTextView.string = @"";
        self.stringEditGroupBox.title = @"";
        [self updateButtonStates];
        return;
    }
    
    self.isUpdatingUI = YES;
    
    StrToken *selectedString = self.currentLanguageStrings[(NSUInteger)selectedRow];
    self.valueTextView.string = selectedString.title ?: @"";
    self.descriptionTextView.string = selectedString.strDescription ?: @"";
    self.stringEditGroupBox.title = [NSString stringWithFormat:@"0x%@", [Helper hexStringWithPadding:(NSUInteger)selectedRow padding:4]];
    
    self.selectedStringIndex = selectedRow;
    [self updateButtonStates];
    
    self.isUpdatingUI = NO;
}

- (void)updateButtonStates {
    BOOL hasSelection = (self.stringsTableView.selectedRow >= 0);
    BOOL hasLanguage = (self.languageComboBox.indexOfSelectedItem >= 0);
    
    self.commitButton.enabled = hasSelection && hasLanguage;
    self.changeAllButton.enabled = hasSelection && hasLanguage;
    self.deleteButton.enabled = hasSelection;
    self.deleteAllButton.enabled = hasSelection;
    self.addButton.enabled = hasLanguage;
    self.addToAllButton.enabled = hasLanguage;
}

- (void)savePendingChanges {
    if (self.isUpdatingUI || !self.wrapper) return;
    
    NSInteger selectedRow = self.stringsTableView.selectedRow;
    if (selectedRow < 0 || selectedRow >= self.currentLanguageStrings.count) return;
    
    // Auto-save changes when switching selection
    [self commitChanges:nil];
}

// MARK: - Actions

- (IBAction)languageChanged:(nullable id)sender {
    if (self.isUpdatingUI) return;
    
    [self savePendingChanges];
    [self updateStringsList];
    [self updateButtonStates];
}

- (IBAction)stringSelectionChanged:(id)sender {
    if (self.isUpdatingUI) return;
    
    [self savePendingChanges];
    [self updateStringEditFields];
}

- (IBAction)textChanged:(id)sender {
    if (self.isUpdatingUI) return;
    
    // Enable commit button when text changes
    if (self.stringsTableView.selectedRow >= 0) {
        self.commitButton.enabled = YES;
        self.changeAllButton.enabled = YES;
    }
}

- (IBAction)addString:(id)sender {
    [self.stringsTableView deselectAll:nil];
    [self commitChanges:nil];
    
    NSInteger newIndex = self.currentLanguageStrings.count;
    [self.stringsTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:(NSUInteger)newIndex] byExtendingSelection:NO];
}

- (IBAction)deleteString:(id)sender {
    NSInteger selectedRow = self.stringsTableView.selectedRow;
    if (selectedRow < 0 || selectedRow >= self.currentLanguageStrings.count) return;
    
    @try {
        StrToken *item = self.currentLanguageStrings[(NSUInteger)selectedRow];
        [self.wrapper removeStrToken:item];
        [self.currentLanguageStrings removeObjectAtIndex:(NSUInteger)selectedRow];
        [self.stringsTableView reloadData];
        [self languageChanged:nil];
        self.wrapper.changed = YES;
    }
    @catch (NSException *exception) {
        [ExceptionForm showError:[[Localization shared] getString:@"errconvert"]];
    }
}

- (IBAction)commitChanges:(nullable id)sender {
    if (self.isUpdatingUI || !self.wrapper) return;
    
    NSInteger selectedLanguageIndex = self.languageComboBox.indexOfSelectedItem;
    if (selectedLanguageIndex < 0) return;
    
    self.isUpdatingUI = YES;
    
    @try {
        StrLanguage *selectedLanguage = [self.wrapper.languages objectAtIndex:(NSUInteger)selectedLanguageIndex];
        NSInteger selectedRow = self.stringsTableView.selectedRow;
        
        if (selectedRow < 0) {
            // Add new string
            StrToken *newString = [[StrToken alloc] initWithIndex:(NSInteger)self.currentLanguageStrings.count
                                                                   languageId:selectedLanguage.languageId
                                                                        title:self.valueTextView.string
                                                                  description:self.descriptionTextView.string];
            [self.wrapper addStrToken:newString];
            [self.currentLanguageStrings addObject:newString];
            [self.stringsTableView reloadData];
        } else {
            // Update existing string
            StrToken *existingString = self.currentLanguageStrings[(NSUInteger)selectedRow];
            existingString.title = self.valueTextView.string;
            existingString.strDescription = self.descriptionTextView.string;
            [self.stringsTableView reloadData];
        }
        
        self.wrapper.changed = YES;
    }
    @catch (NSException *exception) {
        [ExceptionForm showError:[[Localization shared] getString:@"errconvert"]];
    }
    @finally {
        self.isUpdatingUI = NO;
    }
}

- (IBAction)addToAllLanguages:(id)sender {
    @try {
        // Find longest string list
        NSInteger maxCount = 0;
        for (StrLanguage *language in self.wrapper.languages) {
            NSInteger count = [self.wrapper languageItemsForStrLanguage:language].count;
            maxCount = MAX(maxCount, count);
        }
        
        // Add to all languages
        for (StrLanguage *language in self.wrapper.languages) {
            if (!language) continue;
            
            // Pad with empty strings if needed
                        while ([self.wrapper languageItemsForStrLanguage:language].count < maxCount) {
                            StrToken *emptyString = [[StrToken alloc] initWithIndex:(NSInteger)[self.wrapper languageItemsForStrLanguage:language].count
                                                                         languageId:language.languageId
                                                                              title:@""
                                                                        description:@""];
                [self.wrapper addStrToken:emptyString];
            }
            
            // Add the new string
            StrToken *newString = [[StrToken alloc] initWithIndex:(NSInteger)[self.wrapper languageItemsForStrLanguage:language].count
                                 languageId:language.languageId
                                      title:self.valueTextView.string
                                description:self.descriptionTextView.string];
            
            [self.wrapper addStrToken:newString];
        }
        
        [self languageChanged:nil];
        self.wrapper.changed = YES;
    }
    @catch (NSException *exception) {
        [ExceptionForm showError:[[Localization shared] getString:@"errconvert"]];
    }
}

- (IBAction)changeInAllLanguages:(id)sender {
    NSInteger selectedRow = self.stringsTableView.selectedRow;
    if (selectedRow < 0) return;
    
    @try {
        StrToken *currentString = self.currentLanguageStrings[(NSUInteger)selectedRow];
        currentString.title = self.valueTextView.string;
        currentString.strDescription = self.descriptionTextView.string;
        
        for (StrLanguage *language in self.wrapper.languages) {
            if (!language) continue;
            
            // Pad with empty strings if needed
            while ([self.wrapper languageItemsForStrLanguage:language].count <= selectedRow) {
                StrToken *emptyString = [[StrToken alloc] initWithIndex:(uint16_t)[self.wrapper languageItemsForStrLanguage:language].count
                                     languageId:language.languageId
                                          title:@""
                                    description:@""];
                
                [self.wrapper addStrToken:emptyString];
            }
            
            // Update the string at this index
            NSArray<StrToken *> *languageStrings = [self.wrapper languageItemsForStrLanguage:language];
            if (selectedRow < languageStrings.count) {
                StrToken *stringToUpdate = languageStrings[(NSUInteger)selectedRow];
                stringToUpdate.title = currentString.title;
                stringToUpdate.strDescription = currentString.strDescription;
            }
        }
        
        [self languageChanged:nil];
        self.wrapper.changed = YES;
    }
    @catch (NSException *exception) {
        [ExceptionForm showError:[[Localization shared] getString:@"errconvert"]];
    }
}

- (IBAction)deleteInAllLanguages:(id)sender {
    NSInteger selectedRow = self.stringsTableView.selectedRow;
    if (selectedRow < 0) return;
    
    @try {
        for (StrLanguage *language in self.wrapper.languages) {
            NSMutableArray<StrToken *> *languageStrings = [[self.wrapper languageItemsForStrLanguage:language] mutableCopy];
            if (selectedRow < languageStrings.count) {
                [languageStrings removeObjectAtIndex:(NSUInteger)selectedRow];
            }
        }
        
        [self.currentLanguageStrings removeObjectAtIndex:(NSUInteger)selectedRow];
        [self languageChanged:nil];
        self.wrapper.changed = YES;
    }
    @catch (NSException *exception) {
        [ExceptionForm showError:[[Localization shared] getString:@"errconvert"]];
    }
}

- (IBAction)clearStrings:(id)sender {
    @try {
        self.wrapper.items = [[StrItemList alloc] init];
        [self.languageComboBox removeAllItems];
        
        StrLanguageList *languages = [[StrLanguageList alloc] init];
        for (int i = 1; i < 45; i++) {
            StrLanguage *language = [[StrLanguage alloc] initWithLanguageId:(uint8_t)i];
            [self.languageComboBox addItemWithObjectValue:language];
            [languages addObject:language];
        }
        
        self.wrapper.languages = languages;
        [self.languageComboBox selectItemAtIndex:0];
        [self languageChanged:nil];
    }
    @catch (NSException *exception) {
        // Handle silently
    }
}

- (IBAction)commitFile:(id)sender {
    @try {
        if (self.stringsTableView.selectedRow >= 0) {
            [self commitChanges:nil];
        }
        
        [self.wrapper synchronizeUserData];
        
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = [[Localization shared] getString:@"committed"] ?: @"Changes committed successfully";
        alert.alertStyle = NSAlertStyleInformational;
        [alert runModal];
    }
    @catch (NSException *exception) {
        [ExceptionForm showError:[[Localization shared] getString:@"error writing file"]];
    }
}

#if DEBUG
- (IBAction)createTextFile:(id)sender {
    @try {
        NSMutableString *list = [[NSMutableString alloc] init];
        for (NSInteger i = 0; i < self.currentLanguageStrings.count; i++) {
            StrToken *item = self.currentLanguageStrings[(NSUInteger)i];
            [list appendFormat:@"0x%lX: %@ (%@)\n", i, item.title, item.strDescription];
        }
        
        NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
        [pasteboard clearContents];
        [pasteboard setString:list forType:NSPasteboardTypeString];
    }
    @catch (NSException *exception) {
        // Handle silently
    }
}
#endif

- (IBAction)enableAllLanguages:(id)sender {
    StrLanguageList *languages = [[StrLanguageList alloc] init];
    [self.languageComboBox removeAllItems];
    
    for (uint8_t i = 1; i < 45; i++) {
        StrLanguage *language = [[StrLanguage alloc] initWithLanguageId:i];
        [languages addObject:language];
        [self.languageComboBox addItemWithObjectValue:language];
    }
    
    self.wrapper.languages = languages;
    self.wrapper.changed = YES;
    
    if (self.languageComboBox.numberOfItems > 0) {
        [self.languageComboBox selectItemAtIndex:0];
    }
}

// MARK: - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if (tableView == self.stringsTableView) {
        return self.currentLanguageStrings.count;
    }
    return 0;
}

- (nullable id)tableView:(NSTableView *)tableView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    if (tableView == self.stringsTableView && row < self.currentLanguageStrings.count) {
        StrToken *token = self.currentLanguageStrings[(NSUInteger)row];
        return token.title ?: @"";
    }
    return @"";
}

// MARK: - NSTableViewDelegate

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    if (notification.object == self.stringsTableView) {
        [self stringSelectionChanged:self.stringsTableView];
    }
}

// MARK: - NSComboBoxDataSource

- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)comboBox {
    if (comboBox == self.languageComboBox && self.wrapper) {
        return self.wrapper.languages.count;
    }
    return 0;
}

- (nullable id)comboBox:(NSComboBox *)comboBox objectValueForItemAtIndex:(NSInteger)index {
    if (comboBox == self.languageComboBox && self.wrapper && index < self.wrapper.languages.count) {
        return [self.wrapper.languages objectAtIndex:(NSUInteger)index];
    }
    return nil;
}

// MARK: - NSComboBoxDelegate

- (void)comboBoxSelectionDidChange:(NSNotification *)notification {
    if (notification.object == self.languageComboBox) {
        [self languageChanged:self.languageComboBox];
    }
}

// MARK: - NSTextViewDelegate

- (void)textDidChange:(NSNotification *)notification {
    if (notification.object == self.valueTextView || notification.object == self.descriptionTextView) {
        [self textChanged:notification.object];
    }
}

@end
