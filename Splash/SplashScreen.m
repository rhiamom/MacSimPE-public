//
//  SplashScreen.m
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

#import "SplashScreen.h"
#import "SplashForm.h"
#import "Registry.h"

@interface Splash ()
@property (nonatomic, strong, nullable) SplashForm *form;
@property (nonatomic, copy) NSString *currentMessage;
@property (nonatomic, assign) BOOL shouldShow;
@property (nonatomic, strong) dispatch_semaphore_t initSemaphore;
@end

@implementation Splash

static Splash *_screen = nil;
static dispatch_queue_t _serialQueue = nil;

+ (void)initialize {
    if (self == [Splash class]) {
        _serialQueue = dispatch_queue_create("com.simpe.splash", DISPATCH_QUEUE_SERIAL);
    }
}

+ (Splash *)screen {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _screen = [[Splash alloc] init];
    });
    return _screen;
}

+ (BOOL)running {
    return _screen != nil && _screen.form != nil;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _currentMessage = @"";
        _shouldShow = NO;
        _initSemaphore = dispatch_semaphore_create(0);
        
        if ([[Registry windowsRegistry] showStartupSplash]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self startThread];
            });
            dispatch_semaphore_wait(_initSemaphore, DISPATCH_TIME_FOREVER);
        } else {
            dispatch_semaphore_signal(_initSemaphore);
        }
    }
    return self;
}

- (void)startThread {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.form = [[SplashForm alloc] init];
        [self setMessage:self.currentMessage];
        if (self.shouldShow) {
            [self.form startSplash];
        }
        dispatch_semaphore_signal(self.initSemaphore);
    });
}

- (void)setMessage:(NSString *)message {
    dispatch_async(_serialQueue, ^{
        self.currentMessage = message;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.form) {
                self.form.message = message;
            }
        });
    });
}

- (void)start {
    dispatch_async(_serialQueue, ^{
        self.shouldShow = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.form) {
                [self.form startSplash];
            }
        });
    });
}

- (void)stop {
    dispatch_async(_serialQueue, ^{
        self.shouldShow = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.form) {
                [self.form stopSplash];
            }
        });
    });
}

- (void)shutDown {
    [self stop];
    dispatch_async(_serialQueue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            self.form = nil;
        });
    });
}

@end
#import <Foundation/Foundation.h>
