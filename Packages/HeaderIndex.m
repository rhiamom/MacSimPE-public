//
//  HeaderIndex.m
//  MacSimpe
//
//  Created by Catherine Gramze on 7/25/25.
//
/***************************************************************************
 *   Copyright (C) 2005 by Ambertation                                     *
 *   quaxi@ambertation.de                                                  *
 *                                                                         *
 *   Swift translation Copyright (C) 2025 by GramzeSweatShop               *
 *   rhiamom@mac.com                                                       *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program, if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
 ***************************************************************************/

#import "HeaderIndex.h"
#import "IPackageHeader.h"
#import "HeaderData.h"
#import "MetaData.h"

@implementation HeaderIndex

- (instancetype)initWithHeader:(id<IPackageHeader>)hd {
    self = [super init];
    if (self) {
        _parent = hd;
        _iType = 0;
    }
    return self;
}

/**
 * returns the Index Type of the File
 * @remarks This value should be 7
 */
- (int32_t)iType {
    return _iType;
}

- (void)setType:(int32_t)iType {
    _iType = iType;
}

- (int32_t)itemSize {
    if ([self.parent indexType] == ptLongFileIndex) {
        return 6 * 4;
    } else if ([self.parent indexType] == ptShortFileIndex) {
        return 5 * 4;
    }
    return [super itemSize];
}

- (void)useInParent {
    if (self.parent == nil) return;
    
    if ([self.parent isKindOfClass:[HeaderData class]]) {
        HeaderData *hd = (HeaderData *)self.parent;
        hd.index = self;
    }
}


@end
