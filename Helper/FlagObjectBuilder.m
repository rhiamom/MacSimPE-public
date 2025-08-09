//
//  FlagObjectBuilder.m
//  MacSimpe
//
//  Created by Catherine Gramze on 8/8/25.
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

#import "FlagObjectBuilder.h"
#import <objc/runtime.h>

// MARK: - FlagPropertyDescriptor Implementation

@implementation FlagPropertyDescriptor

- (instancetype)init {
    self = [super init];
    if (self) {
        _readOnly = NO;
        _propertyType = [NSObject class];
    }
    return self;
}

@end

// MARK: - FlagObjectBuilder Implementation

@implementation FlagObjectBuilder

// Static registry for dynamic classes and their metadata
static NSMutableDictionary<NSString *, Class> *_dynamicClasses = nil;
static NSMutableDictionary<NSString *, NSArray<FlagPropertyDescriptor *> *> *_classPropertyDescriptors = nil;
static NSMutableDictionary<NSString *, NSDictionary<NSString *, NSNumber *> *> *_classFlagDefinitions = nil;

+ (void)initialize {
    if (self == [FlagObjectBuilder class]) {
        _dynamicClasses = [[NSMutableDictionary alloc] init];
        _classPropertyDescriptors = [[NSMutableDictionary alloc] init];
        _classFlagDefinitions = [[NSMutableDictionary alloc] init];
    }
}

// MARK: - Initialization

- (instancetype)init {
    return [super initWithValue:0];
}

// MARK: - Dynamic Type Creation

+ (Class)buildFlagObjectWithClassName:(NSString *)className
                      flagDefinitions:(NSDictionary<NSString *, NSNumber *> *)flagDefinitions {
    
    if (!className || className.length == 0 || !flagDefinitions || flagDefinitions.count == 0) {
        return [FlagBase class];
    }
    
    // Check if class already exists
    Class existingClass = _dynamicClasses[className];
    if (existingClass) {
        return existingClass;
    }
    
    // Create new dynamic class
    Class dynamicClass = objc_allocateClassPair([FlagObjectBuilder class], [className UTF8String], 0);
    if (!dynamicClass) {
        NSLog(@"Failed to create dynamic class: %@", className);
        return [FlagBase class];
    }
    
    // Create property descriptors
    NSMutableArray<FlagPropertyDescriptor *> *descriptors = [[NSMutableArray alloc] init];
    
    for (NSString *flagName in flagDefinitions) {
        NSNumber *flagValue = flagDefinitions[flagName];
        
        // Parse flag name for category
        NSArray<NSString *> *parts = [flagName componentsSeparatedByString:@"_"];
        NSString *category = @"";
        if (parts.count == 2) {
            category = parts[0];
        }
        
        // Create property descriptor
        FlagPropertyDescriptor *descriptor = [[FlagPropertyDescriptor alloc] init];
        descriptor.name = flagName;
        descriptor.category = category;
        descriptor.description = @"";
        descriptor.readOnly = NO;
        descriptor.defaultValue = @(NO); // Boolean flag properties default to NO
        descriptor.propertyType = [NSNumber class];
        
        [descriptors addObject:descriptor];
        
        // Add dynamic property to the class
        [self addDynamicBoolPropertyToClass:dynamicClass
                                   withName:flagName
                                   bitIndex:[flagValue unsignedIntValue]];
    }
    
    // Register the class
    objc_registerClassPair(dynamicClass);
    
    // Store metadata
    _dynamicClasses[className] = dynamicClass;
    _classPropertyDescriptors[className] = [descriptors copy];
    _classFlagDefinitions[className] = flagDefinitions;
    
    return dynamicClass;
}

+ (Class)buildFlagObjectWithClassName:(NSString *)className
                            flagNames:(NSArray<NSString *> *)flagNames {
    
    // Convert flag names array to definitions dictionary with sequential bit values
    NSMutableDictionary<NSString *, NSNumber *> *flagDefinitions = [[NSMutableDictionary alloc] init];
    
    for (NSUInteger i = 0; i < flagNames.count && i < 16; i++) {
        flagDefinitions[flagNames[i]] = @(i);
    }
    
    return [self buildFlagObjectWithClassName:className flagDefinitions:flagDefinitions];
}

+ (id)activateType:(Class)targetClass withArguments:(NSArray *)arguments {
    if (!targetClass) {
        return nil;
    }
    
    // Try to create instance with arguments
    if (arguments && arguments.count > 0) {
        // For FlagBase subclasses, try initWithValue if first argument is a number
        if ([targetClass isSubclassOfClass:[FlagBase class]] &&
            [arguments[0] isKindOfClass:[NSNumber class]]) {
            NSNumber *value = arguments[0];
            return [[targetClass alloc] initWithValue:[value unsignedShortValue]];
        }
        
        // For other cases, use init and try to set properties
        id instance = [[targetClass alloc] init];
        // Could implement property setting here if needed
        return instance;
    }
    
    // Default initialization
    return [[targetClass alloc] init];
}

// MARK: - Dynamic Property Addition

+ (void)addDynamicBoolPropertyToClass:(Class)targetClass
                              withName:(NSString *)propertyName
                              bitIndex:(NSUInteger)bitIndex {
    
    if (bitIndex >= 16) {
        NSLog(@"Warning: Bit index %lu exceeds 16-bit limit for property %@",
              (unsigned long)bitIndex, propertyName);
        return;
    }
    
    // Create getter method
    NSString *getterName = propertyName;
    SEL getterSelector = NSSelectorFromString(getterName);
    
    IMP getterImp = imp_implementationWithBlock(^BOOL(id self) {
        if ([self isKindOfClass:[FlagBase class]]) {
            FlagBase *flagBase = (FlagBase *)self;
            return [flagBase getBit:(uint8_t)bitIndex];
        }
        return NO;
    });
    
    class_addMethod(targetClass, getterSelector, getterImp, "c@:");
    
    // Create setter method
    NSString *setterName = [NSString stringWithFormat:@"set%@%@:",
                           [[propertyName substringToIndex:1] uppercaseString],
                           [propertyName substringFromIndex:1]];
    SEL setterSelector = NSSelectorFromString(setterName);
    
    IMP setterImp = imp_implementationWithBlock(^void(id self, BOOL value) {
        if ([self isKindOfClass:[FlagBase class]]) {
            FlagBase *flagBase = (FlagBase *)self;
            [flagBase setBit:(uint8_t)bitIndex value:value];
        }
    });
    
    class_addMethod(targetClass, setterSelector, setterImp, "v@:c");
    
    // Add property attributes
    objc_property_attribute_t attrs[] = {
        {"T", "c"},  // Type: BOOL (char)
        {"N", ""},   // Nonatomic
        {"G", [getterName UTF8String]}, // Getter
        {"S", [setterName UTF8String]}  // Setter
    };
    
    class_addProperty(targetClass, [propertyName UTF8String], attrs, 4);
}

// MARK: - Property Management (Simplified for Objective-C)

+ (void)addPropertyWithName:(NSString *)name
                    toClass:(Class)targetClass
               defaultValue:(id)defaultValue
                description:(NSString *)description
                   category:(NSString *)category
                   readOnly:(BOOL)readOnly {
    
    // In Objective-C, we can't easily add arbitrary typed properties at runtime
    // This method is provided for API compatibility but has limited functionality
    NSLog(@"addPropertyWithName:toClass: has limited runtime support in Objective-C");
}

// MARK: - Property Descriptor Management

+ (NSArray<FlagPropertyDescriptor *> *)propertyDescriptorsForClass:(Class)targetClass {
    NSString *className = NSStringFromClass(targetClass);
    return _classPropertyDescriptors[className];
}

+ (void)setPropertyDescriptors:(NSArray<FlagPropertyDescriptor *> *)descriptors
                      forClass:(Class)targetClass {
    NSString *className = NSStringFromClass(targetClass);
    _classPropertyDescriptors[className] = descriptors;
}

// MARK: - Utility Methods

+ (BOOL)isDynamicFlagClass:(Class)targetClass {
    NSString *className = NSStringFromClass(targetClass);
    return _dynamicClasses[className] != nil;
}

+ (NSDictionary<NSString *, NSNumber *> *)flagDefinitionsForClass:(Class)targetClass {
    NSString *className = NSStringFromClass(targetClass);
    return _classFlagDefinitions[className];
}

@end
