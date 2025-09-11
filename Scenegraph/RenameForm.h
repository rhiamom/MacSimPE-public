//
//  RenameForm.h
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

#import <Cocoa/Cocoa.h>
#import "FixObject.h"

@protocol IPackageFile;
@protocol IPackedFileDescriptor;

NS_ASSUME_NONNULL_BEGIN

@interface RenameForm : NSWindowController <NSTableViewDataSource, NSTableViewDelegate>

@property (nonatomic, weak) IBOutlet NSTableView *tableView;
@property (nonatomic, weak) IBOutlet NSTextField *modelNameField;
@property (nonatomic, weak) IBOutlet NSButton *updateButton;
@property (nonatomic, weak) IBOutlet NSButton *okButton;
@property (nonatomic, weak) IBOutlet NSButton *universityV2Checkbox;

@property (nonatomic, strong) id<IPackageFile> package;
@property (nonatomic, strong) NSMutableArray<NSMutableDictionary *> *items;
@property (nonatomic, assign) BOOL dialogResult;

+ (NSString *)findMainOldName:(id<IPackageFile>)package;
+ (NSString *)replaceOldUnique:(NSString *)name
                     newUnique:(NSString *)newUnique
                         force:(BOOL)force;
+ (NSMutableDictionary *)getNames:(BOOL)automatic
                          package:(id<IPackageFile>)package
                        tableView:(nullable NSTableView *)tableView
                         userName:(NSString *)userName;
+ (NSString *)getUniqueName;
+ (NSString *)getUniqueNameOrNull:(BOOL)returnNull;
+ (NSMutableDictionary *)execute:(id<IPackageFile>)package
                      uniqueName:(BOOL)uniqueName
                         version:(FixVersion *)version;

- (IBAction)updateNames:(id)sender;
- (IBAction)okClicked:(id)sender;

@end

NS_ASSUME_NONNULL_END
