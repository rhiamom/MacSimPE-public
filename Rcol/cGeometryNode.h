//
//  cGeometryNode.h
//  MacSimpe
//
//  Created by Catherine Gramze on 9/12/25.
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

@class ObjectGraphNode;
@class SGResource;
@class BinaryReader;
@class BinaryWriter;
@class Rcol;
@protocol IRcolBlock;

/**
 * Zusammenfassung für cGeometryNode.
 */
@interface GeometryNode : AbstractRcolBlock

// MARK: - Properties

/**
 * The ObjectGraphNode associated with this geometry
 */
@property (nonatomic, strong) ObjectGraphNode *objectGraphNode;

/**
 * Unknown value 1
 */
@property (nonatomic, assign) int16_t unknown1;

/**
 * Unknown value 2
 */
@property (nonatomic, assign) int16_t unknown2;

/**
 * Unknown value 3
 */
@property (nonatomic, assign) uint8_t unknown3;

/**
 * Number of blocks stored
 */
@property (nonatomic, readonly) NSInteger count;

/**
 * Array of IRcolBlock objects
 */
@property (nonatomic, strong) NSMutableArray<id<IRcolBlock>> *blocks;

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
 * @remarks
 * Be sure that the Position of the stream is Proper on
 * return (i.e. must point to the first Byte after your actual File)
 */
- (void)serialize:(BinaryWriter *)writer;

// MARK: - Tab Management

/**
 * You can use this to setup the Controls on a TabPage before it is displayed
 */
- (void)initTabPage;

/**
 * Extend the tab control with additional tabs
 * @param tabView The tab view to extend
 */
- (void)extendTabView:(NSTabView *)tabView;

// MARK: - Shape Referencing

/**
 * Returns the RCOL which lists this Resource in its ReferencedFiles Attribute
 * @returns nil or the RCOL Resource
 */
- (Rcol *)findReferencingShpe;

/**
 * Returns the RCOL which lists this Resource in its ReferencedFiles Attribute
 * @returns nil or the RCOL Resource
 * @remarks This Version will not Load the FileTable!
 */
- (Rcol *)findReferencingShpeNoLoad;

// MARK: - Memory Management

/**
 * Dispose of resources
 */
- (void)dispose;

@end
