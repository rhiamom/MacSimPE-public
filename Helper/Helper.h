//
//  Helper.h
//  MacSimpe
//
//  Created by Catherine Gramze on 7/26/25.
//
/***************************************************************************
 *   Copyright (C) 2005 by Ambertation                                                                                                    *
 *   quaxi@ambertation.de                                                                                                               *
 *                                                                         *
 *   Objective C translation Copyright (C) 2025 by GramzeSweatShop                                                              *
 *   rhiamom@mac.com                                                                                                                          *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify                                                 *
 *   it under the terms of the GNU General Public License as published by                                             *
 *   the Free Software Foundation; either version 2 of the License, or                                                     *
 *   (at your option) any later version.                                                                                                        *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,                                                             *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of                                            *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the                                    *
 *   GNU General Public License for more details.                                                                                   *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License                                              *
 *   along with this program, if not, write to the                                                                                        *
 *   Free Software Foundation, Inc.,                                                                                                         *
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.                                                          *
 *****************************************************************************************************************/

#import <Foundation/Foundation.h>

@class BinaryReader, Registry, Parameters, TGILoader, Boolset, MetaData, PathProvider;

/**
 * Determines the Executable that was started
 */
typedef NS_ENUM(uint8_t, Executable) {
    ExecutableClassic = 1,
    ExecutableDefault = 2,
    ExecutableWizardsOfSimpe = 3,
    ExecutableOther = 4
};

/**
 * Some Helper Functions frequently used in the handlers
 */
@interface Helper : NSObject

// MARK: - Constants
extern NSString * const HelperLbr;
extern NSString * const HelperTab;
extern NSString * const HelperPathCharacters;
extern NSString * const HelperPathSep;
extern NSString * const HelperNeighborhoodPackage;

// MARK: - Properties
@property (class, nonatomic, strong) Parameters *commandlineParameters;

// MARK: - Run Mode Flags
@property (class, nonatomic, assign) BOOL localMode;
@property (class, nonatomic, assign) BOOL noPlugins;
@property (class, nonatomic, assign) BOOL fileFormat;
@property (class, nonatomic, assign) BOOL noErrors;
@property (class, nonatomic, assign) BOOL anyPackage;

// MARK: - Path Properties
@property (class, nonatomic, readonly, copy) NSString *simPePath;
@property (class, nonatomic, readonly, copy) NSString *simPePluginPath;
@property (class, nonatomic, readonly, copy) NSString *simPeTeleportPath;
@property (class, nonatomic, readonly, copy) NSString *simPeDataPath;
@property (class, nonatomic, readonly, copy) NSString *simPePluginDataPath;
@property (class, nonatomic, readonly, copy) NSString *simPeViewportFile;
@property (class, nonatomic, readonly, copy) NSString *simPeSemiGlobalFile;

// MARK: - Version Properties
@property (class, nonatomic, readonly, strong) NSBundle *executableVersion;
@property (class, nonatomic, readonly, strong) NSBundle *simPeVersion;
@property (class, nonatomic, readonly, assign) int64_t simPeVersionLong;
@property (class, nonatomic, readonly, copy) NSString *simPeVersionString;
@property (class, nonatomic, readonly, assign) BOOL qaRelease;
@property (class, nonatomic, readonly, assign) BOOL debugMode;
@property (class, nonatomic, readonly, assign) Executable startedGui;

// MARK: - Game Path
@property (class, nonatomic, readonly, copy) NSString *newestGamePath;

// MARK: - TGI Loader
@property (class, nonatomic, readonly, strong) TGILoader *tgiLoader;

// MARK: - Cache Files
@property (class, nonatomic, readonly, copy) NSString *simPeCache;
@property (class, nonatomic, readonly, copy) NSString *simPeLanguageCache;

// MARK: - Binary Reader
+ (BinaryReader *)getBinaryReader:(NSData *)data;

// MARK: - String Length Functions
+ (NSString *)minStrLength:(NSString *)input length:(NSInteger)length;
+ (NSString *)strLength:(NSString *)input length:(NSInteger)length;
+ (NSString *)strLength:(NSString *)input length:(NSInteger)length left:(BOOL)left;

// MARK: - Hex String Functions
+ (NSString *)hexString:(int64_t)input;
+ (NSString *)hexStringUInt64:(uint64_t)input;
+ (NSString *)hexStringInt:(int32_t)input;
+ (NSString *)hexStringUInt:(uint32_t)input;
+ (NSString *)hexStringShort:(int16_t)input;
+ (NSString *)hexStringUShort:(uint16_t)input;
+ (NSString *)hexStringByte:(uint8_t)input;

// MARK: - String Conversion Functions
+ (uint32_t)hexStringToUInt:(NSString *)txt;
+ (uint32_t)stringToUInt32:(NSString *)txt default:(uint32_t)def base:(uint8_t)base;
+ (float)stringToFloat:(NSString *)txt default:(float)def;
+ (int32_t)stringToInt32:(NSString *)txt default:(int32_t)def base:(uint8_t)base;
+ (uint16_t)stringToUInt16:(NSString *)txt default:(uint16_t)def base:(uint8_t)base;
+ (int16_t)stringToInt16:(NSString *)txt default:(int16_t)def base:(uint8_t)base;
+ (uint8_t)stringToByte:(NSString *)txt default:(uint8_t)def base:(uint8_t)base;

// MARK: - Character and String Processing
+ (NSString *)removeUnlistedCharacters:(NSString *)input allowed:(NSString *)allowed;
+ (unichar)displayableCharacter:(unichar)c;
+ (NSString *)toString:(id)object;
+ (NSString *)dataToString:(NSData *)data;

// MARK: - Data Conversion
+ (NSData *)stringToBytes:(NSString *)str;
+ (NSData *)stringToBytes:(NSString *)str length:(NSInteger)len;

// MARK: - Version Functions
+ (int64_t)versionToLong:(NSBundle *)ver;
+ (NSString *)versionToString:(NSBundle *)ver;
+ (NSString *)longVersionToString:(int64_t)l;
+ (NSString *)longVersionToShortString:(int64_t)l;

// MARK: - File System Utilities
+ (void)copyDirectory:(NSString *)sourcePath
        toDestination:(NSString *)destinationPath
              recurse:(BOOL)recurse;

// MARK: - Hex List Functions
+ (NSString *)bytesToHexList:(NSData *)data;
+ (NSString *)bytesToHexList:(NSData *)data dwordPerRow:(NSInteger)dwordPerRow;
+ (NSData *)hexListToBytes:(NSString *)hexlist;

// MARK: - Data Length Functions
+ (NSData *)setLength:(NSData *)array length:(NSInteger)len;

// MARK: - Array Utilities
+ (NSArray *)addToArray:(NSArray *)source item:(id)item;
+ (NSArray *)deleteFromArray:(NSArray *)source item:(id)item;
+ (NSArray *)mergeArrays:(NSArray *)source1 with:(NSArray *)source2;

// MARK: - Bit Manipulation
+ (int16_t)toShort:(uint8_t)low high:(uint8_t)high;
+ (NSArray<NSNumber *> *)shortToBytes:(int16_t)val;
+ (int32_t)toInt:(int16_t)low high:(int16_t)high;
+ (NSArray<NSNumber *> *)intToShorts:(int32_t)val;

// MARK: - Neighborhood Functions
+ (NSString *)getMainNeighborhoodFile:(NSString *)filename;
+ (BOOL)isNeighborhoodFile:(NSString *)filename;

// MARK: - File Utilities
+ (NSString *)saveFileName:(NSString *)flname;
+ (BOOL)equalFileName:(NSString *)fl1 fl2:(NSString *)fl2;
+ (BOOL)isAbsolutePath:(NSString *)path;
+ (NSString *)compareableFileName:(NSString *)fl;
+ (NSString *)toLongPathName:(NSString *)shortName;
+ (NSString *)toLongFileName:(NSString *)shortName;

// MARK: - Cache File Functions
+ (NSString *)getSimPeCache:(NSString *)prefix;
+ (NSString *)getSimPeLanguageCache:(NSString *)prefix;

// MARK: - Exception Handling
+ (void)exceptionMessage:(NSError *)error;
+ (void)exceptionMessage:(NSString *)message error:(NSError *)error;
+ (void)exceptionMessageWithString:(NSString *)message;

// MARK: - Plugin Loading
+ (BOOL)canLoadPlugin:(NSString *)flname;

// MARK: - Key/Shortcut Support
+ (NSString *)toKeys:(NSString *)shortcut;

@end

/**
 * Data folder paths for configuration files
 */
@interface DataFolder : NSObject

@property (class, nonatomic, readonly, copy) NSString *profiles;
@property (class, nonatomic, readonly, copy) NSString *simPeXREGW;
@property (class, nonatomic, readonly, copy) NSString *simPeXREG;
@property (class, nonatomic, readonly, copy) NSString *simPeLayoutW;
@property (class, nonatomic, readonly, copy) NSString *simPeLayout;
@property (class, nonatomic, readonly, copy) NSString *layout2XREGW;
@property (class, nonatomic, readonly, copy) NSString *layout2XREG;
@property (class, nonatomic, readonly, copy) NSString *foldersXREGW;
@property (class, nonatomic, readonly, copy) NSString *foldersXREG;
@property (class, nonatomic, readonly, copy) NSString *mruXREGW;
@property (class, nonatomic, readonly, copy) NSString *mruXREG;

+ (NSString *)profilePath:(NSString *)s;
+ (NSString *)profilePath:(NSString *)s readOnly:(BOOL)readOnly;

@end
