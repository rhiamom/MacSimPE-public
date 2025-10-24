//
//  GroupCacheUI.m
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

#import "GroupCacheUI.h"
#import "GroupCacheForm.h"
#import "GroupCacheWrapper.h"
#import "GroupCacheItem.h"



@implementation GroupCacheUI {
    GroupCacheForm *_form;
}

// MARK: - Class Variables

static GroupCacheForm *sharedForm = nil;

// MARK: - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        // Create shared form instance if it doesn't exist (singleton pattern from C# original)
        if (sharedForm == nil) {
            sharedForm = [[GroupCacheForm alloc] init];
        }
        _form = sharedForm;
    }
    return self;
}

// MARK: - Properties

- (GroupCacheForm *)form {
    return _form;
}

// MARK: - IPackedFileUI Protocol Implementation

- (NSView *)guiHandle {
    // Equivalent to C# form.GropPanel
    return self.form.groupPanel;
}

- (void)updateGUI:(id<IFileWrapper>)wrapper {
    // Cast wrapper to GroupCache (equivalent to C# cast)
    GroupCache *groupCache = (GroupCache *)wrapper;
    
    if (![groupCache isKindOfClass:[GroupCache class]]) {
        NSLog(@"Warning: GroupCacheUI received wrapper that is not a GroupCache");
        return;
    }
    
    // Convert GroupCacheItems to NSArray for the form
    NSMutableArray *itemsArray = [[NSMutableArray alloc] init];
    GroupCacheItems *items = groupCache.items;
    
    for (NSInteger i = 0; i < items.length; i++) {
        GroupCacheItem *item = [items objectAtIndex:(NSUInteger)i];
        [itemsArray addObject:item];
    }
    
    // Sort the items (equivalent to lbgroup.Sorted = true in C#)
    [itemsArray sortUsingComparator:^NSComparisonResult(GroupCacheItem *item1, GroupCacheItem *item2) {
        return [item1.description compare:item2.description];
    }];
    
    // Update the form with the data
    // This is equivalent to:
    // form.lbgroup.BeginUpdate();
    // form.lbgroup.Items.Clear();
    // foreach (GroupCacheItem i in wrp.Items) form.lbgroup.Items.Add(i);
    // form.lbgroup.Sorted = true;
    // form.lbgroup.EndUpdate();
    [self.form loadData:itemsArray];
}

- (void)dispose {
    // Clean up resources if needed
    // In ARC environment, this is mostly handled automatically
    // but we can set the reference to nil to help with cleanup
    _form = nil;
}

// MARK: - Memory Management

- (void)dealloc {
    [self dispose];
}

@end
