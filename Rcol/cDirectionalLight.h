//
//  cDirectionalLight.h
//  MacSimpe
//
//  Created by Catherine Gramze on 9/15/25.
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

@class StandardLightBase;
@class LightT;
@class ReferentNode;
@class ObjectGraphNode;
@class BinaryReader;
@class BinaryWriter;
@class Rcol;

/**
 * Zusammenfassung für StandardLightBase.
 */
@interface DirectionalLight : AbstractRcolBlock

// MARK: - Properties

@property (nonatomic, strong) StandardLightBase *standardLightBase;
@property (nonatomic, strong) LightT *lightT;
@property (nonatomic, strong) ReferentNode *referentNode;
@property (nonatomic, strong) ObjectGraphNode *objectGraphNode;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) float val1;
@property (nonatomic, assign) float val2;
@property (nonatomic, assign) float red;
@property (nonatomic, assign) float green;
@property (nonatomic, assign) float blue;

// MARK: - Initialization

- (instancetype)initWithParent:(Rcol *)parent;

// MARK: - IRcolBlock Protocol Methods

- (void)unserialize:(BinaryReader *)reader;
- (void)serialize:(BinaryWriter *)writer;
- (void)dispose;

// MARK: - UI Management

- (void)extendTabView:(NSTabView *)tabView;

@end
