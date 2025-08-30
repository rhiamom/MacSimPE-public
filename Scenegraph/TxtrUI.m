//
//  TxtrUI.m
//  MacSimpe
//
//  Created by Catherine Gramze on 8/26/25.
//
//
//  TxtrUI.m
//  MacSimpe
//
//  Translated from TxtrUI.cs
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
//
//  TxtrUI.m
//  MacSimpe
//
//  Translated from TxtrUI.cs
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

#import "TxtrUI.h"
#import "TxtrForm.h"
#import "TxtrWrapper.h"
#import "cImageData.h"
#import "ImageLoader.h"

@implementation TxtrUI

// MARK: - Code to Startup the UI

- (instancetype)init {
    self = [super init];
    if (self) {
        _form = [[TxtrForm alloc] init];
        
        // Initialize format combo box with texture formats
        [_form.formatComboBox removeAllItems];
        [_form.formatComboBox addItemWithObjectValue:@(TxtrFormatsUnknown)];
        [_form.formatComboBox addItemWithObjectValue:@(TxtrFormatsExtRaw8Bit)];
        [_form.formatComboBox addItemWithObjectValue:@(TxtrFormatsRaw8Bit)];
        [_form.formatComboBox addItemWithObjectValue:@(TxtrFormatsRaw24Bit)];
        [_form.formatComboBox addItemWithObjectValue:@(TxtrFormatsExtRaw24Bit)];
        [_form.formatComboBox addItemWithObjectValue:@(TxtrFormatsRaw32Bit)];
        [_form.formatComboBox addItemWithObjectValue:@(TxtrFormatsDXT1Format)];
        [_form.formatComboBox addItemWithObjectValue:@(TxtrFormatsDXT3Format)];
        [_form.formatComboBox addItemWithObjectValue:@(TxtrFormatsDXT5Format)];
    }
    return self;
}

// MARK: - IPackedFileUI Protocol

- (NSView *)guiHandle {
    // Create and return the view from the form
    if (self.form != nil) {
        return [self.form createView];
    }
    return nil;
}

- (void)updateGUI:(id<IFileWrapper>)wrapper {
    Txtr *wrp = (Txtr *)wrapper;
    
    if (wrp.blocks.count == 0) {
        NSMutableArray *blocks = [[NSMutableArray alloc] initWithCapacity:1];
        ImageData *imageData = [[ImageData alloc] initWithParent:wrp];
        [blocks addObject:imageData];
        wrp.blocks = blocks;
    }
    
    _form.wrapper = wrp;
    
    // Disable controls and clear lists when loading new data
        [_form.exportButton setEnabled:NO];  // btex -> exportButton
        // TODO: Clear mipMapTableView data source (when LIFO class is implemented?)
        // This corresponds to form.lbimg.Items.Clear() in C#
        [_form.itemComboBox removeAllItems];  // cbitem
        [_form.mipMapBlockComboBox removeAllItems];  // cbmipmaps
        [_form.deleteButton setEnabled:NO];  // lldel -> deleteButton
    
    for (ImageData *imageData in wrp.blocks) {
        [_form.itemComboBox addItemWithObjectValue:imageData];
    }
    
    if (_form.itemComboBox.numberOfItems > 0) {
        [_form.itemComboBox selectItemAtIndex:0];
    }
}

// MARK: - IDisposable Protocol

- (void)dispose {
    [_form dispose];
}

@end
