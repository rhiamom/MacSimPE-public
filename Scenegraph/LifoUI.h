//
//  LifoUI.h
//  MacSimpe
//
//  Created by Catherine Gramze on 8/28/25.
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
#import "IPackedFileUI.h"

@class Lifo;
@class LevelInfo;
@protocol IFileWrapper;

NS_ASSUME_NONNULL_BEGIN

/**
 * This class is used to fill the UI for this FileType with Data
 */
@interface LifoUI : NSObject <IPackedFileUI>

/**
 * The associated LIFO wrapper
 */
@property (nonatomic, weak) Lifo *wrapper;
// IPackedFileUI requires a GUI view; expose it here.
@property (nonatomic, strong, readonly) NSView *guiHandle;

// MARK: - UI Controls (IBOutlets)

// Main container panel
@property (nonatomic, strong) IBOutlet NSView *lifoPanel;

// Top toolbar
@property (nonatomic, strong) IBOutlet NSView *panel2;
@property (nonatomic, strong) IBOutlet NSTextField *label27;
@property (nonatomic, strong) IBOutlet NSButton *btcommit;
@property (nonatomic, strong) IBOutlet NSButton *btim;
@property (nonatomic, strong) IBOutlet NSButton *btex;

// Left panel controls
@property (nonatomic, strong) IBOutlet NSComboBox *cbitem;
@property (nonatomic, strong) IBOutlet NSTextField *label2;
@property (nonatomic, strong) IBOutlet NSTextField *tbflname;
@property (nonatomic, strong) IBOutlet NSComboBox *cbformats;
@property (nonatomic, strong) IBOutlet NSTextField *label3;
@property (nonatomic, strong) IBOutlet NSTextField *label4;
@property (nonatomic, strong) IBOutlet NSTextField *tbwidth;
@property (nonatomic, strong) IBOutlet NSTextField *tbheight;
@property (nonatomic, strong) IBOutlet NSTextField *label5;
@property (nonatomic, strong) IBOutlet NSTextField *tbz;
@property (nonatomic, strong) IBOutlet NSTextField *label1;

// Link labels for utility functions
@property (nonatomic, strong) IBOutlet NSButton *linkLabel1; // assign Hash
@property (nonatomic, strong) IBOutlet NSButton *linkLabel2; // fix TGI

// Image display area
@property (nonatomic, strong) IBOutlet NSView *panel1;
@property (nonatomic, strong) IBOutlet NSScrollView *scrollView;
@property (nonatomic, strong) IBOutlet NSImageView *pb;

// File dialogs
@property (nonatomic, strong) NSSavePanel *sfd;
@property (nonatomic, strong) NSOpenPanel *ofd;

// Context menu
@property (nonatomic, strong) NSMenu *contextMenu1;
@property (nonatomic, strong) NSMenuItem *menuItem1; // Import...
@property (nonatomic, strong) NSMenuItem *menuItem4; // Import Alpha Channel...
@property (nonatomic, strong) NSMenuItem *menuItem3; // Import DDS...
@property (nonatomic, strong) NSMenuItem *menuItem6; // Build DXT...
@property (nonatomic, strong) NSMenuItem *menuItem7; // Separator
@property (nonatomic, strong) NSMenuItem *menuItem2; // Export...
@property (nonatomic, strong) NSMenuItem *menuItem5; // Export Alpha Channel...

@property (nonatomic, assign) BOOL isUpdatingUI;
// MARK: - Initialization

/**
 * Constructor for the Class
 */
- (instancetype)init;

- (instancetype)initWithWrapper:(Lifo *)wrapper;

// MARK: - Action Methods (IBActions)

/**
 * Commit changes to wrapper
 */
- (IBAction)btcommitClick:(id)sender;

/**
 * Export image to file
 */
- (IBAction)btexClick:(id)sender;

/**
 * Import image from file
 */
- (IBAction)btimClick:(id)sender;

/**
 * Item selection changed
 */
- (IBAction)selectItem:(id)sender;

/**
 * Filename text changed
 */
- (IBAction)fileNameChanged:(id)sender;

/**
 * Format selection changed
 */
- (IBAction)changeFormat:(id)sender;

/**
 * Z-level changed
 */
- (IBAction)changeZLevel:(id)sender;

/**
 * Fix TGI link clicked
 */
- (IBAction)fixTGI:(id)sender;

/**
 * Build filename link clicked
 */
- (IBAction)buildFilename:(id)sender;

// MARK: - Context Menu Actions

/**
 * Import alpha channel from file
 */
- (IBAction)importAlpha:(id)sender;

/**
 * Export alpha channel to file
 */
- (IBAction)exportAlpha:(id)sender;

/**
 * Import DDS file
 */
- (IBAction)importDDS:(id)sender;

/**
 * Build DXT texture
 */
- (IBAction)buildDXT:(id)sender;

// MARK: - Utility Methods

/**
 * Get the currently selected level info, creating one if needed
 */
- (LevelInfo *)selectedLevelInfo;

/**
 * Get the currently selected image data
 */
- (LevelInfo *)selectedImageData;

/**
 * Extract alpha channel from image as grayscale
 */
- (NSImage *)getAlpha:(NSImage *)img;

/**
 * Apply alpha channel from grayscale image
 */
- (NSImage *)changeAlpha:(NSImage *)img alpha:(NSImage *)alpha;

/**
 * Crop image to correct aspect ratio
 */
- (nullable NSImage *)cropImage:(LevelInfo *)levelInfo image:(NSImage *)img;

/**
 * Load DDS data into the form
 */
- (void)loadDDS:(NSArray<DDSData *> *)data;

// MARK: - UI Setup

/**
 * Setup the user interface
 */
- (void)setupUI;

/**
 * Setup context menu
 */
- (void)setupContextMenu;

/**
 * Update UI for selected item
 */
- (void)updateUIForSelectedItem;

@end

NS_ASSUME_NONNULL_END
