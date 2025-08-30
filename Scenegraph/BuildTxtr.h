//
//  BuildTxtr.h
//  MacSimpe
//
//  Created by Catherine Gramze on 8/24/25.
//
//****************************************************************************
// *   Copyright (C) 2005 by Ambertation                                     *
// *   quaxi@ambertation.de                                                  *
//*   Copyright (C) 2008 by Peter L Jones                                    *
// *   pljones@users.sf.net                                                  *
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
//****************************************************************************

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "WrapperFactory.h" // For ICommandLine protocol

@class ImageData, DDSData, MipMap, MipMapBlock;

/**
 * Command line interface for building TXTR files
 */
@interface BuildTxtr : NSObject <ICommandLine>

// MARK: - Static TXTR Building Methods

/**
 * Assemble a Picture File from image file
 * @param imageData The ImageData object to populate
 * @param filename Path to the image file
 * @param size Target texture size
 * @param levels Number of mip map levels
 * @param format Texture format
 */
+ (void)loadTxtr:(ImageData *)imageData
        filename:(NSString *)filename
            size:(NSSize)size
          levels:(NSInteger)levels
          format:(TxtrFormats)format;

/**
 * Assemble a Picture File from NSImage
 * @param imageData The ImageData object to populate
 * @param sourceImage The source NSImage
 * @param size Target texture size
 * @param levels Number of mip map levels
 * @param format Texture format
 */
+ (void)loadTxtr:(ImageData *)imageData
           image:(NSImage *)sourceImage
            size:(NSSize)size
          levels:(NSInteger)levels
          format:(TxtrFormats)format;

/**
 * Assemble a Picture File from DDS data
 * @param imageData The ImageData object to populate
 * @param data Array of DDSData objects
 */
+ (void)loadDds:(ImageData *)imageData data:(NSArray<DDSData *> *)data;

// MARK: - ICommandLine Implementation

/**
 * Parse command line arguments
 * @param argv Array of command line arguments
 * @return YES if parsing was successful
 */
- (BOOL)parse:(NSArray<NSString *> *)argv;

/**
 * Get help text for this command
 * @return Array of help strings
 */
- (NSArray<NSString *> *)help;

/**
 * Execute the command line interface
 */
- (void)execute;

/**
 * Get command name/identifier
 */
@property (nonatomic, readonly, copy) NSString *commandName;

@end
