//
//  CountedListItem.m
//  MacSimpe
//
//  Created by Catherine Gramze on 8/8/25.
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

#import "CountedListItem.h"

@interface CountedListItem ()
@property (nonatomic, assign, readwrite) NSInteger index;
@property (nonatomic, assign, readwrite) BOOL hex;
@end

@implementation CountedListItem

// MARK: - Class Variable

static NSInteger _offset = 0;

// MARK: - Class Properties

+ (NSInteger)offset {
    return _offset;
}

+ (void)setOffset:(NSInteger)offset {
    _offset = offset;
}

// MARK: - Initialization

- (instancetype)initWithIndex:(NSInteger)index object:(id)object hex:(BOOL)hex {
    self = [super init];
    if (self) {
        _index = index;
        _object = object;
        _hex = hex;
    }
    return self;
}

// MARK: - Description

- (NSString *)description {
    if (self.hex) {
        return [NSString stringWithFormat:@"0x%lX: %@", (long)self.index, self.object ?: @"(null)"];
    } else {
        return [NSString stringWithFormat:@"%ld: %@", (long)self.index, self.object ?: @"(null)"];
    }
}

// MARK: - Convenience Methods for NSComboBox

+ (void)addToComboBox:(NSComboBox *)comboBox object:(id)object {
    NSInteger currentCount = [comboBox numberOfItems];
    CountedListItem *item = [[CountedListItem alloc] initWithIndex:currentCount + _offset
                                                            object:object
                                                               hex:NO];
    [comboBox addItemWithObjectValue:item];
}

+ (void)addHexToComboBox:(NSComboBox *)comboBox object:(id)object {
    NSInteger currentCount = [comboBox numberOfItems];
    CountedListItem *item = [[CountedListItem alloc] initWithIndex:currentCount + _offset
                                                            object:object
                                                               hex:YES];
    [comboBox addItemWithObjectValue:item];
}

// MARK: - Convenience Methods for NSPopUpButton

+ (void)addToPopUpButton:(NSPopUpButton *)popUpButton object:(id)object {
    NSInteger currentCount = [[popUpButton itemArray] count];
    CountedListItem *item = [[CountedListItem alloc] initWithIndex:currentCount + _offset
                                                            object:object
                                                               hex:NO];
    [popUpButton addItemWithTitle:[item description]];
    
    // Store the CountedListItem as the represented object
    NSMenuItem *menuItem = [popUpButton lastItem];
    [menuItem setRepresentedObject:item];
}

+ (void)addHexToPopUpButton:(NSPopUpButton *)popUpButton object:(id)object {
    NSInteger currentCount = [[popUpButton itemArray] count];
    CountedListItem *item = [[CountedListItem alloc] initWithIndex:currentCount + _offset
                                                            object:object
                                                               hex:YES];
    [popUpButton addItemWithTitle:[item description]];
    
    // Store the CountedListItem as the represented object
    NSMenuItem *menuItem = [popUpButton lastItem];
    [menuItem setRepresentedObject:item];
}

// MARK: - Convenience Methods for NSTableView (via array)

+ (void)addToArray:(NSMutableArray *)array object:(id)object {
    NSInteger currentCount = [array count];
    CountedListItem *item = [[CountedListItem alloc] initWithIndex:currentCount + _offset
                                                            object:object
                                                               hex:NO];
    [array addObject:item];
}

+ (void)addHexToArray:(NSMutableArray *)array object:(id)object {
    NSInteger currentCount = [array count];
    CountedListItem *item = [[CountedListItem alloc] initWithIndex:currentCount + _offset
                                                            object:object
                                                               hex:YES];
    [array addObject:item];
}

// MARK: - Memory Management

- (void)dealloc {
    // Objective-C handles memory management automatically
    // Setting object to nil is optional but can help with debugging
    _object = nil;
}

@end
