//
//  AbstractFactory.h
//  MacSimpe
//
//  Created by Catherine Gramze on 7/26/25.
//
/***************************************************************************
 *   Copyright (C) 2005 by Ambertation                                     *
 *   quaxi@ambertation.de                                                  *
 *                                                                         *
 *   Objective C translation Copyright (C) 2025 by GramzeSweatShop               *
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
 *   along with this program, if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
 **************************************************************************/

#import <Foundation/Foundation.h>
#import "IWrapperFactory.h"

@protocol IWrapperRegistry, IProviderRegistry, IWrapper;

/**
 * Lists all Plugins (=FileType Wrappers) available in this Package
 *
 * @remarks
 * knownWrappers has to return a list of all Plugins provided by this Library.
 * If a Plugin isn't returned, SimPe won't recognize it!
 */
@interface AbstractWrapperFactory : NSObject <IWrapperFactory>

/**
 * Holds a reference to the Registry this Plugin was last registered to (can be nil!)
 */
@property (nonatomic, weak) id<IWrapperRegistry> linkedRegistry;

/**
 * Holds a reference to available Providers (i.e. for Sim Names or Images)
 */
@property (nonatomic, weak) id<IProviderRegistry> linkedProvider;

/**
 * Returns a List of all available Plugins in this Package
 * @return A List of all provided Plugins (=FileType Wrappers)
 */
@property (nonatomic, readonly, strong) NSArray<id<IWrapper>> *knownWrappers;

/**
 * The filename of this factory
 */
@property (nonatomic, readonly, copy) NSString *fileName;

@end
