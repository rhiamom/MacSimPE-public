//
//  ResourceTreeTypeNodeExt.m
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

#import "ResourceTreeTypeNodeExt.h"
#import "ResourceViewManager.h"
#import "TypeAlias.h"
#import "MetaData.h"

@interface ResourceTreeTypeNodeExt ()
@property (nonatomic, assign, readwrite) uint32_t type;
@end

@implementation ResourceTreeTypeNodeExt

// MARK: - Initialization

- (instancetype)initWithResources:(ResourceNameList *)resources
                             type:(uint32_t)type {
    
    // Initialize with parent class using empty text (we'll set it below)
    self = [super initWithID:type resources:resources text:@""];
    if (self) {
        _type = type;
        
        // Set type-specific image index
        self.imageIndex = [ResourceViewManager getIndexForResourceType:type];
        self.selectedImageIndex = self.imageIndex;
        
        // Find type alias and format display text
        TypeAlias *typeAlias = [MetaData findTypeAlias:type];
        
        if (typeAlias != nil) {
            self.text = [NSString stringWithFormat:@"%@ (%@) (%ld)",
                        [typeAlias name],
                        [typeAlias shortName],
                        (long)[resources count]];
        } else {
            // Fallback if no type alias found
            self.text = [NSString stringWithFormat:@"0x%08X (%ld)",
                        type,
                        (long)[resources count]];
        }
    }
    return self;
}

// MARK: - Comparison (override parent)

- (NSComparisonResult)compare:(ResourceTreeNodeExt *)other {
    if (other == nil) {
        return NSOrderedDescending;
    }
    
    return [self.text compare:other.text];
}

// MARK: - Description

- (NSString *)description {
    return [NSString stringWithFormat:@"ResourceTreeTypeNodeExt: %@ (Type: 0x%08X, Resources: %ld)",
            self.text, self.type, (long)[self.resources count]];
}

@end
