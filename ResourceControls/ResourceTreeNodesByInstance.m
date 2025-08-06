//
//  ResourceTreeNodesByInstance.m
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

#import "ResourceTreeNodesByInstance.h"
#import "ResourceTreeNodeExt.h"
#import "ResourceMaps.h"
#import "ResourceTreeNodesByGroup.h"
#import "NamedPackedFileDescriptor.h"
#import "Helper.h"
#import "Localization.h"

@implementation ResourceTreeNodesByInstance

// MARK: - IResourceTreeNodeBuilder Implementation

- (ResourceTreeNodeExt *)buildNodes:(ResourceMaps *)maps {
    ResourceTreeNodeExt *rootNode = [[ResourceTreeNodeExt alloc] initWithID:0
                                                                   resources:[maps everything]
                                                                        text:[[Localization shared] getString:@"AllRes"]];
    
    [ResourceTreeNodesByInstance addInstances:[maps byInstance]
                                       toNode:rootNode
                                    showTypes:YES
                                   showGroups:YES];
    
    [rootNode setImageIndex:0];
    return rootNode;
}

// MARK: - Instance Building Methods

+ (void)addInstances:(LongMap *)map
              toNode:(ResourceTreeNodeExt *)node
           showTypes:(BOOL)showTypes
          showGroups:(BOOL)showGroups {
    
    NSMutableArray<ResourceTreeNodeExt *> *nodeList = [[NSMutableArray alloc] init];
    
    // Iterate through all instances in the map
    for (NSNumber *instanceKey in [map allKeys]) {
        uint64_t instance = [instanceKey unsignedLongLongValue];
        ResourceNameList *resourceList = [map objectForKey:instanceKey];
        
        NSString *instanceText = [NSString stringWithFormat:@"0x%016llX", instance];
        ResourceTreeNodeExt *instanceNode = [[ResourceTreeNodeExt alloc] initWithID:instance
                                                                           resources:resourceList
                                                                                text:instanceText];
        
        if (showGroups) {
            ResourceTreeNodeExt *groupNode = [[ResourceTreeNodeExt alloc] initWithID:instance
                                                                           resources:resourceList
                                                                                text:@"Groups"];
            [ResourceTreeNodesByInstance addSubNodesForGroups:groupNode resources:resourceList];
            [instanceNode addChild:groupNode];
        }
        
        if (showTypes) {
            ResourceTreeNodeExt *typeNode = [[ResourceTreeNodeExt alloc] initWithID:instance
                                                                          resources:resourceList
                                                                               text:@"Types"];
            [ResourceTreeNodesByGroup addSubNodesForTypes:typeNode resources:resourceList];
            [instanceNode addChild:typeNode];
        }
        
        [nodeList addObject:instanceNode];
    }
    
    // Sort nodes and add to parent
    [nodeList sortUsingComparator:^NSComparisonResult(ResourceTreeNodeExt *obj1, ResourceTreeNodeExt *obj2) {
        return [obj1 compare:obj2];
    }];
    
    for (ResourceTreeNodeExt *childNode in nodeList) {
        [node addChild:childNode];
    }
}

// MARK: - Sub-Node Building Methods

+ (void)addSubNodesForGroups:(ResourceTreeNodeExt *)node
                   resources:(ResourceNameList *)resources {
    
    IntMap *groupMap = [[IntMap alloc] init];
    
    // Group resources by group
    for (NamedPackedFileDescriptor *pfd in resources) {
        uint32_t group = [[pfd descriptor] group];
        NSNumber *groupKey = @(group);
        
        ResourceNameList *groupList = [groupMap objectForKey:groupKey];
        if (groupList == nil) {
            groupList = [[ResourceNameList alloc] init];
            [groupMap setObject:groupList forKey:groupKey];
        }
        
        [groupList addObject:pfd];
    }
    
    // Use ResourceTreeNodesByGroup to add the group nodes
    // Note: showTypes and showInstances are both NO to avoid infinite recursion
    [ResourceTreeNodesByGroup addGroups:groupMap
                                 toNode:node
                              showTypes:NO
                          showInstances:NO];
}

@end
