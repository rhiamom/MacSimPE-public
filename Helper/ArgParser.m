//
//  ArgParser.m
//  MacSimpe
//
//  Created by Catherine Gramze on 8/8/25.
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
// *   along with this program; if not, write to the                         *
// *   Free Software Foundation, Inc.,                                       *
// *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
// ***************************************************************************/

#import "ArgParser.h"

@implementation ArgParser

+ (BOOL)parseArguments:(NSMutableArray<NSString *> *)argv
               atIndex:(NSInteger)index
             parameter:(NSString *)parameter
                result:(NSString **)result {
    
    // Find the parameter in the array
    NSUInteger parameterIndex = [argv indexOfObject:parameter];
    
    // Check if parameter was found at the expected index and there's a value after it
    if (parameterIndex == index && argv.count > parameterIndex + 1) {
        // Remove the parameter
        [argv removeObjectAtIndex:parameterIndex];
        
        // Get the value (now at the same index after removing the parameter)
        if (result != NULL) {
            *result = argv[parameterIndex];
        }
        
        // Remove the value
        [argv removeObjectAtIndex:parameterIndex];
        
        return YES;
    }
    
    return NO;
}

+ (NSInteger)parseArguments:(NSMutableArray<NSString *> *)argv
                    atIndex:(NSInteger)index
                 parameters:(NSArray<NSString *> *)parameters {
    
    // Check if index is valid
    if (argv.count <= index) {
        return -1;
    }
    
    // Get the argument at the specified index
    NSString *argument = argv[index];
    
    // Find the argument in the parameters array
    NSUInteger parameterIndex = [parameters indexOfObject:argument];
    
    // If found, remove it from argv
    if (parameterIndex != NSNotFound) {
        [argv removeObjectAtIndex:index];
        return (NSInteger)parameterIndex;
    }
    
    return -1;
}

+ (NSInteger)parseArguments:(NSMutableArray<NSString *> *)argv
                  parameter:(NSString *)parameter {
    
    // Find the parameter in the array
    NSUInteger parameterIndex = [argv indexOfObject:parameter];
    
    // If found, remove it and return the index
    if (parameterIndex != NSNotFound) {
        [argv removeObjectAtIndex:parameterIndex];
        return (NSInteger)parameterIndex;
    }
    
    return -1;
}

@end
