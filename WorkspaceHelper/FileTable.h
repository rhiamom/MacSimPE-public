//
//  FileTable.h
//  MacSimpe
//
//  Created by Catherine Gramze on 7/30/25.
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
#import "FileTableBase.h"
#import "PathProvider.h"
#import "FileTableEnums.h"
#import "FileTableItemType.h"

@protocol IToolRegistry;
@protocol IHelpRegistry;
@protocol ISettingsRegistry;
@protocol ICommandLineRegistry;

// MARK: - File Location Types


// MARK: - FileTablePath

@interface FileTablePath : NSObject

@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, assign, readonly) FTFileLocation location;
@property (nonatomic, strong, readonly) NSString *expansionName; // For expansion pack locations
@property (nonatomic, assign, readonly) Expansions expansion;
@property (nonatomic, assign, readonly) BOOL isPreObject;

- (instancetype)initWithName:(NSString *)name
                    location:(FTFileLocation)location
               expansionName:(NSString *)expansionName
                   expansion:(Expansions)expansion
                 isPreObject:(BOOL)isPreObject;

- (NSString *)fullPath;
- (BOOL)exists;
- (NSString *)basePath;


// MARK: - Factory Methods
+ (FileTableItemType *)fromExpansion:(Expansions)expansion;
+ (FileTableItemType *)fromInteger:(int32_t)value;
+ (FileTableItemType *)fromUnsignedInteger:(uint32_t)value;

// MARK: - Conversion Methods
+ (Expansions)asExpansion:(FileTableItemType *)type;
+ (uint32_t)asUnsignedInteger:(FileTableItemType *)type;

// MARK: - Utility Methods
+ (NSString *)getRootForType:(FileTableItemType *)type;
+ (NSInteger)getEPVersionForType:(FileTableItemType *)type;
+ (NSString *)stringForType:(FileTableItemType *)type;

// MARK: - Comparison Methods
+ (NSComparisonResult)compare:(FileTableItemType *)typeA
                         with:(FileTableItemType *)typeB;
+ (BOOL)isEqual:(FileTableItemType *)typeA to:(FileTableItemType *)typeB;

@end

// MARK: - FileTable

/**
 * Use this class to access the FileIndex
 * Hybrid of C# registry system and Swift file path management
 */
@interface FileTable : FileTableBase

// MARK: - Registry Properties (from C#)

/**
 * Returns/Sets a ToolRegistry (can be null)
 */
@property (class, nonatomic, strong) id<IToolRegistry> toolRegistry;

/**
 * Returns/Sets a HelpTopicRegistry (can be null)
 */
@property (class, nonatomic, strong) id<IHelpRegistry> helpTopicRegistry;

/**
 * Returns/Sets a SettingsRegistry (can be null)
 */
@property (class, nonatomic, strong) id<ISettingsRegistry> settingsRegistry;

/**
 * Returns/Sets a CommandLineRegistry (can be null)
 */
@property (class, nonatomic, strong) id<ICommandLineRegistry> commandLineRegistry;

// MARK: - File System Properties (from Swift)

/**
 * Array of detected stuff pack names
 */
@property (class, nonatomic, strong, readonly) NSArray<NSString *> *detectedStuffPacks;

/**
 * Array of all file table paths
 */
@property (class, nonatomic, strong, readonly) NSArray<FileTablePath *> *fileTable;

// MARK: - Methods

/**
 * Reloads the file index (from C#)
 */
+ (void)reload;

/**
 * Initializes and builds the file table paths
 */
+ (void)buildFileTable;

/**
 * Detects installed stuff packs
 */
+ (void)detectStuffPacks;

@end
