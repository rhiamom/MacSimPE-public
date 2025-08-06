//
//  PackedFile.m
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

#import "PackedFile.h"
#import "MetaData.h"
#import "Helper.h"

// Constants
const NSInteger MAX_OFFSET = 0x20000;
const NSInteger MAX_COPY_COUNT = 0x404;
static const uint16_t COMPRESS_SIGNATURE = 0xFB10;
static NSInteger _compressionStrength = 0x80;

@interface PackedFile ()
@property (nonatomic, strong) NSData *uncdata;
@property (nonatomic, strong) NSInputStream *sourceStream;
@property (nonatomic, strong) NSData *destinationData;
@end

@implementation PackedFile

+ (NSInteger)compressionStrength {
    return _compressionStrength;
}

+ (void)setCompressionStrength:(NSInteger)strength {
    _compressionStrength = strength;
}

- (instancetype)initWithData:(NSData *)content {
    self = [super init];
    if (self) {
        _data = content;
        _headersize = 0;
        _uncdata = nil;
        _sourceStream = nil;
    }
    return self;
}

- (instancetype)initWithInputStream:(NSInputStream *)stream {
    self = [super init];
    if (self) {
        _data = nil;
        _headersize = 0;
        _uncdata = nil;
        _datastart = 0;
        _sourceStream = stream;
        _destinationData = nil;
    }
    return self;
}

- (BOOL)isCompressed {
    return (self.headersize != 0) && (self.signature == COMPRESS_SIGNATURE);
}

- (NSData *)plainData {
    if (self.headersize > 0) {
        NSRange range = NSMakeRange(self.headersize, self.data.length - self.headersize);
        return [self.data subdataWithRange:range];
    } else {
        return self.data;
    }
}

- (NSInputStream *)uncompressedStream {
    if (self.destinationData == nil) {
        @synchronized(self.sourceStream) {
            [self.sourceStream setProperty:@(self.datastart) forKey:NSStreamFileCurrentOffsetKey];
            
            if (self.isCompressed) {
                self.destinationData = [[self class] uncompressStream:self.sourceStream
                                                          dataLength:self.size
                                                          targetSize:self.uncsize
                                                              offset:self.headersize];
            } else {
                NSMutableData *buffer = [NSMutableData dataWithLength:self.datasize];
                [self.sourceStream read:(uint8_t *)[buffer mutableBytes] maxLength:self.datasize];
                self.destinationData = [buffer copy];
            }
        }
    }
    
    return [NSInputStream inputStreamWithData:self.destinationData];
}

- (NSData *)uncompressedData {
    if (self.isCompressed) {
        if (self.uncdata == nil) {
            self.uncdata = [self uncompress:self.data targetSize:self.uncsize offset:self.headersize];
        }
        return self.uncdata;
    } else {
        return self.plainData;
    }
}

- (NSData *)getUncompressedDataWithMaxSize:(NSInteger)maxsize {
    if (self.isCompressed) {
        @synchronized(self.data) {
            return [self uncompress:self.data targetSize:self.uncsize offset:self.headersize maxSize:maxsize];
        }
    } else {
        return self.plainData;
    }
}

- (NSData *)decompressWithSize:(int64_t)size {
    size = MAX(size, self.uncsize);
    @synchronized(self.data) {
        return [self uncompress:self.data targetSize:(uint32_t)size offset:self.headersize];
    }
}

- (NSData *)uncompress:(NSData *)data targetSize:(uint32_t)targetSize offset:(NSInteger)offset {
    return [self uncompress:data targetSize:targetSize offset:offset maxSize:-1];
}

- (NSData *)uncompress:(NSData *)data targetSize:(uint32_t)targetSize offset:(NSInteger)offset maxSize:(NSInteger)maxSize {
    NSMutableData *uncdata = nil;
    NSInteger index = offset;
    
    @try {
        uncdata = [NSMutableData dataWithLength:targetSize];
    } @catch (NSException *exception) {
        uncdata = [NSMutableData data];
    }
    
    const uint8_t *dataBytes = (const uint8_t *)[data bytes];
    uint8_t *uncdataBytes = (uint8_t *)[uncdata mutableBytes];
    NSInteger dataLength = [data length];
    
    NSInteger uncindex = 0;
    NSInteger plaincount = 0;
    NSInteger copycount = 0;
    NSInteger copyoffset = 0;
    uint8_t cc = 0;
    uint8_t cc1 = 0;
    uint8_t cc2 = 0;
    uint8_t cc3 = 0;
    NSInteger source;
    
    @try {
        while ((index < dataLength) && (dataBytes[index] < 0xfc)) {
            cc = dataBytes[index++];
            
            if ((cc & 0x80) == 0) {
                cc1 = dataBytes[index++];
                plaincount = (cc & 0x03);
                copycount = ((cc & 0x1C) >> 2) + 3;
                copyoffset = ((cc & 0x60) << 3) + cc1 + 1;
            } else if ((cc & 0x40) == 0) {
                cc1 = dataBytes[index++];
                cc2 = dataBytes[index++];
                plaincount = (cc1 & 0xC0) >> 6;
                copycount = (cc & 0x3F) + 4;
                copyoffset = ((cc1 & 0x3F) << 8) + cc2 + 1;
            } else if ((cc & 0x20) == 0) {
                cc1 = dataBytes[index++];
                cc2 = dataBytes[index++];
                cc3 = dataBytes[index++];
                plaincount = (cc & 0x03);
                copycount = ((cc & 0x0C) << 6) + cc3 + 5;
                copyoffset = ((cc & 0x10) << 12) + (cc1 << 8) + cc2 + 1;
            } else {
                plaincount = (cc - 0xDF) << 2;
                copycount = 0;
                copyoffset = 0;
            }
            
            // Copy plain data
            for (NSInteger i = 0; i < plaincount; i++) {
                if (uncindex >= targetSize) break;
                uncdataBytes[uncindex++] = dataBytes[index++];
            }
            
            // Copy from previous data
            source = uncindex - copyoffset;
            for (NSInteger i = 0; i < copycount; i++) {
                if (uncindex >= targetSize) break;
                uncdataBytes[uncindex++] = uncdataBytes[source++];
            }
            
            // Check size limit
            if (maxSize != -1 && uncindex >= maxSize) {
                return [uncdata subdataWithRange:NSMakeRange(0, uncindex)];
            }
        }
    } @catch (NSException *ex) {
        @throw ex;
    }
    
    // Handle final bytes
    if (index < dataLength) {
        plaincount = (dataBytes[index++] & 0x03);
        for (NSInteger i = 0; i < plaincount; i++) {
            if (uncindex >= targetSize) break;
            uncdataBytes[uncindex++] = dataBytes[index++];
        }
    }
    
    return uncdata;
}

+ (NSData *)uncompressStream:(NSInputStream *)stream dataLength:(NSInteger)dataLength targetSize:(uint32_t)targetSize offset:(NSInteger)offset {
    NSMutableData *uncdata = nil;
    
    @try {
        uncdata = [NSMutableData dataWithLength:targetSize];
    } @catch (NSException *exception) {
        uncdata = [NSMutableData data];
    }
    
    uint8_t *uncdataBytes = (uint8_t *)[uncdata mutableBytes];
    
    // Skip offset bytes
    uint8_t *offsetBuffer = malloc(offset);
    [stream read:offsetBuffer maxLength:offset];
    free(offsetBuffer);
    
    NSInteger uncindex = 0;
    NSInteger plaincount = 0;
    NSInteger copycount = 0;
    NSInteger copyoffset = 0;
    uint8_t cc = 0;
    uint8_t cc1 = 0;
    uint8_t cc2 = 0;
    uint8_t cc3 = 0;
    NSInteger bytesRead = offset;
    
    @try {
        while (bytesRead < dataLength) {
            [stream read:&cc maxLength:1];
            bytesRead++;
            
            if (cc >= 0xfc) break;
            
            if ((cc & 0x80) == 0) {
                [stream read:&cc1 maxLength:1];
                bytesRead++;
                plaincount = (cc & 0x03);
                copycount = ((cc & 0x1C) >> 2) + 3;
                copyoffset = ((cc & 0x60) << 3) + cc1 + 1;
            } else if ((cc & 0x40) == 0) {
                [stream read:&cc1 maxLength:1];
                [stream read:&cc2 maxLength:1];
                bytesRead += 2;
                plaincount = (cc1 & 0xC0) >> 6;
                copycount = (cc & 0x3F) + 4;
                copyoffset = ((cc1 & 0x3F) << 8) + cc2 + 1;
            } else if ((cc & 0x20) == 0) {
                [stream read:&cc1 maxLength:1];
                [stream read:&cc2 maxLength:1];
                [stream read:&cc3 maxLength:1];
                bytesRead += 3;
                plaincount = (cc & 0x03);
                copycount = ((cc & 0x0C) << 6) + cc3 + 5;
                copyoffset = ((cc & 0x10) << 12) + (cc1 << 8) + cc2 + 1;
            } else {
                plaincount = (cc - 0xDF) << 2;
                copycount = 0;
                copyoffset = 0;
            }
            
            // Read plain data
            for (NSInteger i = 0; i < plaincount; i++) {
                uint8_t byte;
                [stream read:&byte maxLength:1];
                bytesRead++;
                uncdataBytes[uncindex++] = byte;
            }
            
            // Copy from previous data
            NSInteger source = uncindex - copyoffset;
            for (NSInteger i = 0; i < copycount; i++) {
                uncdataBytes[uncindex++] = uncdataBytes[source++];
            }
        }
    } @catch (NSException *ex) {
        @throw ex;
    }
    
    // Handle final bytes
    if (bytesRead < dataLength) {
        uint8_t finalByte;
        [stream read:&finalByte maxLength:1];
        plaincount = (finalByte & 0x03);
        
        for (NSInteger i = 0; i < plaincount; i++) {
            if (uncindex >= targetSize) break;
            uint8_t byte;
            [stream read:&byte maxLength:1];
            uncdataBytes[uncindex++] = byte;
        }
    }
    
    return uncdata;
}

+ (NSData *)compress:(NSData *)data {
    @try {
        const uint8_t *dataBytes = (const uint8_t *)[data bytes];
        NSInteger dataLength = [data length];
        
        // Contains the latest offset for a combination of two characters
        NSMutableArray *cmpmap[0x1000000];
        for (NSInteger i = 0; i < 0x1000000; i++) {
            cmpmap[i] = nil;
        }
        
        // Will contain the compressed data
        NSMutableData *cdata = [NSMutableData dataWithLength:dataLength];
        uint8_t *cdataBytes = (uint8_t *)[cdata mutableBytes];
        
        // Init variables
        NSInteger writeindex = 0;
        NSInteger lastreadindex = 0;
        NSMutableArray *indexlist = nil;
        NSInteger copyoffset = 0;
        NSInteger copycount = 0;
        NSInteger index = -1;
        BOOL end = NO;
        
        @try {
            // Begin main compression loop
            while (index < dataLength - 3) {
                // Get all compression candidates
                do {
                    index++;
                    if (index >= dataLength - 2) {
                        end = YES;
                        break;
                    }
                    
                    NSInteger mapindex = dataBytes[index] | (dataBytes[index + 1] << 0x08) | (dataBytes[index + 2] << 0x10);
                    
                    indexlist = cmpmap[mapindex];
                    if (indexlist == nil) {
                        indexlist = [NSMutableArray array];
                        cmpmap[mapindex] = indexlist;
                    }
                    [indexlist addObject:@(index)];
                } while (index < lastreadindex);
                
                if (end) break;
                
                // Find the longest repeating byte sequence
                NSInteger offsetcopycount = 0;
                NSInteger loopcount = 1;
                
                while ((loopcount < [indexlist count]) && (loopcount < _compressionStrength)) {
                    NSInteger foundindex = [[indexlist objectAtIndex:([indexlist count] - 1) - loopcount] integerValue];
                    if ((index - foundindex) >= MAX_OFFSET) break;
                    
                    loopcount++;
                    copycount = 3;
                    
                    while ((dataLength > index + copycount) &&
                           (dataBytes[index + copycount] == dataBytes[foundindex + copycount]) &&
                           (copycount < MAX_COPY_COUNT)) {
                        copycount++;
                    }
                    
                    if (copycount > offsetcopycount) {
                        offsetcopycount = copycount;
                        copyoffset = index - foundindex;
                    }
                }
                
                // Compression logic
                if (offsetcopycount < 3) offsetcopycount = 0;
                else if ((offsetcopycount < 4) && (copyoffset > 0x400)) offsetcopycount = 0;
                else if ((offsetcopycount < 5) && (copyoffset > 0x4000)) offsetcopycount = 0;
                
                // This is offset-compressible? Do the compression
                if (offsetcopycount > 0) {
                    // Plain copy
                    while ((index - lastreadindex) > 3) {
                        copycount = (index - lastreadindex);
                        while (copycount > 0x71) copycount -= 0x71;
                        copycount = copycount & 0xfc;
                        NSInteger realcopycount = (copycount >> 2);
                        
                        cdataBytes[writeindex++] = (uint8_t)(0xdf + realcopycount);
                        for (NSInteger i = 0; i < copycount; i++) {
                            cdataBytes[writeindex++] = dataBytes[lastreadindex++];
                        }
                    }
                    
                    // Offset copy
                    copycount = index - lastreadindex;
                    copyoffset--;
                    
                    if ((offsetcopycount <= 0xa) && (copyoffset < 0x400)) {
                        cdataBytes[writeindex++] = (uint8_t)((((copyoffset >> 3) & 0x60) | ((offsetcopycount - 3) << 2)) | copycount);
                        cdataBytes[writeindex++] = (uint8_t)(copyoffset & 0xff);
                    } else if ((offsetcopycount <= 0x43) && (copyoffset < 0x4000)) {
                        cdataBytes[writeindex++] = (uint8_t)(0x80 | (offsetcopycount - 4));
                        cdataBytes[writeindex++] = (uint8_t)((copycount << 6) | (copyoffset >> 8));
                        cdataBytes[writeindex++] = (uint8_t)(copyoffset & 0xff);
                    } else if ((offsetcopycount <= MAX_COPY_COUNT) && (copyoffset < MAX_OFFSET)) {
                        cdataBytes[writeindex++] = (uint8_t)(((0xc0 | ((copyoffset >> 0x0c) & 0x10)) + (((offsetcopycount - 5) >> 6) & 0x0c)) | copycount);
                        cdataBytes[writeindex++] = (uint8_t)((copyoffset >> 8) & 0xff);
                        cdataBytes[writeindex++] = (uint8_t)(copyoffset & 0xff);
                        cdataBytes[writeindex++] = (uint8_t)((offsetcopycount - 5) & 0xff);
                    } else {
                        copycount = 0;
                        offsetcopycount = 0;
                    }
                    
                    // Do the offset copy
                    for (NSInteger i = 0; i < copycount; i++) {
                        cdataBytes[writeindex++] = dataBytes[lastreadindex++];
                    }
                    lastreadindex += offsetcopycount;
                }
            }
            
            // Add remaining data
            index = dataLength;
            lastreadindex = MIN(index, lastreadindex);
            
            while ((index - lastreadindex) > 3) {
                copycount = (index - lastreadindex);
                while (copycount > 0x71) copycount -= 0x71;
                copycount = copycount & 0xfc;
                NSInteger realcopycount = (copycount >> 2);
                
                cdataBytes[writeindex++] = (uint8_t)(0xdf + realcopycount);
                for (NSInteger i = 0; i < copycount; i++) {
                    cdataBytes[writeindex++] = dataBytes[lastreadindex++];
                }
            }
            
            copycount = index - lastreadindex;
            cdataBytes[writeindex++] = (uint8_t)(0xfc + copycount);
            for (NSInteger i = 0; i < copycount; i++) {
                cdataBytes[writeindex++] = dataBytes[lastreadindex++];
            }
            
            // Create result with header
            NSMutableData *retdata = [NSMutableData dataWithLength:writeindex + 9];
            uint8_t *retdataBytes = (uint8_t *)[retdata mutableBytes];
            
            // Write size (4 bytes)
            uint32_t size = (uint32_t)[retdata length];
            memcpy(retdataBytes, &size, 4);
            
            // Write signature (2 bytes)
            uint16_t signature = COMPRESS_SIGNATURE;
            memcpy(retdataBytes + 4, &signature, 2);
            
            // Write uncompressed size (3 bytes, big endian)
            uint32_t uncSize = (uint32_t)dataLength;
            retdataBytes[6] = (uncSize >> 16) & 0xff;
            retdataBytes[7] = (uncSize >> 8) & 0xff;
            retdataBytes[8] = uncSize & 0xff;
            
            // Copy compressed data
            memcpy(retdataBytes + 9, cdataBytes, writeindex);
            
            return retdata;
        } @finally {
            // Cleanup
            for (NSInteger i = 0; i < 0x1000000; i++) {
                if (cmpmap[i] != nil) {
                    [cmpmap[i] removeAllObjects];
                    cmpmap[i] = nil;
                }
            }
        }
    } @catch (NSException *ex) {
        if ([Helper debugMode]) {
            [Helper exceptionMessage:@"Compression failed" details:[ex reason]];
        }
        @throw ex;
    }
}

@end
#import <Foundation/Foundation.h>
