//
//  Generic.m
//  MacSimpe
//
//  Created by Catherine Gramze on 9/3/25.
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

#import "Generic.h"
#import "GenericUIBase.h"
#import "GenericElements.h"
#import "GenericCommon.h"
#import "GenericFileItem.h"
#import "IFileWrapper.h"
#import "IFileWrapperSaveExtension.h"
#import "IPackedFileDescriptor.h"
#import "Helper.h"
#import <Cocoa/Cocoa.h>

@implementation GenericUI

// MARK: - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        // GenericUIBase will create the form if needed
    }
    return self;
}

// MARK: - Property Conversion Methods

- (NSString *)propertyToString:(NSString *)name
                          item:(GenericCommon *)item
                        object:(id)object {
    // Virtual method - can be overridden by subclasses
    // Default implementation returns nil to use default conversion
    return nil;
}

- (NSString *)toString:(id)object {
    return [self toString:nil item:nil object:object];
}

- (NSString *)toString:(NSString *)name
                  item:(GenericCommon *)item
                object:(id)object {
    
    if (object == nil) return @"";
    
    // Check for custom property conversion
    if (name != nil && item != nil) {
        NSString *customResult = [self propertyToString:name item:item object:object];
        if (customResult != nil) {
            return customResult;
        }
    }
    
    // Handle value types with hex formatting
    if ([object isKindOfClass:[NSNumber class]]) {
        NSNumber *number = (NSNumber *)object;
        const char *type = [number objCType];
        
        // Convert various integer types to hex format
        if (strcmp(type, @encode(uint8_t)) == 0) {
            return [NSString stringWithFormat:@"0x%X", [number unsignedCharValue]];
        } else if (strcmp(type, @encode(int8_t)) == 0) {
            return [NSString stringWithFormat:@"0x%X", [number charValue]];
        } else if (strcmp(type, @encode(uint16_t)) == 0) {
            return [NSString stringWithFormat:@"0x%X", [number unsignedShortValue]];
        } else if (strcmp(type, @encode(int16_t)) == 0) {
            return [NSString stringWithFormat:@"0x%X", [number shortValue]];
        } else if (strcmp(type, @encode(uint32_t)) == 0) {
            return [NSString stringWithFormat:@"0x%X", [number unsignedIntValue]];
        } else if (strcmp(type, @encode(int32_t)) == 0) {
            return [NSString stringWithFormat:@"0x%X", [number intValue]];
        } else if (strcmp(type, @encode(uint64_t)) == 0) {
            return [NSString stringWithFormat:@"0x%llX", [number unsignedLongLongValue]];
        } else if (strcmp(type, @encode(int64_t)) == 0) {
            return [NSString stringWithFormat:@"0x%llX", [number longLongValue]];
        }
    }
    
    // Handle NSData (equivalent to byte array)
    if ([object isKindOfClass:[NSData class]]) {
        NSData *data = (NSData *)object;
        NSMutableString *result = [[NSMutableString alloc] initWithCapacity:data.length];
        const uint8_t *bytes = (const uint8_t *)data.bytes;
        
        for (NSUInteger i = 0; i < data.length; i++) {
            unichar printableChar = [GenericCommon toPrintableChar:(unichar)bytes[i] alternative:'.'];
            [result appendFormat:@"%C", printableChar];
        }
        
        return result;
    }
    
    // Default: use object's string representation
    return [object description];
}

// MARK: - IPackedFileUI Protocol

- (NSView *)createView {
    return [GenericUIBase form].listPanel;
}

- (void)updateGUI:(id<IFileWrapper>)wrapper {
    GenericElements *form = [GenericUIBase form];
    
    // Setup save wrapper if supported
    if ([wrapper conformsToProtocol:@protocol(IFileWrapperSaveExtension)]) {
        form.wrapper = (id<IFileWrapperSaveExtension>)wrapper;
        form.lllvcommit.enabled = YES;
    } else {
        form.wrapper = nil;
        form.lllvcommit.enabled = NO;
    }
    
    // Get file descriptor
    id<IPackedFileDescriptor> pfd = wrapper.fileDescriptor;
    
    // Clear existing content
    [form.listList removeTableColumn:[form.listList.tableColumns firstObject]];
    while (form.listList.tableColumns.count > 0) {
        [form.listList removeTableColumn:[form.listList.tableColumns firstObject]];
    }
    
    form.listBanner.stringValue = [NSString stringWithFormat:@"[Can't process unknown type 0x%X]", pfd.type];
    
    @try {
        // Note: This assumes the wrapper has methods similar to the C# Generic class
        // You'll need to implement these methods in your Generic wrapper class
        
        // For now, we'll use a simplified approach assuming the wrapper has properties/items
        if ([wrapper respondsToSelector:@selector(count)] && [wrapper respondsToSelector:@selector(getItem:)]) {
            NSInteger count = [(id)wrapper performSelector:@selector(count)];
            
            if (count > 0) {
                // Get first item to determine column structure
                GenericItem *firstItem = [(id)wrapper performSelector:@selector(getItem:) withObject:@(0)];
                if (firstItem != nil) {
                    NSArray<NSString *> *names = firstItem.names;
                    
                    if (names.count > 0) {
                        // Create columns
                        for (NSString *columnName in names) {
                            NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:columnName];
                            column.title = columnName;
                            column.width = MAX(190, columnName.length * 15);
                            [form.listList addTableColumn:column];
                        }
                        
                        // Setup item panel controls
                        [form.itemPanel.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
                        
                        for (NSUInteger i = 0; i < names.count; i++) {
                            NSString *fieldName = names[i];
                            
                            // Create label
                            NSTextField *label = [[NSTextField alloc] init];
                            label.stringValue = fieldName;
                            label.editable = NO;
                            label.bordered = NO;
                            label.backgroundColor = [NSColor clearColor];
                            label.frame = NSMakeRect(0, i * 21 + 4, 0, 17);
                            [label sizeToFit];
                            [form.itemPanel addSubview:label];
                            
                            // Create text field
                            NSTextField *textField = [[NSTextField alloc] init];
                            textField.stringValue = @"";
                            textField.frame = NSMakeRect(label.frame.size.width + 8, i * 21,
                                                        form.itemPanel.frame.size.width - label.frame.size.width - 8,
                                                        21);
                            textField.tag = i;
                            [form.itemPanel addSubview:textField];
                        }
                        
                        // Populate table data
                        // Note: You'll need to implement proper table view data source
                        // This is a simplified version
                        
                        NSString *itemCountText;
                        if (count == 1) {
                            itemCountText = [NSString stringWithFormat:@" (%ld Item)", (long)count];
                        } else {
                            itemCountText = [NSString stringWithFormat:@" (%ld Items)", (long)count];
                        }
                        
                        form.listBanner.stringValue = [NSString stringWithFormat:@"Generic File%@", itemCountText];
                    }
                }
            }
        }
        
    } @catch (NSException *exception) {
        if ([Helper debugMode]) {
            form.listBanner.stringValue = [form.listBanner.stringValue stringByAppendingFormat:@" [%@]", exception.reason];
        }
    }
}

- (void)refresh {
    // Refresh the current display
    [self updateGUI:nil]; // Note: You'll need to store the current wrapper to refresh properly
}

- (void)synchronize {
    // Synchronize any changes back to the wrapper
    GenericElements *form = [GenericUIBase form];
    if (form.wrapper != nil) {
        [form.wrapper synchronizeUserData];
    }
}

- (void)dispose {
    [super dispose];
}

@end
