//
//  ResourceViewManagerHelpers.m
//  SimPE for Mac
//
//  Created by Catherine Gramze on 6/7/25.
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

// Forward declarations only in header
@class NamedPackedFileDescriptor;
@protocol IPackedFileDescriptor;

// MARK: - Sort Column Enum

typedef NS_ENUM(NSInteger, SortColumn) {
    SortColumnName = 0,
    SortColumnGroup = 1,
    SortColumnInstanceHi = 2,
    SortColumnInstanceLo = 3,
    SortColumnOffset = 4,
    SortColumnSize = 5,
    SortColumnType = 6,
    SortColumnInstance = 7,
    SortColumnExtension = 8
};

// MARK: - Resource List

@interface ResourceList : NSMutableArray<id<IPackedFileDescriptor>>

@end

// MARK: - Descriptor Sort Helper

@interface DescriptorSort : NSObject

@property (nonatomic, assign) SortColumn column;
@property (nonatomic, assign) BOOL ascending;

- (instancetype)init;
- (NSComparisonResult)compare:(NamedPackedFileDescriptor *)x
                         with:(NamedPackedFileDescriptor *)y;

@end

// MARK: - Resource Name List

@interface ResourceNameList : NSMutableArray<NamedPackedFileDescriptor *>

@property (nonatomic, strong, readonly) DescriptorSort *sorter;

- (instancetype)init;
- (void)sortByColumn:(SortColumn)column ascending:(BOOL)ascending;

@end
