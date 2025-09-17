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
#import "IFileWrapper.h"
#import "SRelWrapper.h"
#import "LocalizedEnums.h"
#import "MetaData.h"
#import "Boolset.h"

@implementation SRel

// MARK: - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        // Load the view from nib if needed
        [self loadView];
        [self setupRelationshipTypes];
    }
    return self;
}

// MARK: - View Setup

- (void)setupRelationshipTypes {
    [self.cbfamtype removeAllItems];
    [self.cbfamtype addItemWithTitle:[LocalizedRelationshipTypes displayNameForType:RelationshipTypesUnsetUnknown]];
    [self.cbfamtype addItemWithTitle:[LocalizedRelationshipTypes displayNameForType:RelationshipTypesAunt]];
    [self.cbfamtype addItemWithTitle:[LocalizedRelationshipTypes displayNameForType:RelationshipTypesChild]];
    [self.cbfamtype addItemWithTitle:[LocalizedRelationshipTypes displayNameForType:RelationshipTypesCousin]];
    [self.cbfamtype addItemWithTitle:[LocalizedRelationshipTypes displayNameForType:RelationshipTypesGrandchild]];
    [self.cbfamtype addItemWithTitle:[LocalizedRelationshipTypes displayNameForType:RelationshipTypesGrandparent]];
    [self.cbfamtype addItemWithTitle:[LocalizedRelationshipTypes displayNameForType:RelationshipTypesNiceNephew]];
    [self.cbfamtype addItemWithTitle:[LocalizedRelationshipTypes displayNameForType:RelationshipTypesParent]];
    [self.cbfamtype addItemWithTitle:[LocalizedRelationshipTypes displayNameForType:RelationshipTypesSibling]];
    [self.cbfamtype addItemWithTitle:[LocalizedRelationshipTypes displayNameForType:RelationshipTypesSpouses]];
}

// MARK: - IPackedFileUI Protocol

- (NSView *)guiHandle {
    return self.realPanel;
}

- (void)updateGUI:(id<IFileWrapper>)wrapper {
    SRelWrapper *srel = (SRelWrapper *)wrapper;
    self.wrapper = srel;
    
    self.tbshortterm.stringValue = [NSString stringWithFormat:@"%d", srel.shortterm];
    self.tblongterm.stringValue = [NSString stringWithFormat:@"%d", srel.longterm];
    
    // Create array of checkboxes matching the C# pattern
    NSArray<NSButton *> *ltcb = @[
        self.cbcrush,      // 0
        self.cblove,       // 1
        self.cbengaged,    // 2
        self.cbmarried,    // 3
        self.cbfriend,     // 4
        self.cbbuddie,     // 5
        self.cbsteady,     // 6
        self.cbenemy,      // 7
        [NSNull null],     // 8
        [NSNull null],     // 9
        [NSNull null],     // 10
        [NSNull null],     // 11
        [NSNull null],     // 12
        [NSNull null],     // 13
        self.cbfamily,     // 14
        self.cbbest,       // 15
        [NSNull null],     // 16
        [NSNull null],     // 17
        [NSNull null],     // 18
        [NSNull null],     // 19
        [NSNull null],     // 20
        [NSNull null],     // 21
        [NSNull null],     // 22
        [NSNull null],     // 23
        [NSNull null],     // 24 - BFF slot
        [NSNull null],     // 25
        [NSNull null],     // 26
        [NSNull null],     // 27
        [NSNull null],     // 28
        [NSNull null],     // 29
        [NSNull null],     // 30
        [NSNull null],     // 31
    ];
    
    Boolset *bs1 = srel.relationState.value;
    Boolset *bs2 = srel.relationState2.value;
    
    for (NSInteger i = 0; i < ltcb.count; i++) {
        id buttonObj = ltcb[i];
        if (![buttonObj isKindOfClass:[NSNull class]]) {
            NSButton *button = (NSButton *)buttonObj;
            Boolset *boolset = (i < 16) ? bs1 : bs2;
            NSInteger bitIndex = i & 0x0f;
            button.state = [boolset getBit:bitIndex] ? NSControlStateValueOn : NSControlStateValueOff;
        }
    }
    
    // Set family type selection
    [self.cbfamtype selectItemAtIndex:0];
    for (NSInteger i = 1; i < self.cbfamtype.numberOfItems; i++) {
        LocalizedRelationshipTypes *currentType = [[LocalizedRelationshipTypes alloc] initWithType:srel.familyRelation];
        NSString *currentTitle = self.cbfamtype.itemTitleAtIndex:i;
        NSString *expectedTitle = [currentType displayName];
        if ([currentTitle isEqualToString:expectedTitle]) {
            [self.cbfamtype selectItemAtIndex:i];
            break;
        }
    }
}

@end
