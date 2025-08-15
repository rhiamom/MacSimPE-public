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
        _form = [[RcolForm alloc] init];
    }
    return self;
}

// MARK: - IPackedFileUI Protocol

- (NSView *)guiHandle {
    if (self.form == nil) {
        return nil;
    }
    return self.form.view;
}

- (void)updateGUI:(id<IFileWrapper>)wrapper {
    Rcol *wrp = (Rcol *)wrapper;
    self.form.wrapper = wrp;
    
    [self.form.cbitem removeAllItems];
    for (id<IRcolBlock> rb in wrp.blocks) {
        [CountedListItem addHex:self.form.cbitem object:rb];
    }
    
    if ([self.form.cbitem numberOfItems] > 0) {
        [self.form.cbitem selectItemAtIndex:0];
    } else {
        [self.form buildChildTabControl:nil];
    }
    
    [self.form.lbref removeAllObjects];
    for (id<IPackedFileDescriptor> pfd in wrp.referencedFiles) {
        [self.form.lbref addObject:pfd];
    }
    
    if ([self.form.lbref count] > 0) {
        [self.form.lbref selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
    }
    
    [self.form.tbResource removeTabViewItem:self.form.tpref];
    [self.form.tv removeAllChildren];
    
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
            
            [[self.form.tv rootNode] insertChildNode:node atIndex:[[self.form.tv rootNode] countOfChildNodes]];
        }
    }
    
    [self.form.tbResource selectTabViewItemAtIndex:0];
    
    if ([wrp.blocks count] > 0) {
        AbstractRcolBlock *firstBlock = (AbstractRcolBlock *)wrp.blocks[0];
        [firstBlock addToResourceTabControl:self.form.tbResource comboBox:self.form.cbitem];
    }
    
    [self.form.view setEnabled:![wrp duff]];
}

@end
