//
//  GenericTree.m
//  MacSimpe
//
//  Created by Catherine Gramze on 9/3/25.
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

#import "GenericTree.h"
#import "GenericElements.h"
#import "GenericCommon.h"
#import "GenericFileItem.h"
#import "IFileWrapper.h"
#import "IFileWrapperSaveExtension.h"
#import "IPackedFileDescriptor.h"
#import "Helper.h"
#import <Cocoa/Cocoa.h>

#pragma clang assume_nonnull begin

// Simple NSOutlineViewItem subclass to hold our data
@interface GenericTreeNode : NSObject
@property (nonatomic, strong) GenericItem *item;
@property (nonatomic, strong) NSString *displayText;
@property (nonatomic, strong) NSMutableArray<GenericTreeNode *> *children;

- (instancetype)initWithItem:(GenericItem *)item displayText:(NSString *)text;
- (void)addChild:(GenericTreeNode *)child;
@end

@implementation GenericTreeNode

- (instancetype)initWithItem:(GenericItem *)item displayText:(NSString *)text {
    self = [super init];
    if (self) {
        _item = item;
        _displayText = text;
        _children = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addChild:(GenericTreeNode *)child {
    [_children addObject:child];
}

@end

@implementation GenericTree {
    NSMutableArray<GenericTreeNode *> *_treeData;
    NSArray<NSString *> *_currentNames;
}

// MARK: - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        _treeData = [[NSMutableArray alloc] init];
    }
    return self;
}

// MARK: - IPackedFileUI Protocol Override

- (NSView *)createView {
    return [GenericUIBase form].treePanel;
}

- (void)updateGUI:(id<IFileWrapper>)wrapper {
    GenericElements *form = [GenericUIBase form];
    
    // Make tree visible
    form.mytree.hidden = NO;
    
    // Get file descriptor
    id<IPackedFileDescriptor> pfd = wrapper.fileDescriptor;
    
    // Clear existing tree data
    [_treeData removeAllObjects];
    form.treeBanner.stringValue = [NSString stringWithFormat:@"[Can't process unknown type 0x%X]", pfd.type];
    
    @try {
        // Note: This assumes the wrapper has similar methods to the C# Generic class
        // You'll need to implement these methods in your Generic wrapper class
        
        if ([wrapper respondsToSelector:@selector(count)] && [wrapper respondsToSelector:@selector(getItem:)]) {
            NSInteger count = [(id)wrapper performSelector:@selector(count)];
            
            if (count > 0) {
                // Get first item to determine column structure
                GenericItem *firstItem = [(id)wrapper performSelector:@selector(getItem:) withObject:@(0)];
                if (firstItem != nil) {
                    NSArray<NSString *> *names = firstItem.names;
                    _currentNames = names;
                    
                    if (names.count > 0) {
                        form.treeBanner.stringValue = [NSString stringWithFormat:@"Generic File Viewer"];
                        
                        // Setup tree item panel controls
                        [form.treeItemPanel.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
                        
                        for (NSUInteger i = 0; i < names.count; i++) {
                            NSString *fieldName = names[i];
                            
                            // Create label
                            NSTextField *label = [[NSTextField alloc] init];
                            label.stringValue = fieldName;
                            label.editable = NO;
                            label.bordered = NO;
                            label.backgroundColor = [NSColor clearColor];
                            label.frame = NSMakeRect(0, i * 21 + 4, 0, 17);
                            [label sizeToFit];
                            [form.treeItemPanel addSubview:label];
                            
                            // Create text field
                            NSTextField *textField = [[NSTextField alloc] init];
                            textField.stringValue = @"";
                            textField.frame = NSMakeRect(label.frame.size.width + 8, i * 21,
                                                        form.treeItemPanel.frame.size.width - label.frame.size.width - 8,
                                                        21);
                            textField.tag = i;
                            [form.treeItemPanel addSubview:textField];
                        }
                        
                        // Build tree data
                        NSMutableArray<GenericItem *> *items = [[NSMutableArray alloc] init];
                        for (NSInteger i = 0; i < count; i++) {
                            GenericItem *item = [(id)wrapper performSelector:@selector(getItem:) withObject:@(i)];
                            if (item != nil) {
                                [items addObject:item];
                            }
                        }
                        
                        [self addTreeNodes:items parentNode:nil names:names];
                        
                        // Setup outline view data source
                        form.mytree.dataSource = self;
                        form.mytree.delegate = self;
                        [form.mytree reloadData];
                    }
                }
            }
        }
        
    } @catch (NSException *exception) {
        if ([Helper debugMode]) {
            form.treeBanner.stringValue = [form.treeBanner.stringValue stringByAppendingFormat:@" [%@]", exception.reason];
        }
    }
}

// MARK: - Tree Building Methods

- (void)addTreeNodes:(NSArray<GenericItem *> *)items
          parentNode:(nullable GenericTreeNode *)parentNode
               names:(NSArray<NSString *> *)names {
    
    for (GenericItem *fileitem in items) {
        if (fileitem != nil) {
            // Build display text
            NSMutableString *text = [[NSMutableString alloc] init];
            
            if (names.count > 0) {
                NSString *firstValue = [self toString:names[0] item:fileitem object:[fileitem valueForProperty:names[0]]];
                [text appendString:firstValue];
                [text appendString:@" ("];
                
                for (NSUInteger k = 1; k < names.count; k++) {
                    if (k > 1) {
                        [text appendString:@", "];
                    }
                    NSString *value = [self toString:names[k] item:fileitem object:[fileitem valueForProperty:names[k]]];
                    [text appendFormat:@"%@=%@", names[k], value];
                }
                [text appendString:@")"];
            }
            
            // Create tree node
            GenericTreeNode *node = [[GenericTreeNode alloc] initWithItem:fileitem displayText:text];
            
            // Add child nodes if this item has subitems
            if (fileitem.count > 0 && fileitem.subitems != nil) {
                [self addTreeNodes:fileitem.subitems parentNode:node names:names];
            }
            
            // Add to appropriate parent
            if (parentNode == nil) {
                [_treeData addObject:node];
            } else {
                [parentNode addChild:node];
            }
        }
    }
}

// MARK: - NSOutlineViewDataSource

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(nullable id)item {
    if (item == nil) {
        return _treeData.count;
    } else if ([item isKindOfClass:[GenericTreeNode class]]) {
        GenericTreeNode *node = (GenericTreeNode *)item;
        return node.children.count;
    }
    return 0;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(nullable id)item {
    if (item == nil) {
        return _treeData[index];
    } else if ([item isKindOfClass:[GenericTreeNode class]]) {
        GenericTreeNode *node = (GenericTreeNode *)item;
        return node.children[index];
    }
    return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    if ([item isKindOfClass:[GenericTreeNode class]]) {
        GenericTreeNode *node = (GenericTreeNode *)item;
        return node.children.count > 0;
    }
    return NO;
}

// MARK: - NSOutlineViewDelegate

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(nullable NSTableColumn *)tableColumn item:(id)item {
    NSTableCellView *cellView = [outlineView makeViewWithIdentifier:@"DataCell" owner:self];
    if (cellView == nil) {
        cellView = [[NSTableCellView alloc] init];
        cellView.identifier = @"DataCell";
        
        NSTextField *textField = [[NSTextField alloc] init];
        textField.bordered = NO;
        textField.backgroundColor = [NSColor clearColor];
        textField.editable = NO;
        [cellView addSubview:textField];
        cellView.textField = textField;
        
        // Setup constraints
        textField.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [textField.leadingAnchor constraintEqualToAnchor:cellView.leadingAnchor constant:2],
            [textField.trailingAnchor constraintEqualToAnchor:cellView.trailingAnchor constant:-2],
            [textField.topAnchor constraintEqualToAnchor:cellView.topAnchor],
            [textField.bottomAnchor constraintEqualToAnchor:cellView.bottomAnchor]
        ]];
    }
    
    if ([item isKindOfClass:[GenericTreeNode class]]) {
        GenericTreeNode *node = (GenericTreeNode *)item;
        cellView.textField.stringValue = node.displayText;
    }
    
    return cellView;
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
    NSOutlineView *outlineView = notification.object;
    NSInteger selectedRow = outlineView.selectedRow;
    
    if (selectedRow >= 0) {
        id selectedItem = [outlineView itemAtRow:selectedRow];
        if ([selectedItem isKindOfClass:[GenericTreeNode class]]) {
            GenericTreeNode *node = (GenericTreeNode *)selectedItem;
            GenericItem *item = node.item;
            
            // Update the tree item panel with selected item's properties
            GenericElements *form = [GenericUIBase form];
            NSArray<NSView *> *textFields = [form.treeItemPanel.subviews filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id obj, NSDictionary *bindings) {
                return [obj isKindOfClass:[NSTextField class]] && [(NSTextField *)obj isEditable];
            }]];
            
            for (NSTextField *textField in textFields) {
                NSInteger index = textField.tag;
                if (index >= 0 && index < _currentNames.count && _currentNames != nil) {
                    NSString *propertyName = _currentNames[index];
                    id value = [item valueForProperty:propertyName];
                    textField.stringValue = [self toString:propertyName item:item object:value];
                }
            }
        }
    }
}

@end

#pragma clang assume_nonnull end
