//
//  Settings.m
//  MacSimpe
//
//  Created by Catherine Gramze on 8/6/25.
//
// ***************************************************************************
// *   Copyright (C) 2008 by Peter L Jones                                   *
// *   pljones@users.sf.net                                                  *
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
// *  along with this program; if not, write to the                          *
// *   Free Software Foundation, Inc.,                                       *
// *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
// ***************************************************************************

#import "Settings.h"
#import "Localization.h"
#import "Helper.h"
#import "XmlRegistryKey.h"

@interface Settings ()
@property (nonatomic, strong) XmlRegistryKey *xmlRegistryKey;
@end

@implementation Settings

// MARK: - Static Variables

static Settings *sharedSettings = nil;

// MARK: - Static Methods

+ (void)initialize {
    if (self == [Settings class]) {
        sharedSettings = [[Settings alloc] init];
    }
}

+ (BOOL)persistent {
    return sharedSettings.keepFilesOpen;
}

// MARK: - Initialization

- (instancetype)init {
    NSBundle *bundle = [NSBundle mainBundle];
    self = [super initWithBundle:bundle tableName:@"Localization"];
    if (self) {
        _xmlRegistryKey = [Helper windowsRegistry].registryKey;
    }
    return self;
}

// MARK: - Properties

- (BOOL)keepFilesOpen {
    static NSString *const BASENAME = @"Settings";
    XmlRegistryKey *rkf = [self.xmlRegistryKey createSubKey:BASENAME];
    id value = [rkf getValue:@"keepFilesOpen" defaultValue:@YES];
    return [value boolValue];
}

- (void)setKeepFilesOpen:(BOOL)keepFilesOpen {
    static NSString *const BASENAME = @"Settings";
    XmlRegistryKey *rkf = [self.xmlRegistryKey createSubKey:BASENAME];
    [rkf setValue:@(keepFilesOpen) forKey:@"keepFilesOpen"];
}

// MARK: - ISettings Protocol

- (NSString *)description {
    return @"SimPe";
}

- (NSImage *)icon {
    return nil;
}

- (id)getSettingsObject {
    return self;
}

@end

// MARK: - SettingsFactory Implementation

@implementation SettingsFactory

// MARK: - ISettingsFactory Protocol

- (NSArray<id<ISettings>> *)knownSettings {
    return @[[[Settings alloc] init]];
}

@end
