//
//  IOpcodeProvider.h
//  MacSimpe
//
//  Created by Catherine Gramze on 8/19/25.
//
/***************************************************************************
 *   Copyright (C) 2005 by Ambertation                                     *
 *   quaxi@ambertation.de                                                  *
 *                                                                         *
 *   Objective-C translation Copyright (C) 2025 by GramzeSweatShop         *
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
#import "ICommonPackage.h"

@protocol IAlias;
@protocol IScenegraphFileIndexItem;

/**
 * Interface to obtain the SimFamilyNames Alias List from the Type Registry
 */
@protocol IOpcodeProvider <ICommonPackage>

/**
 * Returns the the name of the Function
 * @param opcode The opcode of the primitive
 * @returns The name of the Primitive
 */
- (NSString *)findName:(uint16_t)opcode;

/**
 * Returns the List of known Primitives
 */
@property (nonatomic, readonly, strong) NSArray *storedPrimitives;

/**
 * Returns the the name of the Expression Operator
 * @param op Numerical Value of the Operator
 * @returns The Name of The Operator
 */
- (NSString *)findExpressionOperator:(uint8_t)op;

/**
 * Returns the the name of a Data Owner
 * @param owner Numerical Value of the Owner
 * @returns The Name
 */
- (NSString *)findExpressionDataOwners:(uint8_t)owner;

/**
 * Returns the the name of a Motive
 * @param nr Numerical Value
 * @returns The Name
 */
- (NSString *)findMotives:(uint16_t)nr;

/**
 * Returns the the a Memory Alias
 * @param guid Guid of the Memory
 * @returns An IAlias Object describing the Memory
 * @remarks
 * The Tag returns an Object Array:
 *    0: IPackedFileDescriptor for the Object File in the BasePackage
 */
- (id<IAlias>)findMemory:(uint32_t)guid;

/**
 * Returns a list of all known memories
 */
@property (nonatomic, readonly, strong) NSDictionary *storedMemories;

/**
 * returns null or a Matching global BHAV File
 * @param opcode the Opcode of the BHAV
 * @returns The Descriptor for the Bhav File in the BasePackage
 */
- (id<IScenegraphFileIndexItem>)loadGlobalBHAV:(uint16_t)opcode;

/**
 * Returns the Bhav for a Semi Global Opcode
 * @param opcode The Opcode
 * @param group The group of the SemiGlobal
 * @returns The Descriptor of the Bhaf File in the Base Package or null
 */
- (id<IScenegraphFileIndexItem>)loadSemiGlobalBHAV:(uint16_t)opcode group:(uint32_t)group;

/**
 * Returns the the name of all Fields in an Objd File
 * @param type The Objects type
 */
- (NSArray *)objdDescription:(uint16_t)type;

/**
 * Returns a list of all known Objf Lines
 */
@property (nonatomic, readonly, strong) NSArray *storedObjfLines;

/**
 * Returns the names Operators in Expression Primitives
 */
@property (nonatomic, readonly, strong) NSArray *storedExpressionOperators;

/**
 * Returns the names of the Data in an Expression Primitive
 */
@property (nonatomic, readonly, strong) NSArray *storedDataNames;

/**
 * Returns the List of known Motives
 */
@property (nonatomic, readonly, strong) NSArray *storedMotives;

/**
 * Call this to manually initialize the BasePackage
 */
- (void)loadPackage;

@end
#ifndef IOpcodeProvider_h
#define IOpcodeProvider_h


#endif /* IOpcodeProvider_h */
