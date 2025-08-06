//
//  ResourceTreeNodesByGroup.m
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

#import "ResourceTreeNodesByGroup.h"
#import "ResourceTreeNodeExt.h"
#import "ResourceMaps.h"
#import "ResourceTreeNodesByType.h"
#import "ResourceTreeNodesByInstance.h"
#import "NamedPackedFileDescriptor.h"
#import "Helper.h"
#import "Localization.h"

@implementation ResourceTreeNodesByGroup

// MARK: - IResourceTreeNodeBuilder Implementation

- (ResourceTreeNodeExt *)buildNodes:(ResourceMaps *)maps {
    ResourceTreeNodeExt *rootNode = [[ResourceTreeNodeExt alloc] initWithID:0
                                                                   resources:[maps everything]
                                                                        text:[[Localization shared] getString:@"AllRes"]];
    
    [ResourceTreeNodesByGroup addGroups:[maps byGroup]
                                 toNode:rootNode
                              showTypes:YES
                          showInstances:YES];
    
    [rootNode setImageIndex:0];
    return rootNode;
}

// MARK: - Group Building Methods

+ (void)addGroups:(IntMap *)map
           toNode:(ResourceTreeNodeExt *)node
        showTypes:(BOOL)showTypes
    showInstances:(BOOL)showInstances {
    
    NSMutableArray<ResourceTreeNodeExt *> *nodeList = [[NSMutableArray alloc] init];
    
    // Iterate through all groups in the map
    for (NSNumber *groupKey in [map allKeys]) {
        uint32_t group = [groupKey unsignedIntValue];
        ResourceNameList *resourceList = [map objectForKey:groupKey];
        
        NSString *groupText = [NSString stringWithFormat:@"0x%08X", group];
        ResourceTreeNodeExt *groupNode = [[ResourceTreeNodeExt alloc] initWithID:group
                                                                        resources:resourceList
                                                                             text:groupText];
        
        if (showTypes) {
            ResourceTreeNodeExt *typeNode = [[ResourceTreeNodeExt alloc] initWithID:group
                                                                           resources:resourceList
                                                                                text:@"Types"];
            [ResourceTreeNodesByGroup addSubNodesForTypes:typeNode resources:resourceList];
            [groupNode addChild:typeNode];
        }
        
        if (showInstances) {
            ResourceTreeNodeExt *instanceNode = [[ResourceTreeNodeExt alloc] initWithID:group
                                                                               resources:resourceList
                                                                                    text:@"Instances"];
            [ResourceTreeNodesByGroup addSubNodesForInstances:instanceNode resources:resourceList];
            [groupNode addChild:instanceNode];
        }
        
        [nodeList addObject:groupNode];
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

+ (void)addSubNodesForTypes:(ResourceTreeNodeExt *)node
                  resources:(ResourceNameList *)resources {
    
    IntMap *typeMap = [[IntMap alloc] init];
    
    // Group resources by type
    for (NamedPackedFileDescriptor *pfd in resources) {
        uint32_t type = [[pfd descriptor] type];
        NSNumber *typeKey = @(type);
        
        ResourceNameList *typeList = [typeMap objectForKey:typeKey];
        if (typeList == nil) {
            typeList = [[ResourceNameList alloc] init];
            [typeMap setObject:typeList forKey:typeKey];
        }
        
        [typeList addObject:pfd];
    }
    
    // Use ResourceTreeNodesByType to add the type nodes
    [ResourceTreeNodesByType addTypes:typeMap toNode:node];
}

+ (void)addSubNodesForInstances:(ResourceTreeNodeExt *)node
                      resources:(ResourceNameList *)resources {
    
    LongMap *instanceMap = [[LongMap alloc] init];
    
    // Group resources by long instance
    for (NamedPackedFileDescriptor *pfd in resources) {
        uint64_t longInstance = [[pfd descriptor] longInstance];
        NSNumber *instanceKey = @(longInstance);
        
        ResourceNameList *instanceList = [instanceMap objectForKey:instanceKey];
        if (instanceList == nil) {
            instanceList = [[ResourceNameList alloc] init];
            [instanceMap setObject:instanceList forKey:instanceKey];
        }
        
        [instanceList addObject:pfd];
    }
    
    // Use ResourceTreeNodesByInstance to add the instance nodes
    [ResourceTreeNodesByInstance addInstances:instanceMap
                                       toNode:node
                                    showTypes:NO
                                showInstances:NO];
}

@end
