//
//  ScenegraphHelper.h
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

#import <Foundation/Foundation.h>

@protocol IPackedFileDescriptor;

/// <summary>
/// Some Helper Methods for the Scenegraph Files
/// </summary>
@interface ScenegraphHelper : NSObject

// MARK: - Constant Definitions

/// Scenegraph file type constants (from MetaData)
extern const uint32_t SCENEGRAPH_GMND;
extern const uint32_t SCENEGRAPH_TXMT;
extern const uint32_t SCENEGRAPH_TXTR;
extern const uint32_t SCENEGRAPH_LIFO;
extern const uint32_t SCENEGRAPH_ANIM;
extern const uint32_t SCENEGRAPH_SHPE;
extern const uint32_t SCENEGRAPH_CRES;
extern const uint32_t SCENEGRAPH_GMDC;
extern const uint32_t SCENEGRAPH_MMAT;

/// Package name constants
extern NSString * const SCENEGRAPH_GMND_PACKAGE;
extern NSString * const SCENEGRAPH_MMAT_PACKAGE;

// MARK: - Utility Methods

/// <summary>
/// Returns a PackedFile Descriptor for the given filename
/// </summary>
/// <param name="filename">The filename to build descriptor for</param>
/// <param name="type">The file type</param>
/// <param name="defaultGroup">The default group if not found in filename</param>
/// <returns>A PackedFileDescriptor instance</returns>
+ (id<IPackedFileDescriptor>)buildPfdWithFilename:(NSString *)filename
                                             type:(uint32_t)type
                                     defaultGroup:(uint32_t)defaultGroup;

@end
