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

#import "SRelUI.h"
#import "SRelWrapper.h"
#import "LocalizedEnums.h"
#import "MetaData.h"
#import "Boolset.h"

@implementation SRelUI

// MARK: - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        // NSViewController will call loadView automatically when view is needed
        // Don't call it manually in init
    }
    return self;
}

// MARK: - NSViewController Methods

- (void)loadView {
    // Create the main view
    self.view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 400, 300)];
    
    // Create realPanel as the main container
    self.realPanel = [[NSView alloc] initWithFrame:self.view.bounds];
    self.realPanel.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [self.view addSubview:self.realPanel];
    
    // Create UI components programmatically
    [self createUIComponents];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupRelationshipTypes];
}

// MARK: - UI Creation

- (void)createUIComponents {
    // Create the family type popup button
    self.cbfamtype = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(20, 250, 200, 24)];
    [self.realPanel addSubview:self.cbfamtype];
    
    // Create text fields
    self.tbshortterm = [[NSTextField alloc] initWithFrame:NSMakeRect(20, 220, 100, 24)];
    self.tblongterm = [[NSTextField alloc] initWithFrame:NSMakeRect(130, 220, 100, 24)];
    [self.realPanel addSubview:self.tbshortterm];
    [self.realPanel addSubview:self.tblongterm];
    
    // Create relationship checkboxes
    [self createRelationshipCheckboxes];
}

- (void)createRelationshipCheckboxes {
    NSInteger row = 0, col = 0;
    NSInteger startY = 180;
    NSInteger checkboxWidth = 120;
    NSInteger checkboxHeight = 20;
    NSInteger spacing = 25;
    
    // Define checkbox titles and create them
    NSDictionary *checkboxes = @{
        @"cbcrush": @"Crush",
        @"cblove": @"Love",
        @"cbengaged": @"Engaged",
        @"cbmarried": @"Married",
        @"cbfriend": @"Friend",
        @"cbbuddie": @"Buddy",
        @"cbsteady": @"Steady",
        @"cbenemy": @"Enemy",
        @"cbfamily": @"Family",
        @"cbbest": @"Best Friend"
    };
    
    for (NSString *property in checkboxes) {
        NSString *title = checkboxes[property];
        NSRect frame = NSMakeRect(20 + (col * (checkboxWidth + 10)),
                                  startY - (row * spacing),
                                  checkboxWidth,
                                  checkboxHeight);
        
        NSButton *checkbox = [[NSButton alloc] initWithFrame:frame];
        [checkbox setButtonType:NSButtonTypeSwitch];
        checkbox.title = title;
        [self.realPanel addSubview:checkbox];
        
        // Set the property using setValue:forKey:
        [self setValue:checkbox forKey:property];
        
        col++;
        if (col >= 2) {
            col = 0;
            row++;
        }
    }
}

// MARK: - Setup Methods

- (void)setupRelationshipTypes {
    [self.cbfamtype removeAllItems];
    
    // Add relationship types to popup
    NSArray *relationshipTypes = @[
        @(RelationshipTypesUnsetUnknown),
        @(RelationshipTypesAunt),
        @(RelationshipTypesChild),
        @(RelationshipTypesCousin),
        @(RelationshipTypesGrandchild),
        @(RelationshipTypesGrandparent),
        @(RelationshipTypesNiceNephew),
        @(RelationshipTypesParent),
        @(RelationshipTypesSibling),
        @(RelationshipTypesSpouses)
    ];
    
    for (NSNumber *typeNumber in relationshipTypes) {
        RelationshipTypes type = (RelationshipTypes)[typeNumber unsignedIntValue];
        NSString *displayName = [LocalizedRelationshipTypes displayNameForType:type];
        [self.cbfamtype addItemWithTitle:displayName];
    }
}

// MARK: - IPackedFileUI Protocol

- (NSView *)guiHandle {
    // Ensure view is loaded by accessing it (this triggers loadView if needed)
    if (!self.isViewLoaded) {
        // Just accessing self.view will trigger loadView automatically
        __unused NSView *view = self.view;
    }
    return self.realPanel;
}

- (void)updateGUI:(id<IFileWrapper>)wrapper {
    SRel *srel = (SRel *)wrapper;
    self.wrapper = srel;
    
    self.tbshortterm.stringValue = [NSString stringWithFormat:@"%d", srel.shortterm];
    self.tblongterm.stringValue = [NSString stringWithFormat:@"%d", srel.longterm];
    
    // Update checkboxes based on relationship state
    [self updateCheckboxesFromWrapper:srel];
}

- (void)updateCheckboxesFromWrapper:(SRel *)srel {
    // Create array of checkboxes matching the C# pattern - use 'id' type to allow NSNull
    NSArray<id> *ltcb = @[
        self.cbcrush,      // 0
        self.cblove,       // 1
        self.cbengaged,    // 2
        self.cbmarried,    // 3
        self.cbfriend,     // 4
        self.cbbuddie,     // 5
        self.cbsteady,     // 6
        self.cbenemy,      // 7
        [NSNull null],     // 8-13 (unused)
        [NSNull null],
        [NSNull null],
        [NSNull null],
        [NSNull null],
        [NSNull null],
        self.cbfamily,     // 14
        self.cbbest,       // 15
    ];
    
    Boolset *bs1 = [[Boolset alloc] initWithUInt16:srel.relationState.value];
    Boolset *bs2 = [[Boolset alloc] initWithUInt16:srel.relationState2.value];
    
    for (NSInteger i = 0; i < ltcb.count; i++) {
        id buttonObj = ltcb[i];
        if (![buttonObj isKindOfClass:[NSNull class]]) {
            NSButton *button = (NSButton *)buttonObj;
            Boolset *boolset = (i < 16) ? bs1 : bs2;
            NSInteger bitIndex = i & 0x0f;
            button.state = [boolset getBit:bitIndex] ? NSControlStateValueOn : NSControlStateValueOff;
        }
    }
}

@end
