//
//  Elements.h
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
//
//  Elements.h
//  SimPE
//
//  Copyright (C) 2005 by Ambertation
//  quaxi@ambertation.de
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 2 of the License, or
//  (at your option) any later version.
//

#import <Cocoa/Cocoa.h>

@class IFileWrapperSaveExtension;
@class Fami;
@class Xml;
@class SDesc;
@class PictureWrapper;
@class FamilyTies;
@class SRel;
@class Objd;

@interface Elements : NSWindowController {
    // Panels
    IBOutlet NSView *panel2;
    IBOutlet NSTextField *banner;
    IBOutlet NSImageView *pb;
    IBOutlet NSView *jpegPanel;
    IBOutlet NSView *xmlPanel;
    IBOutlet NSView *panel3;
    IBOutlet NSTextField *label1;
    IBOutlet NSTextView *rtb;
    IBOutlet NSButton *visualStyleLinkLabel2;
    IBOutlet NSTextField *tbsimid;
    IBOutlet NSTextField *label8;
    IBOutlet NSView *panel6;
    IBOutlet NSTextField *label12;
    IBOutlet NSView *objdPanel;
    IBOutlet NSTextField *tbsimname;
    IBOutlet NSTextField *label9;
    IBOutlet NSTabView *tabControl1;
    IBOutlet NSTabViewItem *tabPage1;
    IBOutlet NSView *famiPanel;
    IBOutlet NSTextField *tblotinst;
    IBOutlet NSTextField *label15;
    IBOutlet NSButton *llFamiDeleteSim;
    IBOutlet NSButton *llFamiAddSim;
    IBOutlet NSButton *button1;
    IBOutlet NSPopUpButton *cbsims;
    IBOutlet NSTableView *lbmembers;
    IBOutlet NSTextField *tbname;
    IBOutlet NSTextField *label6;
    IBOutlet NSTextField *tbfamily;
    IBOutlet NSTextField *tbmoney;
    IBOutlet NSTextField *label5;
    IBOutlet NSTextField *label4;
    IBOutlet NSTextField *label3;
    IBOutlet NSView *panel4;
    IBOutlet NSTextField *label2;
    IBOutlet NSTabViewItem *tabPage3;
    IBOutlet NSView *realPanel;
    IBOutlet NSView *panel7;
    IBOutlet NSTextField *label56;
    IBOutlet NSTextField *tblongterm;
    IBOutlet NSTextField *tbshortterm;
    IBOutlet NSTextField *label57;
    IBOutlet NSTextField *label58;
    IBOutlet NSButton *llrelcommit;
    IBOutlet NSBox *gbrelation;
    IBOutlet NSButton *cbmarried;
    IBOutlet NSButton *cbengaged;
    IBOutlet NSButton *cbsteady;
    IBOutlet NSButton *cblove;
    IBOutlet NSButton *cbcrush;
    IBOutlet NSButton *cbenemy;
    IBOutlet NSButton *cbbuddie;
    IBOutlet NSButton *cbfriend;
    IBOutlet NSTabViewItem *tabPage4;
    IBOutlet NSTextField *label64;
    IBOutlet NSView *panel8;
    IBOutlet NSTextField *label68;
    IBOutlet NSView *familytiePanel;
    IBOutlet NSButton *bttiecommit;
    IBOutlet NSPopUpButton *cbtiesims;
    IBOutlet NSBox *gbties;
    IBOutlet NSPopUpButton *cbtietype;
    IBOutlet NSButton *btdeletetie;
    IBOutlet NSButton *btaddtie;
    IBOutlet NSTableView *lbties;
    IBOutlet NSPopUpButton *cballtieablesims;
    IBOutlet NSButton *llcommitties;
    IBOutlet NSButton *btnewtie;
    IBOutlet NSTextField *tblottype;
    IBOutlet NSTextField *label65;
    IBOutlet NSButton *llcommitobjd;
    IBOutlet NSBox *gbelements;
    IBOutlet NSView *pnelements;
    IBOutlet NSButton *llgetGUID;
    IBOutlet NSTextField *lbtypename;
    IBOutlet NSButton *cbfamily;
    IBOutlet NSButton *cbbest;
    IBOutlet NSButton *llsrelcommit;
    IBOutlet NSPopUpButton *cbfamtype;
    IBOutlet NSTextField *label91;
    IBOutlet NSTextField *tbflag;
    IBOutlet NSTextField *label92;
    IBOutlet NSTextField *tbalbum;
    IBOutlet NSTextField *label93;
    IBOutlet NSTextField *tborgguid;
    IBOutlet NSTextField *tbproxguid;
    IBOutlet NSTextField *label97;
    IBOutlet NSTextField *label63;
    IBOutlet NSBox *groupBox4;
    IBOutlet NSButton *cbphone;
    IBOutlet NSButton *cbbaby;
    IBOutlet NSButton *cbcomputer;
    IBOutlet NSButton *cblot;
    IBOutlet NSButton *cbupdate;
    IBOutlet NSTextField *tbsubhood;
    IBOutlet NSTextField *label89;
    IBOutlet NSButton *btPicExport;
    IBOutlet NSTextField *tbvac;
    IBOutlet NSTextField *label7;
    IBOutlet NSBox *gbCastaway;
    IBOutlet NSTextField *tbcaunk;
    IBOutlet NSTextField *label13;
    IBOutlet NSTextField *tbcares;
    IBOutlet NSTextField *label11;
    IBOutlet NSTextField *tbcafood1;
    IBOutlet NSTextField *label10;
    IBOutlet NSTextField *tbblot;
    IBOutlet NSTextField *label14;
    IBOutlet NSTextField *tbbmoney;
    IBOutlet NSTextField *label16;
    
    // Internal properties
    IFileWrapperSaveExtension *wrapper;
    IFileWrapperSaveExtension *picwrapper;
    BOOL simnamechanged;
    BOOL intern;
}

@property (nonatomic, weak) IBOutlet NSImageView *pb;
@property (nonatomic, weak) IBOutlet NSView *jpegPanel;
@property (nonatomic, weak) IBOutlet NSView *xmlPanel;
@property (nonatomic, weak) IBOutlet NSView *objdPanel;
@property (nonatomic, weak) IBOutlet NSView *realPanel;
@property (nonatomic, weak) IBOutlet NSView *famiPanel;
@property (nonatomic, weak) IBOutlet NSView *familytiePanel;
@property (nonatomic, strong) IFileWrapperSaveExtension *wrapper;
@property (nonatomic, strong) IFileWrapperSaveExtension *picwrapper;
@property (nonatomic, assign) BOOL simnamechanged;

// Actions
- (IBAction)commitFamiClick:(id)sender;
- (IBAction)commitXmlClick:(id)sender;
- (IBAction)famiSimAddClick:(id)sender;
- (IBAction)simSelectionChange:(id)sender;
- (IBAction)famiMemberSelectionClick:(id)sender;
- (IBAction)famiDeleteSimClick:(id)sender;
- (IBAction)familyTieSimIndexChanged:(id)sender;
- (IBAction)allTieableSimsIndexChanged:(id)sender;
- (IBAction)deleteTieClick:(id)sender;
- (IBAction)addTieClick:(id)sender;
- (IBAction)commitSimTieClicked:(id)sender;
- (IBAction)tieIndexChanged:(id)sender;
- (IBAction)commitTieClick:(id)sender;
- (IBAction)addSimToTiesClick:(id)sender;
- (IBAction)relationshipFileCommit:(id)sender;
- (IBAction)commitObjdClicked:(id)sender;
- (IBAction)getGUIDClicked:(id)sender;
- (IBAction)simNameChanged:(id)sender;
- (IBAction)flagChanged:(id)sender;
- (IBAction)changeFlags:(id)sender;
- (IBAction)btPicExportClick:(id)sender;
- (IBAction)label15Click:(id)sender;
- (IBAction)changedMoney:(id)sender;
- (IBAction)changedBMoney:(id)sender;

// Progress bar methods
- (void)progressBarMaximize:(NSView *)parent;
- (void)progressBarUpdate:(NSView *)parent;
- (void)progressBarUpdate:(NSProgressIndicator *)pb withEvent:(NSEvent *)event;
- (void)getAssignedProgressbar:(NSTextField *)tb;
- (void)progressBarTextChanged:(id)sender;
- (void)progressBarTextLeave:(id)sender;

@end
