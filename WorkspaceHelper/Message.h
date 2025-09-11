//
//  Message.h
//  MacSimpe
//
//  Created by Catherine Gramze on 9/11/25.
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

#import <Cocoa/Cocoa.h>

typedef NS_ENUM(NSInteger, MessageBoxButtons) {
    MessageBoxButtonsOK,
    MessageBoxButtonsOKCancel,
    MessageBoxButtonsYesNo,
    MessageBoxButtonsYesNoCancel
};

typedef NS_ENUM(NSInteger, MessageBoxResult) {
    MessageBoxResultOK = 1,
    MessageBoxResultCancel = 0,
    MessageBoxResultYes = 6,
    MessageBoxResultNo = 7
};
// Custom modal response constants for Yes/No dialogs
typedef NS_ENUM(NSInteger, CustomModalResponse) {
    CustomModalResponseYes = 1000,
    CustomModalResponseNo = 1001,
    // Standard ones we can use directly:
    // NSModalResponseOK = 1
    // NSModalResponseCancel = 0
};

NS_ASSUME_NONNULL_BEGIN

@interface Message : NSWindowController

@property (nonatomic, strong) NSView *panel1;
@property (nonatomic, strong) NSView *panel2;      
@property (nonatomic, strong) NSTextField *label1;

@property (nonatomic, assign) NSModalResponse dialogResult;

+ (NSModalResponse)show:(NSString *)message;
+ (NSModalResponse)show:(NSString *)message
                caption:(nullable NSString *)caption
                buttons:(MessageBoxButtons)messageBoxButtons;

- (void)addButton:(NSString *)caption dialogResult:(NSModalResponse)dialogResult;
- (void)buttonClick:(id)sender;
- (MessageBoxResult)mapModalResponseToMessageBoxResult:(NSModalResponse)response;
@end

NS_ASSUME_NONNULL_END
