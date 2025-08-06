//
//  ResourceTreeNodeExt.m
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
// ***************************************************************************/

#import "ResourceTreeNodeExt.h"

@interface ResourceTreeNodeExt ()
@property (nonatomic, strong, readwrite) ResourceNameList *resources;
@property (nonatomic, assign, readwrite) uint64_t nodeID;
@end

@implementation ResourceTreeNodeExt

// MARK: - Initialization

- (instancetype)initWithID:(uint64_t)nodeID
                 resources:(ResourceNameList *)resources
                      text:(NSString *)text {
    self = [super init];
    if (self) {
        _nodeID = nodeID;
        _resources = resources;
        _children = [[NSMutableArray alloc] init];
        
        _imageIndex = 0;
        _selectedImageIndex = 0;
        
        // Format text with resource count
        _text = [NSString stringWithFormat:@"%@ (%ld)", text, (long)[resources count]];
    }
    return self;
}

// MARK: - Tree Navigation

- (NSInteger)numberOfChildren {
    return [self.children count];
}

- (ResourceTreeNodeExt *)childAtIndex:(NSInteger)index {
    if (index >= 0 && index < [self.children count]) {
        return [self.children objectAtIndex:index];
    }
    return nil;
}

- (void)addChild:(ResourceTreeNodeExt *)child {
    if (child != nil) {
        [self.children addObject:child];
        child.parent = self;
        
        // Keep children sorted
        [self.children sortUsingComparator:^NSComparisonResult(ResourceTreeNodeExt *obj1, ResourceTreeNodeExt *obj2) {
            return [obj1 compare:obj2];
        }];
    }
}

- (void)removeChild:(ResourceTreeNodeExt *)child {
    if (child != nil) {
        child.parent = nil;
        [self.children removeObject:child];
    }
}

// MARK: - Display

- (NSString *)displayName {
    return self.text;
}

// MARK: - Comparison

- (NSComparisonResult)compare:(ResourceTreeNodeExt *)other {
    if (other == nil) {
        return NSOrderedDescending;
    }
    
    return [self.text compare:other.text];
}

// MARK: - Description

- (NSString *)description {
    return [NSString stringWithFormat:@"ResourceTreeNodeExt: %@ (ID: %llu, Resources: %ld, Children: %ld)",
            self.text, self.nodeID, (long)[self.resources count], (long)[self.children count]];
}

@end
