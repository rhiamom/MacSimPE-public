//
//  Hashes.h
//  MacSimpe
//
//  Created by Catherine Gramze on 7/28/25.
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

@interface Hashes : NSObject

// Constants
extern const uint32_t CRC24_SEED;
extern const uint32_t CRC24_POLY;
extern const uint32_t CRC32_SEED;
extern const uint32_t CRC32_POLY;

// Core hash methods
+ (int64_t)crc24WithSeed:(uint32_t)seed poly:(uint32_t)poly octets:(NSArray<NSNumber *> *)octets;
+ (uint64_t)toLongFromBytes:(NSData *)input;

// File hash methods
+ (uint32_t)fileGroupHash:(NSString *)filename;
+ (uint32_t)groupHash:(NSString *)name;
+ (uint32_t)instanceHash:(NSString *)filename;
+ (uint32_t)subTypeHash:(NSString *)filename;
+ (uint32_t)getCrc32:(NSString *)s;
+ (uint32_t)getCrc24:(NSString *)s;

// Filename utilities
+ (NSString *)stripHashFromName:(NSString *)filename;
+ (uint32_t)getHashGroupFromName:(NSString *)filename defaultGroup:(uint32_t)defgroup;
+ (NSString *)assembleHashedFileName:(uint32_t)hash filename:(NSString *)filename;

@end

@interface UserVerification : NSObject

+ (uint32_t)generateUserId:(uint32_t)guid username:(NSString *)username password:(NSString *)password;
+ (BOOL)validUserId:(uint32_t)userId username:(NSString *)username password:(NSString *)password;
+ (uint32_t)getUserGuid:(uint32_t)userId;
+ (BOOL)haveUserId;
+ (BOOL)haveValidUserId;
+ (uint32_t)userId;

@end
