//
//  LifoUI.h
//  MacSimpe
//
//  Created by Catherine Gramze on 8/28/25.
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
#import "IPackedFileUI.h"

@class LifoForm;
@protocol IFileWrapper;

NS_ASSUME_NONNULL_BEGIN

/**
 * This class is used to fill the UI for this FileType with Data
 */
@interface LifoUI : NSObject <IPackedFileUI>

// MARK: - Properties

/**
 * Holds a reference to the Form containing the UI Panel
 */
@property (nonatomic, strong) LifoForm *form;

// MARK: - Initialization

/**
 * Constructor for the Class
 */
- (instancetype)init;

@end

NS_ASSUME_NONNULL_END
