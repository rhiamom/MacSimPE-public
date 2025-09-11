//
//  RenameForm.m
//  MacSimpe
//
//  Created by Catherine Gramze on 9/11/25.
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

#import "RenameForm.h"
#import "IPackageFile.h"
#import "IPackedFileDescriptor.h"
#import "MetaData.h"
#import "StrWrapper.h"
#import "StrItem.h"
#import "CpfWrapper.h"
#import "CpfItem.h"
#import "Hashes.h"
#import "Helper.h"
#import "Registry.h"
#import "RcolWrapper.h"
#import "GenericRcolWrapper.h"
#import "WarningException.h"

static NSString *currentUnique = nil;

@implementation RenameForm

- (instancetype)init {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    self = [super initWithWindowNibName:@"RenameForm" owner:self];
    if (self) {
        self.items = [[NSMutableArray alloc] init];
        self.dialogResult = NO;
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    self.universityV2Checkbox.hidden = ![[Registry windowsRegistry] hiddenMode];
    
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    
    NSTableColumn *nameColumn = [[NSTableColumn alloc] initWithIdentifier:@"name"];
    nameColumn.title = @"Name";
    nameColumn.width = 336;
    [self.tableView addTableColumn:nameColumn];
    
    NSTableColumn *typeColumn = [[NSTableColumn alloc] initWithIdentifier:@"type"];
    typeColumn.title = @"Type";
    typeColumn.width = 100;
    [self.tableView addTableColumn:typeColumn];
    
    NSTableColumn *originalColumn = [[NSTableColumn alloc] initWithIdentifier:@"original"];
    originalColumn.title = @"Original Name";
    originalColumn.width = 256;
    [self.tableView addTableColumn:originalColumn];
}

+ (NSString *)findMainOldName:(id<IPackageFile>)package {
    NSArray<id<IPackedFileDescriptor>> *pfds = [package findFiles:[MetaData STRING_FILE]];
    for (id<IPackedFileDescriptor> pfd in pfds) {
        if (pfd.instance == 0x85) {
            StrWrapper *str = [[StrWrapper alloc] init];
            [str processData:pfd package:package];
            
            StrItemList *sil = [str languageItemsForLanguage:1];
            if (sil.length > 1) return sil[1].title;
            else if (str.items.count > 1) return str.items[1].title;
        }
    }
    
    pfds = [package findFiles:0x4C697E5A];
    for (id<IPackedFileDescriptor> pfd in pfds) {
        Cpf *cpf = [[Cpf alloc] init];
        [cpf processData:pfd package:package];
        
        NSString *modelName = [[cpf getSaveItem:@"modelName"].stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (![modelName isEqualToString:@""]) return modelName;
    }
    
    return @"SimPE";
}

+ (NSString *)replaceOldUnique:(NSString *)name
                     newUnique:(NSString *)newUnique
                         force:(BOOL)force {
    newUnique = [newUnique stringByReplacingOccurrencesOfString:@"_" withString:@"."];
    NSArray<NSString *> *parts = [name componentsSeparatedByString:@"["];
    
    if (parts.count > 1) {
        NSArray<NSString *> *ends = [parts[1] componentsSeparatedByString:@"]"];
        if (ends.count > 1) {
            return [NSString stringWithFormat:@"%@%@%@", parts[0], newUnique, ends[1]];
        }
    }
    
    if (force) {
        parts = [name componentsSeparatedByString:@"_"];
        
        name = @"";
        BOOL first = YES;
        for (NSString *s in parts) {
            if (!first) name = [name stringByAppendingString:@"_"];
            name = [name stringByAppendingString:s];
            if (first) {
                first = NO;
                name = [name stringByAppendingFormat:@"-%@", newUnique];
            }
        }
    }
    
    return name;
}

+ (NSMutableDictionary *)getNames:(BOOL)automatic
                          package:(id<IPackageFile>)package
                        tableView:(nullable NSTableView *)tableView
                         userName:(NSString *)userName {
    userName = [userName stringByReplacingOccurrencesOfString:@"_" withString:@"."];
    
    if (tableView != nil) {
        // Clear table view data source
        RenameForm *controller = (RenameForm *)tableView.dataSource;
        if (controller && [controller isKindOfClass:[RenameForm class]]) {
            [controller.items removeAllObjects];
            [tableView reloadData];
        }
    }
    
    NSMutableDictionary *hashtable = [[NSMutableDictionary alloc] init];
    NSString *oldName = [[self findMainOldName:package].lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    oldName = [Hashes stripHashFromName:oldName];
    if ([oldName hasSuffix:@"_cres"]) oldName = [oldName substringToIndex:oldName.length - 5];
    
    for (NSNumber *typeNum in [MetaData rcolList]) {
        uint32_t type = typeNum.unsignedIntValue;
        NSArray<id<IPackedFileDescriptor>> *pfds = [package findFiles:type];
        for (id<IPackedFileDescriptor> pfd in pfds) {
            Rcol *rcol = [[GenericRcol alloc] initWithProvider:nil fast:NO];
            [rcol processData:pfd package:package];
            NSString *newName = [[rcol.fileName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].lowercaseString copy];
            newName = [Hashes stripHashFromName:newName];
            
            if ([newName isEqualToString:@""]) newName = [NSString stringWithFormat:@"SimPE_dummy_%@", userName];
            if (oldName == nil) oldName = @"";
            if ([oldName isEqualToString:@""]) oldName = @" ";
            
            if (automatic) {
                NSString *secName = @"";
                if ([newName hasSuffix:@"_anim"]) {
                    NSString *modifiedUserName = userName;
                    secName = [newName stringByReplacingOccurrencesOfString:oldName withString:@""];
                    NSInteger pos = [secName rangeOfString:@"-"].location;
                    if (pos != NSNotFound && pos < secName.length - 1) {
                        NSRange secondDash = [secName rangeOfString:@"-" options:0 range:NSMakeRange(pos + 1, secName.length - pos - 1)];
                        if (secondDash.location != NSNotFound) pos = secondDash.location;
                    }
                    
                    if (pos != NSNotFound && pos < secName.length - 1) {
                        secName = [NSString stringWithFormat:@"%@%@-%@",
                                   [secName substringToIndex:pos + 1],
                                   modifiedUserName,
                                   [secName substringFromIndex:pos + 1]];
                    } else {
                        secName = @"";
                    }
                }
                
                if ([secName isEqualToString:@""]) {
                    secName = [newName stringByReplacingOccurrencesOfString:oldName withString:userName];
                }
                
                if ([secName isEqualToString:newName] && ![oldName isEqualToString:[userName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].lowercaseString]) {
                    secName = [NSString stringWithFormat:@"%@-%@", userName, secName];
                }
                newName = secName;
            }
            
            if (tableView != nil) {
                RenameForm *controller = (RenameForm *)tableView.dataSource;
                if (controller && [controller isKindOfClass:[RenameForm class]]) {
                    NSMutableDictionary *item = [@{
                        @"name": [Hashes stripHashFromName:newName],
                        @"type": [MetaData findTypeAlias:type].shortName,
                        @"original": [Hashes stripHashFromName:rcol.fileName]
                    } mutableCopy];
                    [controller.items addObject:item];
                }
            }
            
            hashtable[[Hashes stripHashFromName:[rcol.fileName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].lowercaseString]] = [Hashes stripHashFromName:newName];
        }
    }
    
    if (tableView != nil) {
        [tableView reloadData];
    }
    
    return hashtable;
}

- (NSMutableDictionary *)getReplacementMap {
    NSMutableDictionary *hashtable = [[NSMutableDictionary alloc] init];
    
    for (NSMutableDictionary *item in self.items) {
        NSString *oldName = [item[@"original"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].lowercaseString;
        NSString *newName = [item[@"name"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        NSString *ext = [NSString stringWithFormat:@"_%@", [item[@"type"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].lowercaseString];
        if (![[newName lowercaseString] hasSuffix:ext]) {
            newName = [newName stringByAppendingString:ext];
        }
        
        @try {
            hashtable[[Hashes stripHashFromName:oldName]] = [Hashes stripHashFromName:newName];
        }
        @catch (NSException *exception) {
            @throw [[Warning alloc] initWithMessage:exception.reason
                                            details:@"Two or more Resources in the package have the same name, which is not allowed! See http://ambertation.de/simpeforum/viewtopic.php?t=1078 for Details."
                                          exception:exception];
        }
    }
    
    return hashtable;
}

+ (NSString *)getUniqueName {
    return [self getUniqueNameOrNull:NO];
}

+ (NSString *)getUniqueNameOrNull:(BOOL)returnNull {
    NSString *userName = [[[Registry windowsRegistry] username] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ([userName isEqualToString:@""]) {
        if (returnNull) return nil;
        userName = [[NSUUID UUID] UUIDString];
    } else {
        userName = [userName stringByReplacingOccurrencesOfString:@" " withString:@"-"];
        userName = [userName stringByReplacingOccurrencesOfString:@"_" withString:@"-"];
        userName = [userName stringByReplacingOccurrencesOfString:@"~" withString:@"-"];
        userName = [userName stringByReplacingOccurrencesOfString:@"!" withString:@"."];
        userName = [userName stringByReplacingOccurrencesOfString:@"#" withString:@"."];
        userName = [userName stringByReplacingOccurrencesOfString:@"[" withString:@"("];
        
        NSDate *now = [NSDate date];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:now];
        
        NSString *timeString = [NSString stringWithFormat:@"%ld.%ld.%ld-%lx%lx%lx",
                                (long)components.day,
                                (long)components.month,
                                (long)components.year,
                                (long)components.hour,
                                (long)components.minute,
                                (long)components.second];
        userName = [userName stringByAppendingFormat:@"-%@", timeString];
    }
    
    return [NSString stringWithFormat:@"[%@]", [userName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
}

+ (NSMutableDictionary *)execute:(id<IPackageFile>)package
                      uniqueName:(BOOL)uniqueName
                         version:(FixVersion *)version {
    RenameForm *renameForm = [[RenameForm alloc] init];
    renameForm.dialogResult = NO;
    renameForm.package = package;
    renameForm.universityV2Checkbox.state = (*version == FixVersionUniversityReady2) ? NSControlStateValueOn : NSControlStateValueOff;
    
    NSString *oldName = [[self findMainOldName:package].lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    oldName = [Hashes stripHashFromName:oldName];
    currentUnique = [self getUniqueName];
    
    if ([oldName hasSuffix:@"_cres"]) oldName = [oldName substringToIndex:oldName.length - 5];
    
    if (uniqueName) {
        NSString *name = [self replaceOldUnique:oldName newUnique:currentUnique force:YES];
        if ([name isEqualToString:oldName]) name = [oldName stringByAppendingString:currentUnique];
        renameForm.modelNameField.stringValue = name;
    } else {
        renameForm.modelNameField.stringValue = oldName;
    }
    
    [self getNames:uniqueName package:package tableView:renameForm.tableView userName:renameForm.modelNameField.stringValue];
    
    [renameForm.window makeKeyAndOrderFront:nil];
    [[NSApplication sharedApplication] runModalForWindow:renameForm.window];
    
    if (renameForm.dialogResult) {
        if (renameForm.universityV2Checkbox.state == NSControlStateValueOn) {
            *version = FixVersionUniversityReady2;
        } else {
            *version = FixVersionUniversityReady;
        }
        return [renameForm getReplacementMap];
    } else {
        return nil;
    }
}

- (IBAction)updateNames:(id)sender {
    [[self class] getNames:YES package:self.package tableView:self.tableView userName:self.modelNameField.stringValue];
}

- (IBAction)okClicked:(id)sender {
    self.dialogResult = YES;
    [self.window orderOut:nil];
    [[NSApplication sharedApplication] stopModal];
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.items.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if (row >= 0 && row < self.items.count) {
        NSMutableDictionary *item = self.items[row];
        NSString *identifier = tableColumn.identifier;
        
        if ([identifier isEqualToString:@"name"]) {
            return item[@"name"];
        } else if ([identifier isEqualToString:@"type"]) {
            return item[@"type"];
        } else if ([identifier isEqualToString:@"original"]) {
            return item[@"original"];
        }
    }
    return @"";
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if (row >= 0 && row < self.items.count && [tableColumn.identifier isEqualToString:@"name"]) {
        self.items[row][@"name"] = object;
    }
}

@end
