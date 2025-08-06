//
//  PackedFile.h
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
#import "IPackedFile.h"

/// A file within a package
@interface PackedFile : NSObject <IPackedFile>

// Compression constants
extern const NSInteger MAX_OFFSET;
extern const NSInteger MAX_COPY_COUNT;

/// The size of the PackedFile header
@property (nonatomic, assign) NSInteger headersize;

/// Returns true if the PackedFile is compressed
@property (nonatomic, readonly) BOOL isCompressed;

@property (nonatomic, readonly) uint32_t uncompressedSize;

/// Size of the compressed file
@property (nonatomic, assign) NSInteger size;

/// Compression signature
@property (nonatomic, assign) uint16_t signature;

/// Data start offset
@property (nonatomic, assign) uint32_t datastart;

/// File size
@property (nonatomic, assign) uint32_t datasize;

/// The file data
@property (nonatomic, strong) NSData *data;

/// Uncompressed size
@property (nonatomic, assign) uint32_t uncsize;

/// Returns the plain file data (might be compressed)
@property (nonatomic, readonly) NSData *plainData;

/// Returns the plain file data. If the packed file is compressed it will be decompressed
@property (nonatomic, readonly) NSData *uncompressedData;

/// Returns the uncompressed data stream
@property (nonatomic, readonly) NSInputStream *uncompressedStream;

/// Returns or sets the compression strength
@property (class, nonatomic, assign) NSInteger compressionStrength;

/// Constructor for the class
/// @param content The content of the packed file
- (instancetype)initWithData:(NSData *)content;

/// Constructor for the class with stream
/// @param stream The stream containing the file data
- (instancetype)initWithInputStream:(NSInputStream *)stream;

/// Returns the uncompressed data with a maximum size limit
/// @param maxsize Maximum number of bytes that should be returned
/// @return The uncompressed data
- (NSData *)getUncompressedDataWithMaxSize:(NSInteger)maxsize;

/// Returns a part of the decompressed file
/// @param size Max number of bytes to decompress
/// @return The decompressed data
- (NSData *)decompressWithSize:(int64_t)size;

/// Uncompresses the file data passed
/// @param data Relevant file data
/// @param targetSize Size of the uncompressed data
/// @param offset File offset, where we should start to decompress from
/// @return The uncompressed file data
- (NSData *)uncompress:(NSData *)data targetSize:(uint32_t)targetSize offset:(NSInteger)offset;

/// Uncompresses the file data passed with size limit
/// @param data Relevant file data
/// @param targetSize Size of the uncompressed data
/// @param offset File offset, where we should start to decompress from
/// @param maxSize Maximum number of bytes that should be read from the resource
/// @return The uncompressed file data
- (NSData *)uncompress:(NSData *)data targetSize:(uint32_t)targetSize offset:(NSInteger)offset maxSize:(NSInteger)maxSize;

/// Compresses the passed content
/// @param data The content
/// @return The compressed data (including the header)
+ (NSData *)compress:(NSData *)data;

/// Returns the stream that holds the given resource
/// @param stream The input stream
/// @param dataLength Length of data to read
/// @param targetSize Size of the uncompressed data
/// @param offset File offset where to start decompression
/// @return The memory stream containing the decompressed data
+ (NSData *)uncompressStream:(NSInputStream *)stream dataLength:(NSInteger)dataLength targetSize:(uint32_t)targetSize offset:(NSInteger)offset;

@end
