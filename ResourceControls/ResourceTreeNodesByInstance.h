//
//  ResourceTreeNodesByInstance.h
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

#import <Foundation/Foundation.h>
#import "AResourceTreeNodeBuilder.h"

@class ResourceTreeNodeExt;
@class ResourceMaps;

/**
 * Tree node builder that organizes resources by instance
 * Creates a hierarchy: All Resources -> Instances -> Groups/Types
 */
@interface ResourceTreeNodesByInstance : AResourceTreeNodeBuilder

// MARK: - IResourceTreeNodeBuilder Implementation
- (ResourceTreeNodeExt *)buildNodes:(ResourceMaps *)maps;

// MARK: - Instance Building Methods
+ (void)addInstances:(LongMap *)map
              toNode:(ResourceTreeNodeExt *)node
           showTypes:(BOOL)showTypes
          showGroups:(BOOL)showGroups;

// MARK: - Sub-Node Building Methods
+ (void)addSubNodesForGroups:(ResourceTreeNodeExt *)node
                   resources:(ResourceNameList *)resources;

@end
