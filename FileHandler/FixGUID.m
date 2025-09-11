//
//  FixGUID.m
//  MacSimpe
//
//  Created by Catherine Gramze on 9/11/25.
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

#import "FixGuid.h"
#import "IPackageFile.h"
#import "IPackedFileDescriptor.h"
#import "MetaData.h"
#import "CpfWrapper.h"
#import "CpfItem.h"

@implementation GuidSet
@end

@implementation FixGuid

- (instancetype)initWithPackage:(id<IPackageFile>)package {
    self = [super init];
    if (self) {
        _package = package;
    }
    return self;
}

- (void)fixGuids:(NSArray<GuidSet *> *)guids {
    NSArray<id<IPackedFileDescriptor>> *mmatPfds = [self.package findFiles:[MetaData MMAT]];
    
    for (id<IPackedFileDescriptor> pfd in mmatPfds) {
        Cpf *mmat = [[Cpf alloc] init];
        [mmat processData:pfd package:self.package];
        
        if (guids != nil) {
            for (GuidSet *guidSet in guids) {
                if ([mmat getSaveItem:@"objectGUID"].uintegerValue == guidSet.oldGuid) {
                    [mmat getSaveItem:@"objectGUID"].uintegerValue = guidSet.guid;
                    [mmat synchronizeUserData];
                }
            }
        }
    }
}

- (void)fixGuid:(uint32_t)newGuid {
    NSArray<id<IPackedFileDescriptor>> *mmatPfds = [self.package findFiles:[MetaData MMAT]];
    
    for (id<IPackedFileDescriptor> pfd in mmatPfds) {
        Cpf *mmat = [[Cpf alloc] init];
        [mmat processData:pfd package:self.package];
        
        [mmat getSaveItem:@"objectGUID"].uintegerValue = newGuid;
        [mmat synchronizeUserData];
    }
}

@end
