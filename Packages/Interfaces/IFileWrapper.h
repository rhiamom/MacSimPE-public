//
//  IPluginFileWrapper.h
//  MacSimpe
//
//  Created by Catherine Gramze on 7/26/25.
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
#import "IPackedFileWrapper.h"

@protocol IFileWrapper;

/**
 * This Interface Implements Methods that must be provided by a PackedFile Wrapper
 */
@protocol IFileWrapper <IPackedFileWrapper>

/**
 * Returns a List of all File Types this Class can Handle
 */
@property (nonatomic, readonly, strong) NSArray<NSNumber *> *assignableTypes;

/**
 * Some Handler identify their Target Files not with a Type but by a PackedFile Header, when this
 * Method does not return an empty Array, all files starting with the passed Signature will
 * be passed to the Handler
 */
@property (nonatomic, readonly, strong) NSData *fileSignature;

@end

/**
 * This Interface has to be implemented by Wrappers that allow multiple Instance
 */
@protocol IMultiplePackedFileWrapper <NSObject>

/**
 * Returns a new Instance of the calling Class
 * @return a new Instance of the calling Type
 */
- (id<IFileWrapper>)activate;

/**
 * Returns a list of Arguments that should be passed to the Constructor during activate
 * @return Array of constructor arguments
 */
- (NSArray *)getConstructorArguments;

@end
