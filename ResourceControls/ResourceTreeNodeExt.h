///
//  ResourceTreeNodeExt.h
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
#import "ResourceViewManagerHelpers.h"

/**
 * Extended tree node for displaying resource hierarchies
 * Used in ResourceTreeViewExt for organizing resources by type, group, or instance
 */
@interface ResourceTreeNodeExt : NSObject

// MARK: - Properties
@property (nonatomic, strong, readonly) ResourceNameList *resources;
@property (nonatomic, assign, readonly) uint64_t nodeID;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, assign) NSInteger imageIndex;
@property (nonatomic, assign) NSInteger selectedImageIndex;

// MARK: - Tree Structure
@property (nonatomic, weak) ResourceTreeNodeExt *parent;
@property (nonatomic, strong) NSMutableArray<ResourceTreeNodeExt *> *children;

// MARK: - Initialization
- (instancetype)initWithID:(uint64_t)nodeID
                 resources:(ResourceNameList *)resources
                      text:(NSString *)text;

// MARK: - Tree Navigation
- (NSInteger)numberOfChildren;
- (ResourceTreeNodeExt *)childAtIndex:(NSInteger)index;
- (void)addChild:(ResourceTreeNodeExt *)child;
- (void)removeChild:(ResourceTreeNodeExt *)child;

// MARK: - Display
- (NSString *)displayName;

// MARK: - Comparison
- (NSComparisonResult)compare:(ResourceTreeNodeExt *)other;

@end
