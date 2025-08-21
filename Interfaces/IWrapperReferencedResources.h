//
//  IWrapperReferencedResources.h
//  MacSimpe
//
//  Created by Catherine Gramze on 8/15/25.
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

#import <Foundation/Foundation.h>

@protocol IPackedFileDescriptorSimple;

// MARK: - ReferenceList

/**
 * A specialized array for holding IPackedFileDescriptorSimple objects
 */
@interface ReferenceList : NSMutableArray<id<IPackedFileDescriptorSimple>>

// NSMutableArray provides all the functionality we need
// This is just a specialized type for better type safety

@end

// MARK: - IReferenceList Protocol

/**
 * Protocol for reference lists (equivalent to IList<IPackedFileDescriptorSimple>)
 */
@protocol IReferenceList <NSObject>

// Array-like access methods
- (NSUInteger)count;
- (id<IPackedFileDescriptorSimple>)objectAtIndex:(NSUInteger)index;
- (void)addObject:(id<IPackedFileDescriptorSimple>)object;
- (void)removeObjectAtIndex:(NSUInteger)index;
- (void)insertObject:(id<IPackedFileDescriptorSimple>)object atIndex:(NSUInteger)index;

// Optional: Additional convenience methods
- (BOOL)containsObject:(id<IPackedFileDescriptorSimple>)object;
- (void)removeObject:(id<IPackedFileDescriptorSimple>)object;
- (void)removeAllObjects;

@end

// MARK: - IWrapperReferencedResources Protocol

/**
 * Interface for wrappers that can provide referenced resources
 */
@protocol IWrapperReferencedResources <NSObject>

/**
 * Returns the list of referenced resources
 * @returns Array of referenced file descriptors
 */
- (id<IReferenceList>)referencedResources;

@end
