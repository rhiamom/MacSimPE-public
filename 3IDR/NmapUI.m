//
//  NmapUI.m
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

#import "NmapUI.h"
#import "NmapForm.h"
#import "NmapWrapper.h"
#import "IFileWrapper.h"
#import "IPackedFileDescriptor.h"

@implementation NmapUI

// MARK: - Code to Startup the UI

- (instancetype)init {
    self = [super init];
    if (self) {
        // form = WrapperFactory.form; // Original commented line
        _form = [[NmapForm alloc] init];
    }
    return self;
}

// MARK: - IPackedFileUI Protocol

- (NSView *)guiHandle {
    return _form.wrapperPanel;
}

- (void)updateGUI:(id<IFileWrapper>)wrapper {
    Nmap *wrp = (Nmap *)wrapper;
    _form.wrapper = wrp;
    
    [_form.itemsArray removeAllObjects];
    
    for (id<IPackedFileDescriptor> pfd in wrp.items) {
        [_form.itemsArray addObject:pfd];
    }
    
    [_form.lblist reloadData];
}

// MARK: - Memory Management

- (void)dispose {
    // In ARC, explicit disposal isn't needed, but we can clean up if necessary
    _form = nil;
}

@end
