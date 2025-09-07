//
//  Elements2.h
//  MacSimpe
//
//  Created by Catherine Gramze on 9/5/25.
//
// ***************************************************************************
// *   Copyright (C) 2005 by Ambertation                                     *
// *   quaxi@ambertation.de                                                  *
// *                                                                         *
// *   Objective-C translation Copyright (C) 2025                            *
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

@protocol IFileWrapperSaveExtension;
@class CpfItem;
@class Cpf;
@class Nref;

typedef void (^ExecutePreview)(Cpf *cpf, id package);

@interface Elements2 : NSWindowController {
    // CPF Panel controls
    IBOutlet NSView *panel5;
    IBOutlet NSTextField *label5;
    IBOutlet NSTableView *lbcpf;
    IBOutlet NSTextView *rtbcpf;
    IBOutlet NSTextField *label6;
    IBOutlet NSTextField *label7;
    IBOutlet NSTextView *rtbcpfname;
    IBOutlet NSTextField *label8;
    IBOutlet NSPopUpButton *cbtype;
    IBOutlet NSButton *btcpfcommit;
    IBOutlet NSButton *btprev;
    IBOutlet NSButton *llcpfadd;
    IBOutlet NSButton *llcpfchange;
    IBOutlet NSButton *linkLabel1;
    
    // NREF Panel controls
    IBOutlet NSView *panel4;
    IBOutlet NSTextField *label12;
    IBOutlet NSTextField *tbNref;
    IBOutlet NSTextField *label10;
    IBOutlet NSTextField *tbnrefhash;
    IBOutlet NSTextField *label9;
    IBOutlet NSButton *button2;
    
    // Internal properties
    id<IFileWrapperSaveExtension> wrapper;
}

// Internal properties
@property (nonatomic, strong) id<IFileWrapperSaveExtension> wrapper;
@property (nonatomic, strong) ExecutePreview fkt;

// Main panel properties for external access
@property (nonatomic, weak) IBOutlet NSView *cpfPanel;
@property (nonatomic, weak) IBOutlet NSView *nrefPanel;

// CPF Actions
- (IBAction)cpfItemSelect:(id)sender;
- (IBAction)cpfChange:(id)sender;
- (IBAction)addCpf:(id)sender;
- (IBAction)cpfCommit:(id)sender;
- (IBAction)btprevClick:(id)sender;
- (IBAction)deleteCpf:(id)sender;
- (IBAction)cpfAutoChange:(id)sender;

// NREF Actions
- (IBAction)tbnrefTextChanged:(id)sender;
- (IBAction)nrefCommit:(id)sender;

// Helper methods
- (void)cpfUpdate;
- (void)cpfAutoChange;

@end
