//
//  NrefUI.m
//  MacSimpe
//
//  Created by Catherine Gramze on 9/17/25.
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

#import "NrefUI.h"
#import "Elements2.h"
#import "IFileWrapper.h"
#import "IFileWrapperSaveExtension.h"
#import "NrefWrapper.h"

@implementation NrefUI

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        _form = [[Elements2 alloc] init];
    }
    return self;
}

#pragma mark - IPackedFileUI Protocol

- (NSView *)guiHandle {
    return self.form.nrefPanel;
}

- (void)updateGUI:(id<IFileWrapper>)wrapper {
    self.form.wrapper = (id<IFileWrapperSaveExtension>)wrapper;
    NrefWrapper *wrp = (NrefWrapper *)wrapper;
    
    self.form.tbNref.tag = 1;  // Set tag to prevent event handling
    [self.form.tbNref setStringValue:wrp.fileName];
    self.form.tbNref.tag = 0;  // Clear tag to re-enable event handling
}

@end
