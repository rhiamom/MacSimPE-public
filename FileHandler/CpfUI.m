//
//  CpfUI.m
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
// ***************************************************************************

#import "CpfUI.h"
#import "CpfWrapper.h"
#import "CpfItem.h"
#import "MetaData.h"
#import "IFileWrapper.h"
#import "IFileWrapperSaveExtension.h"

@interface CpfUI () <NSTableViewDataSource, NSTableViewDelegate>
@property (nonatomic, strong) NSMutableArray<CpfItem *> *internalItems;
@end

@implementation CpfUI

- (instancetype)initWithExecutePreview:(ExecutePreviewBlock)executePreview {
    self = [super initWithNibName:@"CpfUI" bundle:nil];
    if (self) {
        _executePreview = executePreview;
        _internalItems = [[NSMutableArray alloc] init];
        _changeEnabled = NO;
    }
    return self;
}

- (instancetype)initWithWrapper:(id<IFileWrapper>)wrapper {
    self = [self initWithExecutePreview:nil];
    if (self) {
        if ([wrapper isKindOfClass:[Cpf class]]) {
            _wrapper = (Cpf *)wrapper;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self setupDataTypePopUp];
}

- (void)setupUI {
    // Configure table view
    self.itemsTableView.dataSource = self;
    self.itemsTableView.delegate = self;
    
    // Setup table columns
    NSTableColumn *nameColumn = [[NSTableColumn alloc] initWithIdentifier:@"name"];
    nameColumn.title = @"Name";
    nameColumn.width = 150;
    [self.itemsTableView addTableColumn:nameColumn];
    
    NSTableColumn *typeColumn = [[NSTableColumn alloc] initWithIdentifier:@"type"];
    typeColumn.title = @"Type";
    typeColumn.width = 100;
    [self.itemsTableView addTableColumn:typeColumn];
    
    NSTableColumn *valueColumn = [[NSTableColumn alloc] initWithIdentifier:@"value"];
    valueColumn.title = @"Value";
    valueColumn.width = 200;
    [self.itemsTableView addTableColumn:valueColumn];
    
    // Configure buttons
    self.removeButton.enabled = NO;
    self.previewButton.hidden = (self.executePreview == nil);
    
    // Setup text field actions
    self.nameTextField.target = self;
    self.nameTextField.action = @selector(nameChanged:);
    
    self.valueTextField.target = self;
    self.valueTextField.action = @selector(valueChanged:);
}

- (void)setupDataTypePopUp {
    [self.dataTypePopUp removeAllItems];
    
    [self.dataTypePopUp addItemWithTitle:@"String"];
    [[self.dataTypePopUp lastItem] setTag:DataTypesString];
    
    [self.dataTypePopUp addItemWithTitle:@"Unsigned Integer"];
    [[self.dataTypePopUp lastItem] setTag:DataTypesUInteger];
    
    [self.dataTypePopUp addItemWithTitle:@"Integer"];
    [[self.dataTypePopUp lastItem] setTag:DataTypesInteger];
    
    [self.dataTypePopUp addItemWithTitle:@"Single Float"];
    [[self.dataTypePopUp lastItem] setTag:DataTypesSingle];
    
    [self.dataTypePopUp addItemWithTitle:@"Boolean"];
    [[self.dataTypePopUp lastItem] setTag:DataTypesBoolean];
    
    [self.dataTypePopUp selectItemAtIndex:0];
}

#pragma mark - IPackedFileUI Protocol

- (NSView *)guiHandle {
    return self.view;
}

- (void)updateGUI:(id<IFileWrapper>)wrapper {
    if ([wrapper conformsToProtocol:@protocol(IFileWrapperSaveExtension)]) {
        self.saveWrapper = (id<IFileWrapperSaveExtension>)wrapper;
    }
    
    if ([wrapper isKindOfClass:[Cpf class]]) {
        self.wrapper = (Cpf *)wrapper;
        
        [self.internalItems removeAllObjects];
        [self.internalItems addObjectsFromArray:self.wrapper.items];
        
        [self refreshTableView];
        
        self.changeEnabled = NO;
        self.previewButton.hidden = (self.executePreview == nil);
    }
}

#pragma mark - Actions

- (IBAction)addItem:(id)sender {
    if (self.nameTextField.stringValue.length == 0) {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"Name Required";
        alert.informativeText = @"Please enter a name for the new item.";
        [alert runModal];
        return;
    }
    
    CpfItem *newItem = [[CpfItem alloc] init];
    newItem.name = self.nameTextField.stringValue;
    newItem.datatype = (DataTypes)self.dataTypePopUp.selectedItem.tag;
    newItem.stringValue = self.valueTextField.stringValue;
    
    [self.wrapper addItem:newItem];
    [self.internalItems addObject:newItem];
    
    [self refreshTableView];
    [self clearInputFields];
    
    self.changeEnabled = YES;
}

- (IBAction)removeItem:(id)sender {
    NSInteger selectedRow = self.itemsTableView.selectedRow;
    if (selectedRow >= 0 && selectedRow < self.internalItems.count) {
        [self.internalItems removeObjectAtIndex:selectedRow];
        
        // Update the wrapper's items
        self.wrapper.items = [self.internalItems copy];
        
        [self refreshTableView];
        [self clearInputFields];
        
        self.changeEnabled = YES;
    }
}

- (IBAction)previewItem:(id)sender {
    if (self.executePreview && self.wrapper) {
        self.executePreview(self.wrapper, self.wrapper.package);
    }
}

- (IBAction)dataTypeChanged:(id)sender {
    [self updateSelectedItem];
}

- (IBAction)nameChanged:(id)sender {
    [self updateSelectedItem];
}

- (IBAction)valueChanged:(id)sender {
    [self updateSelectedItem];
}

#pragma mark - Table View Management

- (void)refreshTableView {
    [self.itemsTableView reloadData];
    self.removeButton.enabled = (self.itemsTableView.selectedRow >= 0);
}

- (void)updateSelectedItem {
    NSInteger selectedRow = self.itemsTableView.selectedRow;
    if (selectedRow >= 0 && selectedRow < self.internalItems.count) {
        CpfItem *item = self.internalItems[selectedRow];
        
        if (self.nameTextField.stringValue.length > 0) {
            item.name = self.nameTextField.stringValue;
        }
        
        item.datatype = (DataTypes)self.dataTypePopUp.selectedItem.tag;
        
        // Set value based on data type
        switch (item.datatype) {
            case DataTypesString:
                item.stringValue = self.valueTextField.stringValue;
                break;
            case DataTypesInteger:
                item.integerValue = [self.valueTextField.stringValue intValue];
                break;
            case DataTypesUInteger:
                item.uintegerValue = (uint32_t)[self.valueTextField.stringValue integerValue];
                break;
            case DataTypesSingle:
                item.singleValue = [self.valueTextField.stringValue floatValue];
                break;
            case DataTypesBoolean:
                item.booleanValue = [self.valueTextField.stringValue boolValue];
                break;
        }
        
        // Update the wrapper's items
        self.wrapper.items = [self.internalItems copy];
        
        [self refreshTableView];
        self.changeEnabled = YES;
    }
}

- (void)clearInputFields {
    self.nameTextField.stringValue = @"";
    self.valueTextField.stringValue = @"";
    [self.dataTypePopUp selectItemAtIndex:0];
}

- (void)populateFieldsForItem:(CpfItem *)item {
    self.nameTextField.stringValue = item.name ?: @"";
    self.valueTextField.stringValue = item.stringValue ?: @"";
    
    // Select the appropriate data type
    for (NSMenuItem *menuItem in self.dataTypePopUp.itemArray) {
        if (menuItem.tag == item.datatype) {
            [self.dataTypePopUp selectItem:menuItem];
            break;
        }
    }
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.internalItems.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if (row >= self.internalItems.count) return nil;
    
    CpfItem *item = self.internalItems[row];
    
    if ([tableColumn.identifier isEqualToString:@"name"]) {
        return item.name;
    } else if ([tableColumn.identifier isEqualToString:@"type"]) {
        switch (item.datatype) {
            case DataTypesString:
                return @"String";
            case DataTypesInteger:
                return @"Integer";
            case DataTypesUInteger:
                return @"UInteger";
            case DataTypesSingle:
                return @"Single";
            case DataTypesBoolean:
                return @"Boolean";
            default:
                return @"Unknown";
        }
    } else if ([tableColumn.identifier isEqualToString:@"value"]) {
        return item.stringValue;
    }
    
    return nil;
}

#pragma mark - NSTableViewDelegate

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSInteger selectedRow = self.itemsTableView.selectedRow;
    self.removeButton.enabled = (selectedRow >= 0);
    
    if (selectedRow >= 0 && selectedRow < self.internalItems.count) {
        CpfItem *selectedItem = self.internalItems[selectedRow];
        [self populateFieldsForItem:selectedItem];
    } else {
        [self clearInputFields];
    }
}

#pragma mark - Memory Management

- (void)dispose {
    self.executePreview = nil;
    self.wrapper = nil;
    self.saveWrapper = nil;
    [self.internalItems removeAllObjects];
}

@end
