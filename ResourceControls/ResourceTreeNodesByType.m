//
//  ResourceTreeNodesByType.m
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

#import "ResourceTreeNodesByType.h"
#import "ResourceTreeNodeExt.h"
#import "ResourceMaps.h"
#import "Localization.h"
#import "ResourceTreeTypeNodeExt.h"

@implementation ResourceTreeNodesByType

// MARK: - IResourceTreeNodeBuilder Implementation

- (ResourceTreeNodeExt *)buildNodes:(ResourceMaps *)maps {
    ResourceTreeNodeExt *rootNode = [[ResourceTreeNodeExt alloc] initWithID:0
                                                                   resources:[maps everything]
                                                                        text:[[Localization shared] getString:@"AllRes"]];
    
    [ResourceTreeNodesByType addTypes:[maps byType] toNode:rootNode];
    
    [rootNode setImageIndex:0];
    return rootNode;
}

// MARK: - Type Building Methods

+ (void)addTypes:(IntMap *)map toNode:(ResourceTreeNodeExt *)node {
    NSMutableArray<ResourceTreeNodeExt *> *nodeList = [[NSMutableArray alloc] init];
    
    // Create a type node for each type in the map
    for (NSNumber *typeKey in [map allKeys]) {
        uint32_t type = [typeKey unsignedIntValue];
        ResourceNameList *resourceList = [map objectForKey:typeKey];
        
        // Use the specialized ResourceTreeTypeNodeExt for type nodes
        ResourceTreeTypeNodeExt *typeNode = [[ResourceTreeTypeNodeExt alloc] initWithResources:resourceList
                                                                                           type:type];
        [nodeList addObject:typeNode];
    }
    
    // Sort nodes and add to parent
    [nodeList sortUsingComparator:^NSComparisonResult(ResourceTreeNodeExt *obj1, ResourceTreeNodeExt *obj2) {
        return [obj1 compare:obj2];
    }];
    
    for (ResourceTreeNodeExt *childNode in nodeList) {
        [node addChild:childNode];
    }
}

@end
