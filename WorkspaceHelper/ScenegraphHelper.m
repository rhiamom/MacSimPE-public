//
//  ScenegraphHelper.m
//  MacSimpe
//
//  Created by Catherine Gramze on 8/14/25.
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

#import "ScenegraphHelper.h"
#import "IPackedFileDescriptor.h"
#import "PackedFileDescriptor.h"
#import "Hashes.h"
#import "MetaData.h"

// MARK: - Constants

const uint32_t SCENEGRAPH_GMND = 0x4D444E47; // MetaData.GMND
const uint32_t SCENEGRAPH_TXMT = 0x544D5854; // MetaData.TXMT
const uint32_t SCENEGRAPH_TXTR = 0x52545854; // MetaData.TXTR
const uint32_t SCENEGRAPH_LIFO = 0x4F46494C; // MetaData.LIFO
const uint32_t SCENEGRAPH_ANIM = 0x4D494E41; // MetaData.ANIM
const uint32_t SCENEGRAPH_SHPE = 0x45504853; // MetaData.SHPE
const uint32_t SCENEGRAPH_CRES = 0x53455243; // MetaData.CRES
const uint32_t SCENEGRAPH_GMDC = 0x43444D47; // MetaData.GMDC
const uint32_t SCENEGRAPH_MMAT = 0x54414D4D; // MetaData.MMAT

NSString * const SCENEGRAPH_GMND_PACKAGE = @"gmnd_package";
NSString * const SCENEGRAPH_MMAT_PACKAGE = @"mmat_package";

@implementation ScenegraphHelper

// MARK: - Utility Methods

+ (id<IPackedFileDescriptor>)buildPfdWithFilename:(NSString *)filename
                                             type:(uint32_t)type
                                     defaultGroup:(uint32_t)defaultGroup {
    
    NSString *name = [Hashes stripHashFromName:filename];
    PackedFileDescriptor *pfd = [[PackedFileDescriptor alloc] init];
    
    [pfd setType:type];
    [pfd setGroup:[Hashes getHashGroupFromName:filename defaultGroup:defaultGroup]];
    [pfd setInstance:[Hashes instanceHash:name]];
    [pfd setSubType:[Hashes subTypeHash:name]];
    [pfd setFilename:filename];
    
    // Set empty user data
    [pfd setUserData:[[NSData alloc] init]];
    
    return pfd;
}

@end
