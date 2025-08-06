//
//  CaseInvariantArrayList.m
//  MacSimpe
//
//  Created by Catherine Gramze on 7/28/25.
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

#import "CaseInvariantArrayList.h"

@implementation CaseInvariantArrayList

- (BOOL)containsObject:(id)object {
    if ([object isKindOfClass:[NSString class]]) {
        NSString *searchString = [(NSString *)object lowercaseString];
        
        for (id item in self) {
            if (item == nil) continue;
            
            if ([item isKindOfClass:[NSString class]]) {
                if ([[(NSString *)item lowercaseString] isEqualToString:searchString]) {
                    return YES;
                }
            }
        }
        
        return NO;
    } else {
        return [super containsObject:object];
    }
}

- (void)removeObject:(id)obj {
    if ([obj isKindOfClass:[NSString class]]) {
        NSString *searchString = [(NSString *)obj lowercaseString];
        
        for (NSInteger k = 0; k < [self count]; k++) {
            id item = [self objectAtIndex:k];
            if (item == nil) continue;
            
            if ([item isKindOfClass:[NSString class]]) {
                if ([[(NSString *)item lowercaseString] isEqualToString:searchString]) {
                    [self removeObjectAtIndex:k];
                    return;
                }
            }
        }
    } else {
        [super removeObject:obj];
    }
}

@end
