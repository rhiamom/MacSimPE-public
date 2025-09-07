//
//  PictureUI.m
//  MacSimpe
//
//  Created by Catherine Gramze on 9/5/25.
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


#import "PictureUI.h"
#import "Elements.h"
#import "IFileWrapper.h"
#import "IFileWrapperSaveExtension.h"

@implementation PictureUI

// MARK: - Initialization

- (instancetype)init {
    self = [super init];
    return self;
}

// MARK: - IPackedFileUI Implementation

- (NSView *)guiHandle {
    return [UIBase form].jpegPanel;
}

- (void)updateGUI:(id<IFileWrapper>)wrapper {
    Elements *form = [UIBase form];
    
    // Direct assignment with cast - the original C# probably did this
    form.picwrapper = (IFileWrapperSaveExtension *)wrapper;
    
    // Show jpeg panel, hide others
    [form.jpegPanel setHidden:NO];
    [form.xmlPanel setHidden:YES];
    [form.objdPanel setHidden:YES];
    // Add other panels as needed
    
    // Get and set the image
    NSImage *img = nil;
    if ([wrapper respondsToSelector:@selector(image)]) {
        img = [wrapper performSelector:@selector(image)];
    }
    
    if (img) {
        form.pb.image = img;
    }
}

@end
