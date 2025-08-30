//
//  LifoUI.m
//  MacSimpe
//
//  Created by Catherine Gramze on 8/28/25.
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
//  LifoUI.m
//  MacSimpe
//
//  Created by Catherine Gramze on 8/26/25.
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

#import "LifoUI.h"
#import "LifoForm.h"
#import "LifoWrapper.h"
#import "cLevelInfo.h"
#import "ImageLoader.h"

@implementation LifoUI

// MARK: - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        self.form = [[LifoForm alloc] init];
        [self populateFormatComboBox];
    }
    return self;
}

- (void)populateFormatComboBox {
    [self.form.cbformats removeAllItems];
    
    // Add texture format items matching the C# version
    [self.form.cbformats addItemWithObjectValue:@(TxtrFormatsUnknown)];
    [self.form.cbformats addItemWithObjectValue:@(TxtrFormatsDXT1Format)];
    [self.form.cbformats addItemWithObjectValue:@(TxtrFormatsDXT3Format)];
    [self.form.cbformats addItemWithObjectValue:@(TxtrFormatsDXT5Format)];
    [self.form.cbformats addItemWithObjectValue:@(TxtrFormatsRaw8Bit)];
    [self.form.cbformats addItemWithObjectValue:@(TxtrFormatsRaw24Bit)];
    [self.form.cbformats addItemWithObjectValue:@(TxtrFormatsRaw32Bit)];
}

// MARK: - IPackedFileUI Protocol

- (NSView *)createView {
    return self.form.lifoPanel;
}

- (void)refresh {
    // Update the GUI with current wrapper data
    if (self.form.wrapper != nil) {
        // Clear and populate the item combo box
        [self.form.cbitem removeAllItems];
        for (LevelInfo *levelInfo in self.form.wrapper.blocks) {
            [self.form.cbitem addItemWithObjectValue:levelInfo];
        }
        
        // Select the first item if available
        if (self.form.cbitem.numberOfItems > 0) {
            [self.form.cbitem selectItemAtIndex:0];
        }
    }
}

- (void)synchronize {
    // Synchronize any changes made in the UI back to the wrapper
    // This method is called when the user makes changes that need to be saved
    // For LIFO files, this might involve updating the wrapper's blocks
    if (self.form.wrapper != nil) {
        // Implementation depends on what changes users can make in the UI
        // For now, this is a placeholder
    }
}

// MARK: - Update GUI Method (matches C# signature)

- (void)updateGui:(id<IFileWrapper>)wrapper {
    Lifo *wrp = (Lifo *)wrapper;
    self.form.wrapper = wrp;
    
    [self refresh];
}

@end
