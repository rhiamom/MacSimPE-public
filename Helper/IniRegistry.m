//
//  IniRegistry.m
//  MacSimpe
//
//  Created by Catherine Gramze on 7/28/25.
//
// ***************************************************************************
// *   Copyright (C) 2007 by Ambertation                                     *
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

#import "IniRegistry.h"

@interface IniRegistry ()
@property (nonatomic, strong, readwrite) NSMutableDictionary<NSString *, IniRegistrySectionContent *> *sections;
@end

// MARK: - IniRegistrySectionContent Implementation

@implementation IniRegistrySectionContent

- (instancetype)init {
    self = [super init];
    if (self) {
        _keyValuePairs = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)createKey:(NSString *)key {
    [self setValue:@"" forKey:key];
}

- (void)setValue:(NSString *)value forKey:(NSString *)key {
    [self setValue:value forKey:key createIfNeeded:YES];
}

- (void)setValue:(NSString *)value forKey:(NSString *)key createIfNeeded:(BOOL)create {
    if (![self containsKey:key]) {
        if (create) {
            [self.keyValuePairs setObject:value forKey:key];
        }
    } else if (create) {
        NSString *actualKey = nil;
        for (NSString *existingKey in self.keyValuePairs.allKeys) {
            if ([IniRegistry keyCompare:existingKey withKey:key]) {
                actualKey = existingKey;
                break;
            }
        }
        
        if (actualKey != nil) {
            [self.keyValuePairs setObject:value forKey:actualKey];
        }
    }
}

- (NSString *)getValue:(NSString *)key {
    return [self getValue:key defaultValue:nil];
}

- (NSString *)getValue:(NSString *)key defaultValue:(NSString *)defaultValue {
    for (NSString *existingKey in self.keyValuePairs.allKeys) {
        if ([IniRegistry keyCompare:existingKey withKey:key]) {
            return [self.keyValuePairs objectForKey:existingKey];
        }
    }
    return defaultValue;
}

- (BOOL)containsKey:(NSString *)key {
    for (NSString *existingKey in self.keyValuePairs.allKeys) {
        if ([IniRegistry keyCompare:existingKey withKey:key]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)removeKey:(NSString *)key {
    NSString *keyToRemove = nil;
    for (NSString *existingKey in self.keyValuePairs.allKeys) {
        if ([IniRegistry keyCompare:existingKey withKey:key]) {
            keyToRemove = existingKey;
            break;
        }
    }
    
    if (keyToRemove != nil) {
        [self.keyValuePairs removeObjectForKey:keyToRemove];
        return YES;
    }
    return NO;
}

- (void)clear {
    [self.keyValuePairs removeAllObjects];
}

// MARK: - Subscript Access

- (NSString *)objectForKeyedSubscript:(NSString *)key {
    return [self getValue:key];
}

- (void)setObject:(NSString *)value forKeyedSubscript:(NSString *)key {
    [self setValue:value forKey:key createIfNeeded:YES];
}

// MARK: - NSFastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len {
    return [self.keyValuePairs countByEnumeratingWithState:state objects:buffer count:len];
}

@end

// MARK: - IniRegistry Implementation

@implementation IniRegistry

+ (BOOL)keyCompare:(NSString *)key1 withKey:(NSString *)key2 {
    NSString *trimmed1 = [[key1 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
    NSString *trimmed2 = [[key2 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
    return [trimmed1 isEqualToString:trimmed2];
}

// MARK: - Initialization

- (instancetype)initWithFileName:(NSString *)fileName readOnly:(BOOL)readOnly {
    self = [self initWithFileName:fileName];
    if (self) {
        _fileIsReadOnly = readOnly;
    }
    return self;
}

- (instancetype)initWithFileName:(NSString *)fileName {
    NSInputStream *stream = [NSInputStream inputStreamWithFileAtPath:fileName];
    self = [self initWithStreamReader:stream];
    if (self) {
        _iniFile = [fileName copy];
    }
    return self;
}

- (instancetype)initWithStreamReader:(NSInputStream *)stream {
    self = [super init];
    if (self) {
        _sections = [[NSMutableDictionary alloc] init];
        _fileIsReadOnly = YES;
        
        [stream open];
        
        NSString *currentSection = @"";
        
        uint8_t buffer[1024];
        NSMutableData *data = [[NSMutableData alloc] init];
        
        while ([stream hasBytesAvailable]) {
            NSInteger bytesRead = [stream read:buffer maxLength:sizeof(buffer)];
            if (bytesRead > 0) {
                [data appendBytes:buffer length:bytesRead];
            }
        }
        
        [stream close];
        
        NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSArray *lines = [content componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        
        for (NSString *line in lines) {
            NSString *trimmedLine = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            if ([trimmedLine length] == 0 || [trimmedLine hasPrefix:@";"]) {
                continue;
            }
            
            // Remove comments
            NSRange commentRange = [trimmedLine rangeOfString:@";"];
            if (commentRange.location != NSNotFound && commentRange.location > 0) {
                trimmedLine = [[trimmedLine substringToIndex:commentRange.location]
                              stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            }
            
            if ([trimmedLine hasPrefix:@"["]) {
                if ([trimmedLine hasSuffix:@"]"]) {
                    currentSection = [[trimmedLine substringWithRange:NSMakeRange(1, [trimmedLine length] - 2)]
                                     stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    [_sections setObject:[[IniRegistrySectionContent alloc] init] forKey:currentSection];
                    continue;
                }
                // fall through to error case
            } else if ([trimmedLine containsString:@"="]) {
                NSArray *parts = [trimmedLine componentsSeparatedByString:@"="];
                if ([parts count] >= 2) {
                    NSString *key = [[parts objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    
                    // Join remaining parts in case value contains "="
                    NSMutableArray *valueParts = [[parts subarrayWithRange:NSMakeRange(1, [parts count] - 1)] mutableCopy];
                    NSString *value = [[valueParts componentsJoinedByString:@"="]
                                      stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    
                    IniRegistrySectionContent *section = [_sections objectForKey:currentSection];
                    if (section == nil) {
                        section = [[IniRegistrySectionContent alloc] init];
                        [_sections setObject:section forKey:currentSection];
                    }
                    
                    [section setValue:[value lowercaseString] forKey:[key lowercaseString] createIfNeeded:YES];
                    continue;
                }
            }
            
            @throw [NSException exceptionWithName:@"IniParseException"
                                           reason:[NSString stringWithFormat:@"Invalid ini file line: %@", trimmedLine]
                                         userInfo:nil];
        }
    }
    return self;
}

// MARK: - File Operations

- (BOOL)flush {
    if (self.fileIsReadOnly) return NO;
    if ([self.iniFile length] == 0) return NO;
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.iniFile]) return NO;
    
    @try {
        NSMutableString *content = [[NSMutableString alloc] init];
        BOOL wantBlank = NO;
        
        for (NSString *sectionName in self.sections.allKeys) {
            if (wantBlank) {
                [content appendString:@"\n"];
            }
            [content appendFormat:@"[%@]\n", sectionName];
            wantBlank = YES;
            
            IniRegistrySectionContent *section = [self.sections objectForKey:sectionName];
            for (NSString *key in section.keyValuePairs.allKeys) {
                NSString *value = [section.keyValuePairs objectForKey:key];
                [content appendFormat:@"%@=%@\n", key, value];
            }
        }
        
        return [content writeToFile:self.iniFile
                         atomically:YES
                           encoding:NSUTF8StringEncoding
                              error:nil];
    } @catch (NSException *exception) {
        return NO;
    }
}

// MARK: - Section Management

- (IniRegistrySectionContent *)createSection:(NSString *)sectionName {
    return [self getSection:sectionName createIfNeeded:YES];
}

- (IniRegistrySectionContent *)getSection:(NSString *)sectionName {
    return [self getSection:sectionName createIfNeeded:YES];
}

- (IniRegistrySectionContent *)getSection:(NSString *)sectionName createIfNeeded:(BOOL)create {
    for (NSString *existingSection in self.sections.allKeys) {
        if ([[self class] keyCompare:sectionName withKey:existingSection]) {
            return [self.sections objectForKey:existingSection];
        }
    }
    
    if (!create) return nil;
    
    IniRegistrySectionContent *newSection = [[IniRegistrySectionContent alloc] init];
    [self.sections setObject:newSection forKey:sectionName];
    
    return newSection;
}

- (BOOL)containsSection:(NSString *)sectionName {
    IniRegistrySectionContent *section = [self getSection:sectionName createIfNeeded:NO];
    return section != nil;
}

- (BOOL)removeSection:(NSString *)sectionName {
    NSString *sectionToRemove = nil;
    for (NSString *existingSection in self.sections.allKeys) {
        if ([[self class] keyCompare:existingSection withKey:sectionName]) {
            sectionToRemove = existingSection;
            break;
        }
    }
    
    if (sectionToRemove != nil) {
        [self.sections removeObjectForKey:sectionToRemove];
        return YES;
    }
    return NO;
}

- (void)clearSection:(NSString *)sectionName {
    IniRegistrySectionContent *section = [self getSection:sectionName createIfNeeded:NO];
    if (section != nil) {
        [section clear];
    }
}

// MARK: - Direct Key Access

- (NSString *)getValue:(NSString *)key inSection:(NSString *)section {
    return [self getValue:key inSection:section defaultValue:nil];
}

- (NSString *)getValue:(NSString *)key inSection:(NSString *)section defaultValue:(NSString *)defaultValue {
    IniRegistrySectionContent *sectionContent = [self getSection:section createIfNeeded:NO];
    if (sectionContent != nil) {
        return [sectionContent getValue:key defaultValue:defaultValue];
    }
    return defaultValue;
}

- (void)setValue:(NSString *)value forKey:(NSString *)key inSection:(NSString *)section {
    [self setValue:value forKey:key inSection:section createIfNeeded:YES];
}

- (void)setValue:(NSString *)value forKey:(NSString *)key inSection:(NSString *)section createIfNeeded:(BOOL)create {
    IniRegistrySectionContent *sectionContent = [self getSection:section createIfNeeded:YES];
    if (sectionContent != nil) {
        [sectionContent setValue:value forKey:key createIfNeeded:create];
    }
}

// MARK: - Subscript Access

- (IniRegistrySectionContent *)objectForKeyedSubscript:(NSString *)sectionName {
    return [self getSection:sectionName createIfNeeded:NO];
}

- (void)setObject:(IniRegistrySectionContent *)section forKeyedSubscript:(NSString *)sectionName {
    [self.sections setObject:section forKey:sectionName];
}

// MARK: - NSFastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len {
    return [self.sections countByEnumeratingWithState:state objects:buffer count:len];
}

@end
