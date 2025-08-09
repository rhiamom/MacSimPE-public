//
//  IRcolBlock.h
//  MacSimpe
//
//  Created by Catherine Gramze on 8/8/25.
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
#import <Cocoa/Cocoa.h>

@class BinaryReader;
@class BinaryWriter;
@class SGResource;
@class Rcol;

/**
 * You need to implement this to provide a new RCOL Block
 */
@protocol IRcolBlock <NSObject>

/**
 * Unserializes a BinaryStream into the Attributes of this Instance
 * @param reader The Stream that contains the FileData
 */
- (void)unserialize:(BinaryReader *)reader;

/**
 * Serializes the Attributes stored in this Instance to the BinaryStream
 * @param writer The Stream the Data should be stored to
 * @remarks Be sure that the Position of the stream is Proper on
 * return (i.e. must point to the first Byte after your actual File)
 */
- (void)serialize:(BinaryWriter *)writer;

/**
 * Creates a new Instance
 * @param blockId The block ID for the new instance
 * @returns A new IRcolBlock instance
 */
- (id<IRcolBlock>)createWithId:(uint32_t)blockId;

/**
 * Creates a new Instance with the default Block ID
 * @returns A new IRcolBlock instance
 */
- (id<IRcolBlock>)create;

/**
 * Registers the Object in the given Dictionary
 * @param listing The dictionary to register in
 * @returns The Name of the Class Type
 */
- (NSString *)registerInListing:(NSMutableDictionary *)listing;

/**
 * Name of the Block containing the Object
 */
@property (nonatomic, strong) NSString *blockName;

/**
 * Returns the ID used for this Block
 */
@property (nonatomic, assign) uint32_t blockId;

/**
 * Returns / Sets the cSGResource of this Block, or null if none is available
 */
@property (nonatomic, strong) SGResource *nameResource;

/**
 * Returns a view controller that contains a GUI for this Element
 */
@property (nonatomic, readonly) NSViewController *viewController;

/**
 * Returns a view controller that contains a GUI for the first Block in a RCOL Resource
 */
@property (nonatomic, readonly) NSViewController *resourceViewController;

/**
 * Update the displayed Data
 */
- (void)refresh;

/**
 * Adds more view controllers (which are needed to process the Class) to the tab view
 * @param tabView The NSTabView the view controllers will be added to
 */
- (void)extendTabView:(NSTabView *)tabView;

/**
 * Data was changed
 */
@property (nonatomic, assign) BOOL changed;

/**
 * Returns the RCOL which lists this Resource in its ReferencedFiles Attribute
 * @param type The Type of the resource you are looking for
 * @returns nil or the RCOL Resource
 */
- (Rcol *)findReferencingParent:(uint32_t)type;

@end
