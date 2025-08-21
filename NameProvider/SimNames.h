//
//  SimNames.h
//  MacSimpe
//
//  Created by Catherine Gramze on 8/20/25.
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
// ***************************************************************************/

#import <Foundation/Foundation.h>
#import "Thread.h"
#import "ISimNames.h"

@protocol IOpcodeProvider;
@protocol IScenegraphFileIndex;
@protocol IPackageFile;
@protocol IPackedFileDescriptor;
@protocol IAlias;
@class Alias;
@class ExtObjd;

/**
 * Provides an Alias Matching a SimID with it's Name
 * @remarks
 * The Tag of the NameProvider is an Object Array with the following content:
 *  0: The Name of the Character File
 *  1: Image of the Sim (if available)
 *  2: Familyname of the Sim
 *  3: Contains Age Data
 *  4: When NPC, this will get the Filename
 */
@interface SimNames : StoppableThread <ISimNames>

// MARK: - Properties

/**
 * List of known Aliases (can be null)
 */
@property (nonatomic, strong) NSMutableDictionary *names;

/**
 * This is needed for the OBJD to work
 */
@property (nonatomic, strong) id<IOpcodeProvider> opcodes;

/**
 * The Folder from where the SimInformation was loaded
 */
@property (nonatomic, strong) NSString *dir;

/**
 * Additional FileIndex for template SimNames
 */
@property (nonatomic, strong) id<IScenegraphFileIndex> characterfi;

/**
 * Synchronization object
 */
@property (nonatomic, strong) NSObject *sync;

// MARK: - Initialization

/**
 * Creates the List for the specific Folder
 * @param folder The Folder with the Character Files
 * @param opcodes The opcode provider needed for OBJD processing
 */
- (instancetype)initWithFolder:(NSString *)folder opcodes:(id<IOpcodeProvider>)opcodes;

/**
 * Creates the List with empty folder
 * @param opcodes The opcode provider needed for OBJD processing
 */
- (instancetype)initWithOpcodes:(id<IOpcodeProvider>)opcodes;

// MARK: - Loading Methods

/**
 * Loads all package Files in the directory and scans them for Name Informations
 */
- (void)loadSimsFromFolder;

// MARK: - Sim Processing Methods

/**
 * Adds a Sim to the List
 * @param objd The OBJD wrapper
 * @param ct Reference to counter
 * @param step Progress step
 * @param npc Whether this is an NPC
 * @returns The Alias for that Sim
 * @remarks
 * Alias.Tag has the following Structure:
 * [0] : FileName of Character File (if NPC, this will be null)
 * [1] : Thumbnail
 * [2] : FamilyName
 * [3] : Contains Age Data
 * [4] : When NPC, this will get the Filename
 */
- (Alias *)addSim:(ExtObjd *)objd counter:(NSInteger *)ct step:(NSInteger)step npc:(BOOL)npc;

/**
 * Adds a Sim to the List from package file
 * @param packageFile The package file
 * @param objdpfd The OBJD packed file descriptor
 * @param ct Reference to counter
 * @param step Progress step
 * @returns The Alias for that Sim
 */
- (Alias *)addSimFromPackage:(id<IPackageFile>)packageFile
                    objdpfd:(id<IPackedFileDescriptor>)objdpfd
                    counter:(NSInteger *)ct
                       step:(NSInteger)step;

// MARK: - File Scanning Methods

/**
 * Scans the FileTable for template sims
 */
- (void)scanFileTable;

/**
 * Scans the FileTable for specific instance
 * @param instance The instance to scan for
 */
- (void)scanFileTable:(uint32_t)instance;

@end
