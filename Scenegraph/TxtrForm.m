//
//  TxtrForm.m
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

#import "TxtrForm.h"
#import "TxtrWrapper.h"
#import "cImageData.h"
#import "Helper.h"
#import "Localization.h"
#import <AppKit/AppKit.h>
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

@interface TxtrForm () <NSTableViewDataSource, NSTableViewDelegate>

// MARK: - Private Properties
@property (nonatomic, strong) NSView *mainView;
@property (nonatomic, strong) NSMutableArray<MipMap *> *currentMipMaps;
@property (nonatomic, assign) BOOL updatingControls;

@end
static NSImage *scaleImageToSize(NSImage *source, NSSize targetSize) {
    if (!source || targetSize.width <= 0 || targetSize.height <= 0) return nil;
    NSImage *result = [[NSImage alloc] initWithSize:targetSize];
    [result lockFocus];
    NSGraphicsContext *ctx = [NSGraphicsContext currentContext];
    NSImageInterpolation old = ctx.imageInterpolation;
    ctx.imageInterpolation = NSImageInterpolationHigh;
    
    [source drawInRect:(NSRect){.origin = NSZeroPoint, .size = targetSize}
              fromRect:NSZeroRect
             operation:NSCompositingOperationCopy
              fraction:1.0
        respectFlipped:YES
                 hints:nil];
    
    ctx.imageInterpolation = old;
    [result unlockFocus];
    return result;
}

@implementation TxtrForm
// MARK: - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        _currentMipMaps = [[NSMutableArray alloc] init];
        _updatingControls = NO;
    }
    return self;
}

// MARK: - IPackedFileUI Protocol

- (NSView *)createView {
    if (!_mainView) {
        [self setupUI];
    }
    return _mainView;
}

- (void)refresh {
    if (!_wrapper) return;
    
    [self populateItemComboBox];
    [self populateFormatComboBox];
}

- (void)synchronize {
    // Save any pending changes back to the wrapper
    if (_wrapper) {
        [_wrapper synchronizeUserData];
    }
}

- (void)dispose {
    _wrapper = nil;
    _mainView = nil;
    [_currentMipMaps removeAllObjects];
}

// MARK: - UI Setup

- (void)setupUI {
    // Create main container view
    _mainView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 800, 320)];
    
    // Create toolbar
    [self createToolbar];
    
    // Create left panel with controls
    [self createControlsPanel];
    
    // Create right panel with texture preview
    [self createTexturePreviewPanel];
    
    // Create bottom panel with mipmap list
    [self createMipMapListPanel];
    
    // Setup initial state
    [self populateFormatComboBox];
}

- (void)createToolbar {
    // Toolbar panel
    NSView *toolbarPanel = [[NSView alloc] initWithFrame:NSMakeRect(0, 296, 800, 24)];
    toolbarPanel.wantsLayer = YES;
    toolbarPanel.layer.backgroundColor = [[NSColor controlColor] CGColor];
    
    // Title label
    NSTextField *titleLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(8, 4, 100, 16)];
    titleLabel.stringValue = @"TXTR Editor";
    titleLabel.font = [NSFont boldSystemFontOfSize:10];
    titleLabel.editable = NO;
    titleLabel.bordered = NO;
    titleLabel.backgroundColor = [NSColor clearColor];
    [toolbarPanel addSubview:titleLabel];
    
    // Import button
    self.importButton = [[NSButton alloc] initWithFrame:NSMakeRect(520, 0, 80, 23)];
    [_importButton setTitle:@"Import..."];
    [_importButton setTarget:self];
    [_importButton setAction:@selector(importTexture:)];
    [toolbarPanel addSubview:_importButton];
    
    // Export button
    _exportButton = [[NSButton alloc] initWithFrame:NSMakeRect(608, 0, 80, 23)];
    [_exportButton setTitle:@"Export..."];
    [_exportButton setTarget:self];
    [_exportButton setAction:@selector(exportTexture:)];
    [toolbarPanel addSubview:_exportButton];
    
    // Commit button
    _commitButton = [[NSButton alloc] initWithFrame:NSMakeRect(696, 0, 80, 23)];
    [_commitButton setTitle:@"Commit"];
    [_commitButton setTarget:self];
    [_commitButton setAction:@selector(commitChanges:)];
    [toolbarPanel addSubview:_commitButton];
    
    [_mainView addSubview:toolbarPanel];
}

- (void)createControlsPanel {
    // Item ComboBox
    NSTextField *itemLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(8, 262, 70, 16)];
    itemLabel.stringValue = @"Item:";
    itemLabel.font = [NSFont boldSystemFontOfSize:8];
    itemLabel.editable = NO;
    itemLabel.bordered = NO;
    itemLabel.backgroundColor = [NSColor clearColor];
    [_mainView addSubview:itemLabel];
    
    _itemComboBox = [[NSComboBox alloc] initWithFrame:NSMakeRect(80, 260, 344, 21)];
    [_itemComboBox setTarget:self];
    [_itemComboBox setAction:@selector(itemSelectionChanged:)];
    [_mainView addSubview:_itemComboBox];
    
    // Filename
    NSTextField *filenameLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(8, 238, 70, 16)];
    filenameLabel.stringValue = @"Filename:";
    filenameLabel.font = [NSFont boldSystemFontOfSize:8];
    filenameLabel.editable = NO;
    filenameLabel.bordered = NO;
    filenameLabel.backgroundColor = [NSColor clearColor];
    [_mainView addSubview:filenameLabel];
    
    _filenameTextField = [[NSTextField alloc] initWithFrame:NSMakeRect(80, 236, 344, 21)];
    [_filenameTextField setTarget:self];
    [_filenameTextField setAction:@selector(filenameChanged:)];
    [_mainView addSubview:_filenameTextField];
    
    // Format
    NSTextField *formatLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(8, 214, 70, 16)];
    formatLabel.stringValue = @"Format:";
    formatLabel.font = [NSFont boldSystemFontOfSize:8];
    formatLabel.editable = NO;
    formatLabel.bordered = NO;
    formatLabel.backgroundColor = [NSColor clearColor];
    [_mainView addSubview:formatLabel];
    
    _formatComboBox = [[NSComboBox alloc] initWithFrame:NSMakeRect(80, 212, 344, 21)];
    [_formatComboBox setTarget:self];
    [_formatComboBox setAction:@selector(formatChanged:)];
    [_mainView addSubview:_formatComboBox];
    
    // Size controls
    NSTextField *sizeLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(8, 190, 70, 16)];
    sizeLabel.stringValue = @"Size:";
    sizeLabel.font = [NSFont boldSystemFontOfSize:8];
    sizeLabel.editable = NO;
    sizeLabel.bordered = NO;
    sizeLabel.backgroundColor = [NSColor clearColor];
    [_mainView addSubview:sizeLabel];
    
    _widthTextField = [[NSTextField alloc] initWithFrame:NSMakeRect(80, 188, 56, 21)];
    [_widthTextField setTarget:self];
    [_widthTextField setAction:@selector(sizeChanged:)];
    [_mainView addSubview:_widthTextField];
    
    NSTextField *xLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(141, 190, 12, 16)];
    xLabel.stringValue = @"x";
    xLabel.font = [NSFont boldSystemFontOfSize:8];
    xLabel.editable = NO;
    xLabel.bordered = NO;
    xLabel.backgroundColor = [NSColor clearColor];
    [_mainView addSubview:xLabel];
    
    _heightTextField = [[NSTextField alloc] initWithFrame:NSMakeRect(160, 188, 56, 21)];
    [_heightTextField setTarget:self];
    [_heightTextField setAction:@selector(sizeChanged:)];
    [_mainView addSubview:_heightTextField];
    
    // MipMap Level
    NSTextField *levelLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(240, 190, 95, 16)];
    levelLabel.stringValue = @"MipMap Level:";
    levelLabel.font = [NSFont boldSystemFontOfSize:8];
    levelLabel.editable = NO;
    levelLabel.bordered = NO;
    levelLabel.backgroundColor = [NSColor clearColor];
    [_mainView addSubview:levelLabel];
    
    _mipMapLevelTextField = [[NSTextField alloc] initWithFrame:NSMakeRect(336, 188, 88, 21)];
    [_mipMapLevelTextField setTarget:self];
    [_mipMapLevelTextField setAction:@selector(mipMapLevelChanged:)];
    [_mainView addSubview:_mipMapLevelTextField];
    
    // Blocks ComboBox
    NSTextField *blocksLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(8, 166, 70, 16)];
    blocksLabel.stringValue = @"Blocks:";
    blocksLabel.font = [NSFont boldSystemFontOfSize:8];
    blocksLabel.editable = NO;
    blocksLabel.bordered = NO;
    blocksLabel.backgroundColor = [NSColor clearColor];
    [_mainView addSubview:blocksLabel];
    
    _mipMapBlockComboBox = [[NSComboBox alloc] initWithFrame:NSMakeRect(80, 164, 344, 21)];
    [_mipMapBlockComboBox setTarget:self];
    [_mipMapBlockComboBox setAction:@selector(mipMapBlockSelectionChanged:)];
    [_mainView addSubview:_mipMapBlockComboBox];
    
    // Action buttons
    _fixTgiButton = [[NSButton alloc] initWithFrame:NSMakeRect(288, 236, 60, 16)];
    [_fixTgiButton setTitle:@"fix TGI"];
    [_fixTgiButton setFont:[NSFont boldSystemFontOfSize:8]];
    [_fixTgiButton setTarget:self];
    [_fixTgiButton setAction:@selector(fixTgi:)];
    [_fixTgiButton setBordered:NO];
    [_mainView addSubview:_fixTgiButton];
}

- (void)createTexturePreviewPanel {
    // Texture preview scroll view
    _textureScrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(432, 32, 328, 200)];
    _textureScrollView.hasVerticalScroller = YES;
    _textureScrollView.hasHorizontalScroller = YES;
    _textureScrollView.autohidesScrollers = NO;
    
    // Image view for texture preview
    _textureImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, 200, 200)];
    _textureImageView.imageScaling = NSImageScaleProportionallyDown;
    _textureScrollView.documentView = _textureImageView;
    
    // Add context menu to image view
    NSMenu *contextMenu = [[NSMenu alloc] init];
    [contextMenu addItemWithTitle:@"Import..." action:@selector(importTexture:) keyEquivalent:@""];
    [contextMenu addItemWithTitle:@"Import Alpha Channel..." action:@selector(importAlphaChannel:) keyEquivalent:@""];
    [contextMenu addItemWithTitle:@"Import DDS..." action:@selector(importDDS:) keyEquivalent:@""];
    [contextMenu addItem:[NSMenuItem separatorItem]];
    [contextMenu addItemWithTitle:@"Export..." action:@selector(exportTexture:) keyEquivalent:@""];
    [contextMenu addItemWithTitle:@"Export Alpha Channel..." action:@selector(exportAlphaChannel:) keyEquivalent:@""];
    [contextMenu addItem:[NSMenuItem separatorItem]];
    [contextMenu addItemWithTitle:@"Update all Sizes" action:@selector(updateAllSizes:) keyEquivalent:@""];
    [contextMenu addItemWithTitle:@"Build DXT..." action:@selector(buildDXT:) keyEquivalent:@""];
    
    for (NSMenuItem *item in contextMenu.itemArray) {
        item.target = self;
    }
    
    _textureImageView.menu = contextMenu;
    [_mainView addSubview:_textureScrollView];
    
    // Help text
    NSTextField *helpLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(440, 8, 300, 16)];
    helpLabel.stringValue = @"Right click on the Image to get more Interactions.";
    helpLabel.font = [NSFont systemFontOfSize:8];
    helpLabel.textColor = [NSColor secondaryLabelColor];
    helpLabel.editable = NO;
    helpLabel.bordered = NO;
    helpLabel.backgroundColor = [NSColor clearColor];
    [_mainView addSubview:helpLabel];
}

- (void)createMipMapListPanel {
    // MipMap table view
    NSScrollView *tableScrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(8, 32, 416, 80)];
    
    _mipMapTableView = [[NSTableView alloc] init];
    _mipMapTableView.dataSource = self;
    _mipMapTableView.delegate = self;
    
    // Add columns
    NSTableColumn *nameColumn = [[NSTableColumn alloc] initWithIdentifier:@"name"];
    nameColumn.title = @"MipMap";
    nameColumn.width = 350;
    [_mipMapTableView addTableColumn:nameColumn];
    
    NSTableColumn *sizeColumn = [[NSTableColumn alloc] initWithIdentifier:@"size"];
    sizeColumn.title = @"Size";
    sizeColumn.width = 60;
    [_mipMapTableView addTableColumn:sizeColumn];
    
    tableScrollView.documentView = _mipMapTableView;
    [_mainView addSubview:tableScrollView];
    
    // Action buttons
    _buildDefaultMipMapButton = [[NSButton alloc] initWithFrame:NSMakeRect(200, 8, 137, 16)];
    [_buildDefaultMipMapButton setTitle:@"build default MipMap"];
    [_buildDefaultMipMapButton setFont:[NSFont boldSystemFontOfSize:8]];
    [_buildDefaultMipMapButton setTarget:self];
    [_buildDefaultMipMapButton setAction:@selector(buildDefaultMipMap:)];
    [_buildDefaultMipMapButton setBordered:NO];
    [_mainView addSubview:_buildDefaultMipMapButton];
    
    _addButton = [[NSButton alloc] initWithFrame:NSMakeRect(344, 8, 28, 16)];
    [_addButton setTitle:@"add"];
    [_addButton setFont:[NSFont boldSystemFontOfSize:8]];
    [_addButton setTarget:self];
    [_addButton setAction:@selector(addMipMap:)];
    [_addButton setBordered:NO];
    [_mainView addSubview:_addButton];
    
    _deleteButton = [[NSButton alloc] initWithFrame:NSMakeRect(380, 8, 44, 16)];
    [_deleteButton setTitle:@"delete"];
    [_deleteButton setFont:[NSFont boldSystemFontOfSize:8]];
    [_deleteButton setTarget:self];
    [_deleteButton setAction:@selector(deleteMipMap:)];
    [_deleteButton setBordered:NO];
    [_mainView addSubview:_deleteButton];
    
    // LIFO Reference
    NSTextField *lifoLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(432, 8, 107, 16)];
    lifoLabel.stringValue = @"LIFO Reference:";
    lifoLabel.font = [NSFont boldSystemFontOfSize:8];
    lifoLabel.editable = NO;
    lifoLabel.bordered = NO;
    lifoLabel.backgroundColor = [NSColor clearColor];
    [_mainView addSubview:lifoLabel];
    
    _lifoReferenceTextField = [[NSTextField alloc] initWithFrame:NSMakeRect(440, 24, 320, 21)];
    [_mainView addSubview:_lifoReferenceTextField];
}

- (void)populateFormatComboBox {
    [_formatComboBox removeAllItems];
    // Add texture format options based on ImageLoader.TxtrFormats
    [_formatComboBox addItemWithObjectValue:@"DXT1"];
    [_formatComboBox addItemWithObjectValue:@"DXT3"];
    [_formatComboBox addItemWithObjectValue:@"DXT5"];
    [_formatComboBox addItemWithObjectValue:@"Raw24"];
    [_formatComboBox addItemWithObjectValue:@"Raw32"];
    [_formatComboBox selectItemAtIndex:0];
}

- (void)populateItemComboBox {
    if (!_wrapper) return;
    
    [_itemComboBox removeAllItems];
    // Populate with ImageData blocks from the wrapper
    // This would be implemented based on the actual Rcol structure
}

// MARK: - IBActions

- (IBAction)importTexture:(id)sender {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    
    if (@available(macOS 12.0, *)) {
        openPanel.allowedContentTypes = @[
            UTTypePNG,
            UTTypeJPEG,
            UTTypeBMP,
            UTTypeGIF,
            UTTypeTIFF
        ];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        openPanel.allowedFileTypes = @[@"png", @"jpg", @"jpeg", @"bmp", @"gif", @"tiff", @"tif"];
#pragma clang diagnostic pop
    }
    
    openPanel.allowsMultipleSelection = NO;
    
    [openPanel beginWithCompletionHandler:^(NSInteger result) {
        if (result == NSModalResponseOK) {
            NSURL *url = openPanel.URL;
            NSImage *image = [[NSImage alloc] initWithContentsOfURL:url];
            if (image) {
                [self importImage:image];
            }
        }
    }];
}

- (IBAction)exportTexture:(id)sender {
    if (!_textureImageView.image) return;
    
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    
    if (@available(macOS 12.0, *)) {
        savePanel.allowedContentTypes = @[ UTTypePNG ];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        savePanel.allowedFileTypes = @[ @"png" ];
#pragma clang diagnostic pop
    }
    
    // Ensure a sensible default name ends with .png
    NSString *base = _filenameTextField.stringValue.length ? _filenameTextField.stringValue : @"texture";
    if (![base.lowercaseString hasSuffix:@".png"]) {
        base = [base stringByAppendingString:@".png"];
    }
    savePanel.nameFieldStringValue = base;
    
    [savePanel beginWithCompletionHandler:^(NSInteger result) {
        if (result == NSModalResponseOK) {
            NSURL *url = savePanel.URL;
            [self exportImageToURL:url];
        }
    }];
}

- (IBAction)commitChanges:(id)sender {
    @try {
        [self synchronize];
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"Changes committed successfully";
        [alert runModal];
    }
    @catch (NSException *exception) {
        [Helper exceptionMessageWithString:[NSString stringWithFormat:@"Error writing file: %@", exception.reason]];
    }
}

- (IBAction)itemSelectionChanged:(id)sender {
    [self updateControlsForSelectedItem];
}

- (IBAction)filenameChanged:(id)sender {
    if (_updatingControls) return;
    
    ImageData *selectedItem = [self selectedImageData];
    if (selectedItem) {
        // Update the filename in the selected ImageData
        // This would need to be implemented based on the actual ImageData structure
    }
}

- (IBAction)formatChanged:(id)sender {
    if (_updatingControls) return;
    ImageData *item = [self selectedImageData];
    if (!item) return;
    NSString *fmt = _formatComboBox.stringValue;
    @try { [item setValue:fmt forKey:@"format"]; } @catch (__unused id e) {}
}

- (IBAction)sizeChanged:(id)sender {
    if (_updatingControls) return;
    
    ImageData *selectedItem = [self selectedImageData];
    if (!selectedItem) return;
    
    NSInteger width  = _widthTextField.stringValue.integerValue;
    NSInteger height = _heightTextField.stringValue.integerValue;
    if (width <= 0 || height <= 0) return;
    
    // The TXTR/DDS pipeline (buildDefaultMipMap:) should read the current size/state
    // and regenerate mipmaps accordingly.
    [self buildDefaultMipMap:sender];
    
    // Silence “unused variable” warnings without changing behavior
    (void)width;
    (void)height;
}

- (IBAction)mipMapLevelChanged:(id)sender {
    if (_updatingControls) return;
    
    NSInteger requestedLevel = _mipMapLevelTextField.stringValue.integerValue;
    if (requestedLevel < 0) requestedLevel = 0;
    
    // Clamp to the number of mipmaps we currently show
    NSInteger maxIndex = (NSInteger)_currentMipMaps.count - 1;
    if (maxIndex < 0) return; // nothing to select yet
    
    if (requestedLevel > maxIndex) requestedLevel = maxIndex;
    
    // Keep the field in sync if clamped
    if (requestedLevel != _mipMapLevelTextField.stringValue.integerValue) {
        _mipMapLevelTextField.stringValue = [NSString stringWithFormat:@"%ld", (long)requestedLevel];
    }
    
    // Select the mip row; your table delegate will update the preview
    NSIndexSet *set = [NSIndexSet indexSetWithIndex:requestedLevel];
    [_mipMapTableView selectRowIndexes:set byExtendingSelection:NO];
    [_mipMapTableView scrollRowToVisible:requestedLevel];
}

- (IBAction)mipMapBlockSelectionChanged:(id)sender {
    [self updateMipMapList];
}

- (void)fixTgi:(id)sender {
    if (!_wrapper) return;
    
    NSString *original = _filenameTextField.stringValue ?: @"";
    if (original.length == 0) return;
    
    // Strip common trailing hash tokens: "##0xDEADBEEF", "_0xDEADBEEF", "(0xDEADBEEF)", " 0xDEADBEEF"
    NSError *rxError = nil;
    NSRegularExpression *rx =
    [NSRegularExpression regularExpressionWithPattern:
     @"(?:\\s*\\(\\s*0x[0-9A-Fa-f]{8}\\s*\\)\\s*$)|(?:[ _-]*0x[0-9A-Fa-f]{8}\\s*$)|(?:##0x[0-9A-Fa-f]{8}\\s*$)"
                                              options:0
                                                error:&rxError];
    
    NSString *clean = original;
    if (!rxError) {
        NSRange full = NSMakeRange(0, clean.length);
        clean = [rx stringByReplacingMatchesInString:clean options:0 range:full withTemplate:@""];
    }
    clean = [clean stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    while (clean.length > 0) {
        unichar last = [clean characterAtIndex:clean.length - 1];
        if (last == '_' || last == '-') {
            clean = [clean substringToIndex:clean.length - 1];
        } else break;
    }
    
    // Update UI field to cleaned name
    _filenameTextField.stringValue = clean;
    
    // Compute FNV-1a 32-bit over lowercased name (SimPE-style)
    uint32_t instance = 0;
    {
        NSString *s = clean.lowercaseString;
        const uint8_t *bytes = (const uint8_t *)[s cStringUsingEncoding:NSUTF8StringEncoding];
        uint32_t hash = 0x811C9DC5u;
        const uint32_t prime = 0x01000193u;
        for (const uint8_t *p = bytes; p && *p; ++p) { hash ^= *p; hash *= prime; }
        instance = hash;
    }
    
    // Try common keys via KVC; no made-up properties beyond typical names.
    BOOL updated = NO;
    @try { [_wrapper setValue:@(instance) forKey:@"instance"]; updated = YES; } @catch (__unused id e) {}
    if (!updated) { @try { [_wrapper setValue:@(instance) forKey:@"instanceID"]; updated = YES; } @catch (__unused id e) {} }
    if (!updated) { @try { [_wrapper setValue:@(instance) forKey:@"Instance"]; updated = YES; } @catch (__unused id e) {} }
    if (!updated) { @try { [_wrapper setValue:@(instance) forKey:@"InstanceID"]; updated = YES; } @catch (__unused id e) {} }
    
    if (!updated) {
        // We cleaned the name; wrapper didn’t expose a known instance key.
        [Helper exceptionMessageWithString:@"Fixed name. Could not update Instance on wrapper (unknown property name)."];
    }
    
    // Refresh anything that depends on TGI (safe no-ops if not wired yet)
    [self updateMipMapList];
    [self updateTexturePreview];
}

- (IBAction)buildDefaultMipMap:(id)sender {
    @try {
        _updatingControls = YES;
        [_currentMipMaps removeAllObjects];
        
        NSInteger levels = [_mipMapLevelTextField.stringValue integerValue];
        NSInteger width = 1, height = 1;
        
        for (NSInteger i = 0; i < levels; i++) {
            MipMap *mipMap = [[MipMap alloc] init]; // Would need proper initialization
            // Set image properties
            
            [_currentMipMaps addObject:mipMap];
            
            if (width == height && width == 1) {
                // Reset to larger size for next iteration
                ImageData *selectedData = [self selectedImageData];
                if (selectedData) {
                    // width = selectedData.textureSize.width;
                    // height = selectedData.textureSize.height;
                }
            } else {
                width *= 2;
                height *= 2;
            }
        }
        
        [self updateMipMapList];
        [_mipMapTableView reloadData];
        
        if (_currentMipMaps.count > 0) {
            [_mipMapTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:_currentMipMaps.count - 1] byExtendingSelection:NO];
        }
    }
    @catch (NSException *exception) {
        [Helper exceptionMessageWithString:[NSString stringWithFormat:@"Error building mipmap: %@", exception.reason]];
    }
    @finally {
        _updatingControls = NO;
    }
}

- (IBAction)addMipMap:(id)sender {
    ImageData *parent = [self selectedImageData];
    if (!parent) return;
    
    MipMap *mipMap = [[MipMap alloc] initWithParent:parent];
    
    // Default 512×256 bitmap for a new slot
    NSImage *defaultImage = [[NSImage alloc] initWithSize:NSMakeSize(512, 256)];
    mipMap.texture = defaultImage;
    
    if ([mipMap respondsToSelector:@selector(reloadTexture)]) {
        [mipMap reloadTexture];
    }
    
    [_currentMipMaps addObject:mipMap];
    [self updateMipMapList];
    [_mipMapTableView reloadData];
}

- (IBAction)deleteMipMap:(id)sender {
    NSInteger selectedRow = _mipMapTableView.selectedRow;
    if (selectedRow >= 0 && selectedRow < _currentMipMaps.count) {
        [_currentMipMaps removeObjectAtIndex:selectedRow];
        [self updateMipMapList];
        [_mipMapTableView reloadData];
    }
}

// MARK: - Context Menu Actions

- (IBAction)importAlphaChannel:(id)sender {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    
    if (@available(macOS 12.0, *)) {
        openPanel.allowedContentTypes = @[ UTTypePNG, UTTypeJPEG, UTTypeBMP, UTTypeGIF ];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        openPanel.allowedFileTypes = @[ @"png", @"jpg", @"jpeg", @"bmp", @"gif" ];
#pragma clang diagnostic pop
    }
    
    [openPanel beginWithCompletionHandler:^(NSInteger result) {
        if (result == NSModalResponseOK) {
            NSURL *url = openPanel.URL;
            NSImage *alphaImage = [[NSImage alloc] initWithContentsOfURL:url];
            if (alphaImage && self.textureImageView.image) {
                NSImage *combinedImage = [self changeAlphaChannel:self.textureImageView.image alphaImage:alphaImage];
                self.textureImageView.image = combinedImage;
                [self updateSelectedMipMapWithImage:combinedImage];
            }
        }
    }];
}

- (IBAction)exportAlphaChannel:(id)sender {
    if (!_textureImageView.image) return;
    
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    
    if (@available(macOS 12.0, *)) {
        savePanel.allowedContentTypes = @[ UTTypePNG ];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        savePanel.allowedFileTypes = @[ @"png" ];
#pragma clang diagnostic pop
    }
    savePanel.nameFieldStringValue = [NSString stringWithFormat:@"%@_alpha.png", _filenameTextField.stringValue];
    
    [savePanel beginWithCompletionHandler:^(NSInteger result) {
        if (result == NSModalResponseOK) {
            NSURL *url = savePanel.URL;
            NSImage *alphaImage = [self getAlphaChannel:self.textureImageView.image];
            [self exportImage:alphaImage toURL:url];
        }
    }];
}

- (IBAction)importDDS:(id)sender {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    
    if (@available(macOS 12.0, *)) {
        // Create a UTType for the "dds" file extension
        UTType *ddsType = [UTType typeWithFilenameExtension:@"dds"];
        if (ddsType) {
            openPanel.allowedContentTypes = @[ ddsType ];
        }
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        openPanel.allowedFileTypes = @[ @"dds" ];
#pragma clang diagnostic pop
    }
    
    [openPanel beginWithCompletionHandler:^(NSInteger result) {
        if (result == NSModalResponseOK) {
            NSURL *url = openPanel.URL;
            // Import DDS file - would need DDS parsing implementation
            [self importDDSFromURL:url];
        }
    }];
}

- (IBAction)buildDXT:(id)sender {
    ImageData *parent = [self selectedImageData];
    if (!parent) return;
    
    // 1) Capture user-chosen format from the combobox (DXT1/3/5/Raw24/Raw32)
    NSString *fmt = _formatComboBox.stringValue.length ? _formatComboBox.stringValue : @"DXT1";
    
    // Store on the model via common keys (no new properties invented)
    BOOL set = NO;
    @try { [parent setValue:fmt forKey:@"format"]; set = YES; } @catch (__unused id e) {}
    if (!set) { @try { [parent setValue:fmt forKey:@"dxtFormat"]; set = YES; } @catch (__unused id e) {} }
    if (!set) { @try { [parent setValue:fmt forKey:@"compression"]; set = YES; } @catch (__unused id e) {} }
    
    // 2) Capture desired mip level count from the UI and store it
    NSNumber *levels = @(_mipMapLevelTextField.stringValue.integerValue);
    set = NO;
    @try { [parent setValue:levels forKey:@"mipMapLevels"]; set = YES; } @catch (__unused id e) {}
    if (!set) { @try { [parent setValue:levels forKey:@"mipLevels"]; set = YES; } @catch (__unused id e) {} }
    
    // 3) Let your existing code refresh its in-memory mip list if it already knows how
    if ([parent respondsToSelector:@selector(reloadTexture)]) {
        // Some ports put reload on ImageData; call if present
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [parent performSelector:@selector(reloadTexture)];
#pragma clang diagnostic pop
    }
    
    // 4) Refresh the table from your model; preview will update via delegate
    [self updateMipMapList];
    [_mipMapTableView reloadData];
}
- (IBAction)updateAllSizes:(id)sender {
    @try {
        _updatingControls = YES;
        
        MipMap *largestMipMap = nil;
        NSSize largestSize = NSMakeSize(0, 0);
        
        // Find the largest texture
        for (MipMap *mipMap in _currentMipMaps) {
            NSImage *texture = mipMap.texture;
            if (texture && texture.size.width > largestSize.width) {
                largestSize = texture.size;
                largestMipMap = mipMap;
             }
        }
        
        if (!largestMipMap) return;
        
        // Scale all other textures based on the largest one
        for (MipMap *mipMap in _currentMipMaps) {
            if (mipMap != largestMipMap) {
                // Create scaled version
                // This would need proper image scaling implementation
            }
        }
        
        [_mipMapTableView reloadData];
    }
    @catch (NSException *exception) {
        [Helper exceptionMessageWithString:[NSString stringWithFormat:@"Error updating sizes: %@", exception.reason]];
    }
    @finally {
        _updatingControls = NO;
    }
}

- (IBAction)importLocalLifo:(id)sender {
    NSInteger selectedRow = _mipMapTableView.selectedRow;
    if (selectedRow < 0 || selectedRow >= _currentMipMaps.count) return;
    
    @try {
        _updatingControls = YES;
        MipMap *selectedMipMap = _currentMipMaps[selectedRow];
        
        BOOL loaded = NO;
        
        // 1) If the MipMap knows how to fetch its own LIFO, let it do so.
        if ([selectedMipMap respondsToSelector:@selector(getReferencedLifoNoLoad)] &&
            [selectedMipMap respondsToSelector:@selector(getReferencedLifo)]) {
            
            // If there is a known reference but it's not loaded yet, load it.
            BOOL hasRef = [selectedMipMap getReferencedLifoNoLoad];
            if (hasRef) {
                [selectedMipMap getReferencedLifo];
                loaded = YES;
            }
        }
        
        // 2) If there wasn't a known reference, ask the user to choose a .lifo file.
        if (!loaded) {
            NSOpenPanel *openPanel = [NSOpenPanel openPanel];
            if (@available(macOS 12.0, *)) {
                UTType *lifoType = [UTType typeWithFilenameExtension:@"lifo"];
                if (lifoType) openPanel.allowedContentTypes = @[ lifoType ];
            } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                openPanel.allowedFileTypes = @[ @"lifo" ];
#pragma clang diagnostic pop
            }
            openPanel.allowsMultipleSelection = NO;
            
            NSInteger result = [openPanel runModal];
            if (result == NSModalResponseOK) {
                NSURL *url = openPanel.URL;
                if (url) {
                    // Store the reference path on the mip (property exists in your header)
                    selectedMipMap.lifoFile = url.path;
                    
                    // If the class can now load from that path, do it
                    if ([selectedMipMap respondsToSelector:@selector(getReferencedLifo)]) {
                        [selectedMipMap getReferencedLifo];
                    }
                    loaded = YES;
                }
            }
        }
        
        // 3) Ask the mip to refresh its texture (if it provides that API)
        if (loaded && [selectedMipMap respondsToSelector:@selector(reloadTexture)]) {
            [selectedMipMap reloadTexture];
        }
        
        // 4) Refresh UI
        [self updateMipMapList];
        [_mipMapTableView reloadData];
        [self updateTexturePreview];
        
        // Optional: keep the same row selected
        if (selectedRow < _currentMipMaps.count) {
            [_mipMapTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:selectedRow] byExtendingSelection:NO];
        }
        
    } @catch (NSException *exception) {
        [Helper exceptionMessageWithString:[NSString stringWithFormat:@"Error importing LIFO: %@", exception.reason]];
    } @finally {
        _updatingControls = NO;
    }
}

// MARK: - Private Methods

- (void)updateControlsForSelectedItem {
    if (_updatingControls) return;
    
    ImageData *selectedItem = [self selectedImageData];
    if (!selectedItem) return;
    
    _updatingControls = YES;
    
    // Update filename
    // _filenameTextField.stringValue = selectedItem.nameResource.fileName ?: @"";
    
    // Update size
    // _widthTextField.stringValue = @(selectedItem.textureSize.width).stringValue;
    // _heightTextField.stringValue = @(selectedItem.textureSize.height).stringValue;
    
    // Update mipmap level
    // _mipMapLevelTextField.stringValue = @(selectedItem.mipMapLevels).stringValue;
    
    // Update format combobox
    // [_formatComboBox selectItemWithObjectValue:selectedItem.format];
    
    // Populate mipmap blocks
    [_mipMapBlockComboBox removeAllItems];
    // for (MipMapBlock *block in selectedItem.mipMapBlocks) {
    //     [_mipMapBlockComboBox addItemWithObjectValue:block];
    // }
    
    if (_mipMapBlockComboBox.numberOfItems > 0) {
        [_mipMapBlockComboBox selectItemAtIndex:0];
        [self updateMipMapList];
    }
    
    _updatingControls = NO;
}

- (void)updateTexturePreview {
    NSInteger selectedRow = _mipMapTableView.selectedRow;
    if (selectedRow >= 0 && selectedRow < _currentMipMaps.count) {
        MipMap *selectedMipMap = _currentMipMaps[selectedRow];
        _textureImageView.image = selectedMipMap.texture;
        _exportButton.enabled = (selectedMipMap.texture != nil);
        _deleteButton.enabled = YES;
        
        // Update LIFO reference text
        // _lifoReferenceTextField.stringValue = selectedMipMap.lifoFile ?: @"";
    } else {
        _textureImageView.image = nil;
        _exportButton.enabled = NO;
        _deleteButton.enabled = NO;
        _lifoReferenceTextField.stringValue = @"";
    }
}

- (void)updateMipMapList {
    // Update the current mipmaps array based on selected block
    // This would populate _currentMipMaps from the selected MipMapBlock
    [_mipMapTableView reloadData];
}

- (ImageData *)selectedImageData {
    NSInteger selectedIndex = _itemComboBox.indexOfSelectedItem;
    if (selectedIndex >= 0) {
        // Return the selected ImageData from the wrapper's blocks
        // This would need to be implemented based on the actual wrapper structure
    }
    return nil;
}

- (MipMapBlock *)selectedMipMapBlock:(ImageData *)imageData {
    if (!imageData) return nil;
    
    NSInteger selectedIndex = _mipMapBlockComboBox.indexOfSelectedItem;
    if (selectedIndex >= 0) {
        // Return the selected MipMapBlock from the ImageData
        // return imageData.mipMapBlocks[selectedIndex];
    }
    return nil;
}

- (void)importImage:(NSImage *)image {
    ImageData *selectedItem = [self selectedImageData];
    if (!selectedItem) return;
    
    // Crop image to correct aspect ratio
    NSImage *croppedImage = [self cropImage:selectedItem image:image];
    if (!croppedImage) return;
    
    NSInteger selectedRow = _mipMapTableView.selectedRow;
    if (selectedRow >= 0 && selectedRow < _currentMipMaps.count) {
        MipMap *selectedMipMap = _currentMipMaps[selectedRow];
        selectedMipMap.lifoFile = @"";                // reset any old LIFO reference
        selectedMipMap.texture = croppedImage;        // attach the new image to the mip
        _textureImageView.image = croppedImage;       // show it in the preview
        [_mipMapTableView reloadData];
    }
}

- (void)exportImageToURL:(NSURL *)url {
    if (!_textureImageView.image) return;
    
    NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc] initWithData:[_textureImageView.image TIFFRepresentation]];
    NSData *pngData = [bitmap representationUsingType:NSBitmapImageFileTypePNG properties:@{}];
    [pngData writeToURL:url atomically:YES];
}

- (void)exportImage:(NSImage *)image toURL:(NSURL *)url {
    if (!image) return;
    
    NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc] initWithData:[image TIFFRepresentation]];
    NSData *pngData = [bitmap representationUsingType:NSBitmapImageFileTypePNG properties:@{}];
    [pngData writeToURL:url atomically:YES];
}

- (void)updateSelectedMipMapWithImage:(NSImage *)image {
    NSInteger selectedRow = _mipMapTableView.selectedRow;
    if (selectedRow >= 0 && selectedRow < _currentMipMaps.count) {
        _textureImageView.image = image;
        [_mipMapTableView reloadData];
    }
}

- (void)importDDSFromURL:(NSURL *)url {
    // Parse DDS file and load mipmap data
    // This would need DDS parsing implementation
    NSLog(@"DDS import from %@ would be implemented here", url.path);
}

- (NSImage *)cropImage:(ImageData *)imageData image:(NSImage *)image {
    // Calculate aspect ratio and crop if necessary
    // This would need to be implemented based on the ImageData texture size
    return image; // Placeholder - would implement proper cropping
}

- (NSImage *)getAlphaChannel:(NSImage *)image {
    // Extract alpha channel as grayscale image
    // This would need proper image processing implementation
    return image; // Placeholder
}

- (NSImage *)changeAlphaChannel:(NSImage *)baseImage alphaImage:(NSImage *)alphaImage {
    // Combine base image with alpha channel from alpha image
    // This would need proper image processing implementation
    return baseImage; // Placeholder
}

// MARK: - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return _currentMipMaps.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if (row >= _currentMipMaps.count) return nil;
    
    MipMap *mipMap = _currentMipMaps[row];
    
    if ([tableColumn.identifier isEqualToString:@"name"]) {
        // Return mipmap description
        return [mipMap description] ?: @"MipMap";
    } else if ([tableColumn.identifier isEqualToString:@"size"]) {
        // Return size string
        // NSImage *texture = mipMap.texture;
        // if (texture) {
        //     return [NSString stringWithFormat:@"%.0fx%.0f", texture.size.width, texture.size.height];
        // }
        return @"--";
    }
    
    return nil;
}

// MARK: - NSTableViewDelegate

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    (void)notification; // silence unused warning
    [self updateTexturePreview];
}

// MARK: - IPackedFileUI

- (void)updateGUI:(id<IFileWrapper>)wrapper {
    // Store the wrapper and refresh the UI from it.
    _wrapper = (id)wrapper;   // cast safely to id; TxtrWrapper is already imported
    [self refresh];
    [self updateControlsForSelectedItem];
    [self updateMipMapList];
    [self updateTexturePreview];
}

// MARK: - Editing / Coding

- (BOOL)commitEditingAndReturnError:(NSError *__autoreleasing  _Nullable * _Nullable)error {
    (void)error; // no error reporting needed here
    [self synchronize]; // push pending UI changes to the wrapper
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    (void)coder; // no-op: TxtrForm isn't persisted
}

@end
