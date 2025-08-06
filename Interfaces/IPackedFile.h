//
//  IPackedFile.h
//  MacSimpe
//
//  Created by Catherine Gramze on 7/28/25.
//
/***************************************************************************
 *   Copyright (C) 2005 by Ambertation                                     *
 *   quaxi@ambertation.de                                                  *
 *                                                                         *
 *   Objective-C translation Copyright (C) 2025 by GramzeSweatShop        *
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
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
 ***************************************************************************/

#import <Foundation/Foundation.h>

/// Protocol for a PackedFile object
@protocol IPackedFile <NSObject>

/// Returns true if the PackedFile is compressed
@property (nonatomic, readonly) BOOL isCompressed;

/// Returns the size of the file
@property (nonatomic, readonly) NSInteger size;

/// Returns the compression signature
@property (nonatomic, readonly) uint16_t signature;

/// Returns the uncompressed filesize
@property (nonatomic, readonly) uint32_t uncompressedSize;

/// Returns the plain file data (might be compressed)
/// @discussion All header informations are cut from the data, so you really get the data stored in the PackedFile
@property (nonatomic, readonly) NSData *data;

/// Returns the plain file data (might be compressed)
/// @discussion Header informations are included
@property (nonatomic, readonly) NSData *plainData;

/// Returns the plain file data. If the packed file is compressed it will be decompressed
@property (nonatomic, readonly) NSData *uncompressedData;

/// Returns the plain file data stream. If the packed file is compressed it will be decompressed
@property (nonatomic, readonly) NSInputStream *uncompressedStream;

/// Returns the uncompressed data
/// @param maxsize Maximum number of bytes that should be returned
/// @return The uncompressed data with size limit
- (NSData *)getUncompressedDataWithMaxSize:(NSInteger)maxsize;

/// Returns a part of the decompressed file
/// @param size Max number of bytes to decompress
/// @return The decompressed data
- (NSData *)decompressWithSize:(int64_t)size;

@end
#ifndef IPackedFile_h
#define IPackedFile_h


#endif /* IPackedFile_h */
