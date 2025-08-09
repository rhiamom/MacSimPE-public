//
//  DBPFIndexUtility.h
//  MacSimpe
//
//  Created by Catherine Gramze on 8/8/25.
//
// ***************************************************************************
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

NS_ASSUME_NONNULL_BEGIN
@interface DBPFIndexUtil : NSObject
/// Computes indexCount robustly. Returns 0 if it cannot determine a sane count.
+ (NSUInteger)computeIndexCountWithFileData:(NSData *)data
                                indexOffset:(uint64_t)indexOffset
                                  indexSize:(uint64_t)indexSize
                                  entrySize:(NSUInteger)entrySize
                      offsetFieldInEntryAt:(NSUInteger)offsetFieldOffset
                        sizeFieldInEntryAt:(NSUInteger)sizeFieldOffset;
@end
NS_ASSUME_NONNULL_END
#ifndef DBPFIndexUtility_h
#define DBPFIndexUtility_h


#endif /* DBPFIndexUtility_h */
