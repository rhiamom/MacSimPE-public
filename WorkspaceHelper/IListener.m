//
//  IListener.m
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

#import "IListener.h"

@interface Listeners ()
@property (nonatomic, strong, readwrite) NSMutableArray *list;
@end

@implementation Listeners

// MARK: - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        _list = [[NSMutableArray alloc] init];
    }
    return self;
}

// MARK: - Collection Management

- (BOOL)contains:(id<IListener>)listener {
    return [self.list containsObject:listener];
}

- (NSInteger)count {
    return [self.list count];
}

- (void)addListener:(id<IListener>)listener {
    if (listener != nil && ![self contains:listener]) {
        [self.list addObject:listener];
    }
}

- (void)removeListener:(id<IListener>)listener {
    [self.list removeObject:listener];
}

- (void)removeAllListeners {
    [self.list removeAllObjects];
}

// MARK: - Indexers

- (id<IListener>)objectAtIndex:(NSInteger)index {
    if (index >= 0 && index < [self.list count]) {
        return [self.list objectAtIndex:index];
    }
    return nil;
}

- (void)setObject:(id<IListener>)listener atIndex:(NSInteger)index {
    if (index >= 0 && index < [self.list count] && listener != nil) {
        [self.list replaceObjectAtIndex:index withObject:listener];
    }
}

- (id<IListener>)objectAtIndexedSubscript:(NSInteger)index {
    return [self objectAtIndex:index];
}

- (void)setObject:(id<IListener>)listener atIndexedSubscript:(NSInteger)index {
    [self setObject:listener atIndex:index];
}

// MARK: - NSFastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                  objects:(id __unsafe_unretained [])buffer
                                    count:(NSUInteger)len {
    return [self.list countByEnumeratingWithState:state objects:buffer count:len];
}

@end
