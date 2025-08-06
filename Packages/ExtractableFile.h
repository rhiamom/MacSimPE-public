//
//  ExtractableFile.h
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
#import "File.h"

@class PackedFileDescriptor;
@class BinaryReader;

/// Extends the Package Files for Extraction Methods
@interface ExtractableFile : File

/// Constructor for the class
/// @param br The BinaryReader representing the Package File
- (instancetype)initWithBinaryReader:(BinaryReader *)br;

/// Constructor for the class
/// @param filename The filename of the package file
- (instancetype)initWithFilename:(NSString *)filename;

/// Extracts the content of a packed file and returns them as NSData
/// @param pfd The PackedFileDescriptor
/// @return The NSData representing the PackedFile
- (NSData *)extract:(PackedFileDescriptor *)pfd;

/// Stores NSData to a file
/// @param filename The filename
/// @param data The NSData representing the PackedFile. If nil and pfd is not nil, the PackedFile will be loaded with extract.
/// @param pfd The description of the file, or nil. If not nil an additional XML file will be created representing the information like TypeId, SubId, Instance and Group.
/// @param meta Set NO if you do not want to create the Meta XML File
- (void)savePackedFile:(NSString *)filename data:(NSData *)data descriptor:(PackedFileDescriptor *)pfd withMeta:(BOOL)meta;

/// Generates a Package XML File containing all informations needed to recreate the Package
/// @return The Package Content as XML encoded string
- (NSString *)generatePackageXML;

/// Generates a Package XML File containing all informations needed to recreate the Package
/// @param includeHeader YES if you want to generate the xml Header
/// @return The Package Content as XML encoded string
- (NSString *)generatePackageXMLWithHeader:(BOOL)includeHeader;

/// Generates a Package XML File containing all informations needed to recreate the Package
/// @param filename The filename for the file
- (void)generatePackageXMLToFile:(NSString *)filename;

@end

