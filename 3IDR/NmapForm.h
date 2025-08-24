//
//  NmapForm.h
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

#import <Cocoa/Cocoa.h>

@class Nmap;
@protocol IPackedFileDescriptor;

/**
 * Zusammenfassung für NmapForm.
 */
@interface NmapForm : NSViewController <NSTableViewDataSource, NSTableViewDelegate>

// MARK: - IBOutlets (equivalent to Windows Form controls)

@property (weak, nonatomic) IBOutlet NSView *wrapperPanel;
@property (weak, nonatomic) IBOutlet NSTableView *lblist;
@property (weak, nonatomic) IBOutlet NSScrollView *listScrollView;

@property (weak, nonatomic) IBOutlet NSView *panel3;
@property (weak, nonatomic) IBOutlet NSTextField *label1;

@property (weak, nonatomic) IBOutlet NSButton *button1;
@property (weak, nonatomic) IBOutlet NSBox *gbtypes;
@property (weak, nonatomic) IBOutlet NSButton *lladd;
@property (weak, nonatomic) IBOutlet NSButton *lldelete;
@property (weak, nonatomic) IBOutlet NSTextField *tbinstance;
@property (weak, nonatomic) IBOutlet NSTextField *label11;
@property (weak, nonatomic) IBOutlet NSTextField *label9;
@property (weak, nonatomic) IBOutlet NSTextField *tbgroup;
@property (weak, nonatomic) IBOutlet NSButton *llcommit;

@property (weak, nonatomic) IBOutlet NSView *pntypes;
@property (weak, nonatomic) IBOutlet NSTextField *label2;
@property (weak, nonatomic) IBOutlet NSTextField *tbname;

@property (weak, nonatomic) IBOutlet NSButton *btref;
@property (weak, nonatomic) IBOutlet NSBox *groupBox1;
@property (weak, nonatomic) IBOutlet NSTextField *tbfindname;
@property (weak, nonatomic) IBOutlet NSTextField *label3;
@property (weak, nonatomic) IBOutlet NSButton *linkLabel1;

// MARK: - Properties

@property (nonatomic, strong) Nmap *wrapper;
@property (nonatomic, strong) NSMutableArray *itemsArray;
@property (nonatomic, assign) BOOL isUpdatingFields;

// MARK: - IBActions

- (IBAction)selectFile:(id)sender;
- (IBAction)changeFile:(NSButton *)sender;
- (IBAction)addFile:(NSButton *)sender;
- (IBAction)deleteFile:(NSButton *)sender;
- (IBAction)autoChange:(NSTextField *)sender;
- (IBAction)commitAll:(NSButton *)sender;
- (IBAction)showPackageSelector:(NSButton *)sender;
- (IBAction)tbfindnameTextChanged:(NSTextField *)sender;
- (IBAction)createTextFile:(NSButton *)sender;

@end
