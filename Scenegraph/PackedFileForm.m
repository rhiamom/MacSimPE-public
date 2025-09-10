//
//  PackedFileForm.m
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

#import "PackedFileForm.h"
#import "Helper.h"
#import "ExceptionForm.h"
#import "IFileWrapperSaveExtension.h"
#import "IPackedFileDescriptor.h"
#import "TypeAlias.h"
#import "MetaData.h"
#import "PackedFileWrapper.h"
#import "PackedFileItem.h"
#import "GenericRcolWrapper.h"
#import "cImageData.h"
#import "PackedFileDescriptor.h"
#import "FileSelect.h"
#import "PackageFiles.h"
#import "Localization.h"

@implementation RefFileForm

// MARK: - Initialization

- (instancetype)init {
    self = [super initWithWindowNibName:nil];
    if (self) {
        self.fileDescriptors = [[NSMutableArray alloc] init];
        self.isUpdatingFields = NO;
        [self setupUI];
    }
    return self;
}

- (instancetype)initWithWrapper:(id<IFileWrapperSaveExtension>)wrapper {
    self = [self init];
    if (self) {
        self.wrapper = wrapper;
        [self reloadFileList];
    }
    return self;
}

- (void)loadWindow {
    NSWindow *window = [[NSWindow alloc] initWithContentRect:NSMakeRect(100, 100, 856, 350)
                                                   styleMask:NSWindowStyleMaskTitled |
                                                            NSWindowStyleMaskClosable |
                                                            NSWindowStyleMaskMiniaturizable |
                                                            NSWindowStyleMaskResizable
                                                     backing:NSBackingStoreBuffered
                                                       defer:NO];
    [window setTitle:@"3D Referencing File Editor"];
    [window setMinSize:NSMakeSize(600, 300)];
    
    self.window = window;
    [self setupUI];
}

// MARK: - UI Setup

- (void)setupUI {
    if (!self.window) {
        [self loadWindow];
    }
    
    NSView *contentView = self.window.contentView;
    
    // Create wrapper scroll view
    self.wrapperScrollView = [[NSScrollView alloc] init];
    [self.wrapperScrollView setHasVerticalScroller:YES];
    [self.wrapperScrollView setHasHorizontalScroller:YES];
    [self.wrapperScrollView setAutohidesScrollers:YES];
    [self.wrapperScrollView setBorderType:NSNoBorder];
    [self.wrapperScrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    // Create wrapper panel
    self.wrapperPanel = [[NSView alloc] init];
    [self.wrapperPanel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.wrapperScrollView setDocumentView:self.wrapperPanel];
    
    // Create header panel
    self.headerPanel = [[NSView alloc] init];
    [self.headerPanel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.headerPanel setWantsLayer:YES];
    self.headerPanel.layer.backgroundColor = [NSColor controlBackgroundColor].CGColor;
    
    self.titleLabel = [[NSTextField alloc] init];
    [self.titleLabel setStringValue:@"3D Referencing File Editor"];
    [self.titleLabel setBezeled:NO];
    [self.titleLabel setDrawsBackground:NO];
    [self.titleLabel setEditable:NO];
    [self.titleLabel setSelectable:NO];
    [self.titleLabel setFont:[NSFont boldSystemFontOfSize:12]];
    [self.titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.headerPanel addSubview:self.titleLabel];
    
    // Create file list table view
    [self setupTableView];
    
    // Create image view
    self.imageView = [[NSImageView alloc] init];
    [self.imageView setImageScaling:NSImageScaleProportionallyUpOrDown];
    [self.imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.imageView setWantsLayer:YES];
    self.imageView.layer.borderWidth = 1.0;
    self.imageView.layer.borderColor = [NSColor separatorColor].CGColor;
    
    // Create control buttons
    [self setupControlButtons];
    
    // Create file properties box
    [self setupFilePropertiesBox];
    
    // Add all subviews to wrapper panel
    [self.wrapperPanel addSubview:self.headerPanel];
    [self.wrapperPanel addSubview:self.fileListScrollView];
    [self.wrapperPanel addSubview:self.upButton];
    [self.wrapperPanel addSubview:self.downButton];
    [self.wrapperPanel addSubview:self.commitAllButton];
    [self.wrapperPanel addSubview:self.filePropertiesBox];
    [self.wrapperPanel addSubview:self.imageView];
    
    // Add wrapper scroll view to content view
    [contentView addSubview:self.wrapperScrollView];
    
    [self setupConstraints];
    [self loadTypeAliases];
    [self updateButtonStates];
}

- (void)setupTableView {
    self.fileListScrollView = [[NSScrollView alloc] init];
    [self.fileListScrollView setHasVerticalScroller:YES];
    [self.fileListScrollView setHasHorizontalScroller:YES];
    [self.fileListScrollView setAutohidesScrollers:YES];
    [self.fileListScrollView setBorderType:NSBezelBorder];
    [self.fileListScrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    self.fileListTableView = [[NSTableView alloc] init];
    [self.fileListTableView setDataSource:self];
    [self.fileListTableView setDelegate:self];
    [self.fileListTableView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleRegular];
    [self.fileListTableView setAllowsMultipleSelection:NO];
    [self.fileListTableView setHeaderView:nil];
    
    // Add single column for file descriptors
    NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:@"FileDescriptor"];
    [column setTitle:@"Files"];
    [column setWidth:200];
    [self.fileListTableView addTableColumn:column];
    
    [self.fileListScrollView setDocumentView:self.fileListTableView];
    
    // Register for drag and drop
    [self.fileListTableView registerForDraggedTypes:@[@"PackedFileDescriptor"]];
}

- (void)setupControlButtons {
    // Up button
    self.upButton = [[NSButton alloc] init];
    [self.upButton setTitle:@"up"];
    [self.upButton setTarget:self];
    [self.upButton setAction:@selector(moveUp:)];
    [self.upButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    // Down button
    self.downButton = [[NSButton alloc] init];
    [self.downButton setTitle:@"down"];
    [self.downButton setTarget:self];
    [self.downButton setAction:@selector(moveDown:)];
    [self.downButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    // Commit All button
    self.commitAllButton = [[NSButton alloc] init];
    [self.commitAllButton setTitle:@"Commit"];
    [self.commitAllButton setTarget:self];
    [self.commitAllButton setAction:@selector(commitAll:)];
    [self.commitAllButton setTranslatesAutoresizingMaskIntoConstraints:NO];
}

- (void)setupFilePropertiesBox {
    self.filePropertiesBox = [[NSBox alloc] init];
    [self.filePropertiesBox setTitle:@"File Properties"];
    [self.filePropertiesBox setTitleFont:[NSFont boldSystemFontOfSize:11]];
    [self.filePropertiesBox setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    self.propertiesPanel = [[NSView alloc] init];
    [self.propertiesPanel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.filePropertiesBox setContentView:self.propertiesPanel];
    
    // Create property fields and labels
    NSArray *labelTexts = @[@"File Type:", @"SubType/Class ID:", @"Group:", @"Instance:"];
    NSArray *textFields = @[@"typeTextField", @"subtypeTextField", @"groupTextField", @"instanceTextField"];
    
    CGFloat yOffset = 80;
    for (NSInteger i = 0; i < labelTexts.count; i++) {
        // Create label
        NSTextField *label = [[NSTextField alloc] init];
        [label setStringValue:labelTexts[i]];
        [label setBezeled:NO];
        [label setDrawsBackground:NO];
        [label setEditable:NO];
        [label setSelectable:NO];
        [label setAlignment:NSTextAlignmentRight];
        [label setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.propertiesPanel addSubview:label];
        
        // Create text field
        NSTextField *textField = [[NSTextField alloc] init];
        [textField setTarget:self];
        if (i == 0) {
            [textField setAction:@selector(typeTextChanged:)];
            self.typeTextField = textField;
        } else {
            [textField setAction:@selector(autoChange:)];
            if (i == 1) self.subtypeTextField = textField;
            else if (i == 2) self.groupTextField = textField;
            else if (i == 3) self.instanceTextField = textField;
        }
        [textField setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.propertiesPanel addSubview:textField];
        
        // Position constraints
        [NSLayoutConstraint activateConstraints:@[
            [label.trailingAnchor constraintEqualToAnchor:self.propertiesPanel.leadingAnchor constant:112],
            [label.topAnchor constraintEqualToAnchor:self.propertiesPanel.topAnchor constant:yOffset - (i * 24)],
            [label.widthAnchor constraintEqualToConstant:112],
            [label.heightAnchor constraintEqualToConstant:17],
            
            [textField.leadingAnchor constraintEqualToAnchor:self.propertiesPanel.leadingAnchor constant:120],
            [textField.topAnchor constraintEqualToAnchor:self.propertiesPanel.topAnchor constant:yOffset - (i * 24)],
            [textField.widthAnchor constraintEqualToConstant:100],
            [textField.heightAnchor constraintEqualToConstant:21]
        ]];
    }
    
    // Create types popup button
    self.typesPopUpButton = [[NSPopUpButton alloc] init];
    [self.typesPopUpButton setTarget:self];
    [self.typesPopUpButton setAction:@selector(selectType:)];
    [self.typesPopUpButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.propertiesPanel addSubview:self.typesPopUpButton];
    
    // Create action buttons
    self.changeButton = [[NSButton alloc] init];
    [self.changeButton setTitle:@"change"];
    [self.changeButton setTarget:self];
    [self.changeButton setAction:@selector(changeFile:)];
    [self.changeButton setHidden:YES];
    [self.changeButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.propertiesPanel addSubview:self.changeButton];
    
    self.addButton = [[NSButton alloc] init];
    [self.addButton setTitle:@"add"];
    [self.addButton setTarget:self];
    [self.addButton setAction:@selector(addFile:)];
    [self.addButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.propertiesPanel addSubview:self.addButton];
    
    self.deleteButton = [[NSButton alloc] init];
    [self.deleteButton setTitle:@"delete"];
    [self.deleteButton setTarget:self];
    [self.deleteButton setAction:@selector(deleteFile:)];
    [self.deleteButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.propertiesPanel addSubview:self.deleteButton];
    
    self.chooseFileButton = [[NSButton alloc] init];
    [self.chooseFileButton setTitle:@"u"];
    [self.chooseFileButton setTarget:self];
    [self.chooseFileButton setAction:@selector(chooseFile:)];
    [self.chooseFileButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.propertiesPanel addSubview:self.chooseFileButton];
    
    self.packageButton = [[NSButton alloc] init];
    [self.packageButton setTitle:@"Package"];
    [self.packageButton setTarget:self];
    [self.packageButton setAction:@selector(showPackageSelector:)];
    [self.packageButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.propertiesPanel addSubview:self.packageButton];
    
    // Position constraints for popup and buttons
    [NSLayoutConstraint activateConstraints:@[
        [self.typesPopUpButton.leadingAnchor constraintEqualToAnchor:self.propertiesPanel.leadingAnchor constant:224],
        [self.typesPopUpButton.topAnchor constraintEqualToAnchor:self.propertiesPanel.topAnchor constant:80],
        [self.typesPopUpButton.widthAnchor constraintEqualToConstant:240],
        [self.typesPopUpButton.heightAnchor constraintEqualToConstant:26],
        
        [self.changeButton.leadingAnchor constraintEqualToAnchor:self.propertiesPanel.leadingAnchor constant:328],
        [self.changeButton.bottomAnchor constraintEqualToAnchor:self.propertiesPanel.bottomAnchor constant:-8],
        
        [self.addButton.leadingAnchor constraintEqualToAnchor:self.propertiesPanel.leadingAnchor constant:384],
        [self.addButton.bottomAnchor constraintEqualToAnchor:self.propertiesPanel.bottomAnchor constant:-8],
        
        [self.deleteButton.leadingAnchor constraintEqualToAnchor:self.propertiesPanel.leadingAnchor constant:416],
        [self.deleteButton.bottomAnchor constraintEqualToAnchor:self.propertiesPanel.bottomAnchor constant:-8],
        
        [self.chooseFileButton.trailingAnchor constraintEqualToAnchor:self.packageButton.leadingAnchor constant:-5],
        [self.chooseFileButton.topAnchor constraintEqualToAnchor:self.propertiesPanel.topAnchor constant:28],
        [self.chooseFileButton.widthAnchor constraintEqualToConstant:21],
        [self.chooseFileButton.heightAnchor constraintEqualToConstant:21],
        
        [self.packageButton.trailingAnchor constraintEqualToAnchor:self.propertiesPanel.trailingAnchor constant:-8],
        [self.packageButton.topAnchor constraintEqualToAnchor:self.propertiesPanel.topAnchor constant:28],
        [self.packageButton.widthAnchor constraintEqualToConstant:72],
        [self.packageButton.heightAnchor constraintEqualToConstant:21]
    ]];
}

- (void)setupConstraints {
    [NSLayoutConstraint activateConstraints:@[
        // Wrapper scroll view fills content view
        [self.wrapperScrollView.topAnchor constraintEqualToAnchor:self.window.contentView.topAnchor constant:8],
        [self.wrapperScrollView.leadingAnchor constraintEqualToAnchor:self.window.contentView.leadingAnchor constant:8],
        [self.wrapperScrollView.trailingAnchor constraintEqualToAnchor:self.window.contentView.trailingAnchor constant:-8],
        [self.wrapperScrollView.bottomAnchor constraintEqualToAnchor:self.window.contentView.bottomAnchor constant:-8],
        
        // Wrapper panel size
        [self.wrapperPanel.widthAnchor constraintEqualToConstant:664],
        [self.wrapperPanel.heightAnchor constraintEqualToConstant:328],
        
        // Header panel
        [self.headerPanel.topAnchor constraintEqualToAnchor:self.wrapperPanel.topAnchor],
        [self.headerPanel.leadingAnchor constraintEqualToAnchor:self.wrapperPanel.leadingAnchor],
        [self.headerPanel.trailingAnchor constraintEqualToAnchor:self.wrapperPanel.trailingAnchor],
        [self.headerPanel.heightAnchor constraintEqualToConstant:24],
        
        // Title label in header
        [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.headerPanel.leadingAnchor constant:8],
        [self.titleLabel.centerYAnchor constraintEqualToAnchor:self.headerPanel.centerYAnchor],
        
        // File list
        [self.fileListScrollView.topAnchor constraintEqualToAnchor:self.headerPanel.bottomAnchor constant:8],
        [self.fileListScrollView.leadingAnchor constraintEqualToAnchor:self.wrapperPanel.leadingAnchor constant:8],
        [self.fileListScrollView.widthAnchor constraintEqualToConstant:160],
        [self.fileListScrollView.bottomAnchor constraintEqualToAnchor:self.wrapperPanel.bottomAnchor constant:-8],
        
        // Control buttons
        [self.upButton.topAnchor constraintEqualToAnchor:self.headerPanel.bottomAnchor constant:136],
        [self.upButton.leadingAnchor constraintEqualToAnchor:self.fileListScrollView.trailingAnchor constant:8],
        [self.upButton.widthAnchor constraintEqualToConstant:48],
        [self.upButton.heightAnchor constraintEqualToConstant:23],
        
        [self.downButton.topAnchor constraintEqualToAnchor:self.upButton.bottomAnchor constant:8],
        [self.downButton.leadingAnchor constraintEqualToAnchor:self.upButton.leadingAnchor],
        [self.downButton.widthAnchor constraintEqualToConstant:48],
        [self.downButton.heightAnchor constraintEqualToConstant:23],
        
        [self.commitAllButton.topAnchor constraintEqualToAnchor:self.downButton.bottomAnchor constant:8],
        [self.commitAllButton.leadingAnchor constraintEqualToAnchor:self.upButton.leadingAnchor],
        [self.commitAllButton.widthAnchor constraintEqualToConstant:56],
        [self.commitAllButton.heightAnchor constraintEqualToConstant:23],
        
        // File properties box
        [self.filePropertiesBox.topAnchor constraintEqualToAnchor:self.headerPanel.bottomAnchor constant:8],
        [self.filePropertiesBox.leadingAnchor constraintEqualToAnchor:self.upButton.trailingAnchor constant:8],
        [self.filePropertiesBox.widthAnchor constraintEqualToConstant:480],
        [self.filePropertiesBox.heightAnchor constraintEqualToConstant:128],
        
        // Image view
        [self.imageView.topAnchor constraintEqualToAnchor:self.filePropertiesBox.bottomAnchor constant:8],
        [self.imageView.leadingAnchor constraintEqualToAnchor:self.upButton.trailingAnchor constant:64],
        [self.imageView.widthAnchor constraintEqualToConstant:160],
        [self.imageView.bottomAnchor constraintEqualToAnchor:self.wrapperPanel.bottomAnchor constant:-8]
    ]];
}

- (void)loadTypeAliases {
    [self.typesPopUpButton removeAllItems];
    
    // This would need to be implemented based on your MetaData.typeAliases structure
    // For now, adding placeholder items
    [self.typesPopUpButton addItemWithTitle:@"Select Type..."];
    // NSArray *typeAliases = [MetaData typeAliases];
    // for (TypeAlias *alias in typeAliases) {
    //     [self.typesPopUpButton addItemWithTitle:alias.name];
    // }
}

// MARK: - Actions

- (IBAction)selectType:(id)sender {
    if (self.isUpdatingFields) return;
    
    NSInteger selectedIndex = [self.typesPopUpButton indexOfSelectedItem];
    if (selectedIndex <= 0) return;
    
    // This needs to be implemented based on your TypeAlias structure
    // TypeAlias *selectedAlias = [MetaData typeAliases][selectedIndex - 1];
    // [self.typeTextField setStringValue:[NSString stringWithFormat:@"0x%@", [Helper hexString:selectedAlias.id]]];
}

- (IBAction)typeTextChanged:(id)sender {
    self.isUpdatingFields = YES;
    
    @try {
        NSString *typeText = [self.typeTextField stringValue];
        uint32_t typeValue = [Helper hexStringToUInt:typeText];
        
        // Find matching type alias
        // TypeAlias *matchingAlias = [MetaData findTypeAlias:typeValue];
        
        [self autoChange:sender];
        
        // Update popup button selection
        // Implementation would depend on your MetaData structure
        
    } @catch (NSException *exception) {
        [ExceptionForm execute:exception];
    } @finally {
        self.isUpdatingFields = NO;
    }
}

- (IBAction)autoChange:(id)sender {
    if (self.isUpdatingFields) return;
    
    self.isUpdatingFields = YES;
    NSInteger selectedRow = [self.fileListTableView selectedRow];
    if (selectedRow >= 0) {
        [self changeFile:nil];
    }
    self.isUpdatingFields = NO;
}

- (IBAction)selectFile:(id)sender {
    [self updateButtonStates];
    
    NSInteger selectedRow = [self.fileListTableView selectedRow];
    if (selectedRow < 0 || self.isUpdatingFields) return;
    
    @try {
        self.isUpdatingFields = YES;
        
        id<IPackedFileDescriptor> pfd = self.file
