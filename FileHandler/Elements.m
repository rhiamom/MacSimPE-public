//
//  Elements.m
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

#import "Elements.h"
#import "IFileWrapperSaveExtension.h"
#import "FamiWrapper.h"
#import "XmlWrapper.h"
#import "SDescWrapper.h"
#import "PictureWrapper.h"
#import "FamilyTiesWrapper.h"
#import "FamilyTieItem.h"
#import "LocalizedEnums.h"
#import "SRelWrapper.h"
#import "ObjdWrapper.h"
#import "Helper.h"
#import "ExtSDesc.h"
#import "IPackedFileDescriptor.h"
#import "Localization.h"
#import "Registry.h"
#import "FixGuid.h"
#import "FamiWrapper.h"
#import "Boolset.h"
#import "ExceptionForm.h"
#import <AppKit/AppKit.h>

@implementation Elements {
    NSMutableArray *familyTiesDataSource;
    NSMutableArray *familyMembersDataSource;
}

@synthesize wrapper, picwrapper, simnamechanged;

- (id)init {
    self = [super initWithWindowNibName:@"Elements"];
    if (self) {
        intern = NO;
        simnamechanged = NO;
        familyTiesDataSource = [[NSMutableArray alloc] init];
        familyMembersDataSource = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    // Additional setup after loading the window
}

#pragma mark - Actions

- (IBAction)commitFamiClick:(id)sender {
    if (wrapper != nil) {
        @try {
            [[NSCursor arrowCursor] push];
            Fami *fami = (Fami *)wrapper;
            
            [fami setMoney:[[tbmoney stringValue] intValue]];
            [fami setFriends:[[tbfamily stringValue] intValue]];
            
            // Parse hex values
            NSScanner *scanner = [NSScanner scannerWithString:[tbflag stringValue]];
            unsigned int flagValue;
            [scanner scanHexInt:&flagValue];
            [fami setFlags:flagValue];
            
            scanner = [NSScanner scannerWithString:[tbalbum stringValue]];
            unsigned int albumValue;
            [scanner scanHexInt:&albumValue];
            [fami setAlbumGUID:albumValue];
            
            scanner = [NSScanner scannerWithString:[tblotinst stringValue]];
            unsigned int lotValue;
            [scanner scanHexInt:&lotValue];
            [fami setLotInstance:lotValue];
            
            if (![wrapper isEqual:fami] || simnamechanged ||
                ![[tbname stringValue] isEqualToString:[fami name]]) {
                [fami setName:[tbname stringValue]];
            }
            
            [fami synchronizeUserData];
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:[[Localization shared] getString:@"committed"]];
            [alert runModal];
            
        } @catch (NSException *ex) {
            [ExceptionForm showError:[[Localization shared] getString:@"cannot commit family"]
                         withDetails:ex.reason
                           exception:ex];
        } @finally {
            [NSCursor pop];
        }
    }
}

- (IBAction)commitXmlClick:(id)sender {
    if (wrapper != nil) {
        @try {
            Xml *xml = (Xml *)wrapper;
            [xml setText:[rtb string]];
            [wrapper synchronizeUserData];
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:[[Localization shared] getString:@"commited"]];
            [alert runModal];
        } @catch (NSException *ex) {
            // Handle exception silently
        }
    }
}

- (IBAction)famiSimAddClick:(id)sender {
    if ([cbsims indexOfSelectedItem] >= 0) {
        id selectedItem = [[cbsims selectedItem] representedObject];
        
        // Check if item already exists in members list
        BOOL exists = NO;
        for (id existingItem in familyMembersDataSource) {
            if ([existingItem isEqual:selectedItem]) {
                exists = YES;
                break;
            }
        }
        
        if (!exists) {
            [familyMembersDataSource addObject:selectedItem];
            [lbmembers reloadData];
        }
    }
}

- (IBAction)simSelectionChange:(id)sender {
    NSPopUpButton *comboBox = (NSPopUpButton *)sender;
    [llFamiAddSim setEnabled:([comboBox indexOfSelectedItem] >= 0 &&
                              [comboBox numberOfItems] > 0)];
}

- (IBAction)famiMemberSelectionClick:(id)sender {
    NSTableView *tableView = (NSTableView *)sender;
    [llFamiDeleteSim setEnabled:([tableView selectedRow] >= 0)];
    [llFamiDeleteSim setNeedsDisplay:YES];
}

- (IBAction)famiDeleteSimClick:(id)sender {
    NSInteger selectedRow = [lbmembers selectedRow];
    if (selectedRow >= 0 && selectedRow < [familyMembersDataSource count]) {
        [familyMembersDataSource removeObjectAtIndex:selectedRow];
        [lbmembers reloadData];
    }
}

#pragma mark - Family Ties

- (IBAction)familyTieSimIndexChanged:(id)sender {
    [btdeletetie setEnabled:NO];
    if ([cbtiesims indexOfSelectedItem] < 0) return;
    
    FamilyTieSim *sim = (FamilyTieSim *)[[cbtiesims selectedItem] representedObject];
    
    // Clear and reload ties list
    [familyTiesDataSource removeAllObjects];
    NSArray *ties = [sim ties];
    for (FamilyTieItem *tie in ties) {
        [familyTiesDataSource addObject:tie];
    }
    [lbties reloadData];
}

- (IBAction)allTieableSimsIndexChanged:(id)sender {
    [btaddtie setEnabled:NO];
    [btnewtie setEnabled:NO];
    if ([cballtieablesims indexOfSelectedItem] < 0) return;
    [btnewtie setEnabled:YES];
    if ([cbtiesims indexOfSelectedItem] < 0) return;
    [btaddtie setEnabled:YES];
}

- (IBAction)deleteTieClick:(id)sender {
    [btaddtie setEnabled:NO];
    NSInteger selectedRow = [lbties selectedRow];
    if (selectedRow < 0 || selectedRow >= [familyTiesDataSource count]) return;
    
    [familyTiesDataSource removeObjectAtIndex:selectedRow];
    [lbties reloadData];
}

- (IBAction)addTieClick:(id)sender {
    if ([cballtieablesims indexOfSelectedItem] < 0) return;
    if ([cbtietype indexOfSelectedItem] < 0) return;
    
    @try {
        FamilyTies *famt = (FamilyTies *)wrapper;
        LocalizedFamilyTieTypes *ftt = (LocalizedFamilyTieTypes *)[[cbtietype selectedItem] representedObject];
        FamilyTieSim *fts = (FamilyTieSim *)[[cballtieablesims selectedItem] representedObject];
        
        FamilyTieItem *tie = [[FamilyTieItem alloc] initWithSimInstance:[fts instance]
                                                                   famt:famt];
        [familyTiesDataSource addObject:tie];
        [lbties reloadData];
    } @catch (NSException *ex) {
        [Helper exceptionMessage:[[Localization shared] getString:@"cannot add tie"]
                           error:nil];
    }
}

- (IBAction)commitSimTieClicked:(id)sender {
    if ([cbtiesims indexOfSelectedItem] < 0) return;
    
    if (wrapper != nil) {
        @try {
            FamilyTies *famt = (FamilyTies *)wrapper;
            FamilyTieSim *fts = (FamilyTieSim *)[[cbtiesims selectedItem] representedObject];
            
            NSMutableArray *ftis = [NSMutableArray arrayWithArray:familyTiesDataSource];
            [fts setTies:ftis];
        } @catch (NSException *ex) {
            [Helper exceptionMessage:[[Localization shared] getString:@"cannot commit famt"]
                               error:nil];
        }
    }
}

- (IBAction)tieIndexChanged:(id)sender {
    [btdeletetie setEnabled:NO];
    if ([lbties selectedRow] < 0) return;
    [btdeletetie setEnabled:YES];
}

- (IBAction)commitTieClick:(id)sender {
    [self commitSimTieClicked:nil];
    if (wrapper != nil) {
        @try {
            FamilyTies *famt = (FamilyTies *)wrapper;
            
            NSMutableArray *sims = [NSMutableArray array];
            NSInteger itemCount = [cbtiesims numberOfItems];
            for (NSInteger i = 0; i < itemCount; i++) {
                NSMenuItem *item = [cbtiesims itemAtIndex:i];
                FamilyTieSim *sim = (FamilyTieSim *)[item representedObject];
                [sims addObject:sim];
            }
            [famt setSims:sims];
            
            [famt synchronizeUserData];
        } @catch (NSException *ex) {
            [Helper exceptionMessage:[[Localization shared] getString:@"cannot commit"]
                               error:nil];
        }
    }
}

- (IBAction)addSimToTiesClick:(id)sender {
    if ([cballtieablesims indexOfSelectedItem] < 0) return;
    FamilyTieSim *sim = (FamilyTieSim *)[[cballtieablesims selectedItem] representedObject];
    [sim setTies:@[]];
    
    // Check if the tie exists
    BOOL exists = NO;
    NSInteger itemCount = [cbtiesims numberOfItems];
    for (NSInteger i = 0; i < itemCount; i++) {
        NSMenuItem *item = [cbtiesims itemAtIndex:i];
        FamilyTieSim *exsim = (FamilyTieSim *)[item representedObject];
        if ([exsim instance] == [sim instance]) {
            exists = YES;
            break;
        }
    }
    
    if (!exists) {
        [cbtiesims addItemWithTitle:@"New Sim"];
        [[cbtiesims lastItem] setRepresentedObject:sim];
    }
}

#pragma mark - Relationships

- (IBAction)relationshipFileCommit:(id)sender {
    if (wrapper != nil) {
        @try {
            SRel *srel = (SRel *)wrapper;
            [srel setShortterm:[[tbshortterm stringValue] intValue]];
            [srel setLongterm:[[tblongterm stringValue] intValue]];
            
            RelationshipFlags *relationFlags = [srel relationState];
            
            // Set relationship flags based on checkboxes
            relationFlags.hasCrush = ([cbcrush state] == NSControlStateValueOn);
            relationFlags.inLove = ([cblove state] == NSControlStateValueOn);
            relationFlags.isEngaged = ([cbengaged state] == NSControlStateValueOn);
            relationFlags.isMarried = ([cbmarried state] == NSControlStateValueOn);
            relationFlags.isFriend = ([cbfriend state] == NSControlStateValueOn);
            relationFlags.isBuddie = ([cbbuddie state] == NSControlStateValueOn);
            relationFlags.goSteady = ([cbsteady state] == NSControlStateValueOn);
            relationFlags.isEnemy = ([cbenemy state] == NSControlStateValueOn);
            
            if ([cbfamtype indexOfSelectedItem] > 0) {
                LocalizedRelationshipTypes *relType = (LocalizedRelationshipTypes *)[[cbfamtype selectedItem] representedObject];
                [srel setFamilyRelation:[relType relationshipType]];
            }
            
            [wrapper synchronizeUserData];
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:[[Localization shared] getString:@"committed"]];
            [alert runModal];
        } @catch (NSException *ex) {
            [Helper exceptionMessage:@"Unable to Save Relationship Information!"
                               error:nil];
        }
    }
}

- (IBAction)commitObjdClicked:(id)sender {
    // Implementation for objd commit
    if (wrapper != nil) {
        @try {
            [wrapper synchronizeUserData];
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:[[Localization shared] getString:@"committed"]];
            [alert runModal];
        } @catch (NSException *ex) {
            [Helper exceptionMessage:@"Unable to Save Object Data!"
                               error:nil];
        }
    }
}

- (IBAction)getGUIDClicked:(id)sender {
    // Implementation for GUID getter
}

- (IBAction)simNameChanged:(id)sender {
    simnamechanged = YES;
}

- (IBAction)flagChanged:(id)sender {
    // Implementation for flag changes
}

- (IBAction)changeFlags:(id)sender {
    // Implementation for changing flags
}

- (IBAction)btPicExportClick:(id)sender {
    // Implementation for picture export
}

- (IBAction)label15Click:(id)sender {
    // Implementation for label15 click
}

- (IBAction)changedMoney:(id)sender {
    // Implementation for money changes
}

- (IBAction)changedBMoney:(id)sender {
    // Implementation for bonus money changes
}

#pragma mark - Progress bar methods

- (void)progressBarMaximize:(NSView *)parent {
    // Implementation for progress bar maximize
}

- (void)progressBarUpdate:(NSView *)parent {
    // Implementation for progress bar update
}

- (void)progressBarUpdate:(NSProgressIndicator *)pb withEvent:(NSEvent *)event {
    // Implementation for progress bar update with event
}

- (void)getAssignedProgressbar:(NSTextField *)tb {
    // Implementation for getting assigned progress bar
}

- (void)progressBarTextChanged:(id)sender {
    // Implementation for progress bar text change
}

- (void)progressBarTextLeave:(id)sender {
    // Implementation for progress bar text leave
}

@end
