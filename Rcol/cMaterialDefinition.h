//
//  cMaterialDefinition.h
//  MacSimpe
//
//  Created by Catherine Gramze on 8/30/25.
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
#import <AppKit/AppKit.h>
#import "AbstractRcolBlock.h"
#import "IScenegraphBlock.h"

@class BinaryReader, BinaryWriter, Rcol, Vector2, Vector3, Vector4, PropertyParser;

NS_ASSUME_NONNULL_BEGIN

// MARK: - MaterialDefinitionProperty

/**
 * Property item for material definitions
 */
@interface MaterialDefinitionProperty : NSObject

// MARK: - Properties
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *value;

// MARK: - Initialization
- (instancetype)init;

// MARK: - Serialization
- (void)unserialize:(BinaryReader *)reader;
- (void)serialize:(BinaryWriter *)writer;

// MARK: - Value Conversion
- (double)toValue;
- (Vector2 *)toVector2;
- (Vector3 *)toVector3;
- (Vector4 *)toVector4;
- (NSArray<NSNumber *> *)toFloatArray;
- (NSColor *)toRGB;
- (NSColor *)toARGB;

@end

// MARK: - MaterialDefinition

/**
 * Material Definition RCOL Block
 */
@interface MaterialDefinition : AbstractRcolBlock <IScenegraphBlock>

// MARK: - Properties

/**
 * File description
 */
@property (nonatomic, copy) NSString *fileDescription;

/**
 * Material type
 */
@property (nonatomic, copy) NSString *materialType;

/**
 * Array of material properties
 */
@property (nonatomic, strong) NSArray<MaterialDefinitionProperty *> *properties;

/**
 * String listing array
 */
@property (nonatomic, strong) NSMutableArray<NSString *> *listing;

// MARK: - Class Properties

/**
 * Property parser for known properties
 */
@property (class, nonatomic, strong, readonly) PropertyParser *propertyParser;

// MARK: - Initialization

/**
 * Constructor
 * @param parent The parent RCOL object
 */
- (instancetype)initWithParent:(Rcol *)parent;

// MARK: - Property Management

/**
 * Find a property by name
 * @param name The property name
 * @return The property or empty property if not found
 */
- (MaterialDefinitionProperty *)findProperty:(NSString *)name;

/**
 * Get a property by name
 * @param name The property name
 * @return The property or empty property if not found
 */
- (MaterialDefinitionProperty *)getProperty:(NSString *)name;

/**
 * Add a new property
 * @param property The property to add
 * @remarks If the property already exists, its value will be overwritten
 */
- (void)addProperty:(MaterialDefinitionProperty *)property;

/**
 * Add a new property
 * @param property The property to add
 * @param allowDuplicate YES to allow duplicate property names
 * @remarks If allowDuplicate is NO and the property already exists, its value will be overwritten
 */
- (void)addProperty:(MaterialDefinitionProperty *)property allowDuplicate:(BOOL)allowDuplicate;

// MARK: - Utility Methods

/**
 * Sort properties in alphabetical order
 */
- (void)sort;

// MARK: - Import/Export

/**
 * Export material definition properties to XML file
 * @param filename The filename to write to
 */
- (void)exportProperties:(NSString *)filename;

/**
 * Import material definition properties, replacing current ones
 * @param filename The name of the file to import
 */
- (void)importProperties:(NSString *)filename;

/**
 * Merge material definition properties - adds, overwrites or retains as appropriate
 * @param filename The name of the file to merge
 */
- (void)mergeProperties:(NSString *)filename;

// MARK: - IScenegraphBlock Protocol

/**
 * Get referenced items for this block
 * @param refMap Dictionary to store referenced items
 * @param parentGroup The parent group ID
 */
- (void)referencedItems:(NSMutableDictionary *)refMap parentGroup:(uint32_t)parentGroup;

@end

NS_ASSUME_NONNULL_END
