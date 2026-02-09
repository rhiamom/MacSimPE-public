//
//  IPackedFileDescriptor.h
//  MacSimpe
//
//  Created by Catherine Gramze on 7/25/25.
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
#import "IPackedFileDescriptorBasic.h"

typedef void (^PackedFileChanged)(id packedFileDescriptor);

/**
 * Interface for PackedFile Descriptors
 */
@protocol IPackedFileDescriptor <IPackedFileDescriptorBasic>

/**
 * Creates a clone of this Object
 * @returns The Cloned Object
 */
- (id<IPackedFileDescriptor>)clone;

/**
 * Same as userData, but you can decide if the changedUserData Event gets fired
 * @param data the new UserData
 * @param fire true if you want to fire a changedUserData Event.
 * @remarks In Most scenarios you probably want to use userData directly instead of this Method.
 * It is basically only called intern by FileWrappers
 */
- (void)setUserData:(NSData *)data fire:(BOOL)fire;

/**
 * Returns the default string displayed in the ResourceList
 */
- (NSString *)toResListString;

// Events as block properties
@property (nonatomic, copy) PackedFileChanged changedUserData;
@property (nonatomic, copy) PackedFileChanged changedData;
@property (nonatomic, copy) PackedFileChanged closed;
@property (nonatomic, copy) void (^descriptionChanged)(void);
@property (nonatomic, copy) void (^deleted)(void);

@end
