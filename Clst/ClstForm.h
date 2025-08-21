//
//  ClstForm.h
//  MacSimpe
//
//  Created by Catherine Gramze on 8/17/25.
//
// ***************************************************************************
// *   Copyright (C) 2005 by Peter L Jones                                   *
// *   pljones@users.sf.net                                                  *
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

#import <Cocoa/Cocoa.h>
#import "IPackedFileUI.h"

@protocol IFileWrapper;
@class CompressedFileList;

/**
 * Compressed File List (CLST) viewer for SimPE
 * Displays compressed file directory information
 */
@interface ClstForm : NSViewController <IPackedFileUI>

// MARK: - Properties
@property (nonatomic, strong) CompressedFileList *wrapper;

// MARK: - UI Components
@property (nonatomic, strong) IBOutlet NSView *clstPanel;
@property (nonatomic, strong) IBOutlet NSTextField *lbformat;
@property (nonatomic, strong) IBOutlet NSTextField *label9;
@property (nonatomic, strong) IBOutlet NSTableView *lbclst;
@property (nonatomic, strong) IBOutlet NSView *panel4;
@property (nonatomic, strong) IBOutlet NSTextField *label12;

// MARK: - Data Source
@property (nonatomic, strong) NSMutableArray *clstDataSource;

// MARK: - IPackedFileUI Protocol
@property (nonatomic, readonly) NSView *guiHandle;
- (void)updateGUI:(id<IFileWrapper>)wrapper;

@end
