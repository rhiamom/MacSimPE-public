//
//  PackedFileUI.m
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
// ***************************************************************************/

#import "PackedFileUI.h"
#import "PackedFileForm.h"
#import "PackedFileWrapper.h"
#import "IFileWrapper.h"
#import "IFileWrapperSaveExtension.h"
#import "IPackedFileDescriptor.h"
#import "IAlias.h"
#import "Helper.h"
#import "TGILoader.h"
#import "FileTable.h"
#import "FileIndex.h"

@implementation RefFileUI

// MARK: - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        // Create the form that contains the UI
        self.form = [[RefFileForm alloc] init];
        
        // Load file types into the types popup button
        [self loadFileTypes];
    }
    return self;
}

- (void)loadFileTypes {
    // Load file type aliases from TGILoader and populate the types popup
    NSArray<TypeAlias *> *typeAliases = TGILoader.shared.fileTypes;
    NSArray<id<IAlias>> *fileTypes = (NSArray<id<IAlias>> *)typeAliases;
    
    [self.form.typesPopUpButton removeAllItems];
    [self.form.typesPopUpButton addItemWithTitle:@"Select Type..."];
    
    for (id<IAlias> alias in fileTypes) {
        NSString *title = [NSString stringWithFormat:@"%@ (0x%@)",
                          alias.name,
                          [Helper hexString:alias.typeID]];
        [self.form.typesPopUpButton addItemWithTitle:title];
        
        // Store the alias object as the represented object
        NSMenuItem *item = [self.form.typesPopUpButton lastItem];
        [item setRepresentedObject:alias];
    }
}

// MARK: - IPackedFileUI Protocol Implementation

- (NSView *)guiHandle {
    // Return the wrapper panel from the form to be embedded in ResourceViewManager
    if (!self.form.wrapperPanel) {
        // Ensure the form is loaded
        [self.form loadWindow];
    }
    return self.form.wrapperPanel;
}

- (void)updateGUI:(id<IFileWrapper>)wrapper {
    // Load the file index if needed
    [[FileTable fileIndex] load];
    
    // Set the wrapper on the form
    if ([wrapper conformsToProtocol:@protocol(IFileWrapperSaveExtension)]) {
        self.form.wrapper = (id<IFileWrapperSaveExtension>)wrapper;
    }
    
    // Cast to RefFile to access specific properties
    RefFile *refFile = nil;
    if ([wrapper isKindOfClass:[RefFile class]]) {
        refFile = (RefFile *)wrapper;
    } else {
        NSLog(@"Warning: RefFileUI.updateGUI called with non-RefFile wrapper: %@", [wrapper class]);
        return;
    }
    
    // Reset button states
    [self.form.changeButton setEnabled:NO];
    [self.form.deleteButton setEnabled:NO];
    [self.form.upButton setEnabled:NO];
    [self.form.downButton setEnabled:NO];
    
    // Clear existing file descriptors and reload from wrapper
    [self.form.fileDescriptors removeAllObjects];
    
    // Load items from the RefFile wrapper
    if (refFile.items != nil) {
        for (id<IPackedFileDescriptor> pfd in refFile.items) {
            [self.form.fileDescriptors addObject:pfd];
        }
    }
    
    // Reload the table view to display the updated data
    [self.form.fileListTableView reloadData];
    
    // Update button states based on current selection
    [self.form updateButtonStates];
    
    // Clear any selected image
    [self.form.imageView setImage:nil];
}

// MARK: - Resource Management

- (void)dispose {
    if (self.form) {
        // Close the form's window if it's open
        if (self.form.window) {
            [self.form.window close];
        }
        
        // Clear the form reference
        self.form = nil;
    }
}

- (void)dealloc {
    [self dispose];
}

@end
