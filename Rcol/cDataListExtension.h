//
//  cDataListExtension.h
//  MacSimpe
//
//  Created by Catherine Gramze on 9/18/25.
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
#import <Cocoa/Cocoa.h>
#import "AbstractRcolBlock.h"
#import "IScenegraphBlock.h"

// Forward declarations
@class Extension, ExtensionItem, BinaryReader, BinaryWriter, Rcol;

/**
 * This is the actual FileWrapper
 * @remarks The wrapper is used to (un)serialize the Data of a file into it's Attributes.
 *          So Basically it reads a BinaryStream and translates the data into some userdefine Attributes.
 */
@interface DataListExtension : AbstractRcolBlock <IScenegraphBlock>

// MARK: - Properties

/**
 * The extension object
 */
@property (nonatomic, strong, readonly) Extension *extension;

// MARK: - Initialization

/**
 * Constructor
 * @param parent The parent Rcol object
 */
- (instancetype)initWithParent:(Rcol *)parent;

// MARK: - IRcolBlock Protocol Methods

/**
 * Unserializes a BinaryStream into the Attributes of this Instance
 * @param reader The Stream that contains the FileData
 */
- (void)unserialize:(BinaryReader *)reader;

/**
 * Serializes the Attributes stored in this Instance to the BinaryStream
 * @param writer The Stream the Data should be stored to
 * @remarks Be sure that the Position of the stream is Proper on
 *          return (i.e. must point to the first Byte after your actual File)
 */
- (void)serialize:(BinaryWriter *)writer;

/**
 * You can use this to setup the Controls on a TabPage before it is displayed
 */
- (void)initTabPage;

/**
 * Extend the tab view with additional tabs
 * @param tabView The tab view to extend
 */
- (void)extendTabView:(NSTabView *)tabView;

// MARK: - IScenegraphBlock Protocol Methods

/**
 * Adds all Referenced Scenegraph Resources sorted by type of Reference
 * @param refmap Dictionary to store references, where key is reference type name and value is array of referenced files
 * @param parentgroup The parent group identifier
 * @remarks The Key is the name of the Reference Type, the value is an NSArray containing all ReferencedFiles
 */
- (void)referencedItems:(NSMutableDictionary<NSString *, NSMutableArray *> *)refmap
            parentGroup:(uint32_t)parentgroup;

// MARK: - Memory Management

/**
 * Dispose of resources
 */
- (void)dispose;

@end
