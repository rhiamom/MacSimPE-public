//
//  SRel.h
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
// ***************************************************************************/

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "UIBase.h"
#import "IPackedFileUI.h"

@protocol IFileWrapper;
@class LocalizedRelationshipTypes;
@class SRelWrapper;
@class Boolset;

/**
 * Handles Packed SRel Files
 */
@interface SRel : UIBase <IPackedFileUI>

// MARK: - UI Elements

@property (nonatomic, weak) IBOutlet NSView *realPanel;
@property (nonatomic, weak) IBOutlet NSTextField *tbshortterm;
@property (nonatomic, weak) IBOutlet NSTextField *tblongterm;
@property (nonatomic, weak) IBOutlet NSPopUpButton *cbfamtype;

// Relationship checkboxes
@property (nonatomic, weak) IBOutlet NSButton *cbcrush;
@property (nonatomic, weak) IBOutlet NSButton *cblove;
@property (nonatomic, weak) IBOutlet NSButton *cbengaged;
@property (nonatomic, weak) IBOutlet NSButton *cbmarried;
@property (nonatomic, weak) IBOutlet NSButton *cbfriend;
@property (nonatomic, weak) IBOutlet NSButton *cbbuddie;
@property (nonatomic, weak) IBOutlet NSButton *cbsteady;
@property (nonatomic, weak) IBOutlet NSButton *cbenemy;
@property (nonatomic, weak) IBOutlet NSButton *cbfamily;
@property (nonatomic, weak) IBOutlet NSButton *cbbest;

@property (nonatomic, strong) SRelWrapper *wrapper;

// MARK: - Initialization

/**
 * Creates a new Instance and fills the relationship types into the correct form
 */
- (instancetype)init;

// MARK: - IPackedFileUI Protocol

/**
 * Returns the main GUI panel for this handler
 */
- (NSView *)guiHandle;

/**
 * Updates the GUI with data from the wrapper
 * @param wrapper The file wrapper containing the data
 */
- (void)updateGUI:(id<IFileWrapper>)wrapper;

@end
