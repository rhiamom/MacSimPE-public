//
//  RcolForm.h
//  MacSimpe
//
//  Created by Catherine Gramze on 8/14/25.
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

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "WrapperBaseControl.h"

@class Rcol;
@class AbstractRcolBlock;
@protocol IRcolBlock;

@interface RcolForm : WrapperBaseControl

// MARK: - Properties
@property (nonatomic, strong) Rcol *wrapper;

// MARK: - UI Components
@property (nonatomic, strong) IBOutlet NSTabView *tbResource;
@property (nonatomic, strong) IBOutlet NSComboBox *cbitem;
@property (nonatomic, strong) IBOutlet NSTableView *lbref;
@property (nonatomic, strong) IBOutlet NSOutlineView *tv;
@property (nonatomic, strong) IBOutlet NSTabViewItem *tpref;
@property (nonatomic, strong) IBOutlet NSTabView *childtc;

// Content Tab
@property (nonatomic, strong) IBOutlet NSTextField *tbflname;
@property (nonatomic, strong) IBOutlet NSButton *llhash;
@property (nonatomic, strong) IBOutlet NSButton *llfix;

// Reference Tab
@property (nonatomic, strong) IBOutlet NSTextField *tbtype;
@property (nonatomic, strong) IBOutlet NSTextField *tbsubtype;
@property (nonatomic, strong) IBOutlet NSTextField *tbgroup;
@property (nonatomic, strong) IBOutlet NSTextField *tbinstance;
@property (nonatomic, strong) IBOutlet NSComboBox *cbtypes;
@property (nonatomic, strong) IBOutlet NSButton *lladd;
@property (nonatomic, strong) IBOutlet NSButton *lldelete;
@property (nonatomic, strong) IBOutlet NSButton *btref;

// Edit Blocks Tab
@property (nonatomic, strong) IBOutlet NSTableView *lbblocks;
@property (nonatomic, strong) IBOutlet NSComboBox *cbblocks;
@property (nonatomic, strong) IBOutlet NSButton *btup;
@property (nonatomic, strong) IBOutlet NSButton *btdown;
@property (nonatomic, strong) IBOutlet NSButton *btadd;
@property (nonatomic, strong) IBOutlet NSButton *btdel;

// All References Tab
@property (nonatomic, strong) IBOutlet NSTextField *tbrefgroup;
@property (nonatomic, strong) IBOutlet NSTextField *tbrefinst;
@property (nonatomic, strong) IBOutlet NSTextField *tbfile;
@property (nonatomic, strong) IBOutlet NSButton *linkLabel1;

// MARK: - Data Sources
@property (nonatomic, strong) NSMutableArray *referencesDataSource;
@property (nonatomic, strong) NSMutableArray *blocksDataSource;

// MARK: - Initialization
- (instancetype)init;

// MARK: - UI Management
- (void)buildChildTabControl:(AbstractRcolBlock *)rb;
- (void)updateComboBox;
- (void)clearControlTags;

// MARK: - Actions
- (IBAction)selectRcolItem:(id)sender;
- (IBAction)changeFileName:(id)sender;
- (IBAction)buildFilename:(id)sender;
- (IBAction)fixTGI:(id)sender;
- (IBAction)selectType:(id)sender;
- (IBAction)selectReference:(id)sender;
- (IBAction)autoChangeReference:(id)sender;
- (IBAction)srnItemsAdd:(id)sender;
- (IBAction)srnItemsDelete:(id)sender;
- (IBAction)showPackageSelector:(id)sender;
- (IBAction)tabControlSelectedIndexChanged:(id)sender;
- (IBAction)btupClick:(id)sender;
- (IBAction)btdownClick:(id)sender;
- (IBAction)btaddClick:(id)sender;
- (IBAction)btdelClick:(id)sender;
- (IBAction)blocksSelectionChanged:(id)sender;
- (IBAction)selectRefItem:(id)sender;
- (IBAction)reloadFileIndex:(id)sender;
- (IBAction)childTabPageChanged:(id)sender;
- (IBAction)commit:(id)sender;

@end
