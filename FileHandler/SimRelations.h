//
//  SimRelations.h
//  MacSimpe
//
//  Created by Catherine Gramze on 2/7/26.
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

@class SRel;

NS_ASSUME_NONNULL_BEGIN

@interface SimRelations : NSObject

/// Optional display name tag (C# NameTag)
@property (nonatomic, copy, nullable) NSString *nameTag;

/// Outbound (index 0): relation of “your sim” to the other sim
@property (nonatomic, readonly, strong, nullable) SRel *outboundRelation;

/// Inbound (index 1): relation of the other sim to “your sim”
@property (nonatomic, readonly, strong, nullable) SRel *inboundRelation;

/// rels must contain exactly 2 items: [0]=outbound, [1]=inbound
- (instancetype)initWithRelations:(NSArray<SRel *> *)rels;

/// Commits user data (C# SynchronizeUserData)
- (void)synchronizeUserData;

@end
NS_ASSUME_NONNULL_END
