//
//  DBPFIndexUtility.m
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

#import "DBPFIndexUtility.h"
#import <CoreFoundation/CoreFoundation.h>

@implementation DBPFIndexUtil

+ (NSUInteger)computeIndexCountWithFileData:(NSData *)data
                                indexOffset:(uint64_t)indexOffset
                                  indexSize:(uint64_t)indexSize
                                  entrySize:(NSUInteger)entrySize
                      offsetFieldInEntryAt:(NSUInteger)offsetFieldOffset
                        sizeFieldInEntryAt:(NSUInteger)sizeFieldOffset
{
    const uint64_t fileLen = (uint64_t)data.length;
    if (entrySize == 0 || indexOffset == 0 || indexOffset >= fileLen) return 0;

    // 1) If header indexSize looks sane, prefer it.
    if (indexSize > 0 && indexOffset + indexSize <= fileLen && (indexSize % entrySize) == 0) {
        return (NSUInteger)(indexSize / entrySize);
    }

    // 2) Fallback: compute from remaining bytes to EOF (common rescue for bad indexSize).
    uint64_t maxCountFromEOF = (fileLen - indexOffset) / entrySize;
    if (maxCountFromEOF == 0) return 0;

    // 3) Light validation scan to avoid false positives.
    //    We ONLY read the per-entry offset+size fields and ensure they point inside the file.
    //    NOTE: These fields are 32-bit little-endian in SimPE DBPF index entries.
    const uint64_t scanLimitCount = (maxCountFromEOF > 16384) ? 16384 : maxCountFromEOF; // cap for speed/safety
    uint64_t lastDataEnd = 0;

    for (uint64_t i = 0; i < scanLimitCount; i++) {
        uint64_t pos = indexOffset + i * entrySize;
        if (pos + entrySize > fileLen) { // truncated entry
            return (NSUInteger)i;
        }

        if (pos + MAX(offsetFieldOffset, sizeFieldOffset) + 4 > fileLen) {
            return (NSUInteger)i;
        }

        uint32_t offLE = 0, sizeLE = 0;
        [data getBytes:&offLE range:NSMakeRange((NSUInteger)(pos + offsetFieldOffset), 4)];
        [data getBytes:&sizeLE range:NSMakeRange((NSUInteger)(pos + sizeFieldOffset), 4)];
        // Little-endian to host
        uint32_t off = CFSwapInt32LittleToHost(offLE);
        uint32_t siz = CFSwapInt32LittleToHost(sizeLE);

        // Basic sanity: offset+size must be inside file and non-overflowing
        uint64_t dataEnd = (uint64_t)off + (uint64_t)siz;
        if (siz == 0 || off >= fileLen || dataEnd > fileLen) {
            return (NSUInteger)i; // stop at first obviously bad entry
        }
        // Optional: ensure entries don't go backwards; tolerate equals for duplicates
        if (i > 0 && dataEnd + 16 < lastDataEnd) {
            return (NSUInteger)i; // something’s weird, bail at the start of weirdness
        }
        if (dataEnd > lastDataEnd) lastDataEnd = dataEnd;
    }

    // If we got here, the first scanLimitCount entries look sane. Use max available.
    return (NSUInteger)maxCountFromEOF;
}

@end
#import <Foundation/Foundation.h>
