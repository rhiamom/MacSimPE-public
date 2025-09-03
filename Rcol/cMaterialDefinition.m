//
//  cMaterialDefinition.m
//  MacSimpe
//
//  Created by Catherine Gramze on 8/30/25.
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

#import "cMaterialDefinition.h"
#import "BinaryReader.h"
#import "BinaryWriter.h"
#import "RcolWrapper.h"
#import "cSGResource.h"
#import "Helper.h"
#import "Vectors.h"
#import "PropertyParser.h"
#import "ScenegraphHelper.h"
#import "IPackedFileDescriptor.h"
#import "MetaData.h"

// MARK: - MaterialDefinitionProperty Implementation

@implementation MaterialDefinitionProperty

- (instancetype)init {
    self = [super init];
    if (self) {
        _name = @"";
        _value = @"";
    }
    return self;
}

- (void)unserialize:(BinaryReader *)reader {
    self.name = [reader readString];
    self.value = [reader readString];
}

- (void)serialize:(BinaryWriter *)writer {
    [writer writeString:self.name];
    [writer writeString:self.value];
}

- (double)toValue {
    NSArray<NSNumber *> *floatArray = [self toFloatArray];
    if (floatArray.count > 0) {
        return floatArray[0].doubleValue;
    }
    return 0.0;
}

- (Vector2 *)toVector2 {
    NSArray<NSNumber *> *floatArray = [self toFloatArray];
    Vector2 *v = [Vector2 zero];
    if (floatArray.count > 0) v.x = floatArray[0].doubleValue;
    if (floatArray.count > 1) v.y = floatArray[1].doubleValue;
    return v;
}

- (Vector3 *)toVector3 {
    NSArray<NSNumber *> *floatArray = [self toFloatArray];
    Vector3 *v = [Vector3 zero];
    if (floatArray.count > 0) v.x = floatArray[0].doubleValue;
    if (floatArray.count > 1) v.y = floatArray[1].doubleValue;
    if (floatArray.count > 2) v.z = floatArray[2].doubleValue;
    return v;
}

- (Vector4 *)toVector4 {
    NSArray<NSNumber *> *floatArray = [self toFloatArray];
    Vector4 *v = [[Vector4 alloc] initWithX:0 y:0 z:0 w:0];
    if (floatArray.count > 0) v.x = floatArray[0].doubleValue;
    if (floatArray.count > 1) v.y = floatArray[1].doubleValue;
    if (floatArray.count > 2) v.z = floatArray[2].doubleValue;
    if (floatArray.count > 3) v.w = floatArray[3].doubleValue;
    return v;
}

- (NSArray<NSNumber *> *)toFloatArray {
    NSMutableArray<NSNumber *> *result = [[NSMutableArray alloc] init];
    NSArray<NSString *> *parts = [self.value componentsSeparatedByString:@","];
    
    for (NSString *part in parts) {
        NSString *trimmedPart = [part stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSScanner *scanner = [NSScanner scannerWithString:trimmedPart];
        double value;
        if ([scanner scanDouble:&value]) {
            [result addObject:@(value)];
        }
    }
    
    return [result copy];
}

- (NSColor *)toRGB {
    Vector3 *v = [self toVector3];
    [self clampVector3:v];
    return [NSColor colorWithRed:v.x green:v.y blue:v.z alpha:1.0];
}

- (NSColor *)toARGB {
    NSArray<NSNumber *> *floatArray = [self toFloatArray];
    if (floatArray.count < 4) {
        return [self toRGB];
    }
    Vector4 *v = [self toVector4];
    [self clampVector4:v];
    return [NSColor colorWithRed:v.x green:v.y blue:v.z alpha:v.w];
}

- (void)clampVector3:(Vector3 *)v {
    v.x = MAX(0, MIN(1, v.x));
    v.y = MAX(0, MIN(1, v.y));
    v.z = MAX(0, MIN(1, v.z));
}

- (void)clampVector4:(Vector4 *)v {
    v.x = MAX(0, MIN(1, v.x));
    v.y = MAX(0, MIN(1, v.y));
    v.z = MAX(0, MIN(1, v.z));
    v.w = MAX(0, MIN(1, v.w));
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@: %@", self.name, self.value];
}

@end

// MARK: - MaterialDefinition Implementation

@implementation MaterialDefinition

static PropertyParser *_propertyParser = nil;

+ (PropertyParser *)propertyParser {
    if (_propertyParser == nil) {
        NSString *path = [[Helper simPeDataPath] stringByAppendingPathComponent:@"txmtdefinition.xml"];
        _propertyParser = [[PropertyParser alloc] initWithPath:path];
    }
    return _propertyParser;
}

- (instancetype)initWithParent:(Rcol *)parent {
    self = [super initWithParent:parent];
    if (self) {
        _properties = @[];
        _listing = @[];
        self.sgres = [[SGResource alloc] initWithParent:nil];
        self.blockId = 0x49596978;
        _fileDescription = @"";
        _materialType = @"";
    }
    return self;
}

// MARK: - Property Management

- (MaterialDefinitionProperty *)findProperty:(NSString *)name {
    NSString *lowercaseName = [[name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
    for (MaterialDefinitionProperty *property in self.properties) {
        NSString *propertyName = [[property.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
        if ([propertyName isEqualToString:lowercaseName]) {
            return property;
        }
    }
    return [[MaterialDefinitionProperty alloc] init];
}

- (MaterialDefinitionProperty *)getProperty:(NSString *)name {
    return [self findProperty:name];
}

- (void)addProperty:(MaterialDefinitionProperty *)property {
    [self addProperty:property allowDuplicate:NO];
}

- (void)addProperty:(MaterialDefinitionProperty *)property allowDuplicate:(BOOL)allowDuplicate {
    if (!allowDuplicate) {
        MaterialDefinitionProperty *existing = nil;
        NSMutableArray *mutableProperties = [self.properties mutableCopy];
        
        NSString *newPropertyName = [[property.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
        
        for (NSInteger i = 0; i < mutableProperties.count; i++) {
            MaterialDefinitionProperty *existingProperty = mutableProperties[i];
            NSString *existingName = [[existingProperty.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
            
            if ([existingName isEqualToString:newPropertyName]) {
                existing = existingProperty;
                existing.value = property.value;
                break;
            }
        }
        
        if (existing == nil) {
            [mutableProperties addObject:property];
        }
        
        self.properties = [mutableProperties copy];
    } else {
        NSMutableArray *mutableProperties = [self.properties mutableCopy];
        [mutableProperties addObject:property];
        self.properties = [mutableProperties copy];
    }
}

- (void)sort {
    self.properties = [self.properties sortedArrayUsingComparator:^NSComparisonResult(MaterialDefinitionProperty *obj1, MaterialDefinitionProperty *obj2) {
        return [obj1.name compare:obj2.name];
    }];
}

// MARK: - IRcolBlock Implementation

- (void)unserialize:(BinaryReader *)reader {
    self.version = [reader readUInt32];
    
    NSString *name = [reader readString];
    uint32_t myId = [reader readUInt32];
    [self.sgres unserialize:reader];
    self.sgres.blockId = myId;
    
    self.fileDescription = [reader readString];
    self.materialType = [reader readString];
    
    uint32_t propertyCount = [reader readUInt32];
    NSMutableArray *propertiesArray = [[NSMutableArray alloc] initWithCapacity:propertyCount];
    
    for (int i = 0; i < propertyCount; i++) {
        MaterialDefinitionProperty *property = [[MaterialDefinitionProperty alloc] init];
        [property unserialize:reader];
        [propertiesArray addObject:property];
    }
    self.properties = [propertiesArray copy];
    
    if (self.version == 8) {
        self.listing = @[];
    } else {
        uint32_t listingCount = [reader readUInt32];
        NSMutableArray *listingArray = [[NSMutableArray alloc] initWithCapacity:listingCount];
        
        for (int i = 0; i < listingCount; i++) {
            [listingArray addObject:[reader readString]];
        }
        self.listing = [listingArray copy];
    }
}

- (void)serialize:(BinaryWriter *)writer {
    [writer writeUInt32:self.version];
    
    NSString *name = [self.sgres registerInListing:nil];
    [writer writeString:name];
    [writer writeUInt32:self.sgres.blockId];
    [self.sgres serialize:writer];
    
    [writer writeString:self.fileDescription];
    [writer writeString:self.materialType];
    
    [writer writeUInt32:(uint32_t)self.properties.count];
    for (MaterialDefinitionProperty *property in self.properties) {
        [property serialize:writer];
    }
    
    if (self.version != 8) {
        [writer writeUInt32:(uint32_t)self.listing.count];
        for (NSString *item in self.listing) {
            [writer writeString:item];
        }
    }
}

// MARK: - Import/Export

- (void)exportProperties:(NSString *)filename {
    NSError *error = nil;
    NSXMLDocument *document = [[NSXMLDocument alloc] initWithRootElement:nil];
    document.version = @"1.0";
    document.characterEncoding = @"UTF-8";
    
    NSXMLElement *root = [[NSXMLElement alloc] initWithName:@"materialDefinition"];
    [document setRootElement:root];
    
    NSString *sourceComment = [NSString stringWithFormat:@"Source: %@", self.parent.fileDescriptor.exportFileName];
    [root addChild:[NSXMLNode commentWithStringValue:sourceComment]];
    
    NSString *blockNameComment = [NSString stringWithFormat:@"Block name: %@", self.blockName];
    [root addChild:[NSXMLNode commentWithStringValue:blockNameComment]];
    
    NSString *fileDescComment = [NSString stringWithFormat:@"File description: %@", self.fileDescription];
    [root addChild:[NSXMLNode commentWithStringValue:fileDescComment]];
    
    NSString *materialTypeComment = [NSString stringWithFormat:@"Material Type: %@", self.materialType];
    [root addChild:[NSXMLNode commentWithStringValue:materialTypeComment]];
    
    for (MaterialDefinitionProperty *property in self.properties) {
        NSXMLElement *propElement = [[NSXMLElement alloc] initWithName:@"materialDefinitionProperty"];
        NSXMLNode *nameAttribute = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
        nameAttribute.name = @"name";
        nameAttribute.stringValue = property.name;
        [propElement addAttribute:nameAttribute];
        propElement.stringValue = property.value;
        [root addChild:propElement];
    }
    
    NSData *xmlData = [document XMLDataWithOptions:NSXMLNodePrettyPrint];
    if (![xmlData writeToFile:filename atomically:YES]) {
        NSLog(@"Failed to export properties to %@", filename);
    }
}

- (void)importProperties:(NSString *)filename {
    self.properties = @[];
    [self mergeProperties:filename];
}

- (void)mergeProperties:(NSString *)filename {
    NSError *error = nil;
    NSData *xmlData = [NSData dataWithContentsOfFile:filename];
    if (xmlData == nil) {
        NSLog(@"Failed to read file: %@", filename);
        return;
    }
    
    NSXMLDocument *document = [[NSXMLDocument alloc] initWithData:xmlData options:0 error:&error];
    if (document == nil) {
        NSLog(@"Failed to parse XML: %@", error.localizedDescription);
        return;
    }
    
    NSXMLElement *root = document.rootElement;
    if (![root.name isEqualToString:@"materialDefinition"]) {
        NSLog(@"Invalid XML format - expected materialDefinition root element");
        return;
    }
    
    NSArray *propertyElements = [root elementsForName:@"materialDefinitionProperty"];
    for (NSXMLElement *element in propertyElements) {
        MaterialDefinitionProperty *property = [[MaterialDefinitionProperty alloc] init];
        
        NSXMLNode *nameAttribute = [element attributeForName:@"name"];
        if (nameAttribute) {
            property.name = nameAttribute.stringValue;
        }
        
        property.value = element.stringValue ?: @"";
        [self addProperty:property allowDuplicate:NO];
    }
}

// MARK: - IScenegraphBlock Implementation

- (void)referencedItems:(NSMutableDictionary *)refMap parentGroup:(uint32_t)parentGroup {
    // TXTR references from listing
    NSMutableArray *txtrList = [[NSMutableArray alloc] init];
    for (NSString *name in self.listing) {
        NSString *txtrName = [NSString stringWithFormat:@"%@_txtr", name];
        id<IPackedFileDescriptor> pfd = [ScenegraphHelper buildPfdWithFilename:txtrName
                                                                          type:[MetaData TXTR]
                                                                  defaultGroup:parentGroup];
        [txtrList addObject:pfd];
    }
    refMap[@"TXTR"] = txtrList;
    
    // stdMatBaseTextureName reference
    NSString *refName = [self getProperty:@"stdMatBaseTextureName"].value;
    if (refName.length > 0 && ![[refName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        NSMutableArray *baseTextureList = [[NSMutableArray alloc] init];
        NSString *txtrName = [NSString stringWithFormat:@"%@_txtr", refName];
        id<IPackedFileDescriptor> pfd = [ScenegraphHelper buildPfdWithFilename:txtrName
                                                                      type:[MetaData TXTR]
                                                              defaultGroup:parentGroup];
        [baseTextureList addObject:pfd];
        refMap[@"stdMatBaseTextureName"] = baseTextureList;
    }
    
    // stdMatNormalMapTextureName reference
    refName = [self getProperty:@"stdMatNormalMapTextureName"].value;
    if (refName.length > 0 && ![[refName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        NSMutableArray *normalMapList = [[NSMutableArray alloc] init];
        NSString *txtrName = [NSString stringWithFormat:@"%@_txtr", refName];
        id pfd = [ScenegraphHelper buildPfdWithFilename:txtrName
                                                   type:[MetaData TXTR]
                                           defaultGroup:parentGroup];
        [normalMapList addObject:pfd];
        refMap[@"stdMatNormalMapTextureName"] = normalMapList;
    }
    
    // stdMatEnvCubeTextureName reference
    refName = [self getProperty:@"stdMatEnvCubeTextureName"].value;
    if (refName.length > 0 && ![[refName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        NSMutableArray *envCubeList = [[NSMutableArray alloc] init];
        NSString *txtrName = [NSString stringWithFormat:@"%@_txtr", refName];
        id pfd = [ScenegraphHelper buildPfdWithFilename:txtrName
                                                   type:[MetaData TXTR]
                                           defaultGroup:parentGroup];
        [envCubeList addObject:pfd];
        refMap[@"stdMatEnvCubeTextureName"] = envCubeList;
    }
    
    // Composite textures for characters
    int count = 0;
    @try {
        NSString *countString = [self getProperty:@"numTexturesToComposite"].value;
        if (countString.length > 0) {
            count = countString.intValue;
        }
    } @catch (NSException *exception) {
        // Ignore conversion errors
    }
    
    NSMutableArray *baseTextureList = [[NSMutableArray alloc] init];
    refMap[@"baseTexture"] = baseTextureList;
    
    for (int i = 0; i < count; i++) {
        NSString *propertyName = [NSString stringWithFormat:@"baseTexture%d", i];
        refName = [[self getProperty:propertyName].value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (refName.length > 0) {
            if (![refName hasSuffix:@"_txtr"]) {
                refName = [NSString stringWithFormat:@"%@_txtr", refName];
            }
            id pfd = [ScenegraphHelper buildPfdWithFilename:refName
                                                       type:[MetaData TXTR]
                                               defaultGroup:parentGroup];
            [baseTextureList addObject:pfd];
        }
    }
}

// MARK: - UI Management

- (void)initTabPage {
    // UI initialization will be handled by the view controller
}

- (void)extendTabView:(NSTabView *)tabView {
    // UI tab extension will be handled by the view controller
}

- (NSViewController *)viewController {
    // Return appropriate view controller for material definition editing
    return nil; // Will be implemented with actual UI components
}

@end

