//
//  IWrapperInfo.h
//  MacSimpe
//
//  Created by Catherine Gramze on 7/30/25.
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
#import <AppKit/AppKit.h>

/**
 * Contains Human Readable Information about a Wrapper
 * @remarks Never Implement a new Version of this Interface, use AbstractWrapperInfo as starting Point for a new Implementation. Otherwise the Loader Wrapper loader won't load the Image Index correct!
 */
@protocol IWrapperInfo <NSObject>

// MARK: - Properties

/**
 * The Name of this Wrapper
 */
@property (nonatomic, readonly, copy) NSString *name;

/**
 * The Description of this Wrapper
 */
@property (nonatomic, readonly, copy) NSString *wrapperDescription;

/**
 * The Author of this Wrapper
 */
@property (nonatomic, readonly, copy) NSString *author;

/**
 * The Version of this Wrapper
 */
@property (nonatomic, readonly) NSInteger version;

/**
 * Returns a Unique ID for this Wrapper
 */
@property (nonatomic, readonly) uint64_t uid;

/**
 * Returns a Icon that should be presented for that resource
 */
@property (nonatomic, readonly) NSImage *icon;

/**
 * Returns the Index of the Wrapper icon in the ImageList of the Registry
 */
@property (nonatomic, readonly) NSInteger iconIndex;

@end
