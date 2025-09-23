//
//  Fami.m
//  MacSimpe
//
//  Created by Catherine Gramze on 9/19/25.
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

#import "FamiUI.h"
#import "FamiWrapper.h"
#import "Helper.h"
#import "Registry.h"
#import "Alias.h"

@implementation FamiUI

// MARK: - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        // Initialize if needed
    }
    return self;
}

// MARK: - IPackedFileUI Protocol

- (NSView *)guiHandle {
    return self.famiPanel;
}

- (void)updateGUI:(id<IFileWrapper>)wrapper {
    FamiWrapper *fami = (FamiWrapper *)wrapper;
    self.wrapper = fami;
    
    // Update basic fields
    self.tbname.stringValue = fami.name ?: @"";
    self.tbmoney.stringValue = [NSString stringWithFormat:@"%ld", (long)fami.money];
    self.tbfamily.stringValue = [NSString stringWithFormat:@"%ld", (long)fami.friends];
    self.tblotinst.stringValue = [NSString stringWithFormat:@"0x%@", [Helper hexString:fami.lotInstance]];
    self.tbalbum.stringValue = [NSString stringWithFormat:@"0x%@", [Helper hexString:fami.albumGUID]];
    self.tbflag.stringValue = [NSString stringWithFormat:@"0x%@", [Helper hexString:fami.flags]];
    self.tbsubhood.stringValue = [NSString stringWithFormat:@"0x%@", [Helper hexString:fami.subHoodNumber]];
    self.tbvac.stringValue = [NSString stringWithFormat:@"0x%@", [Helper hexString:fami.vacationLotInstance]];
    self.tbblot.stringValue = [NSString stringWithFormat:@"0x%@", [Helper hexString:fami.currentlyOnLotInstance]];
    self.tbbmoney.stringValue = [NSString stringWithFormat:@"%ld", (long)fami.businessMoney];
    
    // Update Castaway fields
    self.tbcafood1.stringValue = [NSString stringWithFormat:@"%ld", (long)fami.castAwayFood];
    self.tbcares.stringValue = [NSString stringWithFormat:@"%ld", (long)fami.castAwayResources];
    self.tbcaunk.stringValue = [NSString stringWithFormat:@"0x%@", [Helper hexString:fami.castAwayFoodDecay]];
    self.tbcaunk.editable = [[Registry windowsRegistry] hiddenMode];
    
    // Enable/disable controls based on version
    self.tbbmoney.enabled = (NSInteger)fami.version >= (NSInteger)FamiVersionsBusiness;
    self.tbblot.enabled = (NSInteger)fami.version >= (NSInteger)FamiVersionsBusiness;
    self.tbvac.enabled = (NSInteger)fami.version >= (NSInteger)FamiVersionsVoyage;
    self.tbsubhood.enabled = (NSInteger)fami.version >= (NSInteger)FamiVersionsUniversity;
    self.gbCastaway.hidden = !((NSInteger)fami.version >= (NSInteger)FamiVersionsCastaway);
    
    self.tbmoney.enabled = (NSInteger)fami.version < (NSInteger)FamiVersionsCastaway;
    self.tbbmoney.enabled = (NSInteger)fami.version < (NSInteger)FamiVersionsCastaway;
    
    // Clear and populate members list
    // Note: This would need a proper data source implementation for NSTableView
    // For now, we'll use a simple approach
    
    // Update sims combo box
    [self.cbsims removeAllItems];
    
    NSArray *simNames = fami.simNames;
    NSArray *members = fami.members;
    
    // Add members to the list (this would need proper NSTableView data source)
    for (NSInteger i = 0; i < members.count && i < simNames.count; i++) {
        NSNumber *memberID = members[i];
        NSString *simName = simNames[i];
        
        Alias *alias = [[Alias alloc] initWithId:[memberID unsignedIntValue] name:simName];
        // Add to table view data source here
    }
    
    // Populate combo box with all available sims
    NSDictionary *storedData = fami.nameProvider.storedData;
    NSMutableArray *sortedAliases = [[NSMutableArray alloc] init];
    
    for (id<IAlias> alias in storedData.allValues) {
        [sortedAliases addObject:alias];
        [self.cbsims addItemWithObjectValue:[alias description]];
    }
    
    // Sort the combo box items
    [self.cbsims.objectValues sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
}

@end
