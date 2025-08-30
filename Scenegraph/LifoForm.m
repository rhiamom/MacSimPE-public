//
//  LifoForm.m
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

#import "LifoForm.h"
#import "LifoWrapper.h"
#import "cLevelInfo.h"
#import "ImageLoader.h"
#import "cImageData.h"
#import "ExceptionForm.h"
#import "Localization.h"
#import "Hashes.h"
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>
#import "Soil2.h"
#import "cSGResource.h"
#import "PackedFileDescriptorSimple.h"
#import "File.h"
#import "BuildTxtr.h"


@interface LifoForm ()
@property (nonatomic, assign) BOOL isUpdatingUI;
@end

@implementation LifoForm

// MARK: - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithWrapper:(Lifo *)wrapper {
    self = [super init];
    if (self) {
        _wrapper = wrapper;
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    _isUpdatingUI = NO;
    
    // Initialize file dialogs
    _sfd = [NSSavePanel savePanel];
    _sfd.allowedContentTypes = @[[UTType typeWithIdentifier:@"public.png"],
                                 [UTType typeWithIdentifier:@"com.microsoft.bmp"],
                                 [UTType typeWithIdentifier:@"com.compuserve.gif"],
                                 [UTType typeWithIdentifier:@"public.jpeg"]];
    _sfd.title = @"Export Image";
    
    _ofd = [NSOpenPanel openPanel];
    _ofd.allowedContentTypes = @[[UTType typeWithIdentifier:@"public.jpeg"],
                                 [UTType typeWithIdentifier:@"com.microsoft.bmp"],
                                 [UTType typeWithIdentifier:@"com.compuserve.gif"],
                                 [UTType typeWithIdentifier:@"public.png"]];
    _ofd.title = @"Import Image";
    _ofd.canChooseFiles = YES;
    _ofd.canChooseDirectories = NO;
    _ofd.allowsMultipleSelection = NO;
}

- (void)loadView {
    // Create the main view
    NSView *view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 792, 310)];
    
    // Create lifoPanel
    self.lifoPanel = [[NSView alloc] initWithFrame:NSMakeRect(8, 8, 768, 288)];
    [view addSubview:self.lifoPanel];
    
    [self setupUI];
    [self setupContextMenu];
    
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateUIForSelectedItem];
}

// MARK: - UI Setup

- (void)setupUI {
    // Create toolbar panel (panel2)
    self.panel2 = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 768, 24)];
    self.panel2.wantsLayer = YES;
    self.panel2.layer.backgroundColor = [NSColor controlBackgroundColor].CGColor;
    [self.lifoPanel addSubview:self.panel2];
    
    // Toolbar label
    self.label27 = [[NSTextField alloc] initWithFrame:NSMakeRect(4, 4, 81, 16)];
    self.label27.stringValue = @"Lifo Editor";
    self.label27.font = [NSFont boldSystemFontOfSize:12];
    self.label27.backgroundColor = [NSColor clearColor];
    self.label27.bordered = NO;
    self.label27.editable = NO;
    [self.panel2 addSubview:self.label27];
    
    // Toolbar buttons
    self.btcommit = [[NSButton alloc] initWithFrame:NSMakeRect(688, 0, 75, 23)];
    [self.btcommit setTitle:@"Save"];
    [self.btcommit setTarget:self];
    [self.btcommit setAction:@selector(btcommitClick:)];
    [self.panel2 addSubview:self.btcommit];
    
    self.btex = [[NSButton alloc] initWithFrame:NSMakeRect(584, 0, 80, 23)];
    [self.btex setTitle:@"Export..."];
    [self.btex setTarget:self];
    [self.btex setAction:@selector(btexClick:)];
    [self.panel2 addSubview:self.btex];
    
    self.btim = [[NSButton alloc] initWithFrame:NSMakeRect(504, 0, 75, 23)];
    [self.btim setTitle:@"Import..."];
    [self.btim setTarget:self];
    [self.btim setAction:@selector(btimClick:)];
    [self.panel2 addSubview:self.btim];
    
    // Left panel controls
    CGFloat yPos = 32;
    
    // Item combo box
    self.cbitem = [[NSComboBox alloc] initWithFrame:NSMakeRect(80, yPos, 344, 21)];
    self.cbitem.hasVerticalScroller = YES;
    self.cbitem.intercellSpacing = NSMakeSize(3, 2);
    [self.cbitem setTarget:self];
    [self.cbitem setAction:@selector(selectItem:)];
    [self.lifoPanel addSubview:self.cbitem];
    
    // Filename controls
    yPos += 24;
    self.label2 = [[NSTextField alloc] initWithFrame:NSMakeRect(11, yPos, 71, 13)];
    self.label2.stringValue = @"Filename:";
    self.label2.font = [NSFont boldSystemFontOfSize:10];
    self.label2.backgroundColor = [NSColor clearColor];
    self.label2.bordered = NO;
    self.label2.editable = NO;
    [self.lifoPanel addSubview:self.label2];
    
    self.tbflname = [[NSTextField alloc] initWithFrame:NSMakeRect(80, yPos, 344, 21)];
    [self.tbflname setTarget:self];
    [self.tbflname setAction:@selector(fileNameChanged:)];
    [self.lifoPanel addSubview:self.tbflname];
    
    // Link labels
    yPos += 24;
    self.linkLabel2 = [[NSButton alloc] initWithFrame:NSMakeRect(288, yPos, 51, 13)];
    [self.linkLabel2 setTitle:@"fix TGI"];
    [self.linkLabel2 setBordered:NO];
           [self.linkLabel2 setButtonType:NSButtonTypeMomentaryLight];
    self.linkLabel2.font = [NSFont boldSystemFontOfSize:10];
    [self.linkLabel2 setTarget:self];
    [self.linkLabel2 setAction:@selector(fixTGI:)];
    [self.lifoPanel addSubview:self.linkLabel2];
    
    self.linkLabel1 = [[NSButton alloc] initWithFrame:NSMakeRect(343, yPos, 85, 13)];
    [self.linkLabel1 setTitle:@"assign Hash"];
    [self.linkLabel1 setBordered:NO];
           [self.linkLabel1 setButtonType:NSButtonTypeMomentaryLight];
    self.linkLabel1.font = [NSFont boldSystemFontOfSize:10];
    self.linkLabel1.hidden = YES; // Initially hidden like in original
    [self.linkLabel1 setTarget:self];
    [self.linkLabel1 setAction:@selector(buildFilename:)];
    [self.lifoPanel addSubview:self.linkLabel1];
    
    // Format controls
    yPos += 24;
    self.label3 = [[NSTextField alloc] initWithFrame:NSMakeRect(24, yPos, 58, 13)];
    self.label3.stringValue = @"Format:";
    self.label3.font = [NSFont boldSystemFontOfSize:10];
    self.label3.backgroundColor = [NSColor clearColor];
    self.label3.bordered = NO;
    self.label3.editable = NO;
    [self.lifoPanel addSubview:self.label3];
    
    self.cbformats = [[NSComboBox alloc] initWithFrame:NSMakeRect(80, yPos, 344, 21)];
    self.cbformats.hasVerticalScroller = YES;
    self.cbformats.intercellSpacing = NSMakeSize(3, 2);
    [self.cbformats setTarget:self];
    [self.cbformats setAction:@selector(changeFormat:)];
    [self.lifoPanel addSubview:self.cbformats];
    
    // Size controls
    yPos += 24;
    self.label4 = [[NSTextField alloc] initWithFrame:NSMakeRect(43, yPos, 38, 13)];
    self.label4.stringValue = @"Size:";
    self.label4.font = [NSFont boldSystemFontOfSize:10];
    self.label4.backgroundColor = [NSColor clearColor];
    self.label4.bordered = NO;
    self.label4.editable = NO;
    [self.lifoPanel addSubview:self.label4];
    
    self.tbwidth = [[NSTextField alloc] initWithFrame:NSMakeRect(80, yPos, 56, 21)];
    self.tbwidth.editable = NO;
    [self.lifoPanel addSubview:self.tbwidth];
    
    self.label5 = [[NSTextField alloc] initWithFrame:NSMakeRect(141, yPos, 15, 13)];
    self.label5.stringValue = @"x";
    self.label5.font = [NSFont boldSystemFontOfSize:10];
    self.label5.backgroundColor = [NSColor clearColor];
    self.label5.bordered = NO;
    self.label5.editable = NO;
    [self.lifoPanel addSubview:self.label5];
    
    self.tbheight = [[NSTextField alloc] initWithFrame:NSMakeRect(160, yPos, 56, 21)];
    self.tbheight.editable = NO;
    [self.lifoPanel addSubview:self.tbheight];
    
    // Z-Level controls
    self.label1 = [[NSTextField alloc] initWithFrame:NSMakeRect(248, yPos, 60, 13)];
    self.label1.stringValue = @"Z-Level:";
    self.label1.font = [NSFont boldSystemFontOfSize:10];
    self.label1.backgroundColor = [NSColor clearColor];
    self.label1.bordered = NO;
    self.label1.editable = NO;
    [self.lifoPanel addSubview:self.label1];
    
    self.tbz = [[NSTextField alloc] initWithFrame:NSMakeRect(304, yPos, 56, 21)];
    [self.tbz setTarget:self];
    [self.tbz setAction:@selector(changeZLevel:)];
    [self.lifoPanel addSubview:self.tbz];
    
    // Image display area (panel1)
    self.panel1 = [[NSView alloc] initWithFrame:NSMakeRect(432, 32, 328, 248)];
    [self.lifoPanel addSubview:self.panel1];
    
    // Scroll view for image
    self.scrollView = [[NSScrollView alloc] initWithFrame:self.panel1.bounds];
    self.scrollView.hasVerticalScroller = YES;
    self.scrollView.hasHorizontalScroller = YES;
    self.scrollView.autohidesScrollers = NO;
    self.scrollView.borderType = NSBezelBorder;
    [self.panel1 addSubview:self.scrollView];
    
    // Image view
    self.pb = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, 100, 50)];
    self.pb.imageScaling = NSImageScaleNone;
    self.pb.imageAlignment = NSImageAlignTopLeft;
    self.pb.allowsCutCopyPaste = NO;
    self.pb.editable = NO;
    
    // Set background pattern image (checkerboard for transparency)
    NSImage *bgImage = [self createTransparencyBackgroundImage];
    if (bgImage) {
        self.pb.wantsLayer = YES;
        self.pb.layer.backgroundColor = [NSColor colorWithPatternImage:bgImage].CGColor;
    }
    
    self.scrollView.documentView = self.pb;
}

- (void)setupContextMenu {
    self.contextMenu1 = [[NSMenu alloc] initWithTitle:@"Context Menu"];
    
    self.menuItem1 = [[NSMenuItem alloc] initWithTitle:@"&Import..." action:@selector(btimClick:) keyEquivalent:@""];
    [self.menuItem1 setTarget:self];
    [self.contextMenu1 addItem:self.menuItem1];
    
    self.menuItem4 = [[NSMenuItem alloc] initWithTitle:@"Import &Alpha Channel..." action:@selector(importAlpha:) keyEquivalent:@""];
    [self.menuItem4 setTarget:self];
    [self.contextMenu1 addItem:self.menuItem4];
    
    self.menuItem3 = [[NSMenuItem alloc] initWithTitle:@"Import &DDS..." action:@selector(importDDS:) keyEquivalent:@""];
    [self.menuItem3 setTarget:self];
    [self.contextMenu1 addItem:self.menuItem3];
    
    self.menuItem6 = [[NSMenuItem alloc] initWithTitle:@"Build DXT..." action:@selector(buildDXT:) keyEquivalent:@""];
    [self.menuItem6 setTarget:self];
    [self.contextMenu1 addItem:self.menuItem6];
    
    self.menuItem7 = [NSMenuItem separatorItem];
    [self.contextMenu1 addItem:self.menuItem7];
    
    self.menuItem2 = [[NSMenuItem alloc] initWithTitle:@"&Export..." action:@selector(btexClick:) keyEquivalent:@""];
    [self.menuItem2 setTarget:self];
    [self.contextMenu1 addItem:self.menuItem2];
    
    self.menuItem5 = [[NSMenuItem alloc] initWithTitle:@"Export Alpha &Channel..." action:@selector(exportAlpha:) keyEquivalent:@""];
    [self.menuItem5 setTarget:self];
    [self.contextMenu1 addItem:self.menuItem5];
    
    // Set context menu for image view
    self.pb.menu = self.contextMenu1;
}

- (NSImage *)createTransparencyBackgroundImage {
    // Create a small checkerboard pattern for transparency background
    NSSize size = NSMakeSize(16, 16);
    NSImage *image = [[NSImage alloc] initWithSize:size];
    [image lockFocus];
    
    // Light gray squares
    [[NSColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] setFill];
    NSRectFill(NSMakeRect(0, 0, 8, 8));
    NSRectFill(NSMakeRect(8, 8, 8, 8));
    
    // Darker gray squares
    [[NSColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0] setFill];
    NSRectFill(NSMakeRect(8, 0, 8, 8));
    NSRectFill(NSMakeRect(0, 8, 8, 8));
    
    [image unlockFocus];
    return image;
}

// MARK: - Action Methods

- (IBAction)btcommitClick:(id)sender {
    @try {
        Lifo *wrp = (Lifo *)self.wrapper;
        [wrp synchronizeUserData];
        // Show success message
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = [Localization getString:@"committed"];
        alert.alertStyle = NSAlertStyleInformational;
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];
    }
    @catch (NSException *ex) {
        [ExceptionForm executeWithMessage:[Localization getString:@"errwritingfile"] exception:ex];
    }
}

- (IBAction)btexClick:(id)sender {
    if (self.pb.image == nil) return;
    
    NSString *filename = [NSString stringWithFormat:@"%@_%@x%@.png",
                         self.tbflname.stringValue,
                         self.tbwidth.stringValue,
                         self.tbheight.stringValue];
    self.sfd.nameFieldStringValue = filename;
    
    [self.sfd beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {
        if (result == NSModalResponseOK) {
            @try {
                NSURL *url = self.sfd.URL;
                NSData *imageData = [self.pb.image TIFFRepresentation];
                NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
                NSData *pngData = [imageRep representationUsingType:NSBitmapImageFileTypePNG properties:@{}];
                [pngData writeToURL:url atomically:YES];
            }
            @catch (NSException *ex) {
                [ExceptionForm executeWithMessage:[Localization getString:@"errwritingfile"] exception:ex];
            }
        }
    }];
}

- (IBAction)btimClick:(id)sender {
    [self.ofd beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {
        if (result == NSModalResponseOK) {
            @try {
                LevelInfo *levelInfo = (LevelInfo *)[self.cbitem objectValueOfSelectedItem];
                NSURL *url = self.ofd.URL;
                NSImage *img = [[NSImage alloc] initWithContentsOfURL:url];
                img = [self cropImage:levelInfo image:img];
                if (img == nil) return;
                
                levelInfo.texture = img;
                self.pb.image = img;
            }
            @catch (NSException *ex) {
                [ExceptionForm executeWithMessage:[Localization getString:@"erropenfile"] exception:ex];
            }
        }
    }];
}

- (IBAction)selectItem:(id)sender {
    if (self.isUpdatingUI) return;
    if (self.cbitem.indexOfSelectedItem < 0) return;
    
    @try {
            self.isUpdatingUI = YES;
            LevelInfo *selectedItem = (LevelInfo *)[self.cbitem objectValueOfSelectedItem];
            
            self.tbflname.stringValue = selectedItem.nameResource.fileName ?: @"";
            self.tbwidth.stringValue = [NSString stringWithFormat:@"%ld", (long)selectedItem.textureSize.width];
            self.tbheight.stringValue = [NSString stringWithFormat:@"%ld", (long)selectedItem.textureSize.height];
            self.tbz.stringValue = [NSString stringWithFormat:@"%ld", (long)selectedItem.zLevel];
        
        // Update format combo box
        [self.cbformats selectItemAtIndex:0];
        for (NSInteger i = 0; i < self.cbformats.numberOfItems; i++) {
            NSNumber *format = [self.cbformats itemObjectValueAtIndex:i];
            if ([format integerValue] == selectedItem.format) {
                [self.cbformats selectItemAtIndex:i];
                break;
            }
        }
        
        self.pb.image = selectedItem.texture;
    }
    @catch (NSException *ex) {
        [ExceptionForm executeWithMessage:[Localization getString:@"erropenfile"] exception:ex];
    }
    @finally {
        self.isUpdatingUI = NO;
    }
}

- (IBAction)fileNameChanged:(id)sender {
    if (self.isUpdatingUI) return;
    if (self.cbitem.indexOfSelectedItem < 0) return;
    
    @try {
        self.isUpdatingUI = YES;
        LevelInfo *selectedItem = (LevelInfo *)[self.cbitem objectValueOfSelectedItem];
        selectedItem.nameResource.fileName = self.tbflname.stringValue;
        [self.cbitem reloadData];
        self.cbitem.stringValue = self.tbflname.stringValue;
    }
    @catch (NSException *ex) {
        [ExceptionForm executeWithMessage:[Localization getString:@"erropenfile"] exception:ex];
    }
    @finally {
        self.isUpdatingUI = NO;
    }
}

- (IBAction)changeFormat:(id)sender {
    if (self.isUpdatingUI) return;
    if (self.cbitem.indexOfSelectedItem < 0) return;
    if (self.cbformats.indexOfSelectedItem < 1) return;
    
    @try {
        self.isUpdatingUI = YES;
        LevelInfo *selectedItem = (LevelInfo *)[self.cbitem objectValueOfSelectedItem];
        NSNumber *format = [self.cbformats objectValueOfSelectedItem];
        selectedItem.format = [format integerValue];
    }
    @catch (NSException *ex) {
        [ExceptionForm executeWithMessage:[Localization getString:@"erropenfile"] exception:ex];
    }
    @finally {
        self.isUpdatingUI = NO;
    }
}

- (IBAction)changeZLevel:(id)sender {
    @try {
        LevelInfo *levelInfo = [self selectedLevelInfo];
        levelInfo.zLevel = [self.tbz.stringValue intValue];
    }
    @catch (NSException *ex) {
        [ExceptionForm executeWithMessage:[Localization getString:@"errconvert"] exception:ex];
    }
}

- (IBAction)fixTGI:(id)sender {
    NSString *filename = [Hashes stripHashFromName:self.tbflname.stringValue];
    // Cast to the concrete class to access the properties
    PackedFileDescriptorSimple *descriptor = (PackedFileDescriptorSimple *)self.wrapper.fileDescriptor;
    descriptor.instance = [Hashes instanceHash:filename];
    descriptor.subType = [Hashes subTypeHash:filename];
}


- (IBAction)buildFilename:(id)sender {
    NSString *filename = [Hashes stripHashFromName:self.tbflname.stringValue];
    // Cast to the concrete class to access the fileGroupHash property
    File *packageFile = (File *)self.wrapper.package;
    self.tbflname.stringValue = [Hashes assembleHashedFileName:packageFile.fileGroupHash filename:filename];

}

// MARK: - Context Menu Actions

- (IBAction)importAlpha:(id)sender {
    [self.ofd beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {
        if (result == NSModalResponseOK) {
            @try {
                LevelInfo *levelInfo = (LevelInfo *)[self.cbitem objectValueOfSelectedItem];
                NSURL *url = self.ofd.URL;
                NSImage *img = [[NSImage alloc] initWithContentsOfURL:url];
                img = [self cropImage:levelInfo image:img];
                if (img == nil) return;
                
                levelInfo.texture = [self changeAlpha:levelInfo.texture alpha:img];
                self.pb.image = levelInfo.texture;
            }
            @catch (NSException *ex) {
                [ExceptionForm executeWithMessage:[Localization getString:@"erropenfile"] exception:ex];
            }
        }
    }];
}

- (IBAction)exportAlpha:(id)sender {
    if (self.pb.image == nil) return;
    
    NSString *filename = [NSString stringWithFormat:@"%@_alpha_%dx%d.png",
                         self.tbflname.stringValue,
                         (int)self.pb.image.size.width,
                         (int)self.pb.image.size.height];
    self.sfd.nameFieldStringValue = filename;
    
    [self.sfd beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {
        if (result == NSModalResponseOK) {
            @try {
                NSURL *url = self.sfd.URL;
                NSImage *alphaImage = [self getAlpha:self.pb.image];
                NSData *imageData = [alphaImage TIFFRepresentation];
                NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
                NSData *pngData = [imageRep representationUsingType:NSBitmapImageFileTypePNG properties:@{}];
                [pngData writeToURL:url atomically:YES];
            }
            @catch (NSException *ex) {
                [ExceptionForm executeWithMessage:[Localization getString:@"errwritingfile"] exception:ex];
            }
        }
    }];
}

- (IBAction)importDDS:(id)sender {
    NSOpenPanel *ddsPanel = [NSOpenPanel openPanel];
    ddsPanel.allowedContentTypes = @[[UTType typeWithIdentifier:@"com.microsoft.dds"]];
    ddsPanel.title = @"Import DDS";
    
    [ddsPanel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {
        if (result == NSModalResponseOK) {
            @try {
                self.isUpdatingUI = YES;
                NSURL *url = ddsPanel.URL;
                NSArray<DDSData *> *data = [ImageLoader parseDDS:url.path];
                [self loadDDS:data];
            }
            @catch (NSException *ex) {
                [ExceptionForm executeWithMessage:@"" exception:ex];
            }
            @finally {
                self.isUpdatingUI = NO;
            }
        }
    }];
}

- (IBAction)buildDXT:(id)sender {
    LevelInfo *levelInfo = [self selectedImageData];
    
    if (levelInfo.texture) {
        // Create a temporary ImageData to hold the result
        ImageData *imageData = [[ImageData alloc] initWithParent:nil];
        
        // Use BuildTxtr's loadTxtr method to process the texture
        [BuildTxtr loadTxtr:imageData
                      image:levelInfo.texture
                       size:levelInfo.textureSize
                     levels:1
                     format:levelInfo.format];
        
        // Extract the data from the processed ImageData
        if (imageData.mipMapBlocks.count > 0) {
            MipMapBlock *block = imageData.mipMapBlocks.firstObject;
            if (block.mipMaps.count > 0) {
                MipMap *mipMap = block.mipMaps.firstObject;
                levelInfo.data = mipMap.data;
                levelInfo.texture = mipMap.texture;
                self.pb.image = levelInfo.texture;
            }
        }
    }
}
// MARK: - Utility Methods

- (LevelInfo *)selectedLevelInfo {
    LevelInfo *levelInfo = nil;
    if (self.cbitem.indexOfSelectedItem < 0) {
        // Add a new LevelInfo if it doesn't exist
        Lifo *wrp = (Lifo *)self.wrapper;
        levelInfo = [[LevelInfo alloc] initWithParent:wrp];
        levelInfo.nameResource.fileName = @"Unknown";
        
        NSMutableArray *blocks = [wrp.blocks mutableCopy];
        [blocks addObject:levelInfo];
        wrp.blocks = [blocks copy];
        
        [self.cbitem addItemWithObjectValue:levelInfo];
        [self.cbitem selectItemAtIndex:self.cbitem.numberOfItems - 1];
    } else {
        levelInfo = (LevelInfo *)[self.cbitem objectValueOfSelectedItem];
    }
    
    return levelInfo;
}

- (LevelInfo *)selectedImageData {
    LevelInfo *levelInfo = nil;
    if (self.cbitem.indexOfSelectedItem < 0) {
        // Add a new LevelInfo if it doesn't exist
        Lifo *wrp = (Lifo *)self.wrapper;
        levelInfo = [[LevelInfo alloc] initWithParent:wrp];
        levelInfo.nameResource.fileName = @"Unknown";
        levelInfo.format = [(NSNumber *)[self.cbformats objectValueOfSelectedItem] integerValue];
        
        NSMutableArray *blocks = [wrp.blocks mutableCopy];
        [blocks addObject:levelInfo];
        wrp.blocks = [blocks copy];
        
        [self.cbitem addItemWithObjectValue:levelInfo];
        [self.cbitem selectItemAtIndex:self.cbitem.numberOfItems - 1];
    } else {
        levelInfo = (LevelInfo *)[self.cbitem objectValueOfSelectedItem];
    }
    
    return levelInfo;
}
- (NSBitmapImageRep *)getBitmapFromImage:(NSImage *)image {
    // Try to get existing bitmap representation first
    for (NSImageRep *rep in [image representations]) {
        if ([rep isKindOfClass:[NSBitmapImageRep class]]) {
            return (NSBitmapImageRep *)rep;
        }
    }
    
    // Fallback to TIFF conversion (your current approach)
    NSData *tiffData = [image TIFFRepresentation];
    return [NSBitmapImageRep imageRepWithData:tiffData];
}

// For very large textures, direct pixel buffer access is faster
- (NSImage *)getAlphaOptimized:(NSImage *)img {
    NSBitmapImageRep *srcRep = [self getBitmapFromImage:img];
    if (!srcRep) return nil;
    
    NSInteger width = srcRep.pixelsWide;
    NSInteger height = srcRep.pixelsHigh;
    
    // Direct buffer access for better performance
    unsigned char *srcData = [srcRep bitmapData];
    NSInteger srcBytesPerRow = [srcRep bytesPerRow];
    NSInteger srcSamplesPerPixel = [srcRep samplesPerPixel];
    
    // Create alpha bitmap
    NSBitmapImageRep *alphaRep = [[NSBitmapImageRep alloc]
                                  initWithBitmapDataPlanes:NULL
                                  pixelsWide:width
                                  pixelsHigh:height
                                  bitsPerSample:8
                                  samplesPerPixel:3
                                  hasAlpha:NO
                                  isPlanar:NO
                                  colorSpaceName:NSCalibratedRGBColorSpace
                                  bytesPerRow:0
                                  bitsPerPixel:0];
    
    unsigned char *alphaData = [alphaRep bitmapData];
    NSInteger alphaBytesPerRow = [alphaRep bytesPerRow];
    
    // Process pixels via direct buffer access
    for (NSInteger y = 0; y < height; y++) {
        for (NSInteger x = 0; x < width; x++) {
            NSInteger srcOffset = y * srcBytesPerRow + x * srcSamplesPerPixel;
            NSInteger alphaOffset = y * alphaBytesPerRow + x * 3;
            
            // Extract alpha component (usually the last channel)
            unsigned char alphaValue = srcData[srcOffset + (srcSamplesPerPixel - 1)];
            
            // Set RGB to alpha value for grayscale representation
            alphaData[alphaOffset] = alphaValue;     // R
            alphaData[alphaOffset + 1] = alphaValue; // G
            alphaData[alphaOffset + 2] = alphaValue; // B
        }
    }
    
    NSImage *alphaImage = [[NSImage alloc] initWithSize:img.size];
    [alphaImage addRepresentation:alphaRep];
    return alphaImage;
}

- (NSImage *)getAlpha:(NSImage *)img {
    NSSize size = img.size;
    NSBitmapImageRep *srcRep = nil;
    
    // Get bitmap representation
    NSData *tiffData = [img TIFFRepresentation];
    NSBitmapImageRep *rep = [NSBitmapImageRep imageRepWithData:tiffData];
    if (rep) {
        srcRep = rep;
    } else {
        return nil;
    }
    
    // Create new bitmap for alpha channel
    NSBitmapImageRep *alphaRep = [[NSBitmapImageRep alloc]
                                  initWithBitmapDataPlanes:NULL
                                  pixelsWide:size.width
                                  pixelsHigh:size.height
                                  bitsPerSample:8
                                  samplesPerPixel:3
                                  hasAlpha:NO
                                  isPlanar:NO
                                  colorSpaceName:NSCalibratedRGBColorSpace
                                  bytesPerRow:0
                                  bitsPerPixel:0];
    
    // Extract alpha channel
    for (int y = 0; y < size.height; y++) {
        for (int x = 0; x < size.width; x++) {
            NSColor *pixel = [srcRep colorAtX:x y:y];
            CGFloat alpha = pixel.alphaComponent;
            NSUInteger alphaValue = (NSUInteger)(alpha * 255);
            NSColor *grayColor = [NSColor colorWithRed:alphaValue/255.0
                                                green:alphaValue/255.0
                                                 blue:alphaValue/255.0
                                                alpha:1.0];
            [alphaRep setColor:grayColor atX:x y:y];
        }
    }
    
    NSImage *alphaImage = [[NSImage alloc] initWithSize:size];
    [alphaImage addRepresentation:alphaRep];
    return alphaImage;
}

- (NSImage *)changeAlpha:(NSImage *)img alpha:(NSImage *)alpha {
    NSSize size = img.size;
    
    // Get bitmap representations
    NSData *imgTiffData = [img TIFFRepresentation];
    NSBitmapImageRep *srcRep = [NSBitmapImageRep imageRepWithData:imgTiffData];
    
    NSData *alphaTiffData = [alpha TIFFRepresentation];
    NSBitmapImageRep *alphaRep = [NSBitmapImageRep imageRepWithData:alphaTiffData];
    
    if (!srcRep || !alphaRep) return img;
    
    // Create new bitmap with alpha
    NSBitmapImageRep *resultRep = [[NSBitmapImageRep alloc]
                                   initWithBitmapDataPlanes:NULL
                                   pixelsWide:size.width
                                   pixelsHigh:size.height
                                   bitsPerSample:8
                                   samplesPerPixel:4
                                   hasAlpha:YES
                                   isPlanar:NO
                                   colorSpaceName:NSCalibratedRGBColorSpace
                                   bytesPerRow:0
                                   bitsPerPixel:0];
    
    // Apply alpha channel
    for (int y = 0; y < size.height; y++) {
        for (int x = 0; x < size.width; x++) {
            NSColor *srcPixel = [srcRep colorAtX:x y:y];
            NSColor *alphaPixel = [alphaRep colorAtX:x y:y];
            
            NSColor *resultColor = [NSColor colorWithRed:srcPixel.redComponent
                                                   green:srcPixel.greenComponent
                                                    blue:srcPixel.blueComponent
                                                   alpha:alphaPixel.redComponent];
            [resultRep setColor:resultColor atX:x y:y];
        }
    }
    
    NSImage *resultImage = [[NSImage alloc] initWithSize:size];
    [resultImage addRepresentation:resultRep];
    return resultImage;
}

- (nullable NSImage *)cropImage:(LevelInfo *)levelInfo image:(NSImage *)img {
    double ratio = (double)levelInfo.textureSize.width / (double)levelInfo.textureSize.height;
    double newRatio = (double)img.size.width / (double)img.size.height;
    
    if (ratio != newRatio) {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"Warning";
        alert.informativeText = @"The file you want to import does not have the correct aspect ratio!\n\nDo you want SimPE to crop the image?";
        [alert addButtonWithTitle:@"Yes"];
        [alert addButtonWithTitle:@"No"];
        
        NSModalResponse response = [alert runModal];
        if (response == NSAlertFirstButtonReturn) {
            int w = (int)(img.size.height * ratio);
            int h = (int)img.size.height;
            if (w > img.size.width) {
                w = (int)img.size.width;
                h = (int)(img.size.width / ratio);
            }
            
            NSImage *croppedImage = [[NSImage alloc] initWithSize:NSMakeSize(w, h)];
            [croppedImage lockFocus];
            [img drawAtPoint:NSZeroPoint fromRect:NSMakeRect(0, 0, w, h) operation:NSCompositeSourceOver fraction:1.0];
            [croppedImage unlockFocus];
            return croppedImage;
        } else {
            return nil;
        }
    }
    
    return img;
}

- (void)loadDDS:(NSArray<DDSData *> *)data {
    if (data == nil || data.count == 0) return;
    
    @try {
        self.isUpdatingUI = YES;
        
        LevelInfo *levelInfo = [self selectedImageData];
        DDSData *ddsData = data.firstObject;
        levelInfo.format = ddsData.format;
        levelInfo.data = ddsData.data;
        self.pb.image = ddsData.texture;
        
        self.tbwidth.stringValue = [NSString stringWithFormat:@"%d", (int)levelInfo.textureSize.width];
        self.tbheight.stringValue = [NSString stringWithFormat:@"%d", (int)levelInfo.textureSize.height];
        
        // Update format combo box
        [self.cbformats selectItemAtIndex:0];
        for (NSInteger i = 0; i < self.cbformats.numberOfItems; i++) {
            NSNumber *format = [self.cbformats itemObjectValueAtIndex:i];
            if ([format integerValue] == levelInfo.format) {
                [self.cbformats selectItemAtIndex:i];
                break;
            }
        }
    }
    @finally {
        self.isUpdatingUI = NO;
    }
}

- (void)updateUIForSelectedItem {
    // Populate combo boxes and update UI based on wrapper data
    if (self.wrapper) {
        // Clear existing items
        [self.cbitem removeAllItems];
        [self.cbformats removeAllItems];
        
        // Add items from wrapper
        for (id block in self.wrapper.blocks) {
            if ([block isKindOfClass:[LevelInfo class]]) {
                [self.cbitem addItemWithObjectValue:block];
            }
        }
        
        // Add format options (these would come from ImageLoader.TxtrFormats enum)
        [self.cbformats addItemWithObjectValue:@(0)]; // Raw format
        [self.cbformats addItemWithObjectValue:@(1)]; // DXT1
        [self.cbformats addItemWithObjectValue:@(2)]; // DXT3
        [self.cbformats addItemWithObjectValue:@(3)]; // DXT5
        
        // Select first item if available
        if (self.cbitem.numberOfItems > 0) {
            [self.cbitem selectItemAtIndex:0];
            [self selectItem:self.cbitem];
        }
    }
}

// MARK: - IPackedFileUI Protocol

- (BOOL)canHandleWrapper:(id)wrapper {
    return [wrapper isKindOfClass:[Lifo class]];
}

- (void)setWrapper:(id)wrapper {
    if ([wrapper isKindOfClass:[Lifo class]]) {
        self.wrapper = (Lifo *)wrapper;
        [self updateUIForSelectedItem];
    }
}

- (NSString *)tabText {
    return @"LIFO Editor";
}

- (NSString *)tabTooltip {
    return @"LIFO (Light Information) File Editor";
}

- (void)updateGUI:(id<IFileWrapper>)wrapper { 
    <#code#>
}

- (BOOL)commitEditingAndReturnError:(NSError *__autoreleasing  _Nullable * _Nullable)error { 
    <#code#>
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder { 
    <#code#>
}

@end
