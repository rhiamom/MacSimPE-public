//
//  NmapForm.m
//  MacSimpe
//
//  Created by Catherine Gramze on 8/24/25.
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

#import "NmapForm.h"
#import "NmapWrapper.h"
#import "NmapItem.h"
#import "Helper.h"
#import "Localization.h"
#import "MetaData.h"
#import "PackageFiles.h"
#import "IPackedFileDescriptor.h"
#import "ExceptionForm.h"
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

@implementation NmapForm

// MARK: - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupForm];
}

- (void)setupForm {
    // Initialize table view
    _lblist.dataSource = self;
    _lblist.delegate = self;
    _lblist.target = self;
    _lblist.action = @selector(selectFile:);
    
    // Enable drag and drop
    [_lblist registerForDraggedTypes:@[NSPasteboardTypeString]];
    
    // Initialize arrays
    _itemsArray = [[NSMutableArray alloc] init];
    
    // Set up labels
    _label1.stringValue = @"File Map Editor";
    _label2.stringValue = @"Filename:";
    _label3.stringValue = @"Filename:";
    _label9.stringValue = @"Group:";
    _label11.stringValue = @"Instance:";
    
    // Set up group boxes
    _groupBox1.title = @"Finder";
    _gbtypes.title = @"Properties";
    
    // Set up buttons
    _button1.title = @"Commit";
    _lladd.title = @"add";
    _lldelete.title = @"delete";
    _llcommit.title = @"change";
    _linkLabel1.title = @"create Text File";
    _btref.title = @"u";
    
    // Initial button states
    _llcommit.enabled = NO;
    _lldelete.enabled = NO;
}

- (void)dealloc {
    // Clean up (ARC handles most memory management)
}

// MARK: - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return _itemsArray.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if (row >= 0 && row < _itemsArray.count) {
        id<IPackedFileDescriptor> pfd = _itemsArray[row];
        return [pfd description]; // Uses the toString equivalent
    }
    return @"";
}

// MARK: - Table View Management

- (IBAction)selectFile:(id)sender {
    _llcommit.enabled = NO;
    _lldelete.enabled = NO;
    
    NSInteger selectedRow = _lblist.selectedRow;
    if (selectedRow < 0) return;
    
    _llcommit.enabled = YES;
    _lldelete.enabled = YES;
    
    if (_isUpdatingFields) return;
    
    @try {
        _isUpdatingFields = YES;
        
        id<IPackedFileDescriptor> pfd = _itemsArray[selectedRow];
        _tbgroup.stringValue = [NSString stringWithFormat:@"0x%@", [Helper hexStringUInt:pfd.group]];
        _tbinstance.stringValue = [NSString stringWithFormat:@"0x%@", [Helper hexStringUInt:pfd.instance]];
        _tbname.stringValue = pfd.filename ?: @"";
        
    } @catch (NSException *ex) {
        [ExceptionForm executeWithMessage:[Localization getString:@"errconvert"] exception:ex];
    } @finally {
        _isUpdatingFields = NO;
    }
}

- (IBAction)changeFile:(NSButton *)sender {
    @try {
        id<IPackedFileDescriptor> pfd = nil;
        NSInteger selectedRow = _lblist.selectedRow;
        
        if (selectedRow >= 0) {
            pfd = _itemsArray[selectedRow];
        } else {
            pfd = [[NmapItem alloc] initWithParent:_wrapper];
        }
        
        // Parse hex strings (remove 0x prefix if present)
        NSString *groupText = _tbgroup.stringValue;
        NSString *instanceText = _tbinstance.stringValue;
        
        if ([groupText hasPrefix:@"0x"]) {
            groupText = [groupText substringFromIndex:2];
        }
        if ([instanceText hasPrefix:@"0x"]) {
            instanceText = [instanceText substringFromIndex:2];
        }
        
        pfd.group = (uint32_t)strtoul([groupText UTF8String], NULL, 16);
        pfd.instance = (uint32_t)strtoul([instanceText UTF8String], NULL, 16);
        pfd.filename = _tbname.stringValue;
        
        if (selectedRow >= 0) {
            _itemsArray[selectedRow] = pfd;
        } else {
            [_itemsArray addObject:pfd];
        }
        
        [_lblist reloadData];
        
    } @catch (NSException *ex) {
        [ExceptionForm executeWithMessage:[Localization getString:@"errconvert"] exception:ex];
    }
}

- (IBAction)addFile:(NSButton *)sender {
    [_lblist deselectAll:nil];
    [self changeFile:nil];
    
    // Select the newly added item
    if (_itemsArray.count > 0) {
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:_itemsArray.count - 1];
        [_lblist selectRowIndexes:indexSet byExtendingSelection:NO];
    }
}

- (IBAction)deleteFile:(NSButton *)sender {
    NSInteger selectedRow = _lblist.selectedRow;
    if (selectedRow < 0) return;
    
    _llcommit.enabled = NO;
    _lldelete.enabled = NO;
    
    [_itemsArray removeObjectAtIndex:selectedRow];
    [_lblist reloadData];
}

- (IBAction)autoChange:(NSTextField *)sender {
    if (_isUpdatingFields) return;
    
    _isUpdatingFields = YES;
    if (_lblist.selectedRow >= 0) {
        [self changeFile:nil];
    }
    _isUpdatingFields = NO;
}

- (IBAction)commitAll:(NSButton *)sender {
    @try {
        _wrapper.items = [_itemsArray copy];
        [_wrapper synchronizeUserData];
        
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = [Localization getString:@"commited"];
        [alert runModal];
        
    } @catch (NSException *ex) {
        [ExceptionForm executeWithMessage:[Localization getString:@"errwritingfile"] exception:ex];
    }
}

// MARK: - Package Selector

- (IBAction)showPackageSelector:(NSButton *)sender {
    PackageSelectorForm *form = [[PackageSelectorForm alloc] init];
    [form executeWithPackage:_wrapper.package];
}

// MARK: - Drag and Drop

- (NSDragOperation)tableView:(NSTableView *)tableView
                validateDrop:(id<NSDraggingInfo>)info
                 proposedRow:(NSInteger)row
       proposedDropOperation:(NSTableViewDropOperation)dropOperation {
    
    NSPasteboard *pasteboard = [info draggingPasteboard];
    if ([pasteboard canReadObjectForClasses:@[[NSString class]] options:nil]) {
        return NSDragOperationCopy;
    }
    return NSDragOperationNone;
}

- (BOOL)tableView:(NSTableView *)tableView
       acceptDrop:(id<NSDraggingInfo>)info
              row:(NSInteger)row
    dropOperation:(NSTableViewDropOperation)dropOperation {
    @try {
        // This would handle dropped PackedFileDescriptor objects
        // Implementation depends on the drag/drop protocol established
        
        NmapItem *nmi = [[NmapItem alloc] initWithParent:_wrapper];
        // Set properties from dropped data
        // nmi.group = pfd.group;
        // nmi.type = pfd.type;
        // nmi.subType = pfd.subType;
        // nmi.instance = pfd.instance;
        // nmi.filename = [MetaData findTypeAlias:pfd.type].name;
        
        [_itemsArray addObject:nmi];
        [_lblist reloadData];
        return YES;
        
    } @catch (NSException *ex) {
        [ExceptionForm executeWithMessage:[Localization getString:@" "] exception:ex];
        return NO;
    }
}

// MARK: - Search Functionality

- (IBAction)tbfindnameTextChanged:(NSTextField *)sender {
    NSString *searchName = [sender.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *searchLower = [searchName lowercaseString];
    
    for (NSInteger i = 0; i < _itemsArray.count; i++) {
        id<IPackedFileDescriptor> pfd = _itemsArray[i];
        NSString *filename = [pfd.filename stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *filenameLower = [filename lowercaseString];
        
        if ([filenameLower hasPrefix:searchLower]) {
            _tbfindname.stringValue = filename;
            
            // Set text selection
            NSInteger nameLength = searchName.length;
            NSRange selectionRange = NSMakeRange(nameLength, MAX(0, (NSInteger)filename.length - nameLength));
            NSText *fieldEditor = [_tbfindname.window fieldEditor:YES forObject:_tbfindname];
            [fieldEditor setSelectedRange:selectionRange];
            
            // Select the row
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:i];
            [_lblist selectRowIndexes:indexSet byExtendingSelection:NO];
            [_lblist scrollRowToVisible:i];
            break;
        }
    }
}

// MARK: - Text File Export

- (IBAction)createTextFile:(NSButton *)sender {
    NSSavePanel *savePanel = [NSSavePanel savePanel];
        savePanel.allowedContentTypes = @[[UTType typeWithIdentifier:@"public.plain-text"]];
    
    if (_wrapper.package && _wrapper.package.fileName) {
        NSString *baseName = [_wrapper.package.fileName stringByDeletingPathExtension];
        savePanel.nameFieldStringValue = [NSString stringWithFormat:@"%@_NameMap.txt", baseName];
    } else {
        savePanel.nameFieldStringValue = @"NameMap.txt";
    }
    
    if ([savePanel runModal] == NSModalResponseOK) {
        @try {
            NSMutableString *content = [[NSMutableString alloc] init];
            
            [content appendString:@"Filename; Group; Instance;\n"];
            
            for (id<IPackedFileDescriptor> pfd in _itemsArray) {
                [content appendFormat:@"%@; 0x%@; 0x%@;\n",
                 pfd.filename ?: @"",
                 [Helper hexStringUInt:pfd.group],
                 [Helper hexStringUInt:pfd.instance]];
            }
            
            NSError *error;
            if (![content writeToURL:savePanel.URL
                          atomically:YES
                            encoding:NSUTF8StringEncoding
                               error:&error]) {
                NSAlert *alert = [[NSAlert alloc] init];
                alert.messageText = @"Export Failed";
                alert.informativeText = error.localizedDescription;
                [alert runModal];
            }
            
        } @catch (NSException *ex) {
            [ExceptionForm executeWithMessage:@"" exception:ex];
        }
    }
}

// MARK: - Wrapper Management

- (void)setWrapper:(Nmap *)wrapper {
    _wrapper = wrapper;
    
    // Update the items array
    [_itemsArray removeAllObjects];
    if (wrapper.items) {
        [_itemsArray addObjectsFromArray:wrapper.items];
    }
    
    [_lblist reloadData];
}

@end
