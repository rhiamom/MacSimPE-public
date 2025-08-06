//
//  ViewFilter.m
//  MacSimpe
//
//  Created by Catherine Gramze on 7/29/25.
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

#import "ViewFilter.h"
#import "IPackedFileDescriptor.h"

@implementation ViewFilter

// MARK: - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        _filterInstance = NO;
        _filterGroup = NO;
        _instance = 0;
        _group = 0;
    }
    return self;
}

// MARK: - Property Setters with Change Notifications

- (void)setInstance:(uint32_t)instance {
    if (_instance != instance) {
        _instance = instance;
        if (self.filterInstance) {
            [self fireChangedFilter];
        }
    }
}

- (void)setFilterInstance:(BOOL)filterInstance {
    if (_filterInstance != filterInstance) {
        _filterInstance = filterInstance;
        [self fireChangedFilter];
    }
}

- (void)setGroup:(uint32_t)group {
    if (_group != group) {
        _group = group;
        if (self.filterGroup) {
            [self fireChangedFilter];
        }
    }
}

- (void)setFilterGroup:(BOOL)filterGroup {
    if (_filterGroup != filterGroup) {
        _filterGroup = filterGroup;
        [self fireChangedFilter];
    }
}

// MARK: - IResourceViewFilter Protocol

- (BOOL)active {
    return self.filterGroup || self.filterInstance;
}

- (BOOL)isFiltered:(id<IPackedFileDescriptor>)pfd {
    if (self.filterGroup) {
        if ([pfd group] != self.group) {
            return YES;
        }
    }
    
    if (self.filterInstance) {
        if ([pfd instance] != self.instance) {
            return YES;
        }
    }
    
    return NO;
}

// MARK: - Change Notification

- (void)fireChangedFilter {
    [[NSNotificationCenter defaultCenter] postNotificationName:IResourceViewFilterChangedFilterNotification
                                                        object:self];
}

@end
