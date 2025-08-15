//
//  RcolForm.m
//  MacSimpe
//
//  Created by Catherine Gramze on 8/14/25.
//
//
//  RcolForm.m
//  MacSimpe
//
//  Created by Catherine Gramze on 7/28/25.
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

#import "RcolForm.h"
#import "RcolWrapper.h"
#import "AbstractRcolBlock.h"
#import "IRcolBlock.h"
#import "CountedListItem.h"
#import "Helper.h"
#import "Hashes.h"
#import "Localization.h"
#import "IPackedFileDescriptor.h"
#import "PackedFileDescriptor.h"
#import "TypeAlias.h"
#import "IAlias.h"
#import "TGILoader.h"
#import "WaitingScreen.h"
#import "FileTable.h"
#import "IScenegraphFileIndexItem.h"
#import "PackageSelectorForm.h"

@interface RcolForm () <NSTabViewDelegate, NSComboBoxDelegate, NSTableViewDataSource, NSTableViewDelegate, NSOutlineViewDataSource, NSOutlineViewDelegate>
@property (nonatomic, assign) BOOL updatingSelection;
@end

@implementation RcolForm

// MARK: - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        _referencesDataSource = [[NSMutableArray alloc] init];
        _blocksDataSource = [[NSMutableArray alloc] init];
        _updatingSelection = NO;
        
        [self setupUI];
        [self setupDataSources];
    }
    return self;
}

- (void)setupUI {
    // Set header text
    self.headerText = @"Generic Rcol Editor";
    
    // Setup combo boxes
    NSArray<id<IAlias>> *fileTypes = [[Helper tgiLoader] fileTypes];
    for (id<IAlias> alias in fileTypes) {
        [self.cbtypes addItemWithObjectValue:alias];
    }
}

- (void)setupDataSources {
    // Setup table view data sources
    [self.lbref setDataSource:self];
    [self.lbref setDelegate:self];
    [self.lbblocks setDataSource:self];
    [self.lbblocks setDelegate:self];
    [self.tv setDataSource:self];
    [self.tv setDelegate:self];
    [self.tbResource setDelegate:self];
}

// MARK: - UI Management

- (void)buildChildTabControl:(AbstractRcolBlock *)rb {
    [self.childtc removeAllTabViewItems];
    
    if (rb == nil) return;
    
    NSTabViewItem *tabPage = [rb tabPage];
    if (tabPage != nil) {
        [rb addToTabControl:self.childtc];
    }
}

- (void)updateComboBox {
    [self.cbitem removeAllItems];
    self.tbflname.stringValue = @"";
    [self.childtc removeAllTabViewItems];
    
    for (id item in self.blocksDataSource) {
        [self.cbitem addItemWithObjectValue:item];
    }
    
    if ([self.cbitem numberOfItems] > 0) {
        [self.cbitem selectItemAtIndex:0];
    }
}

- (void)clearControlTags {
    // Implementation for clearing control tags if needed
    // AppKit doesn't use the same tag system as WinForms
}

// MARK: - Actions

- (IBAction)selectRcolItem:(id)sender {
    if (self.updatingSelection) return;
    if ([self.cbitem indexOfSelectedItem] < 0) return;
    
    @try {
        self.updatingSelection = YES;
        
        CountedListItem *cli = [self.cbitem objectValueOfSelectedItem];
        AbstractRcolBlock *rb = (AbstractRcolBlock *)[cli object];
        
        BOOL hasNameResource = ([rb nameResource] != nil);
        [self.tbflname setEnabled:hasNameResource];
        [self.llhash setEnabled:hasNameResource];
        [self.llfix setEnabled:hasNameResource];
        
        if (hasNameResource) {
            self.tbflname.stringValue = [[rb nameResource] fileName];
        } else {
            self.tbflname.stringValue = @"";
        }
        
        [self buildChildTabControl:rb];
    } @catch (NSException *ex) {
        [Helper exceptionMessage:@"" exception:ex];
    } @finally {
        self.updatingSelection = NO;
    }
}

- (IBAction)changeFileName:(id)sender {
    if (self.updatingSelection) return;
    if ([self.cbitem indexOfSelectedItem] < 0) return;
    
    @try {
        self.updatingSelection = YES;
        
        CountedListItem *cli = [self.cbitem objectValueOfSelectedItem];
        AbstractRcolBlock *rb = (AbstractRcolBlock *)[cli object];
        
        if ([rb nameResource] != nil) {
            [[rb nameResource] setFileName:self.tbflname.stringValue];
            [self.cbitem reloadData];
        }
    } @catch (NSException *ex) {
        [Helper exceptionMessage:[Localization getString:@"erropenfile"] exception:ex];
    } @finally {
        self.updatingSelection = NO;
    }
}

- (IBAction)buildFilename:(id)sender {
    NSString *fl = [Hashes stripHashFromName:self.tbflname.stringValue];
    self.tbflname.stringValue = [Hashes assembleHashedFileName:[self.wrapper.package fileGroupHash] filename:fl];
}

- (IBAction)fixTGI:(id)sender {
    NSString *fl = [Hashes stripHashFromName:self.tbflname.stringValue];
    if (self.wrapper != nil) {
        if ([self.wrapper fileDescriptor] != nil) {
            [[self.wrapper fileDescriptor] setInstance:[Hashes instanceHash:fl]];
            [[self.wrapper fileDescriptor] setSubType:[Hashes subTypeHash:fl]];
        }
    }
}

- (IBAction)selectType:(id)sender {
    if (self.updatingSelection) return;
    
    TypeAlias *selectedAlias = [self.cbtypes objectValueOfSelectedItem];
    self.tbtype.stringValue = [NSString stringWithFormat:@"0x%@", [Helper hexString:[selectedAlias typeID]]];
}

- (IBAction)selectReference:(id)sender {
    if (self.updatingSelection) return;
    if ([self.lbref selectedRow] < 0) return;
    
    @try {
        self.updatingSelection = YES;
        
        id<IPackedFileDescriptor> pfd = self.referencesDataSource[[self.lbref selectedRow]];
        self.tbtype.stringValue = [NSString stringWithFormat:@"0x%@", [Helper hexString:[pfd type]]];
        self.tbsubtype.stringValue = [NSString stringWithFormat:@"0x%@", [Helper hexString:[pfd subType]]];
        self.tbgroup.stringValue = [NSString stringWithFormat:@"0x%@", [Helper hexString:[pfd group]]];
        self.tbinstance.stringValue = [NSString stringWithFormat:@"0x%@", [Helper hexString:[pfd instance]]];
    } @catch (NSException *ex) {
        [Helper exceptionMessage:@"" exception:ex];
    } @finally {
        self.updatingSelection = NO;
    }
}

- (IBAction)autoChangeReference:(id)sender {
    [self changeReference];
}

- (void)changeReference {
    if (self.updatingSelection) return;
    if ([self.lbref selectedRow] < 0) return;
    
    @try {
        self.updatingSelection = YES;
        
        id<IPackedFileDescriptor> pfd = self.referencesDataSource[[self.lbref selectedRow]];
        
        [pfd setType:[Helper hexStringToUInt:self.tbtype.stringValue]];
        [pfd setSubType:[Helper hexStringToUInt:self.tbsubtype.stringValue]];
        [pfd setGroup:[Helper hexStringToUInt:self.tbgroup.stringValue]];
        [pfd setInstance:[Helper hexStringToUInt:self.tbinstance.stringValue]];
        
        [self.lbref reloadData];
    } @catch (NSException *ex) {
        // Silently handle conversion errors
    } @finally {
        self.updatingSelection = NO;
    }
}

- (IBAction)srnItemsAdd:(id)sender {
    @try {
        id<IPackedFileDescriptor> pfd = [[PackedFileDescriptor alloc] init];
        
        [pfd setType:[Helper hexStringToUInt:self.tbtype.stringValue]];
        [pfd setSubType:[Helper hexStringToUInt:self.tbsubtype.stringValue]];
        [pfd setGroup:[Helper hexStringToUInt:self.tbgroup.stringValue]];
        [pfd setInstance:[Helper hexStringToUInt:self.tbinstance.stringValue]];
        
        NSMutableArray *newReferences = [self.wrapper.referencedFiles mutableCopy];
        [newReferences addObject:pfd];
        self.wrapper.referencedFiles = [newReferences copy];
        
        [self.referencesDataSource addObject:pfd];
        [self.lbref reloadData];
        
        [self.wrapper setChanged:YES];
    } @catch (NSException *ex) {
        [Helper exceptionMessage:@"" exception:ex];
    }
}

- (IBAction)srnItemsDelete:(id)sender {
    if ([self.lbref selectedRow] < 0) return;
    
    @try {
        id<IPackedFileDescriptor> pfd = self.referencesDataSource[[self.lbref selectedRow]];
        
        NSMutableArray *newReferences = [self.wrapper.referencedFiles mutableCopy];
        [newReferences removeObject:pfd];
        self.wrapper.referencedFiles = [newReferences copy];
        
        [self.referencesDataSource removeObject:pfd];
        [self.lbref reloadData];
        
        [self.wrapper setChanged:YES];
        
        [self.btup setEnabled:NO];
        [self.btdown setEnabled:NO];
        [self.btdel setEnabled:NO];
    } @catch (NSException *ex) {
        [Helper exceptionMessage:@"" exception:ex];
    }
}

- (IBAction)showPackageSelector:(id)sender {
    PackageSelectorForm *form = [[PackageSelectorForm alloc] init];
    [form execute:[self.wrapper package]];
}

- (IBAction)commit:(id)sender {
    @try {
        [self.wrapper synchronizeUserData];
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:[Localization getString:@"commited"]];
        [alert runModal];
    } @catch (NSException *ex) {
        [Helper exceptionMessage:[Localization getString:@"errwritingfile"] exception:ex];
    }
}

// MARK: - Tab Control Actions

- (IBAction)tabControlSelectedIndexChanged:(id)sender {
    NSTabViewItem *selectedItem = [self.tbResource selectedTabViewItem];
    
    // Check if Edit Blocks tab is selected
    if ([selectedItem.identifier isEqualToString:@"EditBlocks"]) {
        [self.blocksDataSource removeAllObjects];
        
        for (id<IRcolBlock> irb in self.wrapper.blocks) {
            CountedListItem *item = [CountedListItem createHex:irb];
            [self.blocksDataSource addObject:item];
        }
        [self.lbblocks reloadData];
        
        [self.cbblocks removeAllItems];
        NSDictionary *tokens = [Rcol tokens];
        for (NSString *key in tokens.allKeys) {
            @try {
                Class blockClass = tokens[key];
                id<IRcolBlock> irb = [AbstractRcolBlock create:blockClass parent:nil];
                [self.cbblocks addItemWithObjectValue:irb];
            } @catch (NSException *ex) {
                [Helper exceptionMessage:[NSString stringWithFormat:@"Error in Block %@", key] exception:ex];
            }
        }
        
        if ([self.cbblocks numberOfItems] > 0) {
            [self.cbblocks selectItemAtIndex:0];
        }
    }
}

// MARK: - Block Management Actions

- (IBAction)btupClick:(id)sender {
    NSInteger selectedRow = [self.lbblocks selectedRow];
    if (selectedRow < 1) return;
    
    @try {
        // Swap items in data source
        [self.blocksDataSource exchangeObjectAtIndex:selectedRow withObjectAtIndex:selectedRow - 1];
        
        // Swap in wrapper
        NSMutableArray *blocks = [self.wrapper.blocks mutableCopy];
        [blocks exchangeObjectAtIndex:selectedRow withObjectAtIndex:selectedRow - 1];
        self.wrapper.blocks = [blocks copy];
        
        [self.lbblocks reloadData];
        [self.lbblocks selectRowIndexes:[NSIndexSet indexSetWithIndex:selectedRow - 1] byExtendingSelection:NO];
        
        [self updateComboBox];
    } @catch (NSException *ex) {
        [Helper exceptionMessage:@"" exception:ex];
    }
}

- (IBAction)btdownClick:(id)sender {
    NSInteger selectedRow = [self.lbblocks selectedRow];
    if (selectedRow < 0 || selectedRow >= [self.blocksDataSource count] - 1) return;
    
    @try {
        // Swap items in data source
        [self.blocksDataSource exchangeObjectAtIndex:selectedRow withObjectAtIndex:selectedRow + 1];
        
        // Swap in wrapper
        NSMutableArray *blocks = [self.wrapper.blocks mutableCopy];
        [blocks exchangeObjectAtIndex:selectedRow withObjectAtIndex:selectedRow + 1];
        self.wrapper.blocks = [blocks copy];
        
        [self.lbblocks reloadData];
        [self.lbblocks selectRowIndexes:[NSIndexSet indexSetWithIndex:selectedRow + 1] byExtendingSelection:NO];
        
        [self updateComboBox];
    } @catch (NSException *ex) {
        [Helper exceptionMessage:@"" exception:ex];
    }
}

- (IBAction)btaddClick:(id)sender {
    @try {
        id<IRcolBlock> irb = [[self.cbblocks objectValueOfSelectedItem] create];
        if ([irb conformsToProtocol:@protocol(AbstractRcolBlock)]) {
            [(AbstractRcolBlock *)irb setParent:self.wrapper];
        }
        
        CountedListItem *item = [CountedListItem createHex:irb];
        [self.blocksDataSource addObject:item];
        
        NSMutableArray *blocks = [self.wrapper.blocks mutableCopy];
        [blocks addObject:irb];
        self.wrapper.blocks = [blocks copy];
        
        [self.lbblocks reloadData];
        [self updateComboBox];
    } @catch (NSException *ex) {
        [Helper exceptionMessage:@"" exception:ex];
    }
}

- (IBAction)btdelClick:(id)sender {
    NSInteger selectedRow = [self.lbblocks selectedRow];
    if (selectedRow < 0) return;
    
    @try {
        CountedListItem *cli = self.blocksDataSource[selectedRow];
        id<IRcolBlock> irb = [cli object];
        
        [self.blocksDataSource removeObjectAtIndex:selectedRow];
        
        NSMutableArray *blocks = [self.wrapper.blocks mutableCopy];
        [blocks removeObject:irb];
        self.wrapper.blocks = [blocks copy];
        
        [self.lbblocks reloadData];
        [self updateComboBox];
    } @catch (NSException *ex) {
        [Helper exceptionMessage:@"" exception:ex];
    }
}

- (IBAction)blocksSelectionChanged:(id)sender {
    NSInteger selectedRow = [self.lbblocks selectedRow];
    [self.btup setEnabled:selectedRow >= 1];
    [self.btdown setEnabled:selectedRow >= 0 && selectedRow < [self.blocksDataSource count] - 1];
    [self.btdel setEnabled:selectedRow >= 0];
}

// MARK: - Reference Tree Actions

- (IBAction)selectRefItem:(id)sender {
    NSOutlineView *outlineView = (NSOutlineView *)sender;
    id selectedItem = [outlineView itemAtRow:[outlineView selectedRow]];
    
    if (selectedItem != nil) {
        NSTreeNode *node = (NSTreeNode *)selectedItem;
        id<IPackedFileDescriptor> pfd = [node representedObject];
        
        if ([pfd conformsToProtocol:@protocol(IPackedFileDescriptor)]) {
            self.tbrefgroup.stringValue = [NSString stringWithFormat:@"0x%@", [Helper hexString:[pfd group]]];
            self.tbrefinst.stringValue = [NSString stringWithFormat:@"0x%@", [Helper hexString:[pfd instance]]];
            
            [[FileTable fileIndex] load];
            NSArray<id<IScenegraphFileIndexItem>> *items = [[FileTable fileIndex] findFile:pfd package:nil];
            
            if ([items count] == 0) {
                id<IScenegraphFileIndexItem> item = [[FileTable fileIndex] findFileByName:[pfd filename]
                                                                                      type:[pfd type]
                                                                                     group:[pfd group]
                                                                                 recursive:YES];
                if (item != nil) {
                    items = @[item];
                }
            }
            
            if ([items count] == 0) {
                id<IPackedFileDescriptor> npfd = [pfd copy];
                [npfd setSubType:0];
                items = [[FileTable fileIndex] findFile:npfd package:nil];
            }
            
            if ([items count] > 0) {
                self.tbfile.stringValue = [[[items firstObject] package] fileName];
            } else {
                self.tbfile.stringValue = @"[unreferenced]";
            }
        }
    }
}

- (IBAction)reloadFileIndex:(id)sender {
    [WaitingScreen wait];
    @try {
        [[FileTable fileIndex] forceReload];
    } @finally {
        [WaitingScreen stop];
    }
}

- (IBAction)childTabPageChanged:(id)sender {
    [self.wrapper childTabPageChanged:self event:nil];
}

// MARK: - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if (tableView == self.lbref) {
        return [self.referencesDataSource count];
    } else if (tableView == self.lbblocks) {
        return [self.blocksDataSource count];
    }
    return 0;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if (tableView == self.lbref) {
        id<IPackedFileDescriptor> pfd = self.referencesDataSource[row];
        return [pfd description];
    } else if (tableView == self.lbblocks) {
        CountedListItem *item = self.blocksDataSource[row];
        return [item description];
    }
    return nil;
}

// MARK: - NSTableViewDelegate

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSTableView *tableView = [notification object];
    
    if (tableView == self.lbref) {
        [self selectReference:tableView];
    } else if (tableView == self.lbblocks) {
        [self blocksSelectionChanged:tableView];
    }
}

// MARK: - NSOutlineViewDataSource

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    if (item == nil) {
        return [[self.tv rootNode] countOfChildNodes];
    }
    
    NSTreeNode *node = (NSTreeNode *)item;
    return [node countOfChildNodes];
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    if (item == nil) {
        return [[self.tv rootNode] childNodes][index];
    }
    
    NSTreeNode *node = (NSTreeNode *)item;
    return [node childNodes][index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    if (item == nil) return YES;
    
    NSTreeNode *node = (NSTreeNode *)item;
    return [node countOfChildNodes] > 0;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    if (item == nil) return nil;
    
    NSTreeNode *node = (NSTreeNode *)item;
    id representedObject = [node representedObject];
    
    if ([representedObject isKindOfClass:[NSString class]]) {
        return representedObject;
    } else if ([representedObject conformsToProtocol:@protocol(IPackedFileDescriptor)]) {
        id<IPackedFileDescriptor> pfd = representedObject;
        return [NSString stringWithFormat:@"%@: %@", [pfd filename], [pfd description]];
    }
    
    return [representedObject description];
}

// MARK: - NSOutlineViewDelegate

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
    [self selectRefItem:[notification object]];
}

// MARK: - NSTabViewDelegate

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem {
    if (tabView == self.tbResource) {
        [self tabControlSelectedIndexChanged:tabView];
    } else if (tabView == self.childtc) {
        [self childTabPageChanged:tabView];
    }
}

// MARK: - Drag and Drop Support

- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id<NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation {
    if (tableView == self.lbref) {
        NSPasteboard *pasteboard = [info draggingPasteboard];
        if ([pasteboard availableTypeFromArray:@[NSPasteboardTypeString]]) {
            return NSDragOperationCopy;
        }
    }
    return NSDragOperationNone;
}

- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id<NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)dropOperation {
    if (tableView == self.lbref) {
        @try {
            self.updatingSelection = YES;
            
            // This would need to be adapted based on your drag/drop data format
            // The original code expected PackedFileDescriptor objects
            NSPasteboard *pasteboard = [info draggingPasteboard];
            NSString *draggedString = [pasteboard stringForType:NSPasteboardTypeString];
            
            // You would need to convert the dragged data to a PackedFileDescriptor
            // This is a placeholder implementation
            id<IPackedFileDescriptor> pfd = [[PackedFileDescriptor alloc] init];
            
            NSMutableArray *newReferences = [self.wrapper.referencedFiles mutableCopy];
            [newReferences addObject:pfd];
            self.wrapper.referencedFiles = [newReferences copy];
            
            [self.referencesDataSource addObject:pfd];
            [self.lbref reloadData];
            
            [self.wrapper setChanged:YES];
            return YES;
        } @catch (NSException *ex) {
            [Helper exceptionMessage:@"" exception:ex];
        } @finally {
            self.updatingSelection = NO;
        }
    }
    return NO;
}

@end
