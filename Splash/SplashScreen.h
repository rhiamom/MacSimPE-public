//
//  SplashScreen.h
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
//*   Objective-C translation Copyright (C) 2025 by GramzeSweatShop         *
//*   rhiamom@mac.com                                                       *
//***************************************************************************/

#import <Foundation/Foundation.h>

@class SplashForm;

NS_ASSUME_NONNULL_BEGIN

@interface Splash : NSObject

@property (class, nonatomic, readonly) Splash *screen;
@property (class, nonatomic, readonly) BOOL running;

- (void)setMessage:(NSString *)message;
- (void)start;
- (void)stop;
- (void)shutDown;

@end

NS_ASSUME_NONNULL_END
