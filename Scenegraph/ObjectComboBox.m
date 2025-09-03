//
//  ObjectComboBox.m
//  MacSimpe
//
//  Created by Catherine Gramze on 8/30/25.
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

#import "ObjectComboBox.h"
#import "MemoryCacheFile.h"
#import "MemoryCacheItem.h"
#import "StaticAlias.h"
#import "IAlias.h"

@interface ObjectComboBox ()

@property (nonatomic, strong) NSComboBox *comboBox;
@property (nonatomic, assign) BOOL loaded;

@end

@implementation ObjectComboBox

static MemoryCacheFile *_cacheFile = nil;

// MARK: - Class Properties

+ (MemoryCacheFile *)objectCache {
    if (_cacheFile == nil) {
        _cacheFile = [MemoryCacheFile initCacheFile];
    }
    return _cacheFile;
}

// MARK: - Initialization

- (instancetype)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        [self setupComboBox];
        [self initializeProperties];
    }
    return self;
}

- (void)setupComboBox {
    // Create and configure the combo box
    self.comboBox = [[NSComboBox alloc] initWithFrame:NSMakeRect(0, 0, self.frame.size.width, 21)];
    self.comboBox.font = [NSFont systemFontOfSize:12];
    
    // Set up autolayout
    self.comboBox.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.comboBox];
    
    // Constraints
    [NSLayoutConstraint activateConstraints:@[
        [self.comboBox.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.comboBox.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [self.comboBox.topAnchor constraintEqualToAnchor:self.topAnchor],
        [self.comboBox.heightAnchor constraintEqualToConstant:21]
    ]];
    
    // Set up event handling
    self.comboBox.target = self;
    self.comboBox.action = @selector(comboBoxSelectionChanged:);
    
    // Use a custom data source
    self.comboBox.usesDataSource = YES;
    self.comboBox.dataSource = self;
    self.comboBox.delegate = self;
}

- (void)initializeProperties {
    self.loaded = NO;
    self.showInventory = YES;
    self.showTokens = NO;
    self.showMemories = NO;
    self.showJobData = NO;
    self.showAspiration = NO;
    self.showBadge = NO;
    self.showSkill = NO;
}

// MARK: - Property Setters

- (void)setShowInventory:(BOOL)showInventory {
    if (_showInventory != showInventory) {
        _showInventory = showInventory;
        [self setContent];
    }
}

- (void)setShowTokens:(BOOL)showTokens {
    if (_showTokens != showTokens) {
        _showTokens = showTokens;
        [self setContent];
    }
}

- (void)setShowMemories:(BOOL)showMemories {
    if (_showMemories != showMemories) {
        _showMemories = showMemories;
        [self setContent];
    }
}

- (void)setShowJobData:(BOOL)showJobData {
    if (_showJobData != showJobData) {
        _showJobData = showJobData;
        [self setContent];
    }
}

- (void)setShowAspiration:(BOOL)showAspiration {
    if (_showAspiration != showAspiration) {
        _showAspiration = showAspiration;
        [self setContent];
    }
}

- (void)setShowBadge:(BOOL)showBadge {
    if (_showBadge != showBadge) {
        _showBadge = showBadge;
        [self setContent];
    }
}

- (void)setShowSkill:(BOOL)showSkill {
    if (_showSkill != showSkill) {
        _showSkill = showSkill;
        [self setContent];
    }
}

// MARK: - Selection Properties

- (uint32_t)selectedGuid {
    MemoryCacheItem *mci = self.selectedItem;
    if (mci == nil) {
        return 0xffffffff;
    }
    return mci.guid;
}

- (void)setSelectedGuid:(uint32_t)selectedGuid {
    NSInteger selectedIndex = -1;
    NSInteger count = 0;
    
    for (NSInteger i = 0; i < self.comboBox.numberOfItems; i++) {
        id<IAlias> alias = [self.comboBox itemObjectValueAtIndex:i];
        if ([alias.tag count] > 0) {
            MemoryCacheItem *mci = alias.tag[0];
            if ([mci isKindOfClass:[MemoryCacheItem class]] && mci.guid == selectedGuid) {
                selectedIndex = count;
                break;
            }
        }
        count++;
    }
    
    [self.comboBox selectItemAtIndex:selectedIndex];
}

- (MemoryCacheItem *)selectedItem {
    if (self.comboBox.indexOfSelectedItem == -1) {
        return nil;
    }
    
    id<IAlias> alias = [self.comboBox itemObjectValueAtIndex:self.comboBox.indexOfSelectedItem];
    if (alias && [alias.tag count] > 0) {
        return alias.tag[0];
    }
    
    return nil;
}

- (void)setSelectedItem:(MemoryCacheItem *)selectedItem {
    NSInteger selectedIndex = -1;
    
    if (selectedItem != nil) {
        NSInteger count = 0;
        for (NSInteger i = 0; i < self.comboBox.numberOfItems; i++) {
            id<IAlias> alias = [self.comboBox itemObjectValueAtIndex:i];
            if ([alias.tag count] > 0) {
                MemoryCacheItem *mci = alias.tag[0];
                if ([mci isKindOfClass:[MemoryCacheItem class]] && mci.guid == selectedItem.guid) {
                    selectedIndex = count;
                    break;
                }
            }
            count++;
        }
    }
    
    [self.comboBox selectItemAtIndex:selectedIndex];
}

// MARK: - Content Management

- (void)setContent {
    if (!self.loaded) return;
    
    @try {
        [self.comboBox removeAllItems];
        
        NSMutableArray *items = [[NSMutableArray alloc] init];
        
        for (MemoryCacheItem *mci in [ObjectComboBox objectCache].list) {
            BOOL use = NO;
            
            if (self.showInventory && mci.isInventory && !mci.isToken && !mci.isMemory && !mci.isJobData) {
                use = YES;
            }
            if (self.showTokens && mci.isToken) {
                use = YES;
            }
            if (self.showMemories && !mci.isToken && mci.isMemory) {
                use = YES;
            }
            if (self.showJobData && mci.isJobData) {
                use = YES;
            }
            if (self.showAspiration && mci.isAspiration) {
                use = YES;
            }
            if (self.showBadge && mci.isBadge) {
                use = YES;
            }
            if (self.showSkill && mci.isSkill) {
                use = YES;
            }
            
            if (!use) continue;
            
            NSString *displayName = [NSString stringWithFormat:@"%@ {%@}", mci.name, mci.objdName];
            StaticAlias *alias = [[StaticAlias alloc] initWithGuid:mci.guid
                                                              name:displayName
                                                               tag:@[mci]];
            
            [items addObject:alias];
        }
        
        // Sort items by display name
        [items sortUsingComparator:^NSComparisonResult(id<IAlias> obj1, id<IAlias> obj2) {
            return [obj1.name localizedCaseInsensitiveCompare:obj2.name];
        }];
        
        // Add sorted items to combo box
        for (id<IAlias> alias in items) {
            [self.comboBox addItemWithObjectValue:alias];
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Exception in ObjectComboBox setContent: %@", exception.reason);
    }
}

- (void)reload {
    self.loaded = YES;
    [self setContent];
    [self setNeedsDisplay:YES];
}

// MARK: - View Lifecycle

- (void)viewDidMoveToWindow {
    [super viewDidMoveToWindow];
    if (!self.loaded && self.window != nil) {
        [self reload];
    }
}

// MARK: - Event Handlers

- (void)comboBoxSelectionChanged:(id)sender {
    if (self.selectedObjectChanged) {
        self.selectedObjectChanged(self);
    }
}

// MARK: - NSComboBoxDataSource

- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)comboBox {
    return comboBox.numberOfItems;
}

- (id)comboBox:(NSComboBox *)comboBox objectValueForItemAtIndex:(NSInteger)index {
    return [comboBox itemObjectValueAtIndex:index];
}

// MARK: - NSComboBoxDelegate

- (NSString *)comboBox:(NSComboBox *)comboBox completedString:(NSString *)string {
    // Find the first item that starts with the string
    for (NSInteger i = 0; i < comboBox.numberOfItems; i++) {
        id<IAlias> alias = [comboBox itemObjectValueAtIndex:i];
        if ([alias.name hasPrefix:string]) {
            return alias.name;
        }
    }
    return nil;
}

@end
#import <Foundation/Foundation.h>
