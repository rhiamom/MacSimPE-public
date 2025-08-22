//
//  SemiGlobalListing.m
//  MacSimpe
//
//  Created by Catherine Gramze on 8/22/25.
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

#import "SemiGlobalListing.h"
#import "SemiGlobalAlias.h"
#import "Helper.h"

@implementation SemiGlobalListing {
    NSMutableArray<SemiGlobalAlias *> *_storage;
}

- (instancetype)init {
    return [self initWithFilename:[Helper simPeSemiGlobalFile]];
}

- (instancetype)initWithFilename:(NSString *)filename {
    self = [super init];
    if (self) {
        _filename = [filename copy];
        _storage = [[NSMutableArray alloc] init];
        [self loadXML];
    }
    return self;
}

#pragma mark - XML Loading

- (void)loadXML {
    NSError *error = nil;
    NSData *xmlData = [NSData dataWithContentsOfFile:_filename options:0 error:&error];
    
    if (!xmlData) {
        NSLog(@"Failed to load XML file: %@, error: %@", _filename, error.localizedDescription);
        return;
    }
    
    NSXMLDocument *xmlDocument = [[NSXMLDocument alloc] initWithData:xmlData options:0 error:&error];
    
    if (!xmlDocument) {
        NSLog(@"Failed to parse XML file: %@, error: %@", _filename, error.localizedDescription);
        return;
    }
    
    // Seek Root Node
    NSArray<NSXMLElement *> *semiglobalElements = [xmlDocument.rootElement elementsForName:@"semiglobals"];
    
    // Process all Root Node Entries
    for (NSXMLElement *semiglobalElement in semiglobalElements) {
        for (NSXMLNode *childNode in semiglobalElement.children) {
            if ([childNode isKindOfClass:[NSXMLElement class]]) {
                [self processItem:(NSXMLElement *)childNode];
            }
        }
    }
}

- (void)processItem:(NSXMLElement *)element {
    BOOL known = NO;
    uint32_t group = 0;
    NSString *name = @"";
    
    for (NSXMLNode *subnode in element.children) {
        if ([subnode isKindOfClass:[NSXMLElement class]]) {
            NSXMLElement *subelement = (NSXMLElement *)subnode;
            
            if ([subelement.name isEqualToString:@"known"]) {
                known = YES;
            } else if ([subelement.name isEqualToString:@"group"]) {
                group = [Helper stringToUInt32:subelement.stringValue default:0 base:16];
            } else if ([subelement.name isEqualToString:@"name"]) {
                name = [subelement.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            }
        }
    }
    
    if (![name isEqualToString:@""] && group != 0) {
        SemiGlobalAlias *alias = [[SemiGlobalAlias alloc] initWithKnown:known id:group name:name];
        [_storage addObject:alias];
    }
}

#pragma mark - NSMutableArray Override Methods

- (NSUInteger)count {
    return _storage.count;
}

- (id)objectAtIndex:(NSUInteger)index {
    return [_storage objectAtIndex:index];
}

- (void)insertObject:(id)object atIndex:(NSUInteger)index {
    [_storage insertObject:object atIndex:index];
}

- (void)removeObjectAtIndex:(NSUInteger)index {
    [_storage removeObjectAtIndex:index];
}

- (void)addObject:(id)object {
    [_storage addObject:object];
}

- (void)removeLastObject {
    [_storage removeLastObject];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)object {
    [_storage replaceObjectAtIndex:index withObject:object];
}

#pragma mark - Additional Array Methods

- (NSArray<SemiGlobalAlias *> *)allObjects {
    return [_storage copy];
}

- (SemiGlobalAlias *)firstObject {
    return _storage.firstObject;
}

- (SemiGlobalAlias *)lastObject {
    return _storage.lastObject;
}

- (BOOL)containsObject:(SemiGlobalAlias *)object {
    return [_storage containsObject:object];
}

- (NSUInteger)indexOfObject:(SemiGlobalAlias *)object {
    return [_storage indexOfObject:object];
}

- (void)removeObject:(SemiGlobalAlias *)object {
    [_storage removeObject:object];
}

- (void)removeAllObjects {
    [_storage removeAllObjects];
}

#pragma mark - Fast Enumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len {
    return [_storage countByEnumeratingWithState:state objects:buffer count:len];
}

@end
