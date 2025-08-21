//
//  RcolUI.m
//  MacSimpe
//
//  Created by Catherine Gramze on 8/14/25.
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

#import "RcolUI.h"
#import "RcolForm.h"
#import "RcolWrapper.h"
#import "IRcolBlock.h"
#import "CountedListItem.h"
#import "IScenegraphItem.h"
#import "IPackedFileDescriptor.h"
#import "AbstractRcolBlock.h"

@implementation RcolUI

// MARK: - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        // Form will be created in viewDidLoad
    }
    return self;
}

- (instancetype)initWithWrapper:(id<IFileWrapper>)wrapper {
    self = [self init];
    if (self) {
        _wrapper = wrapper;
    }
    return self;
}

- (instancetype)initWithResource:(id<IPackedFileDescriptor>)resource {
    self = [self init];
    if (self) {
        _resource = resource;
    }
    return self;
}

// MARK: - ViewController Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create the RcolForm
    self.form = [[RcolForm alloc] init];
    
    // Set the form's view as our main view
    self.view = self.form.view;
    
    // If we have a wrapper, update the GUI
    if (self.wrapper != nil) {
        [self updateGUI:self.wrapper];
    }
}

- (void)viewWillAppear {
    [super viewWillAppear];
    
    // Refresh the GUI if needed
    if (self.wrapper != nil) {
        [self updateGUI:self.wrapper];
    }
}

// MARK: - IPackedFileUI Protocol

- (NSView *)guiHandle {
    // If view is loaded, return it directly
    if (self.isViewLoaded) {
        return self.view;
    }
    
    // If form exists, return its view
    if (self.form != nil) {
        return self.form.view;
    }
    
    // Otherwise return nil - view will be available after viewDidLoad
    return nil;
}

- (void)updateGUI:(id<IFileWrapper>)wrapper {
    // Store the wrapper
    self.wrapper = wrapper;
    
    // Cast to Rcol wrapper
    Rcol *wrp = (Rcol *)wrapper;
    
    // If view isn't loaded yet, the update will happen in viewDidLoad
    if (!self.isViewLoaded || self.form == nil) {
        return;
    }
    
    // Set the wrapper on the form
    self.form.wrapper = wrp;
    
    // Update the combo box with blocks
    [self.form.cbitem removeAllItems];
    for (id<IRcolBlock> rb in wrp.blocks) {
        [CountedListItem addHexToComboBox:self.form.cbitem object:rb];
    }
    
    if ([self.form.cbitem numberOfItems] > 0) {
        [self.form.cbitem selectItemAtIndex:0];
    } else {
        [self.form buildChildTabControl:nil];
    }
    
    // Update the referenced files list
    [self.form.referencesDataSource removeAllObjects];
    [self.form.lbref reloadData];
    for (id<IPackedFileDescriptor> pfd in wrp.referencedFiles) {
        [self.form.referencesDataSource addObject:pfd];
    }
    
    if ([self.form.referencesDataSource count] > 0) {
        [self.form.lbref selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
    }
    
    // Manage the reference tab
    [self.form.tbResource removeTabViewItem:self.form.tpref];
    [self.form.rootItems removeAllObjects];
    [self.form.tv reloadData];
    
    // Check if wrapper implements IScenegraphItem
    if ([wrp conformsToProtocol:@protocol(IScenegraphItem)]) {
        [self.form.tbResource addTabViewItem:self.form.tpref];
        
        id<IScenegraphItem> sgItem = (id<IScenegraphItem>)wrp;
        NSDictionary *refMap = [sgItem referenceChains];
        
        for (NSString *key in refMap.allKeys) {
            NSArray *list = refMap[key];
            NSTreeNode *node = [NSTreeNode treeNodeWithRepresentedObject:key];
            
            for (id<IPackedFileDescriptor> pfd in list) {
                NSString *childTitle = [NSString stringWithFormat:@"%@: %@",
                                       [pfd filename], [pfd description]];
                NSTreeNode *child = [NSTreeNode treeNodeWithRepresentedObject:pfd];
                [child.representedObject setValue:childTitle forKey:@"title"];
                [[node mutableChildNodes] addObject:child];
            }
            
            [self.form.rootItems addObject:node];
            [self.form.tv reloadData];
        }
    }
    
    // Select the first tab
    [self.form.tbResource selectTabViewItemAtIndex:0];
    
    // Add the first block to the resource tab control
    if ([wrp.blocks count] > 0) {
        AbstractRcolBlock *firstBlock = (AbstractRcolBlock *)wrp.blocks[0];
        [firstBlock addToResourceTabControl:self.form.tbResource comboBox:self.form.cbitem];
    }
    
    // Enable/disable based on wrapper state
    self.form.view.alphaValue = [wrp duff] ? 0.5 : 1.0;
}

@end
