//
//  SplashForm.h
//  MacSimpe
//
//  Created by Catherine Gramze on 9/11/25.
//
//***************************************************************************
//*   Copyright (C) 2005 by Ambertation                                     *
//*   quaxi@ambertation.de                                                  *
//*   Copyright (C) 2008 by Peter L Jones                                   *
//*   pljones@users.sf.net                                                  *
//*                                                                         *
//*   This program is free software; you can redistribute it and/or modify  *
//*   it under the terms of the GNU General Public License as published by  *
//*   the Free Software Foundation; either version 2 of the License, or     *
//*   (at your option) any later version.                                   *
//*                                                                         *
//*   This program is distributed in the hope that it will be useful,       *
//*   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
//*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
//*   GNU General Public License for more details.                          *
//*                                                                         *
//*   You should have received a copy of the GNU General Public License     *
//*   along with this program; if not, write to the                         *
//*   Free Software Foundation, Inc.,                                       *
//*   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
//***************************************************************************/

#import <Cocoa/Cocoa.h>

@interface SplashForm : NSWindowController

@property (nonatomic, strong) NSTextField *lbtxt;
@property (nonatomic, strong) NSTextField *lbver;
@property (nonatomic, strong) NSTextField *label2;
@property (nonatomic, strong) NSImageView *backgroundImageView;
@property (nonatomic, copy) NSString *message;

- (instancetype)init;
- (void)startSplash;
- (void)stopSplash;
- (void)updateProgress:(NSString *)progressMessage;
- (void)sendMessageChangeSignal;

+ (SplashForm *)sharedSplash;

@end
