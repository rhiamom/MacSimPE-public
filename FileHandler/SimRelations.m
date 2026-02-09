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

#import "SimRelations.h"
#import "SRelWrapper.h"

@interface SimRelations ()
@property (nonatomic, strong) NSArray<SRel *> *rels;
@end

@implementation SimRelations

- (instancetype)initWithRelations:(NSArray<SRel *> *)rels {
    self = [super init];
    if (self) {
        _rels = rels ?: @[];
    }
    return self;
}

- (SRel *)outboundRelation {
    return (self.rels.count > 0) ? self.rels[0] : nil;
}

- (SRel *)inboundRelation {
    return (self.rels.count > 1) ? self.rels[1] : nil;
}

- (NSString *)description {
    if (self.nameTag != nil) return self.nameTag;
    return [super description];
}

- (void)synchronizeUserData {
    if (self.rels.count > 0 && self.rels[0] != nil) [self.rels[0] synchronizeUserData];
    if (self.rels.count > 1 && self.rels[1] != nil) [self.rels[1] synchronizeUserData];
}

@end
