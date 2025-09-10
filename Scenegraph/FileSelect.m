//
//  FileSelect.m
//  MacSimpe
//
//  Created by Catherine Gramze on 9/9/25.
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

#import "FileSelect.h"
#import "FileTable.h"
#import "FileTableBase.h"
#import "IScenegraphFileIndex.h"
#import "CpfWrapper.h"
#import "CpfItem.h"
#import "PackedFileItem.h"
#import "GenericRcolWrapper.h"
#import "cImageData.h"
#import "ImageLoader.h"
#import "Helper.h"
#import "WaitingScreen.h"
#import "MetaData.h"

@implementation SkinTreeNode

@synthesize skinData = _skinData;

- (instancetype)initWithTitle:(NSString *)title {
    return [self initWithTitle:title skinData:nil];
}

- (instancetype)initWithTitle:(NSString *)title skinData:(nullable Cpf *)skinData {
    self = [super init];
    if (self) {
        _title = [title copy];
        _skinData = skinData;
        _children = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addChild:(SkinTreeNode *)child {
    child.parent = self;
    [_children addObject:child];
}

- (BOOL)isLeaf {
    return _children.count == 0;
}

- (NSString *)description {
    return _title;
}

@end

@interface FileSelect()

@property (nonatomic, strong, nullable) FileSelect *sharedInstance;

@end

@implementation FileSelect

static FileSelect *sharedForm = nil;

// MARK: - Class Methods

+ (nullable id<IPackedFileDescriptor>)execute {
    if (sharedForm == nil) {
        sharedForm = [[FileSelect alloc] init];
    }
    return [sharedForm doExecute];
}

// MARK: - Initialization

- (instancetype)init {
    self = [super initWithWindowNibName:@"FileSelect"];
    if (self) {
        _categoryMap = [[NSMutableDictionary alloc] init];
        _femaleRootNodes = [[NSMutableArray alloc] init];
        _maleRootNodes = [[NSMutableArray alloc] init];
        _userConfirmed = NO;
        _selectedNode = nil;
        
        [self createCategoryNodes:_femaleRootNodes forGender:1];
        [self createCategoryNodes:_maleRootNodes forGender:2];
        
        [self fillCategoryNodes];
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Configure window
    self.window.title = @"Skin Select";
    
    // Configure tree views
    _femaleTreeView.dataSource = self;
    _femaleTreeView.delegate = self;
    _maleTreeView.dataSource = self;
    _maleTreeView.delegate = self;
    
    // Configure tab view
    NSTabViewItem *femaleTab = [_tabControl tabViewItemAtIndex:0];
    femaleTab.label = @"Female";
    
    NSTabViewItem *maleTab = [_tabControl tabViewItemAtIndex:1];
    maleTab.label = @"Male";
    
    // Configure picture box
    _pictureBox.imageScaling = NSImageScaleProportionallyUpOrDown;
    
    // Configure name label
    _nameLabel.stringValue = @"";
    _nameLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    // Configure use button
    _useButton.enabled = NO;
    
    [_femaleTreeView reloadData];
    [_maleTreeView reloadData];
}

// MARK: - Public Methods

- (nullable id<IPackedFileDescriptor>)doExecute {
    _nameLabel.stringValue = @"";
    _userConfirmed = NO;
    _selectedNode = nil;
    _useButton.enabled = NO;
    _pictureBox.image = nil;
    
    NSModalResponse response = [NSApp runModalForWindow:self.window];
    
    if (response == NSModalResponseOK && _selectedNode != nil) {
        if ([_selectedNode isKindOfClass:[SkinTreeNode class]]) {
            SkinTreeNode *node = (SkinTreeNode *)_selectedNode;
            if (node.skinData != nil) {
                return node.skinData.fileDescriptor;
            }
        }
    }
    
    return nil;
}

// MARK: - IBActions

- (IBAction)useButtonClicked:(id)sender {
    _userConfirmed = YES;
    [NSApp stopModalWithCode:NSModalResponseOK];
    [self.window orderOut:nil];
}

// MARK: - Private Methods

- (void)createCategoryNodes:(NSMutableArray *)treeNodes forGender:(uint32_t)gender {
    // Get enum values for ages and skin categories
    NSArray<NSNumber *> *ages = @[@(AgeBaby), @(AgeToddler), @(AgeChild), @(AgeTeen), @(AgeYoungAdult), @(AgeAdult), @(AgeElder)];
    NSArray<NSNumber *> *categories = @[@(SkinCategoriesSkin), @(SkinCategoriesEveryday), @(SkinCategoriesActivewear),
                                        @(SkinCategoriesFormal), @(SkinCategoriesSwimwear), @(SkinCategoriesOuterwear),
                                        @(SkinCategoriesPj), @(SkinCategoriesUndies)];
    
    for (NSNumber *ageNum in ages) {
        uint32_t age = [ageNum unsignedIntValue];
        NSString *ageString = [self stringForAge:age];
        
        SkinTreeNode *ageNode = [[SkinTreeNode alloc] initWithTitle:ageString];
        [treeNodes addObject:ageNode];
        
        NSMutableDictionary *catMap = _categoryMap[@(age)];
        if (catMap == nil) {
            catMap = [[NSMutableDictionary alloc] init];
            _categoryMap[@(age)] = catMap;
        }
        
        for (NSNumber *catNum in categories) {
            uint32_t category = [catNum unsignedIntValue];
            NSString *categoryString = [self stringForSkinCategory:category];
            
            SkinTreeNode *catNode = [[SkinTreeNode alloc] initWithTitle:categoryString];
            [ageNode addChild:catNode];
            
            NSMutableDictionary *genderMap = catMap[@(category)];
            if (genderMap == nil) {
                genderMap = [[NSMutableDictionary alloc] init];
                catMap[@(category)] = genderMap;
            }
            
            genderMap[@(gender)] = catNode;
        }
    }
}

- (void)fillCategoryNodes {
    [WaitingScreen wait];
    
    @try {
        [[FileTable fileIndex] load];
        // Use findFileWithType:noLocal: instead of findFiles:
        NSArray *items = [[FileTable fileIndex] findFileWithType:[MetaData GZPS] noLocal:NO];
        
        for (id<IScenegraphFileIndexItem> item in items) {
            Cpf *skin = [[Cpf alloc] init];
            [skin processData:item];
            
            NSString *typeValue = [[skin getSaveItem:@"type"] stringValue];
            if ([typeValue isEqualToString:@"skin"]) {
                BOOL added = NO;
                // Remove unsignedIntValue calls - uintegerValue already returns uint32_t
                uint32_t skinAge = [[skin getSaveItem:@"age"] uintegerValue];
                uint32_t skinCat = [[skin getSaveItem:@"category"] uintegerValue];
                
                // Handle special skin category cases
                if ((skinCat & SkinCategoriesSkin) == SkinCategoriesSkin) {
                    skinCat = SkinCategoriesSkin;
                }
                
                NSString *override0 = [[skin getSaveItem:@"override0subset"] stringValue];
                NSString *lowerOverride = [override0.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                if ([lowerOverride hasPrefix:@"hair"] || [lowerOverride hasPrefix:@"bang"]) {
                    skinCat = SkinCategoriesSkin;
                }
                
                uint32_t skinSex = [[skin getSaveItem:@"gender"] uintegerValue];
                NSString *name = [[skin getSaveItem:@"name"] stringValue];
                // ... rest of your code
                
                // Try to find appropriate category node
                for (NSNumber *ageKey in _categoryMap.allKeys) {
                    uint32_t age = [ageKey unsignedIntValue];
                    if ((age & skinAge) == age) {
                        NSDictionary *cats = _categoryMap[ageKey];
                        for (NSNumber *catKey in cats.allKeys) {
                            uint32_t cat = [catKey unsignedIntValue];
                            if ((cat & skinCat) == cat) {
                                NSDictionary *genderMap = cats[catKey];
                                for (NSNumber *genderKey in genderMap.allKeys) {
                                    uint32_t gender = [genderKey unsignedIntValue];
                                    if ((gender & skinSex) == gender) {
                                        SkinTreeNode *parentNode = genderMap[genderKey];
                                        SkinTreeNode *skinNode = [[SkinTreeNode alloc] initWithTitle:name skinData:skin];
                                        [parentNode addChild:skinNode];
                                        added = YES;
                                    }
                                }
                            }
                        }
                    }
                }
                
                // If not categorized, add to both root trees
                if (!added) {
                    SkinTreeNode *maleNode = [[SkinTreeNode alloc] initWithTitle:name skinData:skin];
                    SkinTreeNode *femaleNode = [[SkinTreeNode alloc] initWithTitle:name skinData:skin];
                    [_maleRootNodes addObject:maleNode];
                    [_femaleRootNodes addObject:femaleNode];
                }
            }
        }
    }
    @finally {
        [WaitingScreen stop];
    }
}

- (void)handleSelectionChange:(NSOutlineView *)outlineView {
    _pictureBox.image = nil;
    _useButton.enabled = NO;
    _nameLabel.stringValue = @"";
    _selectedNode = nil;
    
    NSInteger selectedRow = outlineView.selectedRow;
    if (selectedRow == -1) return;
    
    id item = [outlineView itemAtRow:selectedRow];
    if (![item isKindOfClass:[SkinTreeNode class]]) return;
    
    SkinTreeNode *node = (SkinTreeNode *)item;
    if (node.skinData == nil) return;
    
    _useButton.enabled = YES;
    _selectedNode = node;
    
    SkinChain *skinChain = [[SkinChain alloc] initWithCpf:node.skinData];
    GenericRcol *rcol = skinChain.txtr;
    
    if (rcol != nil && rcol.blocks.count > 0) {
        ImageData *imageData = rcol.blocks[0];
        MipMap *mipMap = [imageData getLargestTextureForSize:_pictureBox.bounds.size];
        if (mipMap != nil) {
            NSImage *preview = [ImageLoader previewForTexture:mipMap.texture size:_pictureBox.bounds.size];
            _pictureBox.image = preview;
        }
    }
    
    NSString *lineBreak = @"\n";
    NSMutableString *infoText = [[NSMutableString alloc] init];
    [infoText appendFormat:@"Name: %@%@%@", lineBreak, skinChain.name, lineBreak];
    [infoText appendFormat:@"Category: %@%@%@", lineBreak, skinChain.categoryNames, lineBreak];
    [infoText appendFormat:@"Age: %@%@%@", lineBreak, skinChain.ageNames, lineBreak];
    [infoText appendFormat:@"Override: %@%@%@", lineBreak,
     [[node.skinData getSaveItem:@"override0subset"] stringValue], lineBreak];
    [infoText appendFormat:@"Group: %@%@%@", lineBreak,
     [Helper hexString:node.skinData.fileDescriptor.group], lineBreak];
    
    _nameLabel.stringValue = infoText;
}

// MARK: - Helper Methods

- (NSString *)stringForAge:(uint32_t)age {
    switch (age) {
        case AgeBaby: return @"Baby";
        case AgeToddler: return @"Toddler";
        case AgeChild: return @"Child";
        case AgeTeen: return @"Teen";
        case AgeYoungAdult: return @"YoungAdult";
        case AgeAdult: return @"Adult";
        case AgeElder: return @"Elder";
        default: return [NSString stringWithFormat:@"Age_%u", age];
    }
}

- (NSString *)stringForSkinCategory:(uint32_t)category {
    switch (category) {
        case SkinCategoriesSkin: return @"Skin";
        case SkinCategoriesEveryday: return @"Everyday";
        case SkinCategoriesFormal: return @"Formal";
        case SkinCategoriesSwimwear: return @"Swimwear";
        case SkinCategoriesPj: return @"Pajamas";
        case SkinCategoriesUndies: return @"Underwear";
        case SkinCategoriesOuterwear: return @"Outerwear";
        case SkinCategoriesActivewear: return @"Activewear";
        case SkinCategoriesPregnant: return @"Pregnant";
        default: return [NSString stringWithFormat:@"Category_%u", category];
    }
}

// MARK: - NSOutlineViewDataSource

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(nullable id)item {
    if (item == nil) {
        // Root level
        if (outlineView == _femaleTreeView) {
            return _femaleRootNodes.count;
        } else if (outlineView == _maleTreeView) {
            return _maleRootNodes.count;
        }
        return 0;
    } else if ([item isKindOfClass:[SkinTreeNode class]]) {
        SkinTreeNode *node = (SkinTreeNode *)item;
        return node.children.count;
    }
    return 0;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(nullable id)item {
    if (item == nil) {
        // Root level
        if (outlineView == _femaleTreeView && index < _femaleRootNodes.count) {
            return _femaleRootNodes[index];
        } else if (outlineView == _maleTreeView && index < _maleRootNodes.count) {
            return _maleRootNodes[index];
        }
        return nil;
    } else if ([item isKindOfClass:[SkinTreeNode class]]) {
        SkinTreeNode *node = (SkinTreeNode *)item;
        if (index < node.children.count) {
            return node.children[index];
        }
    }
    return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    if ([item isKindOfClass:[SkinTreeNode class]]) {
        SkinTreeNode *node = (SkinTreeNode *)item;
        return !node.isLeaf;
    }
    return NO;
}

// MARK: - NSOutlineViewDelegate

- (nullable NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(nullable NSTableColumn *)tableColumn item:(id)item {
    NSTableCellView *cellView = [outlineView makeViewWithIdentifier:@"DataCell" owner:self];
    if (cellView == nil) {
        cellView = [[NSTableCellView alloc] init];
        cellView.identifier = @"DataCell";
        
        NSTextField *textField = [[NSTextField alloc] init];
        textField.bordered = NO;
        textField.backgroundColor = [NSColor clearColor];
        textField.editable = NO;
        textField.translatesAutoresizingMaskIntoConstraints = NO;
        [cellView addSubview:textField];
        cellView.textField = textField;
        
        [NSLayoutConstraint activateConstraints:@[
            [textField.leadingAnchor constraintEqualToAnchor:cellView.leadingAnchor constant:2],
            [textField.trailingAnchor constraintEqualToAnchor:cellView.trailingAnchor constant:-2],
            [textField.centerYAnchor constraintEqualToAnchor:cellView.centerYAnchor]
        ]];
    }
    
    if ([item isKindOfClass:[SkinTreeNode class]]) {
        SkinTreeNode *node = (SkinTreeNode *)item;
        cellView.textField.stringValue = node.title;
    }
    
    return cellView;
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
    NSOutlineView *outlineView = notification.object;
    [self handleSelectionChange:outlineView];
}

@end
