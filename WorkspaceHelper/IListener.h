//
//  IListener.h
//  MacSimpe
//
//  Created by Catherine Gramze on 8/14/25.
//
// ***************************************************************************
// *   Copyright (C) 2005 by Ambertation                                     *
// *   quaxi@ambertation.de                                                  *
// *   Copyright (C) 2008 by Peter L Jones                                   *
// *   pljones@users.sf.net                                                  *
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
#import "ITool.h"

@class ResourceEventArgs;

/// <summary>
/// defines a Listener
/// </summary>
@protocol IListener <IToolPlugin>

/// <summary>
/// This EventHandler will be connected to the ChangeResource Event of the Caller, you can set
/// the Enabled State here
/// </summary>
/// <param name="sender"></param>
/// <param name="e"></param>
/// <returns>
/// Should always return true for listeners.
/// Tools displayed in a Menu or ActionList, should only return true, when they are
/// enabled for the passed Selection and package
/// </returns>
- (void)selectionChangedHandler:(id)sender resourceEventArgs:(ResourceEventArgs *)e;

@end

// MARK: - Listeners Collection

@interface Listeners : NSObject <NSFastEnumeration>

// MARK: - Properties
@property (nonatomic, strong, readonly) NSMutableArray *list;

// MARK: - Initialization
- (instancetype)init;

// MARK: - Collection Management
- (BOOL)contains:(id<IListener>)listener;
- (NSInteger)count;
- (void)addListener:(id<IListener>)listener;
- (void)removeListener:(id<IListener>)listener;
- (void)removeAllListeners;

// MARK: - Indexers
- (id<IListener>)objectAtIndex:(NSInteger)index;
- (void)setObject:(id<IListener>)listener atIndex:(NSInteger)index;
- (id<IListener>)objectAtIndexedSubscript:(NSInteger)index;
- (void)setObject:(id<IListener>)listener atIndexedSubscript:(NSInteger)index;

@end
