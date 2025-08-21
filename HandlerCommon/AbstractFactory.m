//
//  AbstractFactory.m
//  MacSimpe
//
//  Created by Catherine Gramze on 7/26/25.
//
/***************************************************************************
 *   Copyright (C) 2005 by Ambertation                                                                                                    *
 *   quaxi@ambertation.de                                                                                                                *
 *                                                                         *
 *   Objective C  translation Copyright (C) 2025 by GramzeSweatShop                                                              *
 *   rhiamom@mac.com                                                                                                                           *
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
 ***************************************************************************/

#import "AbstractFactory.h"
#import "IWrapperRegistry.h"
#import "IProviderRegistry.h"
#import "IWrapper.h"

@implementation AbstractWrapperFactory

#pragma mark - IWrapperFactory Methods

- (NSArray<id<IWrapper>> *)knownWrappers {
    // Default implementation returns empty array
    // Subclasses should override this to return their specific wrappers
    return @[];
}

- (NSString *)fileName {
    // In Objective-C, we can get the bundle identifier or main bundle path
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *bundleIdentifier = [bundle bundleIdentifier];
    
    if (bundleIdentifier) {
        return bundleIdentifier;
    } else {
        // Fallback to bundle path if no identifier
        return [bundle bundlePath];
    }
}

@end
