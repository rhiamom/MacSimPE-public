///
//  Helper.m
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

#import "Helper.h"
#import "BinaryReader.h"
#import "Registry.h"
#import "Parameters.h"
#import "TGILoader.h"
#import "MemoryStream.h"

// Forward declarations
@interface HoodsXMLDelegate : NSObject <NSXMLParserDelegate>
@property (nonatomic, strong) NSMutableArray<NSString *> *hoods;
@end

// Constants
NSString * const HelperLbr = @"\r\n";
NSString * const HelperTab = @"    ";
NSString * const HelperPathCharacters = @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyzß0123456789.-_ ";
NSString * const HelperPathSep = @"/";
NSString * const HelperNeighborhoodPackage = @"_neighborhood.package";

@implementation Helper

// Static variables
static Parameters *_commandlineParameters = nil;
static TGILoader *_tgiLoader = nil;
static NSArray<NSString *> *_knownHoods = nil;

// Run mode flags
static BOOL _localMode = NO;
static BOOL _noPlugins = NO;
static BOOL _fileFormat = NO;
static BOOL _noErrors = NO;
static BOOL _anyPackage = NO;

// MARK: - Properties

+ (Parameters *)commandlineParameters {
    return _commandlineParameters;
}

+ (void)setCommandlineParameters:(Parameters *)parameters {
    _commandlineParameters = parameters;
}

// MARK: - Run Mode Flags

+ (BOOL)localMode { return _localMode; }
+ (void)setLocalMode:(BOOL)localMode { _localMode = localMode; }

+ (BOOL)noPlugins { return _noPlugins; }
+ (void)setNoPlugins:(BOOL)noPlugins { _noPlugins = noPlugins; }

+ (BOOL)fileFormat { return _fileFormat; }
+ (void)setFileFormat:(BOOL)fileFormat { _fileFormat = fileFormat; }

+ (BOOL)noErrors { return _noErrors; }
+ (void)setNoErrors:(BOOL)noErrors { _noErrors = noErrors; }

+ (BOOL)anyPackage { return _anyPackage; }
+ (void)setAnyPackage:(BOOL)anyPackage { _anyPackage = anyPackage; }

// MARK: - Path Properties

+ (NSString *)pathSeparator {
#if TARGET_OS_WIN32
    return @"\\";
#else
    return @"/";
#endif
}

+ (NSString *)simPePath {
    return [[NSBundle mainBundle] bundlePath];
}

+ (NSString *)simPePluginPath {
    return [[self simPePath] stringByAppendingPathComponent:@"Plugins"];
}

+ (NSString *)simPeTeleportPath {
    NSString *dir = [[self simPePath] stringByAppendingPathComponent:@"Teleport"];
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:dir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dir
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
    }
    return dir;
}

+ (NSString *)simPeDataPath {
    NSString *path = [[self simPePath] stringByAppendingPathComponent:@"Data"];
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
    }
    return path;
}

+ (NSString *)simPePluginDataPath {
    NSString *path = [[self simPeDataPath] stringByAppendingPathComponent:@"Plugins"];
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
    }
    return path;
}

+ (NSString *)simPeViewportFile {
    return [[self simPeDataPath] stringByAppendingPathComponent:@"vport.set"];
}

+ (NSString *)simPeSemiGlobalFile {
    return [[self simPeDataPath] stringByAppendingPathComponent:@"semiglobals.xml"];
}

// MARK: - Version Properties

+ (NSBundle *)executableVersion {
    return [NSBundle mainBundle];
}

+ (NSBundle *)simPeVersion {
    return [NSBundle mainBundle];
}

+ (int64_t)simPeVersionLong {
    return [self versionToLong:[self simPeVersion]];
}

+ (NSString *)simPeVersionString {
    return [self versionToString:[self simPeVersion]];
}

+ (BOOL)qaRelease {
    NSString *buildString = [[[self simPeVersion] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSInteger buildNumber = [buildString integerValue];
    return (buildNumber % 2) == 1;
}

+ (BOOL)debugMode {
#ifdef DEBUG
    return YES;
#else
    return NO;
#endif
}

+ (Executable)startedGui {
    return ExecutableDefault; // On Mac, always default
}

// MARK: - Game Path

+ (NSString *)newestGamePath {
    // This would need to be implemented based on your PathProvider class
    // return [[PathProvider global] newestGamePath];
    return @""; // Placeholder
}

// MARK: - TGI Loader

+ (TGILoader *)tgiLoader {
    if (!_tgiLoader) {
        _tgiLoader = [[TGILoader alloc] init];
    }
    return _tgiLoader;
}

// MARK: - Cache Files

+ (NSString *)simPeCache {
    return [self getSimPeCache:@"objcache"];
}

+ (NSString *)simPeLanguageCache {
    return [self getSimPeLanguageCache:@"objcache_"];
}

// MARK: - Binary Reader

+ (BinaryReader *)getBinaryReader:(NSData *)data {
    MemoryStream *stream = [[MemoryStream alloc] initWithData:data];
    return [[BinaryReader alloc] initWithStream:stream];
}

// MARK: - String Length Functions

+ (NSString *)minStrLength:(NSString *)input length:(NSInteger)length {
    NSMutableString *result = [input mutableCopy];
    while (result.length < length) {
        [result insertString:@"0" atIndex:0];
    }
    return [result copy];
}

+ (NSString *)strLength:(NSString *)input length:(NSInteger)length {
    return [self strLength:input length:length left:YES];
}

+ (NSString *)strLength:(NSString *)input length:(NSInteger)length left:(BOOL)left {
    NSMutableString *result = [input mutableCopy];
    
    if (left) {
        while (result.length < length) {
            [result appendString:@"0"];
        }
        if (result.length > length) {
            result = [[result substringToIndex:length] mutableCopy];
        }
    } else {
        while (result.length < length) {
            [result insertString:@"0" atIndex:0];
        }
        if (result.length > length) {
            result = [[result substringFromIndex:result.length - length] mutableCopy];
        }
    }
    
    return [result copy];
}

// MARK: - Hex String Functions

+ (NSString *)hexString:(int64_t)input {
    return [self hexStringUInt64:(uint64_t)input];
}

+ (NSString *)hexStringUInt64:(uint64_t)input {
    return [self minStrLength:[NSString stringWithFormat:@"%llX", input] length:16];
}

+ (NSString *)hexStringInt:(int32_t)input {
    return [self hexStringUInt:(uint32_t)input];
}

+ (NSString *)hexStringUInt:(uint32_t)input {
    return [self minStrLength:[NSString stringWithFormat:@"%X", input] length:8];
}

+ (NSString *)hexStringShort:(int16_t)input {
    return [self hexStringUShort:(uint16_t)input];
}

+ (NSString *)hexStringUShort:(uint16_t)input {
    return [self minStrLength:[NSString stringWithFormat:@"%X", input] length:4];
}

+ (NSString *)hexStringByte:(uint8_t)input {
    return [self minStrLength:[NSString stringWithFormat:@"%X", input] length:2];
}

// MARK: - String Conversion Functions

+ (uint32_t)hexStringToUInt:(NSString *)txt {
    return [self stringToUInt32:txt default:0 base:16];
}

+ (uint32_t)stringToUInt32:(NSString *)txt default:(uint32_t)def base:(uint8_t)base {
    NSScanner *scanner = [NSScanner scannerWithString:txt];
    unsigned int result;
    if (base == 16) {
        if ([scanner scanHexInt:&result]) {
            return (uint32_t)result;
        }
    } else {
        if ([scanner scanInt:(int *)&result]) {
            return (uint32_t)result;
        }
    }
    return def;
}

+ (float)stringToFloat:(NSString *)txt default:(float)def {
    NSScanner *scanner = [NSScanner scannerWithString:txt];
    float result;
    if ([scanner scanFloat:&result]) {
        return result;
    }
    return def;
}

+ (int32_t)stringToInt32:(NSString *)txt default:(int32_t)def base:(uint8_t)base {
    NSScanner *scanner = [NSScanner scannerWithString:txt];
    int result;
    if (base == 16) {
        unsigned int hexResult;
        if ([scanner scanHexInt:&hexResult]) {
            return (int32_t)hexResult;
        }
    } else {
        if ([scanner scanInt:&result]) {
            return (int32_t)result;
        }
    }
    return def;
}

+ (uint16_t)stringToUInt16:(NSString *)txt default:(uint16_t)def base:(uint8_t)base {
    uint32_t result = [self stringToUInt32:txt default:def base:base];
    return (uint16_t)(result & 0xFFFF);
}

+ (int16_t)stringToInt16:(NSString *)txt default:(int16_t)def base:(uint8_t)base {
    int32_t result = [self stringToInt32:txt default:def base:base];
    return (int16_t)(result & 0xFFFF);
}

+ (uint8_t)stringToByte:(NSString *)txt default:(uint8_t)def base:(uint8_t)base {
    uint32_t result = [self stringToUInt32:txt default:def base:base];
    return (uint8_t)(result & 0xFF);
}

// MARK: - Character and String Processing

+ (NSString *)removeUnlistedCharacters:(NSString *)input allowed:(NSString *)allowed {
    NSMutableString *output = [NSMutableString string];
    for (NSUInteger i = 0; i < input.length; i++) {
        unichar c = [input characterAtIndex:i];
        NSString *charStr = [NSString stringWithCharacters:&c length:1];
        if ([allowed containsString:charStr]) {
            [output appendString:charStr];
        }
    }
    return [output copy];
}

+ (unichar)displayableCharacter:(unichar)c {
    if ((c > 0x1F) && (c < 0xFF) && (c != 0xAD) && ((c < 0x7F) || (c > 0x9F))) {
        return c;
    } else {
        return '.';
    }
}

+ (NSString *)toString:(id)object {
    if (object == nil) return @"";
    return [object description];
}

+ (NSString *)dataToString:(NSData *)data {
    if (!data || data.length == 0) return @"";
    
    NSMutableString *text = [NSMutableString string];
    const uint8_t *bytes = [data bytes];
    
    for (NSUInteger i = 0; i < data.length; i++) {
        if (bytes[i] == 0) break;
        [text appendFormat:@"%c", bytes[i]];
    }
    
    return [text copy];
}

+ (NSString *)integerToString:(NSInteger)value {
    return [NSString stringWithFormat:@"%ld", (long)value];
}

+ (NSString *)unsignedIntegerToString:(NSUInteger)value {
    return [NSString stringWithFormat:@"%lu", (unsigned long)value];
}

+ (NSString *)hexToString:(NSUInteger)value {
    return [NSString stringWithFormat:@"%lX", (unsigned long)value];
}

+ (NSString *)hexStringWithPadding:(NSUInteger)value padding:(NSInteger)padding {
    return [NSString stringWithFormat:@"%0*lX", (int)padding, (unsigned long)value];
}


// MARK: - Data Conversion

+ (NSData *)stringToBytes:(NSString *)str {
    return [self stringToBytes:str length:0];
}

+ (NSData *)stringToBytes:(NSString *)str length:(NSInteger)len {
    NSData *stringData = [str dataUsingEncoding:NSASCIIStringEncoding];
    
    if (len != 0) {
        NSMutableData *data = [NSMutableData dataWithLength:len];
        NSUInteger copyLength = MIN(len, stringData.length);
        [data replaceBytesInRange:NSMakeRange(0, copyLength) withBytes:stringData.bytes];
        return [data copy];
    } else {
        return stringData;
    }
}

// MARK: - Version Functions

+ (int64_t)versionToLong:(NSBundle *)ver {
    NSString *versionString = [[ver infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    if (!versionString) versionString = @"0.0.0.0";
    
    NSArray *components = [versionString componentsSeparatedByString:@"."];
    
    int64_t major = components.count > 0 ? [components[0] integerValue] : 0;
    int64_t minor = components.count > 1 ? [components[1] integerValue] : 0;
    int64_t build = components.count > 2 ? [components[2] integerValue] : 0;
    int64_t revision = components.count > 3 ? [components[3] integerValue] : 0;
    
    int64_t lver = major;
    lver = (lver << 16) + minor;
    lver = (lver << 16) + build;
    lver = (lver << 16) + revision;
    
    return lver;
}

+ (NSString *)versionToString:(NSBundle *)ver {
    NSString *versionString = [[ver infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    if (!versionString) versionString = @"0.0.0.0";
    
    NSArray *components = [versionString componentsSeparatedByString:@"."];
    
    NSInteger major = components.count > 0 ? [components[0] integerValue] : 0;
    NSInteger minor = components.count > 1 ? [components[1] integerValue] : 0;
    NSInteger build = components.count > 2 ? [components[2] integerValue] : 0;
    NSInteger revision = components.count > 3 ? [components[3] integerValue] : 0;
    
    return [NSString stringWithFormat:@"%ld.%ld.%ld.%ld", (long)major, (long)minor, (long)build, (long)revision];
}

+ (NSString *)longVersionToString:(int64_t)l {
    int64_t lver = l;
    int64_t revision = lver & 0xFFFF;
    lver = lver >> 16;
    int64_t build = lver & 0xFFFF;
    lver = lver >> 16;
    int64_t minor = lver & 0xFFFF;
    lver = lver >> 16;
    int64_t major = lver & 0xFFFF;
    
    return [NSString stringWithFormat:@"%lld.%lld.%lld.%lld", major, minor, build, revision];
}

+ (NSString *)longVersionToShortString:(int64_t)l {
    int64_t lver = l;
    lver = lver >> 16; // Skip revision
    lver = lver >> 16; // Skip build
    int64_t minor = lver & 0xFFFF;
    lver = lver >> 16;
    int64_t major = lver & 0xFFFF;
    
    return [NSString stringWithFormat:@"%lld.%lld", major, minor];
}

// MARK: - File System Utilities

+ (void)copyDirectory:(NSString *)sourcePath
        toDestination:(NSString *)destinationPath
              recurse:(BOOL)recurse {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *destPath = destinationPath;
    
    if (![destPath hasSuffix:@"/"]) {
        destPath = [destPath stringByAppendingString:@"/"];
    }
    
    NSError *error;
    if (![fileManager fileExistsAtPath:destPath]) {
        [fileManager createDirectoryAtPath:destPath
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:&error];
    }
    
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:sourcePath error:&error];
    
    for (NSString *item in contents) {
        NSString *sourceItemPath = [sourcePath stringByAppendingPathComponent:item];
        NSString *destItemPath = [destPath stringByAppendingPathComponent:item];
        
        BOOL isDirectory;
        if ([fileManager fileExistsAtPath:sourceItemPath isDirectory:&isDirectory]) {
            if (recurse && isDirectory) {
                [self copyDirectory:sourceItemPath toDestination:destItemPath recurse:recurse];
            } else if (!isDirectory) {
                [fileManager copyItemAtPath:sourceItemPath toPath:destItemPath error:&error];
            }
        }
    }
}

// MARK: - Hex List Functions

+ (NSString *)bytesToHexList:(NSData *)data {
    return [self bytesToHexList:data dwordPerRow:-1];
}

+ (NSString *)bytesToHexList:(NSData *)data dwordPerRow:(NSInteger)dwordPerRow {
    NSInteger dwordsPerRow = dwordPerRow;
    if (dwordsPerRow > 0) dwordsPerRow++;
    
    NSMutableString *s = [NSMutableString string];
    NSInteger dwords = 0;
    const uint8_t *bytes = [data bytes];
    
    for (NSUInteger i = 0; i < data.length; i++) {
        uint8_t byte = bytes[i];
        [s appendString:[self hexStringByte:byte]];
        [s appendString:@" "];
        
        if (i % 4 == 3) {
            [s appendString:@" "];
            dwords++;
        }
        
        if (dwordsPerRow > 0) {
            if (dwords % dwordsPerRow == dwordsPerRow - 1) {
                dwords = 0;
                [s appendString:HelperLbr];
            }
        }
    }
    
    return [s stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (NSData *)hexListToBytes:(NSString *)hexlist {
    NSMutableString *cleanHex = [hexlist mutableCopy];
    while ([cleanHex containsString:@"  "]) {
        [cleanHex replaceOccurrencesOfString:@"  "
                                  withString:@" "
                                     options:0
                                       range:NSMakeRange(0, cleanHex.length)];
    }
    
    NSArray *tokens = [cleanHex componentsSeparatedByString:@" "];
    NSMutableData *data = [NSMutableData data];
    
    for (NSString *token in tokens) {
        NSString *trimmedToken = [token stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (trimmedToken.length > 0) {
            uint8_t byte = [self stringToByte:trimmedToken default:0 base:16];
            [data appendBytes:&byte length:1];
        }
    }
    
    return [data copy];
}

// MARK: - Data Length Functions

+ (NSData *)setLength:(NSData *)array length:(NSInteger)len {
    if (array.length == len) return array;
    
    NSMutableData *ret = [NSMutableData dataWithLength:len];
    NSUInteger copyLength = MIN(array.length, ret.length);
    [ret replaceBytesInRange:NSMakeRange(0, copyLength) withBytes:array.bytes length:copyLength];
    
    return [ret copy];
}

// MARK: - Array Utilities

+ (NSArray *)addToArray:(NSArray *)source item:(id)item {
    NSMutableArray *result = [source mutableCopy];
    [result addObject:item];
    return [result copy];
}

+ (NSArray *)deleteFromArray:(NSArray *)source item:(id)item {
    NSMutableArray *result = [NSMutableArray array];
    for (id element in source) {
        if (element == nil) {
            if (item != nil) {
                [result addObject:element];
            }
        } else if (![element isEqual:item]) {
            [result addObject:element];
        }
    }
    return [result copy];
}

+ (NSArray *)mergeArrays:(NSArray *)source1 with:(NSArray *)source2 {
    NSMutableArray *result = [source1 mutableCopy];
    [result addObjectsFromArray:source2];
    return [result copy];
}

// MARK: - Bit Manipulation

+ (int16_t)toShort:(uint8_t)low high:(uint8_t)high {
    return (int16_t)(low + (high << 8));
}

+ (NSArray<NSNumber *> *)shortToBytes:(int16_t)val {
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:2];
    [ret addObject:@((uint8_t)(val & 0xFF))];
    [ret addObject:@((uint8_t)((val >> 8) & 0xFF))];
    return [ret copy];
}

+ (int32_t)toInt:(int16_t)low high:(int16_t)high {
    return (int32_t)(low + (high << 16));
}

+ (NSArray<NSNumber *> *)intToShorts:(int32_t)val {
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:2];
    [ret addObject:@((int16_t)(val & 0xFFFF))];
    [ret addObject:@((int16_t)((val >> 16) & 0xFFFF))];
    return [ret copy];
}

// MARK: - Neighborhood Functions

+ (NSString *)getMainNeighborhoodFile:(NSString *)filename {
    if (!filename) return @"";
    
    NSString *fname = [[filename lastPathComponent] lowercaseString];
    
    if ([fname hasSuffix:HelperNeighborhoodPackage]) {
        return filename;
    }
    
    NSString *nameWithoutExtension = [[fname stringByDeletingPathExtension] lastPathComponent];
    NSArray *parts = [nameWithoutExtension componentsSeparatedByString:@"_"];
    if (parts.count == 0) return filename;
    
    NSString *directory = [filename stringByDeletingLastPathComponent];
    NSString *newFilename = [NSString stringWithFormat:@"%@%@", parts[0], HelperNeighborhoodPackage];
    
    return [directory stringByAppendingPathComponent:newFilename];
}

+ (BOOL)isNeighborhoodFile:(NSString *)filename {
    if (!filename) return NO;
    
    NSString *fname = [[filename lastPathComponent] lowercaseString];
    
    if ([fname hasPrefix:@"n"] && [fname hasSuffix:HelperNeighborhoodPackage] &&
        fname.length == 4 + HelperNeighborhoodPackage.length) {
        return YES;
    }
    
    // Check against known neighborhoods
    for (NSString *hood in [self knownHoods]) {
        NSString *expectedName = [NSString stringWithFormat:@"_%@", hood];
        NSRange nameRange = [fname rangeOfString:expectedName];
        if (nameRange.location == 4) {
            NSString *packageSuffix = @".package";
            NSRange packageRange = [fname rangeOfString:packageSuffix];
            if (packageRange.location == 4 + 1 + hood.length + 3) {
                return YES;
            }
        }
    }
    
    return NO;
}

// MARK: - File Utilities

+ (NSString *)saveFileName:(NSString *)flname {
    if (!flname) return @"";
    
    NSMutableString *name = [flname mutableCopy];
    [name replaceOccurrencesOfString:@"\\" withString:@"_" options:0 range:NSMakeRange(0, name.length)];
    [name replaceOccurrencesOfString:@"/" withString:@"_" options:0 range:NSMakeRange(0, name.length)];
    [name replaceOccurrencesOfString:@":" withString:@"_" options:0 range:NSMakeRange(0, name.length)];
    
    return [name copy];
}

+ (BOOL)equalFileName:(NSString *)fl1 fl2:(NSString *)fl2 {
    NSString *trimmed1 = [fl1 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *trimmed2 = [fl2 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return [trimmed1 isEqualToString:trimmed2];
}

+ (BOOL)isAbsolutePath:(NSString *)path {
    if (!path) return NO;
    NSString *trimmedPath = [path stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return [trimmedPath hasPrefix:@"/"];
}

+ (NSString *)compareableFileName:(NSString *)fl {
    NSString *trimmed = [fl stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return [trimmed stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
}

+ (NSString *)toLongPathName:(NSString *)shortName {
    return shortName; // macOS doesn't have short path names like Windows
}

+ (NSString *)toLongFileName:(NSString *)shortName {
    return shortName; // macOS doesn't have short file names like Windows
}

// MARK: - Cache File Functions

+ (NSString *)getSimPeCache:(NSString *)prefix {
    return [[self simPeDataPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.simpepkg", prefix]];
}

+ (NSString *)getSimPeLanguageCache:(NSString *)prefix {
    uint8_t languageCode = [AppPreferences languageCode];
    return [[self simPeDataPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@.simpepkg", prefix, [self hexStringByte:languageCode]]];
}

// MARK: - Exception Handling

+ (void)exceptionMessage:(NSError *)error {
    [self exceptionMessage:@"" error:error];
}

+ (void)exceptionMessage:(NSString *)message error:(NSError *)error {
    if ([self noErrors]) return;
    
    NSLog(@"Exception: %@ - %@", message, error.localizedDescription);
    
    // In a real app, you'd show an alert dialog here
    // For now, just log to console
}

+ (void)exceptionMessageWithString:(NSString *)message {
    NSError *error = [NSError errorWithDomain:@"SimPE" code:1 userInfo:@{NSLocalizedDescriptionKey: message}];
    [self exceptionMessage:@"" error:error];
}

// MARK: - Plugin Loading

+ (BOOL)canLoadPlugin:(NSString *)flname {
    if (![self noPlugins]) return YES;
    
    NSString *name = [[flname stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
    if ([name containsString:@"/pj"]) return YES;
    if ([name containsString:@"simpe.dockbox"]) return YES;
    
    return NO;
}

// MARK: - Key/Shortcut Support

+ (NSString *)toKeys:(NSString *)shortcut {
    NSMutableString *result = [NSMutableString string];
    NSString *name = [shortcut lowercaseString];
    
    if ([name containsString:@"ctrl"]) [result appendString:@"⌘"];
    if ([name containsString:@"shift"]) [result appendString:@"⇧"];
    if ([name containsString:@"alt"]) [result appendString:@"⌥"];
    
    // Add key mappings as needed
    return [result copy];
}

// MARK: - Private Helper Methods

+ (NSArray<NSString *> *)knownHoods {
    if (!_knownHoods) {
        [self loadKnownHoods];
    }
    return _knownHoods;
}

+ (void)loadKnownHoods {
    _knownHoods = @[];
    
    NSString *hoodsFile = [[self simPeDataPath] stringByAppendingPathComponent:@"hoods.xml"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:hoodsFile]) {
        return;
    }
    
    NSData *data = [NSData dataWithContentsOfFile:hoodsFile];
    if (!data) return;
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    HoodsXMLDelegate *delegate = [[HoodsXMLDelegate alloc] init];
    parser.delegate = delegate;
    [parser parse];
    _knownHoods = [delegate.hoods copy];
}

@end

// MARK: - DataFolder Implementation

@implementation DataFolder

+ (NSString *)profiles {
    NSString *path = [[Helper simPeDataPath] stringByAppendingPathComponent:@"Profiles"];
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
    }
    return path;
}

+ (NSString *)profilePath:(NSString *)s {
    return [self profilePath:s readOnly:NO];
}

+ (NSString *)profilePath:(NSString *)s readOnly:(BOOL)readOnly {
    NSString *path = [Helper simPeDataPath];
    if ([AppPreferences profile].length > 0 && readOnly) {
        path = [[[Helper simPeDataPath] stringByAppendingPathComponent:@"Profiles"] stringByAppendingPathComponent:[AppPreferences profile]];
    }
    return [path stringByAppendingPathComponent:s];
}

+ (NSString *)simPeXREGW {
    return [self profilePath:@"simpe.xreg"];
}

+ (NSString *)simPeXREG {
    return [self profilePath:@"simpe.xreg" readOnly:YES];
}

+ (NSString *)simPeLayoutW {
    return [self profilePath:@"simpe.layout"];
}

+ (NSString *)simPeLayout {
    return [self profilePath:@"simpe.layout" readOnly:YES];
}

+ (NSString *)layout2XREGW {
    return [self profilePath:@"layout2.xreg"];
}

+ (NSString *)layout2XREG {
    return [self profilePath:@"layout2.xreg" readOnly:YES];
}

+ (NSString *)foldersXREGW {
    return [self profilePath:@"folders.xreg"];
}

+ (NSString *)foldersXREG {
    return [self profilePath:@"folders.xreg" readOnly:YES];
}

+ (NSString *)mruXREGW {
    return [self profilePath:@"mru.xreg"];
}

+ (NSString *)mruXREG {
    return [self mruXREGW]; // Only one global MRU list
}

@end

// MARK: - HoodsXMLDelegate Implementation

@implementation HoodsXMLDelegate

- (instancetype)init {
    self = [super init];
    if (self) {
        _hoods = [NSMutableArray array];
    }
    return self;
}

- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
    attributes:(NSDictionary<NSString *,NSString *> *)attributeDict {
    if ([elementName isEqualToString:@"hood"]) {
        NSString *name = attributeDict[@"name"];
        if (name) {
            [self.hoods addObject:name];
        }
    }
}

@end
