//
//  FixPackage.m
//  MacSimpe
//
//  Created by Catherine Gramze on 8/24/25.
//
//****************************************************************************
// *   Copyright (C) 2005 by Ambertation                                     *
// *   quaxi@ambertation.de                                                  *
//*   Copyright (C) 2008 by Peter L Jones                                    *
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
// *   along with this program; if not, write to the                         *
// *   Free Software Foundation, Inc.,                                       *
// *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
//****************************************************************************

#import "FixPackage.h"
#import "GeneratableFile.h"
#import "FixObject.h"
#import "RenameForm.h"
#import "ArgParser.h"
#import "Message.h"

@implementation FixPackage

// MARK: - ICommandLine Protocol Implementation

- (NSString *)commandName {
    return @"FixPackage";
}

- (void)execute {
    // This method could be implemented if needed for direct execution
    NSLog(@"FixPackage command executed - use parse: method with arguments");
}

// MARK: - Command Line Parsing

- (BOOL)parse:(NSArray<NSString *> *)argv {
    NSInteger index = [ArgParser parseArgv:argv option:@"-fix"];
    if (index < 0) {
        return NO;
    }

    NSString *modelName = @"";
    NSString *prefix = @"";
    NSString *packagePath = @"";
    NSString *versionText = @"";
    FixVersion version = FixVersionUniversityReady;

    NSMutableArray<NSString *> *mutableArgv = [argv mutableCopy];

    while (mutableArgv.count > index) {
        if ([ArgParser parseArgv:mutableArgv atIndex:index option:@"-package" value:&packagePath]) continue;
        if ([ArgParser parseArgv:mutableArgv atIndex:index option:@"-modelname" value:&modelName]) continue;
        if ([ArgParser parseArgv:mutableArgv atIndex:index option:@"-prefix" value:&prefix]) continue;
        if ([ArgParser parseArgv:mutableArgv atIndex:index option:@"-fixversion" value:&versionText]) {
            NSString *trimmedVersion = [[versionText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString];
            if ([trimmedVersion isEqualToString:@"uni1"]) {
                version = FixVersionUniversityReady;
            } else if ([trimmedVersion isEqualToString:@"uni2"]) {
                version = FixVersionUniversityReady2;
            }
            continue;
        }
        [Message show:[self help].firstObject];
        return YES;
    }

    [FixPackage fixPackage:packagePath
                 modelName:[prefix stringByAppendingString:modelName]
                   version:version];
    return YES;
}

- (NSArray<NSString *> *)help {
    return @[@"-fix -package <pkg> -modelname <mdl> -prefix <pfx> -fixversion uni1|uni2"];
}

// MARK: - Static Fix Implementation

+ (void)fixPackage:(NSString *)packagePath
         modelName:(NSString *)modelName
           version:(FixVersion)version {
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:packagePath]) {
        GeneratableFile *package = [GeneratableFile loadFromFile:packagePath];

        // Get names mapping
        BOOL hasModelName = [[modelName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0;
        NSDictionary *nameMap = [RenameForm getNames:hasModelName
                                             package:package
                                              parent:nil
                                           modelName:modelName];

        // Create and configure FixObject
        FixObject *fixObject = [[FixObject alloc] initWithPackage:package
                                                          version:version
                                                         autoFix:NO];
        
        // Apply fixes
        [fixObject fix:nameMap autoFix:NO];
        [fixObject cleanUp];
        [fixObject fixGroup];

        // Save the package
        [package save];
    }
}

@end
