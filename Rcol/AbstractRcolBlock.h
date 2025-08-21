//
//  AbstractRcolBlock.h
//  MacSimpe
//
//  Created by Catherine Gramze on 8/15/25
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
#import "IRcolBlock.h"

@class SGResource;
@class Rcol;
@class BinaryReader;
@class BinaryWriter;

/**
 * You need to implement this to provide a new RCOL Block
 */
@interface AbstractRcolBlock : NSObject <IRcolBlock>

// MARK: - Protected Properties
@property (nonatomic, strong) SGResource *sgres;
@property (nonatomic, assign) uint32_t version;
@property (nonatomic, weak) Rcol *parent;
@property (nonatomic, assign) uint32_t blockId;
@property (nonatomic, strong) NSString *blockName;

// MARK: - IRcolBlock Protocol Properties
@property (nonatomic, strong) SGResource *nameResource;
@property (nonatomic, assign) BOOL changed;
@property (nonatomic, readonly) NSViewController *viewController;
@property (nonatomic, readonly) NSViewController *resourceViewController;
@property (nonatomic, readonly) NSTabViewItem *tabPage;
@property (nonatomic, readonly) NSTabViewItem *resourceTabPage;
// MARK: - Initialization
- (instancetype)init;
- (instancetype)initWithParent:(Rcol *)parent;

// MARK: - Template Methods (Override in Subclasses)
- (void)initTabPage;
- (void)initResourceTabPage;

// MARK: - UI Management
- (void)addToResourceTabControl:(NSTabView *)tabView comboBox:(NSComboBox *)comboBox;
- (void)addToTabControl:(NSTabView *)tabView;
- (void)extendTabView:(NSTabView *)tabView;

// MARK: - Static Factory Methods
+ (id<IRcolBlock>)createWithType:(Class)type parent:(Rcol *)parent;
+ (id<IRcolBlock>)createWithType:(Class)type parent:(Rcol *)parent blockId:(uint32_t)blockId;

// MARK: - Instance Factory Methods
- (id<IRcolBlock>)create;
- (id<IRcolBlock>)createWithId:(uint32_t)blockId;

// MARK: - Registration
- (NSString *)registerInListing:(NSMutableDictionary *)listing;

// MARK: - Parent Search
- (Rcol *)findReferencingParent:(uint32_t)type;
- (Rcol *)findReferencingParentNoLoad:(uint32_t)type;

// MARK: - IRcolBlock Protocol Methods (Abstract)
- (void)unserialize:(BinaryReader *)reader;
- (void)serialize:(BinaryWriter *)writer;
- (void)refresh;
- (void)dispose;

@end
