//
//  TxtrForm.h
//  MacSimpe
//
//  Created by Catherine Gramze on 8/26/25.
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

@class Txtr;
@class ImageData;
@class MipMapBlock;
@class MipMap;

NS_ASSUME_NONNULL_BEGIN


 // UI Handler for TXTR (Texture) files
 // Complete AppKit implementation of the TXTR Editor interface

@interface TxtrForm : NSViewController <IPackedFileUI>

// MARK: - Properties

/**
 * The associated texture wrapper
 */
@property (nonatomic, weak) Txtr *wrapper;
@property (nonatomic, strong, readonly) NSView *guiHandle; // required by IPackedFileUI
// MARK: - UI Controls (IBOutlets)

// Top toolbar
@property (nonatomic, strong) IBOutlet NSButton *importButton;
@property (nonatomic, strong) IBOutlet NSButton *exportButton;
@property (nonatomic, strong) IBOutlet NSButton *commitButton;

// Left panel controls
@property (nonatomic, strong) IBOutlet NSComboBox *itemComboBox;
@property (nonatomic, strong) IBOutlet NSTextField *filenameTextField;
@property (nonatomic, strong) IBOutlet NSComboBox *formatComboBox;
@property (nonatomic, strong) IBOutlet NSTextField *widthTextField;
@property (nonatomic, strong) IBOutlet NSTextField *heightTextField;
@property (nonatomic, strong) IBOutlet NSTextField *mipMapLevelTextField;
@property (nonatomic, strong) IBOutlet NSComboBox *mipMapBlockComboBox;

// Right panel - texture preview
@property (nonatomic, strong) IBOutlet NSScrollView *textureScrollView;
@property (nonatomic, strong) IBOutlet NSImageView *textureImageView;

// Bottom panel - mipmap list
@property (nonatomic, strong) IBOutlet NSTableView *mipMapTableView;
@property (nonatomic, strong) IBOutlet NSTextField *lifoReferenceTextField;

// Action links/buttons
@property (nonatomic, strong) IBOutlet NSButton *fixTgiButton;
@property (nonatomic, strong) IBOutlet NSButton *buildDefaultMipMapButton;
@property (nonatomic, strong) IBOutlet NSButton *addButton;
@property (nonatomic, strong) IBOutlet NSButton *deleteButton;

// MARK: - Initialization

- (instancetype)init;

// MARK: - IPackedFileUI Protocol

- (NSView *)createView;
- (void)refresh;
- (void)synchronize;
- (void)dispose;

// MARK: - IBActions

- (IBAction)importTexture:(id)sender;
- (IBAction)exportTexture:(id)sender;
- (IBAction)commitChanges:(id)sender;
- (IBAction)itemSelectionChanged:(id)sender;
- (IBAction)filenameChanged:(id)sender;
- (IBAction)formatChanged:(id)sender;
- (IBAction)sizeChanged:(id)sender;
- (IBAction)mipMapLevelChanged:(id)sender;
- (IBAction)mipMapBlockSelectionChanged:(id)sender;
- (IBAction)fixTgi:(id)sender;
- (IBAction)buildDefaultMipMap:(id)sender;
- (IBAction)addMipMap:(id)sender;
- (IBAction)deleteMipMap:(id)sender;

// MARK: - Context Menu Actions

- (IBAction)importAlphaChannel:(id)sender;
- (IBAction)exportAlphaChannel:(id)sender;
- (IBAction)importDDS:(id)sender;
- (IBAction)buildDXT:(id)sender;
- (IBAction)updateAllSizes:(id)sender;
- (IBAction)importLocalLifo:(id)sender;

// MARK: - Private Methods

- (void)setupUI;
- (void)populateFormatComboBox;
- (void)updateTexturePreview;
- (void)updateMipMapList;
- (ImageData *)selectedImageData;
- (MipMapBlock *)selectedMipMapBlock:(ImageData *)imageData;
- (NSImage *)cropImage:(ImageData *)imageData image:(NSImage *)image;
- (NSImage *)getAlphaChannel:(NSImage *)image;
- (NSImage *)changeAlphaChannel:(NSImage *)baseImage alphaImage:(NSImage *)alphaImage;

@end

NS_ASSUME_NONNULL_END
