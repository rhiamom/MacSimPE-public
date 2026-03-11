//
//  RemoteControl.h
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

#pragma once
#import <Foundation/Foundation.h>

@class ControlEventArgs;

@protocol IPackageFile;
@protocol IPackedFileDescriptor;
@protocol IScenegraphFileIndexItem;
@protocol ISettings;

typedef void (^ControlEvent)(id _Nullable sender, ControlEventArgs * _Nonnull e);
typedef BOOL (^OpenPackageDelegate)(NSString * _Nonnull filename);
typedef BOOL (^OpenMemoryPackageDelegate)(id<IPackageFile> _Nonnull pkg);
typedef BOOL (^OpenPackedFileDelegate)(id<IScenegraphFileIndexItem> _Nonnull fii);
typedef void (^ShowDockDelegate)(id _Nonnull doc, BOOL hide);

// “Event” equivalent for ResourceListSelectionChanged
typedef void (^ResourceListSelectionChangedHandler)(id _Nullable sender, id _Nonnull e);

NS_ASSUME_NONNULL_BEGIN

@interface ControlEventArgs : NSObject

- (instancetype)initWithTarget:(uint32_t)target;
- (instancetype)initWithTarget:(uint32_t)target item:(nullable id)item;
- (instancetype)initWithTarget:(uint32_t)target items:(nullable NSArray *)items;

@property (nonatomic, readonly) uint32_t targetType;
@property (nonatomic, readonly, nullable) id item;
@property (nonatomic, readonly) NSArray *items;

@end

@interface RemoteControl : NSObject

// MARK: - Message Queue
+ (void)hookToMessageQueue:(uint32_t)type fkt:(ControlEvent)fkt;
+ (void)unhookFromMessageQueue:(uint32_t)type fkt:(ControlEvent)fkt;
+ (void)addMessage:(nullable id)sender eventArgs:(ControlEventArgs *)e;

// MARK: - Application Window (macOS adaptation)
+ (nullable id)applicationForm;
+ (void)setApplicationForm:(nullable id)form;

+ (void)showSubForm:(id)form;
+ (void)hideApplicationForm;
+ (void)showApplicationForm;
+ (void)minimizeApplicationForm;
+ (void)restoreApplicationForm;

// MARK: - Delegates
+ (nullable ShowDockDelegate)showDockFkt;
+ (void)setShowDockFkt:(nullable ShowDockDelegate)fkt;

+ (nullable OpenPackedFileDelegate)openPackedFileFkt;
+ (void)setOpenPackedFileFkt:(nullable OpenPackedFileDelegate)fkt;

+ (nullable OpenPackageDelegate)openPackageFkt;
+ (void)setOpenPackageFkt:(nullable OpenPackageDelegate)fkt;

+ (nullable OpenMemoryPackageDelegate)openMemoryPackageFkt;
+ (void)setOpenMemoryPackageFkt:(nullable OpenMemoryPackageDelegate)fkt;

// MARK: - Actions
+ (void)showDock:(id)doc hide:(BOOL)hide;

+ (BOOL)openPackage:(NSString *)filename;
+ (BOOL)openMemoryPackage:(id<IPackageFile>)pkg;

// Overload equivalents (Obj-C names differ to avoid C# overloads)
+ (BOOL)openPackedFileWithDescriptor:(id<IPackedFileDescriptor>)pfd
                             package:(id<IPackageFile>)pkg;
+ (BOOL)openPackedFile:(id<IScenegraphFileIndexItem>)fii;

// MARK: - Help
+ (void)showHelp:(NSString *)url;
+ (void)showHelp:(NSString *)url topic:(NSString *)topic;

// MARK: - Custom Settings
+ (void)showCustomSettings:(id<ISettings>)settings;

// MARK: - ResourceListSelectionChanged (event equivalent)
+ (void)addResourceListSelectionChangedHandler:(ResourceListSelectionChangedHandler)handler;
+ (void)removeResourceListSelectionChangedHandler:(ResourceListSelectionChangedHandler)handler;
+ (void)fireResourceListSelectionChangedHandler:(nullable id)sender eventArgs:(id)e;

@end

NS_ASSUME_NONNULL_END

