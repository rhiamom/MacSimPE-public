//
//  AbstractWrapperInfo.h
//  MacSimpe
//
//  Created by Catherine Gramze on 7/26/25.
//
/**************************************************************************
 *   Copyright (C) 2005 by Ambertation                                     *
 *   quaxi@ambertation.de                                                  *
 *                                                                         *
 *   Swift translation Copyright (C) 2025 by GramzeSweatShop               *
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
#import "IWrapperInfo.h"

#if TARGET_OS_MAC
#import <AppKit/AppKit.h>
typedef NSImage PlatformImage;
#else
#import <UIKit/UIKit.h>
typedef UIImage PlatformImage;
#endif

/**
 * Wrapper information implementation
 */
@interface AbstractWrapperInfo : NSObject <IWrapperInfo>

/**
 * The Name of this Wrapper
 */
@property (nonatomic, readonly, copy) NSString *name;

/**
 * The Description of this Wrapper
 */
@property (nonatomic, readonly, copy) NSString *wrapperDescription;

/**
 * The Author of this Wrapper
 */
@property (nonatomic, readonly, copy) NSString *author;

/**
 * The Version of this Wrapper
 */
@property (nonatomic, readonly, assign) NSInteger version;

/**
 * Returns an Icon that should be presented for that resource
 */
@property (nonatomic, strong) PlatformImage *icon;

/**
 * Returns/Sets the Index of the Wrapper icon in the ImageList of the Registry
 * @remarks Do never set this yourself, it is set automatically by the Registry
 */
@property (nonatomic, assign) NSInteger iconIndex;

/**
 * Returns a Unique ID for this Wrapper
 */
@property (nonatomic, readonly, assign) uint64_t uid;

/**
 * Constructor
 * @param name Name of the Wrapper
 * @param author The Author of the Wrapper
 * @param description Description of the Wrapper
 * @param version Version of the Wrapper
 * @param icon Icon that represents this Resource
 */
- (instancetype)initWithName:(NSString *)name
                      author:(NSString *)author
                 description:(NSString *)description
                     version:(NSInteger)version
                        icon:(PlatformImage *)icon;

/**
 * Constructor
 * @param name Name of the Wrapper
 * @param author The Author of the Wrapper
 * @param description Description of the Wrapper
 * @param version Version of the Wrapper
 */
- (instancetype)initWithName:(NSString *)name
                      author:(NSString *)author
                 description:(NSString *)description
                     version:(NSInteger)version;

/**
 * Dispose of resources
 */
- (void)dispose;

@end
