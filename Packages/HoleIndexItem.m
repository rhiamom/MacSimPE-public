//
//  HoleIndexItem.m
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

#import "HoleIndexItem.h"

@implementation HoleIndexItem

/**
 * Constructor
 */
- (instancetype)init {
    self = [super init];
    if (self) {
        _offset = 0;
        _size = 0;
    }
    return self;
}

/**
 * Constructor
 * @param offset the offset of the Hole
 * @param size the size of the Hole
 */
- (instancetype)initWithOffset:(uint32_t)offset size:(int32_t)size {
    self = [super init];
    if (self) {
        _offset = offset;
        _size = size;
    }
    return self;
}

/**
 * return true if the passed Hole Index directly follows this one
 * @param hii another Hole
 * @returns true if it follows the current Hole
 */
- (BOOL)isMyFollowup:(HoleIndexItem *)hii {
    return (self.offset + self.size) == hii.offset;
}

@end
