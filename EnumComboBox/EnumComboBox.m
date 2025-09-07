//
//  EnumComboBox.m
//  MacSimpe
//
//  Created by Catherine Gramze on 9/4/25.
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

#import "EnumComboBox.h"
#import <objc/runtime.h>

// MARK: - EnumComboBoxItem Implementation

@interface EnumComboBoxItem ()
@property (nonatomic, strong, readwrite) id content;
@property (nonatomic, copy, readwrite) NSString *name;
@end

@implementation EnumComboBoxItem

- (instancetype)initWithEnumClass:(Class)enumClass
                        enumValue:(id)enumValue
                           bundle:(NSBundle *)bundle {
    self = [super init];
    if (self) {
        self.content = enumValue;
        
        // Generate display name
        NSString *className = NSStringFromClass(enumClass);
        NSString *valueName = [enumValue description];
        
#if DEBUG
        // Debug format: (value)Namespace.ClassName.ValueName
        self.name = [NSString stringWithFormat:@"(%@)%@.%@", valueName, className, valueName];
#else
        // Release format: just the value name
        self.name = valueName;
#endif
        
        // Try to get localized name if bundle is provided
        if (bundle) {
            NSString *localizationKey = [NSString stringWithFormat:@"%@.%@", className, valueName];
            NSString *localizedName = [bundle localizedStringForKey:localizationKey
                                                              value:nil
                                                              table:nil];
            
            // Use localized name if found and different from key
            if (localizedName && ![localizedName isEqualToString:localizationKey]) {
                self.name = localizedName;
            }
        }
    }
    return self;
}

- (NSString *)description {
    return self.name;
}

// Make this object work properly with NSComboBox display
- (NSString *)stringValue {
    return self.name;
}

@end

// MARK: - EnumComboBox Implementation

@interface EnumComboBox () <NSComboBoxDataSource, NSComboBoxDelegate>
@property (nonatomic, strong) NSMutableArray<EnumComboBoxItem *> *enumItems;
@end

@implementation EnumComboBox

// MARK: - Initialization

- (instancetype)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.enumItems = [[NSMutableArray alloc] init];
    self.dataSource = self;
    self.delegate = self;
    self.usesDataSource = YES;
}

// MARK: - Properties

- (void)setEnumClass:(Class)enumClass {
    if (_enumClass != enumClass) {
        _enumClass = enumClass;
        [self updateContentKeepingSelection:NO];
    }
}

- (void)setResourceBundle:(NSBundle *)resourceBundle {
    if (_resourceBundle != resourceBundle) {
        _resourceBundle = resourceBundle;
        [self updateContentKeepingSelection:YES];
    }
}

- (id)selectedEnumValue {
    NSInteger selectedIndex = self.indexOfSelectedItem;
    if (selectedIndex < 0 || selectedIndex >= self.enumItems.count) {
        return nil;
    }
    
    EnumComboBoxItem *selectedItem = self.enumItems[selectedIndex];
    return selectedItem.content;
}

- (void)setSelectedEnumValue:(id)selectedEnumValue {
    if (!selectedEnumValue) {
        [self selectItemAtIndex:-1];
        return;
    }
    
    // Find the item with matching content
    for (NSUInteger i = 0; i < self.enumItems.count; i++) {
        EnumComboBoxItem *item = self.enumItems[i];
        
        // Handle different comparison types
        BOOL isMatch = NO;
        
        if ([item.content isKindOfClass:[NSNumber class]] && [selectedEnumValue isKindOfClass:[NSNumber class]]) {
            // Compare NSNumber enum values
            isMatch = [item.content isEqualToNumber:selectedEnumValue];
        } else if ([item.content respondsToSelector:@selector(isEqual:)]) {
            // Use standard equality comparison
            isMatch = [item.content isEqual:selectedEnumValue];
        } else {
            // Fall back to pointer comparison
            isMatch = (item.content == selectedEnumValue);
        }
        
        if (isMatch) {
            [self selectItemAtIndex:i];
            return;
        }
    }
    
    // No match found, deselect
    [self selectItemAtIndex:-1];
}

// MARK: - Public Methods

- (void)updateContentKeepingSelection:(BOOL)keepSelection {
    id previousSelection = nil;
    if (keepSelection) {
        previousSelection = self.selectedEnumValue;
    }
    
    [self.enumItems removeAllObjects];
    [self reloadData];
    
    if (self.enumClass) {
        [self populateWithEnumClass:self.enumClass];
    }
    
    if (keepSelection && previousSelection) {
        self.selectedEnumValue = previousSelection;
    }
}

- (void)configureWithEnumClass:(Class)enumClass bundle:(NSBundle *)bundle {
    self.resourceBundle = bundle;
    self.enumClass = enumClass; // This will trigger updateContent
}

- (void)addEnumValuesFromDictionary:(NSDictionary<NSString *, id> *)enumValues enumClass:(Class)enumClass {
    [enumValues enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, BOOL *stop) {
        EnumComboBoxItem *item = [[EnumComboBoxItem alloc] initWithEnumClass:enumClass
                                                                   enumValue:value
                                                                      bundle:self.resourceBundle];
        [self.enumItems addObject:item];
    }];
    
    [self reloadData];
}

- (NSString *)localizedNameForEnumValue:(id)enumValue enumClass:(Class)enumClass bundle:(NSBundle *)bundle {
    NSString *className = NSStringFromClass(enumClass);
    NSString *valueName = [enumValue description];
    
    if (bundle) {
        NSString *localizationKey = [NSString stringWithFormat:@"%@.%@", className, valueName];
        NSString *localizedName = [bundle localizedStringForKey:localizationKey
                                                          value:nil
                                                          table:nil];
        
        if (localizedName && ![localizedName isEqualToString:localizationKey]) {
            return localizedName;
        }
    }
    
    return valueName;
}

// MARK: - Private Methods

- (void)populateWithEnumClass:(Class)enumClass {
    if (!enumClass) return;
    
    // For Objective-C, we need to handle this differently than C# enums
    // We'll try several approaches to get enum-like values
    
    // Method 1: Try to get class methods that return constant values (common pattern)
    [self populateFromClassMethods:enumClass];
    
    // Method 2: If no items found, try to populate from a predefined constants dictionary
    if (self.enumItems.count == 0) {
        [self populateFromConstantsDictionary:enumClass];
    }
    
    [self reloadData];
}

- (void)populateFromClassMethods:(Class)enumClass {
    unsigned int methodCount;
    Method *methods = class_copyMethodList(object_getClass(enumClass), &methodCount);
    
    for (unsigned int i = 0; i < methodCount; i++) {
        Method method = methods[i];
        SEL selector = method_getName(method);
        NSString *methodName = NSStringFromSelector(selector);
        
        // Look for class methods that might return enum values
        // Common patterns: +constantName, +enumValueName, etc.
        if ([methodName hasPrefix:@"enum"] || [methodName hasSuffix:@"Value"] ||
            ([methodName length] > 3 && [[methodName substringToIndex:1] isEqualToString:[[methodName substringToIndex:1] uppercaseString]])) {
            
            // Check if method takes no parameters and returns an object
            char returnType[256];
            method_getReturnType(method, returnType, sizeof(returnType));
            
            if (method_getNumberOfArguments(method) == 2) { // self and _cmd
                // Try to call the method
                @try {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    id result = [enumClass performSelector:selector];
#pragma clang diagnostic pop
                    
                    if (result) {
                        EnumComboBoxItem *item = [[EnumComboBoxItem alloc] initWithEnumClass:enumClass
                                                                                   enumValue:result
                                                                                      bundle:self.resourceBundle];
                        [self.enumItems addObject:item];
                    }
                }
                @catch (NSException *exception) {
                    // Ignore methods that can't be called
                }
            }
        }
    }
    
    free(methods);
}

- (void)populateFromConstantsDictionary:(Class)enumClass {
    // Try to get a constants dictionary from the class
    // This is a common pattern where classes define +enumConstants or similar
    
    NSArray<NSString *> *constantMethodNames = @[@"enumConstants", @"allValues", @"constants", @"enumDictionary"];
    
    for (NSString *methodName in constantMethodNames) {
        SEL selector = NSSelectorFromString(methodName);
        
        if ([enumClass respondsToSelector:selector]) {
            @try {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                id result = [enumClass performSelector:selector];
#pragma clang diagnostic pop
                
                if ([result isKindOfClass:[NSDictionary class]]) {
                    [self addEnumValuesFromDictionary:result enumClass:enumClass];
                    return;
                } else if ([result isKindOfClass:[NSArray class]]) {
                    NSArray *values = result;
                    for (id value in values) {
                        EnumComboBoxItem *item = [[EnumComboBoxItem alloc] initWithEnumClass:enumClass
                                                                                   enumValue:value
                                                                                      bundle:self.resourceBundle];
                        [self.enumItems addObject:item];
                    }
                    return;
                }
            }
            @catch (NSException *exception) {
                // Continue to next method
            }
        }
    }
}

// MARK: - NSComboBoxDataSource

- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)comboBox {
    return self.enumItems.count;
}

- (id)comboBox:(NSComboBox *)comboBox objectValueForItemAtIndex:(NSInteger)index {
    if (index < 0 || index >= self.enumItems.count) {
        return nil;
    }
    
    return self.enumItems[index];
}

- (NSUInteger)comboBox:(NSComboBox *)comboBox indexOfItemWithStringValue:(NSString *)string {
    for (NSUInteger i = 0; i < self.enumItems.count; i++) {
        EnumComboBoxItem *item = self.enumItems[i];
        if ([item.name isEqualToString:string]) {
            return i;
        }
    }
    return NSNotFound;
}

- (NSString *)comboBox:(NSComboBox *)comboBox completedString:(NSString *)string {
    for (EnumComboBoxItem *item in self.enumItems) {
        if ([item.name hasPrefix:string]) {
            return item.name;
        }
    }
    return nil;
}

// MARK: - NSComboBoxDelegate

- (void)comboBoxSelectionDidChange:(NSNotification *)notification {
    // Override point for subclasses or delegate callbacks
    // The selectedEnumValue property will automatically reflect the new selection
}

// MARK: - NSObject

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p> enumClass=%@ items=%lu selected=%@",
            NSStringFromClass([self class]), self,
            NSStringFromClass(self.enumClass),
            (unsigned long)self.enumItems.count,
            self.selectedEnumValue];
}

@end
