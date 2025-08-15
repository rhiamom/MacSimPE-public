//
//  WrapperBaseControl.h
//  MacSimpe
//
//  Created by Catherine Gramze on 8/14/25.
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
#import "IPackedFileUI.h"

@protocol IFileWrapper;
@class ThemeManager;

// MARK: - WrapperChangedEventArgs

@interface WrapperChangedEventArgs : NSObject

@property (nonatomic, strong, readonly) id<IFileWrapper> oldWrapper;
@property (nonatomic, strong, readonly) id<IFileWrapper> newWrapper;

- (instancetype)initWithOldWrapper:(id<IFileWrapper>)oldWrapper
                        newWrapper:(id<IFileWrapper>)newWrapper;

@end

// MARK: - WrapperBaseControl

@interface WrapperBaseControl : NSViewController <IPackedFileUI>

// MARK: - Properties
@property (nonatomic, strong) NSString *headerText;
@property (nonatomic, strong) NSColor *headBackColor;
@property (nonatomic, strong) NSColor *headForeColor;
@property (nonatomic, strong) NSFont *headFont;
@property (nonatomic, strong) NSColor *gradientColor;
@property (nonatomic, assign) NSInteger headerHeight;
@property (nonatomic, assign) BOOL canCommit;

// MARK: - UI Components
@property (nonatomic, strong) IBOutlet NSButton *btCommit;
@property (nonatomic, strong) IBOutlet NSView *contentView;

// MARK: - Wrapper Management
@property (nonatomic, strong, readonly) id<IFileWrapper> wrapper;

// MARK: - Events
@property (nonatomic, copy) void (^wrapperChangedHandler)(WrapperChangedEventArgs *args);
@property (nonatomic, copy) void (^commitHandler)(void);

// MARK: - Initialization
- (instancetype)init;

// MARK: - IPackedFileUI Protocol
@property (nonatomic, strong, readonly) NSView *guiHandle;
- (void)updateGUI:(id<IFileWrapper>)wrapper;

// MARK: - Template Methods (Override in Subclasses)
- (void)refreshGUI;
- (void)onCommit;
- (void)onWrapperChanged:(WrapperChangedEventArgs *)args;

// MARK: - Actions
- (IBAction)commitAction:(id)sender;

// MARK: - Private Methods
- (void)setWrapper:(id<IFileWrapper>)wrapper;
- (void)setupDefaults;


@end
