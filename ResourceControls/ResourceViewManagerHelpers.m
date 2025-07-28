//
//  ResourceViewManagerHelperClasses.m
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

#import "ResourceViewManagerHelpers.h"
#import "NamedPackedFileDescriptor.h"
#import "IPackedFileDescriptor.h"
#import 

// MARK: - Resource List Implementation

@implementation ResourceList

// ResourceList inherits all functionality from NSMutableArray
// No additional implementation needed for basic list operations

@end

// MARK: - Descriptor Sort Implementation

@implementation DescriptorSort

- (instancetype)init {
    self = [super init];
    if (self) {
        _column = SortColumnOffset;
        _ascending = YES;
    }
    return self;
}

- (NSComparisonResult)compare:(NamedPackedFileDescriptor *)x
                         with:(NamedPackedFileDescriptor *)y {
    
    NSComparisonResult result = NSOrderedSame;
    
    if (self.ascending) {
        switch (self.column) {
            case SortColumnName:
                result = [[x getRealName] compare:[y getRealName]];
                break;
                
            case SortColumnType:
            case SortColumnExtension: {
                uint32_t xType = [[x descriptor] type];
                uint32_t yType = [[y descriptor] type];
                if (xType < yType) result = NSOrderedAscending;
                else if (xType > yType) result = NSOrderedDescending;
                else result = NSOrderedSame;
                break;
            }
            
            case SortColumnGroup: {
                uint32_t xGroup = [[x descriptor] group];
                uint32_t yGroup = [[y descriptor] group];
                if (xGroup < yGroup) result = NSOrderedAscending;
                else if (xGroup > yGroup) result = NSOrderedDescending;
                else result = NSOrderedSame;
                break;
            }
            
            case SortColumnInstanceHi: {
                uint32_t xSubType = [[x descriptor] subType];
                uint32_t ySubType = [[y descriptor] subType];
                if (xSubType < ySubType) result = NSOrderedAscending;
                else if (xSubType > ySubType) result = NSOrderedDescending;
                else result = NSOrderedSame;
                break;
            }
            
            case SortColumnInstanceLo: {
                uint32_t xInstance = [[x descriptor] instance];
                uint32_t yInstance = [[y descriptor] instance];
                if (xInstance < yInstance) result = NSOrderedAscending;
                else if (xInstance > yInstance) result = NSOrderedDescending;
                else result = NSOrderedSame;
                break;
            }
            
            case SortColumnInstance: {
                uint64_t xLongInstance = [[x descriptor] longInstance];
                uint64_t yLongInstance = [[y descriptor] longInstance];
                if (xLongInstance < yLongInstance) result = NSOrderedAscending;
                else if (xLongInstance > yLongInstance) result = NSOrderedDescending;
                else result = NSOrderedSame;
                break;
            }
            
            case SortColumnOffset: {
                NSInteger xOffset = [[x descriptor] offset];
                NSInteger yOffset = [[y descriptor] offset];
                if (xOffset < yOffset) result = NSOrderedAscending;
                else if (xOffset > yOffset) result = NSOrderedDescending;
                else result = NSOrderedSame;
                break;
            }
            
            case SortColumnSize: {
                NSInteger xSize = [[x descriptor] size];
                NSInteger ySize = [[y descriptor] size];
                if (xSize < ySize) result = NSOrderedAscending;
                else if (xSize > ySize) result = NSOrderedDescending;
                else result = NSOrderedSame;
                break;
            }
        }
    } else {
        // Descending order - reverse the comparison
        switch (self.column) {
            case SortColumnName:
                result = [[y getRealName] compare:[x getRealName]];
                break;
                
            case SortColumnType:
            case SortColumnExtension: {
                uint32_t xType = [[x descriptor] type];
                uint32_t yType = [[y descriptor] type];
                if (yType < xType) result = NSOrderedAscending;
                else if (yType > xType) result = NSOrderedDescending;
                else result = NSOrderedSame;
                break;
            }
            
            case SortColumnGroup: {
                uint32_t xGroup = [[x descriptor] group];
                uint32_t yGroup = [[y descriptor] group];
                if (yGroup < xGroup) result = NSOrderedAscending;
                else if (yGroup > xGroup) result = NSOrderedDescending;
                else result = NSOrderedSame;
                break;
            }
            
            case SortColumnInstanceHi: {
                uint32_t xSubType = [[x descriptor] subType];
                uint32_t ySubType = [[y descriptor] subType];
                if (ySubType < xSubType) result = NSOrderedAscending;
                else if (ySubType > xSubType) result = NSOrderedDescending;
                else result = NSOrderedSame;
                break;
            }
            
            case SortColumnInstanceLo: {
                uint32_t xInstance = [[x descriptor] instance];
                uint32_t yInstance = [[y descriptor] instance];
                if (yInstance < xInstance) result = NSOrderedAscending;
                else if (yInstance > xInstance) result = NSOrderedDescending;
                else result = NSOrderedSame;
                break;
            }
            
            case SortColumnInstance: {
                uint64_t xLongInstance = [[x descriptor] longInstance];
                uint64_t yLongInstance = [[y descriptor] longInstance];
                if (yLongInstance < xLongInstance) result = NSOrderedAscending;
                else if (yLongInstance > xLongInstance) result = NSOrderedDescending;
                else result = NSOrderedSame;
                break;
            }
            
            case SortColumnOffset: {
                NSInteger xOffset = [[x descriptor] offset];
                NSInteger yOffset = [[y descriptor] offset];
                if (yOffset < xOffset) result = NSOrderedAscending;
                else if (yOffset > xOffset) result = NSOrderedDescending;
                else result = NSOrderedSame;
                break;
            }
            
            case SortColumnSize: {
                NSInteger xSize = [[x descriptor] size];
                NSInteger ySize = [[y descriptor] size];
                if (ySize < xSize) result = NSOrderedAscending;
                else if (ySize > xSize) result = NSOrderedDescending;
                else result = NSOrderedSame;
                break;
            }
        }
    }
    
    return result;
}

@end

// MARK: - Resource Name List Implementation

@implementation ResourceNameList

- (instancetype)init {
    self = [super init];
    if (self) {
        _sorter = [[DescriptorSort alloc] init];
    }
    return self;
}

- (void)sortByColumn:(SortColumn)column ascending:(BOOL)ascending {
    self.sorter.column = column;
    self.sorter.ascending = ascending;
    
    [self sortUsingComparator:^NSComparisonResult(NamedPackedFileDescriptor *obj1,
                                                  NamedPackedFileDescriptor *obj2) {
        return [self.sorter compare:obj1 with:obj2];
    }];
}

@end
