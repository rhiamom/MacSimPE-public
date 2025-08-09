//
//  ArgParser.h
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

#import <Foundation/Foundation.h>

/**
 * Command line argument parser utility
 */
@interface ArgParser : NSObject

/**
 * Parse a parameter with a value from the argument list
 * @param argv The mutable array of arguments
 * @param index The expected index of the parameter
 * @param parameter The parameter name to look for
 * @param result Pointer to store the result value (out parameter)
 * @returns YES if the parameter was found and parsed successfully
 */
+ (BOOL)parseArguments:(NSMutableArray<NSString *> *)argv
               atIndex:(NSInteger)index
             parameter:(NSString *)parameter
                result:(NSString **)result;

/**
 * Parse a parameter from a list of valid parameters
 * @param argv The mutable array of arguments
 * @param index The index to check in the argument array
 * @param parameters Array of valid parameter names
 * @returns The index of the matched parameter in the parameters array, or -1 if not found
 */
+ (NSInteger)parseArguments:(NSMutableArray<NSString *> *)argv
                    atIndex:(NSInteger)index
                 parameters:(NSArray<NSString *> *)parameters;

/**
 * Parse and remove a parameter from the argument list
 * @param argv The mutable array of arguments
 * @param parameter The parameter name to look for
 * @returns The index where the parameter was found, or -1 if not found
 */
+ (NSInteger)parseArguments:(NSMutableArray<NSString *> *)argv
                  parameter:(NSString *)parameter;

@end
