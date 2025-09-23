//
//  Fami.h
//  MacSimpe
//
//  Created by Catherine Gramze on 9/19/25.
//
// ***************************************************************************
// *   Copyright (C) 2005 by Ambertation                                     *
// *   quaxi@ambertation.de                                                  *
// *                                                                         *
// *   Objective-C translation Copyright (C) 2025                            *
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
#import <AppKit/AppKit.h>
#import "UIBase.h"
#import "IPackedFileUI.h"

@protocol IFileWrapper;
@class FamiWrapper;

NS_ASSUME_NONNULL_BEGIN

/**
 * Handles packed family files UI
 */
@interface FamiUI : UIBase <IPackedFileUI>

// MARK: - UI Elements

@property (nonatomic, weak) IBOutlet NSView *famiPanel;
@property (nonatomic, weak) IBOutlet NSTextField *tbname;
@property (nonatomic, weak) IBOutlet NSTextField *tbmoney;
@property (nonatomic, weak) IBOutlet NSTextField *tbfamily;
@property (nonatomic, weak) IBOutlet NSTextField *tblotinst;
@property (nonatomic, weak) IBOutlet NSTextField *tbalbum;
@property (nonatomic, weak) IBOutlet NSTextField *tbflag;
@property (nonatomic, weak) IBOutlet NSTextField *tbsubhood;
@property (nonatomic, weak) IBOutlet NSTextField *tbvac;
@property (nonatomic, weak) IBOutlet NSTextField *tbblot;
@property (nonatomic, weak) IBOutlet NSTextField *tbbmoney;
@property (nonatomic, weak) IBOutlet NSTextField *tbcafood1;
@property (nonatomic, weak) IBOutlet NSTextField *tbcares;
@property (nonatomic, weak) IBOutlet NSTextField *tbcaunk;
@property (nonatomic, weak) IBOutlet NSTableView *lbmembers;
@property (nonatomic, weak) IBOutlet NSComboBox *cbsims;
@property (nonatomic, weak) IBOutlet NSBox *gbCastaway;

// MARK: - Properties

@property (nonatomic, strong) FamiWrapper *wrapper;

// MARK: - Initialization

/**
 * Constructor
 */
- (instancetype)init;

@end

NS_ASSUME_NONNULL_END
