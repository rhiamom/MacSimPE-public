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
//
//  SRelUI.h
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
//
//  SRelUI.m
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

#import <Cocoa/Cocoa.h>
#import "IPackedFileUI.h"

@class SRel;
@protocol IFileWrapper;

NS_ASSUME_NONNULL_BEGIN

/**
 * UI Controller for SRel (Relationship) files
 * Provides the interface for editing Sim relationships
 */
@interface SRelUI : NSViewController <IPackedFileUI>

// MARK: - UI Components
@property (nonatomic, strong) IBOutlet NSView *realPanel;
@property (nonatomic, strong) IBOutlet NSPopUpButton *cbfamtype;
@property (nonatomic, strong) IBOutlet NSTextField *tbshortterm;
@property (nonatomic, strong) IBOutlet NSTextField *tblongterm;

// Relationship checkboxes
@property (nonatomic, strong) IBOutlet NSButton *cbcrush;
@property (nonatomic, strong) IBOutlet NSButton *cblove;
@property (nonatomic, strong) IBOutlet NSButton *cbengaged;
@property (nonatomic, strong) IBOutlet NSButton *cbmarried;
@property (nonatomic, strong) IBOutlet NSButton *cbfriend;
@property (nonatomic, strong) IBOutlet NSButton *cbbuddie;
@property (nonatomic, strong) IBOutlet NSButton *cbsteady;
@property (nonatomic, strong) IBOutlet NSButton *cbenemy;
@property (nonatomic, strong) IBOutlet NSButton *cbfamily;
@property (nonatomic, strong) IBOutlet NSButton *cbbest;

// MARK: - Data
@property (nonatomic, weak, nullable) SRel *wrapper;

// MARK: - Initialization
- (instancetype)init;

// MARK: - View Management (NSViewController methods)
- (void)loadView;
- (void)viewDidLoad;
- (void)setupRelationshipTypes;

// MARK: - UI Creation
- (void)createUIComponents;
- (void)createRelationshipCheckboxes;

// MARK: - Data Updates
- (void)updateCheckboxesFromWrapper:(SRel *)srel;

// MARK: - IPackedFileUI Protocol
- (NSView *)guiHandle;
- (void)updateGUI:(id<IFileWrapper>)wrapper;

@end

NS_ASSUME_NONNULL_END
