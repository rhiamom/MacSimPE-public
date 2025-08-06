//
//  XmlRegistry.m
//  MacSimpe
//
//  Created by Catherine Gramze on 7/28/25.
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

#import "XmlRegistryKey.h"
#import "CaseInvariantArrayList.h"
#import "Helper.h"
#import "WarningException.h"
#import <Cocoa/Cocoa.h>

@interface XmlRegistryKey ()
@property (nonatomic, strong) NSMutableDictionary *tree;
@property (nonatomic, strong, readwrite) NSString *name;
@end

@implementation XmlRegistryKey

// MARK: - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        _tree = [[NSMutableDictionary alloc] init];
    }
    return self;
}

// MARK: - Private Helper Methods

- (NSArray<NSString *> *)getPath:(NSString *)key {
    return [key componentsSeparatedByString:@"\\"];
}

- (XmlRegistryKey *)openLocalSubKey:(NSString *)name create:(BOOL)create {
    if ([self.tree objectForKey:name] != nil) {
        id object = [self.tree objectForKey:name];
        if (object != nil && ![object isKindOfClass:[XmlRegistryKey class]]) {
            @throw [NSException exceptionWithName:@"InvalidKeyException"
                                          reason:[NSString stringWithFormat:@"The SubElement %@ is not a Key!", name]
                                        userInfo:nil];
        }
        return (XmlRegistryKey *)object;
    }
    
    if (create) {
        XmlRegistryKey *xrk = [[XmlRegistryKey alloc] init];
        xrk.name = name;
        [self.tree setObject:xrk forKey:name];
        return [self createSubKey:name];
    }
    
    return nil;
}

- (XmlRegistryKey *)openSubKeyWithPath:(NSArray<NSString *> *)path create:(BOOL)create {
    XmlRegistryKey *key = self;
    
    NSString *curkey = @"";
    for (NSInteger i = 0; i < [path count]; i++) {
        key = [key openLocalSubKey:path[i] create:create];
        curkey = [curkey stringByAppendingFormat:@"\\%@", path[i]];
        if (key == nil) return nil;
    }
    
    return key;
}

- (void)deleteSubKeyWithPath:(NSArray<NSString *> *)path throwOnException:(BOOL)throwOnException {
    if ([path count] < 1) return;
    
    XmlRegistryKey *key = self;
    NSString *curkey = @"";
    
    for (NSInteger i = 0; i < [path count] - 1; i++) {
        key = [key openLocalSubKey:path[i] create:NO];
        curkey = [curkey stringByAppendingFormat:@"\\%@", path[i]];
        if (key == nil) {
            if (throwOnException) {
                @throw [NSException exceptionWithName:@"KeyNotFoundException"
                                              reason:[NSString stringWithFormat:@"The Key %@ was not found!", curkey]
                                            userInfo:nil];
            } else {
                return;
            }
        }
    }
    
    NSString *name = [path lastObject];
    if (![key.tree objectForKey:name] && throwOnException) {
        @throw [NSException exceptionWithName:@"KeyNotFoundException"
                                      reason:[NSString stringWithFormat:@"The Key %@ was not found!", curkey]
                                    userInfo:nil];
    }
    if ([key.tree objectForKey:name]) {
        [key.tree removeObjectForKey:name];
    }
}

// MARK: - Public Methods

- (XmlRegistryKey *)createSubKey:(NSString *)name {
    XmlRegistryKey *xrk = [self openSubKey:name create:YES];
    return xrk;
}

- (XmlRegistryKey *)openSubKey:(NSString *)name create:(BOOL)create {
    return [self openSubKeyWithPath:[self getPath:name] create:create];
}

- (void)deleteSubKey:(NSString *)name throwOnException:(BOOL)throwOnException {
    [self deleteSubKeyWithPath:[self getPath:name] throwOnException:throwOnException];
}

- (void)setValue:(NSString *)name object:(id)object {
    [self.tree setObject:object forKey:name];
}

- (id)getValue:(NSString *)name {
    return [self getValue:name defaultValue:nil];
}

- (id)getValue:(NSString *)name defaultValue:(id)defaultValue {
    id object = [self.tree objectForKey:name];
    if (defaultValue != nil && object == nil) object = defaultValue;
    if (object != nil && [object isKindOfClass:[XmlRegistryKey class]]) {
        @throw [NSException exceptionWithName:@"InvalidValueException"
                                      reason:[NSString stringWithFormat:@"The SubElement %@ is a Key!", name]
                                    userInfo:nil];
    }
    return object;
}

- (NSArray<NSString *> *)getSubKeyNames {
    NSMutableArray<NSString *> *list = [[NSMutableArray alloc] init];
    
    for (NSString *key in [self.tree allKeys]) {
        if ([[self.tree objectForKey:key] isKindOfClass:[XmlRegistryKey class]]) {
            [list addObject:key];
        }
    }
    
    return [list copy];
}

- (NSArray<NSString *> *)getValueNames {
    NSMutableArray<NSString *> *list = [[NSMutableArray alloc] init];
    
    for (NSString *key in [self.tree allKeys]) {
        if (![[self.tree objectForKey:key] isKindOfClass:[XmlRegistryKey class]]) {
            [list addObject:key];
        }
    }
    
    return [list copy];
}

@end

@interface XmlRegistry ()
@property (nonatomic, strong) NSString *filename;
@property (nonatomic, strong, readwrite) XmlRegistryKey *currentUser;
@end

@implementation XmlRegistry

// MARK: - Initialization

- (instancetype)initWithInputFile:(NSString *)inFilename
                       outputFile:(NSString *)outFilename
                           create:(BOOL)create {
    self = [super init];
    if (self) {
#ifdef DEBUG
        NSLog(@"Loading Settings from \"%@\".", inFilename);
#endif
        _currentUser = [[XmlRegistryKey alloc] init];
        
        if (create) {
            NSString *directory = [outFilename stringByDeletingLastPathComponent];
            if (![[NSFileManager defaultManager] fileExistsAtPath:directory]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:directory
                                           withIntermediateDirectories:YES
                                                            attributes:nil
                                                                 error:nil];
            }
            if (![[NSFileManager defaultManager] fileExistsAtPath:outFilename]) {
                [self flushToFile:outFilename];
            }
        }
        
        _filename = outFilename;
        
        // Read XML File
        NSError *error = nil;
        NSXMLDocument *xmlDocument = [[NSXMLDocument alloc] initWithContentsOfURL:[NSURL fileURLWithPath:inFilename]
                                                                          options:0
                                                                            error:&error];
        if (error) {
            NSLog(@"Error loading XML file: %@", error.localizedDescription);
            return self;
        }
        
        // Seek Root Node
        NSArray *XMLData = [xmlDocument nodesForXPath:@"//registry" error:&error];
        if (error) {
            NSLog(@"Error finding registry nodes: %@", error.localizedDescription);
            return self;
        }
        
        // Process all Root Node Entries
        for (NSXMLElement *node in XMLData) {
            [self parseSubNode:node key:_currentUser];
        }
    }
    return self;
}

// MARK: - XML Parsing

- (void)parseValues:(NSXMLElement *)subnode key:(XmlRegistryKey *)subkey {
    NSString *nodeName = [subnode name];
    
    if ([nodeName isEqualToString:@"string"]) {
        [self parseStringValue:subnode key:subkey];
    } else if ([nodeName isEqualToString:@"int"]) {
        [self parseIntValue:subnode key:subkey];
    } else if ([nodeName isEqualToString:@"uint"]) {
        [self parseUIntValue:subnode key:subkey];
    } else if ([nodeName isEqualToString:@"long"]) {
        [self parseLongValue:subnode key:subkey];
    } else if ([nodeName isEqualToString:@"ulong"]) {
        [self parseULongValue:subnode key:subkey];
    } else if ([nodeName isEqualToString:@"bool"]) {
        [self parseBoolValue:subnode key:subkey];
    } else if ([nodeName isEqualToString:@"float"]) {
        [self parseFloatValue:subnode key:subkey];
    } else if ([nodeName isEqualToString:@"datetime"]) {
        [self parseDateTimeValue:subnode key:subkey];
    }
}

- (void)parseSubNode:(NSXMLElement *)node key:(XmlRegistryKey *)key {
    XmlRegistryKey *subkey = key;
    
    // Remember the Name of the Node
    if ([[node name] isEqualToString:@"key"]) {
        NSString *keyName = [[node attributeForName:@"name"] stringValue];
        if (keyName) {
            subkey = [key createSubKey:keyName];
        }
    }
    
    for (NSXMLElement *subnode in [node children]) {
        if (!([subnode isKindOfClass:[NSXMLElement class]])) continue;
        
        NSString *subnodeName = [subnode name];
        if ([subnodeName isEqualToString:@"key"]) {
            [self parseSubNode:subnode key:subkey];
        } else if ([subnodeName isEqualToString:@"list"]) {
            [self parseListNode:subnode key:subkey caseInvariant:NO];
        } else if ([subnodeName isEqualToString:@"cilist"]) {
            [self parseListNode:subnode key:subkey caseInvariant:YES];
        } else {
            [self parseValues:subnode key:subkey];
        }
    }
}

- (void)parseListNode:(NSXMLElement *)node key:(XmlRegistryKey *)key caseInvariant:(BOOL)caseInvariant {
    XmlRegistryKey *subkey = [[XmlRegistryKey alloc] init];
    NSMutableArray *names = [[NSMutableArray alloc] init];
    
    for (NSXMLElement *subnode in [node children]) {
        if (!([subnode isKindOfClass:[NSXMLElement class]])) continue;
        NSXMLNode *nameAttribute = [subnode attributeForName:@"name"];
        if (nameAttribute == nil) continue;
        
        [names addObject:[nameAttribute stringValue]];
        [self parseValues:subnode key:subkey];
    }
    
    NSMutableArray *list = nil;
    if (!caseInvariant) {
        list = [[NSMutableArray alloc] init];
    } else {
        list = [[CaseInvariantArrayList alloc] init];
    }
    
    for (NSString *name in names) {
        [list addObject:[subkey getValue:name]];
    }
    
    NSString *listName = [[node attributeForName:@"name"] stringValue];
    if (listName) {
        [key setValue:listName object:list];
    }
}

// MARK: - Parse Value Methods

- (void)parseDateTimeValue:(NSXMLElement *)node key:(XmlRegistryKey *)key {
    NSDate *val = [NSDate date];
    @try {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *parsedDate = [formatter dateFromString:[node stringValue]];
        if (parsedDate) val = parsedDate;
    } @catch (NSException *exception) {
        // Use default value
    }
    NSString *name = [[node attributeForName:@"name"] stringValue];
    if (name) [key setValue:name object:val];
}

- (void)parseIntValue:(NSXMLElement *)node key:(XmlRegistryKey *)key {
    NSInteger val = 0;
    @try {
        val = [[node stringValue] integerValue];
    } @catch (NSException *exception) {
        // Use default value
    }
    NSString *name = [[node attributeForName:@"name"] stringValue];
    if (name) [key setValue:name object:@(val)];
}

- (void)parseUIntValue:(NSXMLElement *)node key:(XmlRegistryKey *)key {
    NSUInteger val = 0;
    @try {
        val = (NSUInteger)[[node stringValue] longLongValue];
    } @catch (NSException *exception) {
        // Use default value
    }
    NSString *name = [[node attributeForName:@"name"] stringValue];
    if (name) [key setValue:name object:@(val)];
}

- (void)parseLongValue:(NSXMLElement *)node key:(XmlRegistryKey *)key {
    long long val = 0;
    @try {
        val = [[node stringValue] longLongValue];
    } @catch (NSException *exception) {
        // Use default value
    }
    NSString *name = [[node attributeForName:@"name"] stringValue];
    if (name) [key setValue:name object:@(val)];
}

- (void)parseULongValue:(NSXMLElement *)node key:(XmlRegistryKey *)key {
    unsigned long long val = 0;
    @try {
        val = (unsigned long long)[[node stringValue] longLongValue];
    } @catch (NSException *exception) {
        // Use default value
    }
    NSString *name = [[node attributeForName:@"name"] stringValue];
    if (name) [key setValue:name object:@(val)];
}

- (void)parseFloatValue:(NSXMLElement *)node key:(XmlRegistryKey *)key {
    float val = 0.0f;
    @try {
        val = [[node stringValue] floatValue];
    } @catch (NSException *exception) {
        // Use default value
    }
    NSString *name = [[node attributeForName:@"name"] stringValue];
    if (name) [key setValue:name object:@(val)];
}

- (void)parseBoolValue:(NSXMLElement *)node key:(XmlRegistryKey *)key {
    BOOL val = NO;
    @try {
        NSString *s = [[[node stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
        if ([s isEqualToString:@"false"] || [s isEqualToString:@"no"] ||
            [s isEqualToString:@"off"] || [s isEqualToString:@"0"]) {
            val = NO;
        } else {
            val = YES;
        }
    } @catch (NSException *exception) {
        // Use default value
    }
    NSString *name = [[node attributeForName:@"name"] stringValue];
    if (name) [key setValue:name object:@(val)];
}

- (void)parseStringValue:(NSXMLElement *)node key:(XmlRegistryKey *)key {
    NSString *val = [node stringValue];
    NSString *name = [[node attributeForName:@"name"] stringValue];
    if (name) [key setValue:name object:val];
}

// MARK: - Writing

- (void)flush {
    [self flushToFile:self.filename];
}

- (void)flushToFile:(NSString *)filename {
    @try {
        NSString *directory = [filename stringByDeletingLastPathComponent];
        if (![[NSFileManager defaultManager] fileExistsAtPath:directory]) {
            @throw [NSException exceptionWithName:@"DirectoryNotFoundException"
                                          reason:[NSString stringWithFormat:@"Directory \"%@\" not found!", directory]
                                        userInfo:nil];
        }
        
        NSMutableString *xmlContent = [[NSMutableString alloc] init];
        [xmlContent appendString:@"<?xml version=\"1.0\" encoding=\"utf-8\" ?>\n"];
        [xmlContent appendString:@"<registry>\n"];
        
        [self writeKey:xmlContent key:self.currentUser];
        
        [xmlContent appendString:@"</registry>\n"];
        
        NSError *error = nil;
        [xmlContent writeToFile:filename
                     atomically:YES
                       encoding:NSUTF8StringEncoding
                          error:&error];
        if (error) {
            @throw [NSException exceptionWithName:@"FileWriteException"
                                          reason:[NSString stringWithFormat:@"Unable to write to file: %@", error.localizedDescription]
                                        userInfo:nil];
        }
        
    } @catch (NSException *ex) {
            Warning *warning = [[Warning alloc] initWithTitle:@"Unable to create settings File."
                                                  description:[NSString stringWithFormat:@"SimPE was unable to create the file %@.\n\nYour Settings won't be saved!", filename]
                                                    exception:ex];
            // Display the warning to the user
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:warning.message];
            [alert setInformativeText:warning.details];
            [alert setAlertStyle:NSAlertStyleWarning];
            [alert runModal];
        }
    }

- (void)writeKey:(NSMutableString *)xmlContent key:(XmlRegistryKey *)key {
    if (key != self.currentUser) {
        [xmlContent appendFormat:@"<key name=\"%@\">\n", key.name];
    }
    
    NSArray<NSString *> *keys = [key getSubKeyNames];
    for (NSString *keyName in keys) {
        [self writeKey:xmlContent key:[key openSubKey:keyName create:NO]];
    }
    
    NSArray<NSString *> *values = [key getValueNames];
    for (NSString *valueName in values) {
        [self writeValue:xmlContent name:valueName object:[key getValue:valueName]];
    }
    
    if (key != self.currentUser) {
        [xmlContent appendString:@"</key>\n"];
    }
}

- (void)writeValue:(NSMutableString *)xmlContent name:(NSString *)name object:(id)object {
    if (object == nil) return;
    
    NSString *tag = @"string";
    NSString *val = [object description];
    
    if ([object isKindOfClass:[NSNumber class]]) {
        NSNumber *number = (NSNumber *)object;
        const char *type = [number objCType];
        
        if (strcmp(type, @encode(int)) == 0 || strcmp(type, @encode(short)) == 0 || strcmp(type, @encode(char)) == 0) {
            tag = @"int";
        } else if (strcmp(type, @encode(unsigned int)) == 0 || strcmp(type, @encode(unsigned short)) == 0) {
            tag = @"uint";
        } else if (strcmp(type, @encode(long long)) == 0) {
            tag = @"long";
        } else if (strcmp(type, @encode(unsigned long long)) == 0) {
            tag = @"ulong";
        } else if (strcmp(type, @encode(BOOL)) == 0) {
            tag = @"bool";
            val = [number boolValue] ? @"true" : @"false";
        } else if (strcmp(type, @encode(float)) == 0) {
            tag = @"float";
        }
    } else if ([object isKindOfClass:[NSDate class]]) {
        tag = @"datetime";
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        val = [formatter stringFromDate:(NSDate *)object];
    } else if ([object isKindOfClass:[CaseInvariantArrayList class]]) {
        [self writeList:xmlContent name:name list:(NSArray *)object caseInvariant:YES];
        return;
    } else if ([object isKindOfClass:[NSArray class]]) {
        [self writeList:xmlContent name:name list:(NSArray *)object caseInvariant:NO];
        return;
    }
    
    // XML escape the value
    val = [val stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
    val = [val stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
    val = [val stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
    
    [xmlContent appendFormat:@"<%@ name=\"%@\">%@</%@>\n", tag, name, val, tag];
}

- (void)writeList:(NSMutableString *)xmlContent name:(NSString *)name list:(NSArray *)list caseInvariant:(BOOL)caseInvariant {
    if (!caseInvariant) {
        [xmlContent appendFormat:@"<list name=\"%@\">\n", name];
    } else {
        [xmlContent appendFormat:@"<cilist name=\"%@\">\n", name];
    }
    
    NSInteger ct = -1;
    for (id object in list) {
        ct++;
        if (object == nil) continue;
        if ([object isKindOfClass:[NSArray class]]) continue;
        [self writeValue:xmlContent name:[NSString stringWithFormat:@"%ld", (long)ct] object:object];
    }
    
    if (!caseInvariant) {
        [xmlContent appendString:@"</list>\n"];
    } else {
        [xmlContent appendString:@"</cilist>\n"];
    }
}

@end
