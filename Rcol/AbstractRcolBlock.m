//
//  AbstractRcolBlock.m
//  MacSimpe
//
//  Created by Catherine Gramze on 8/15/25.
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

#import <Foundation/Foundation.h>
#import "AbstractRcolBlock.h"
#import "cSGResource.h"
#import "RcolWrapper.h"
#import "BinaryReader.h"
#import "BinaryWriter.h"
#import "GenericRcolWrapper.h"
#import "IPackedFileDescriptor.h"
#import "IScenegraphFileIndex.h"
#import "IScenegraphFileIndexItem.h"
#import "FileTable.h"
#import "Wait.h"
#import "WarningException.h"
#import "MetaData.h"
#import "Helper.h"
#import "IPackageFile.h"

@implementation AbstractRcolBlock

// MARK: - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        _sgres = nil;
        _blockId = 0;
        _version = 0;
        _parent = nil;
        _blockName = nil;
    }
    return self;
}

- (instancetype)initWithParent:(Rcol *)parent {
    self = [self init];
    if (self) {
        _parent = parent;
        if (parent != nil) {
            [self registerInListing:[Rcol tokens]];
        }
    }
    return self;
}

// MARK: - Properties

- (SGResource *)nameResource {
    return self.sgres;
}

- (void)setNameResource:(SGResource *)nameResource {
    self.sgres = nameResource;
}

- (BOOL)changed {
    if (self.parent != nil) {
        return [self.parent changed];
    }
    return NO;
}

- (void)setChanged:(BOOL)changed {
    if (self.parent != nil) {
        [self.parent setChanged:changed];
    }
}

- (NSString *)blockName {
    if (_blockName == nil) {
        return [NSString stringWithFormat:@"c%@", NSStringFromClass([self class])];
    }
    return _blockName;
}

- (NSViewController *)viewController {
    // Override in subclasses to provide custom view controller
    return nil;
}

- (NSViewController *)resourceViewController {
    // Override in subclasses to provide custom resource view controller
    return nil;
}

// MARK: - Template Methods

- (void)initTabPage {
    // Override in subclasses to setup controls on tab page before display
}

- (void)initResourceTabPage {
    // Override in subclasses to setup controls on resource tab page before display
}

- (void)refresh {
    [self initTabPage];
    [self initResourceTabPage];
}

// MARK: - UI Management

- (void)addToResourceTabControl:(NSTabView *)tabView comboBox:(NSComboBox *)comboBox {
    // Store the combo box reference on the tab view
    [tabView setValue:comboBox forKey:@"comboBoxReference"];
    
    // Remove all additional tab view items with tags
    NSArray *tabViewItems = [tabView.tabViewItems copy];
    for (NSTabViewItem *item in tabViewItems) {
        if ([item.identifier isKindOfClass:[NSObject class]]) {
            [tabView removeTabViewItem:item];
        }
    }
    
    NSViewController *resourceVC = [self resourceViewController];
    if (resourceVC != nil) {
        NSTabViewItem *tabItem = [[NSTabViewItem alloc] initWithIdentifier:self];
        [tabItem setViewController:resourceVC];
        [tabItem setLabel:[self blockName]];
        
        [self initResourceTabPage];
        [tabView addTabViewItem:tabItem];
    }
}

- (void)addToTabControl:(NSTabView *)tabView {
    if (self.parent != nil) {
        [self.parent clearTabPageChanged];
    }
    
    NSViewController *vc = [self viewController];
    if (vc != nil) {
        [self initTabPage];
    }
    
    [AbstractRcolBlock addToTabControl:tabView rcolBlock:self];
    [self extendTabView:tabView];
}

+ (void)addToTabControl:(NSTabView *)tabView rcolBlock:(id<IRcolBlock>)rcolBlock {
    NSViewController *vc = [rcolBlock viewController];
    if (vc != nil) {
        NSTabViewItem *tabItem = [[NSTabViewItem alloc] initWithIdentifier:rcolBlock];
        [tabItem setViewController:vc];
        [tabItem setLabel:[rcolBlock blockName]];
        [tabView addTabViewItem:tabItem];
    }
}

- (void)extendTabView:(NSTabView *)tabView {
    // Override in subclasses to add additional tab view items
}

// MARK: - Factory Methods

+ (id<IRcolBlock>)createWithType:(Class)type parent:(Rcol *)parent {
    id<IRcolBlock> instance = [[type alloc] initWithParent:parent];
    return instance;
}

+ (id<IRcolBlock>)createWithType:(Class)type parent:(Rcol *)parent blockId:(uint32_t)blockId {
    id<IRcolBlock> instance = [self createWithType:type parent:parent];
    [instance setBlockId:blockId];
    return instance;
}

- (id<IRcolBlock>)create {
    return [AbstractRcolBlock createWithType:[self class] parent:self.parent];
}

- (id<IRcolBlock>)createWithId:(uint32_t)blockId {
    return [AbstractRcolBlock createWithType:[self class] parent:self.parent blockId:blockId];
}

// MARK: - Registration

- (NSString *)registerInListing:(NSMutableDictionary *)listing {
    NSString *name = [self blockName];
    if (listing != nil && ![listing objectForKey:name]) {
        [listing setObject:[self class] forKey:name];
    }
    return name;
}

// MARK: - Parent Search

- (Rcol *)findReferencingParent:(uint32_t)type {
    id<IScenegraphFileIndex> nfi = [[FileTable fileIndex] addNewChild];
    [nfi addIndexFromPackage:[self.parent package]];
    
    Rcol *rcol = [self findReferencingParentNoLoad:type];
    
    [[FileTable fileIndex] removeChild:nfi];
    [nfi clear];
    
    if (rcol == nil && ![[FileTable fileIndex] loaded]) {
        [[FileTable fileIndex] load];
        rcol = [self findReferencingParentNoLoad:type];
    }
    
    if (rcol == nil) {
        @throw [[Warning alloc] initWithMessage:@"No Parent was found in the Search Path!"
                                        details:@"Either there is no Scenegraph Resource that is referencing the File, or the package containing that Resource is not in the FileTable (see Extra->Preferences...)"];
    }
    
    return rcol;
}

- (Rcol *)findReferencingParentNoLoad:(uint32_t)type {
    NSArray<id<IScenegraphFileIndexItem>> *items = [[FileTable fileIndex] findFileWithType:type noLocal:YES];
    
    @try {
        if ([Wait running]) {
            [Wait subStartWithCount:(NSInteger)[items count]];
        }
        
        for (id<IScenegraphFileIndexItem> item in items) {
            if ([Wait running]) {
                [Wait setMessage:@""];
                [Wait setProgress:[Wait progress] + 1];
            }
            
            Rcol *r = [[GenericRcol alloc] initWithProvider:nil fast:NO];
            
            // Try to open the file in the same package, not in the FileTable package
            NSString *itemPackagePath = [[[item package] saveFileName] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *parentPackagePath = [[[self.parent package] saveFileName] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if ([[itemPackagePath lowercaseString] isEqualToString:[parentPackagePath lowercaseString]]) {
                id<IPackedFileDescriptor> foundDescriptor = [[self.parent package] findFileWithDescriptor:[item fileDescriptor]];
                if (foundDescriptor) {
                    [r processData:foundDescriptor package:[self.parent package]];
                }
            } else {
                [r processData:item];
            }
            
            for (id<IPackedFileDescriptor> pfd in [r referencedFiles]) {
                if ([pfd type] == [[self.parent fileDescriptor] type] &&
                    ([pfd group] == [[self.parent fileDescriptor] group] ||
                     ([pfd group] == [MetaData GLOBAL_GROUP] && [[self.parent fileDescriptor] group] == [MetaData LOCAL_GROUP])) &&
                    [pfd subtype] == [[self.parent fileDescriptor] subtype] &&
                    [pfd instance] == [[self.parent fileDescriptor] instance]) {
                    return r;
                }
            }
        }
    } @finally {
        if ([Wait running]) {
            [Wait subStop];
        }
    }
    
    return nil;
}

// MARK: - String Representation

- (NSString *)description {
    if (self.sgres == nil) {
        return [self blockName];
    } else {
        return [NSString stringWithFormat:@"%@ (%@)", [self.sgres fileName], [self blockName]];
    }
}

// MARK: - IRcolBlock Protocol Methods (Abstract)

- (void)unserialize:(BinaryReader *)reader {
    // Abstract method - must be implemented by subclasses
    [NSException raise:NSInternalInconsistencyException
                format:@"Abstract method %@ must be implemented by subclass %@",
                       NSStringFromSelector(_cmd), NSStringFromClass([self class])];
}

- (void)serialize:(BinaryWriter *)writer {
    // Abstract method - must be implemented by subclasses
    [NSException raise:NSInternalInconsistencyException
                format:@"Abstract method %@ must be implemented by subclass %@",
                       NSStringFromSelector(_cmd), NSStringFromClass([self class])];
}

- (void)dispose {
    // Abstract method - must be implemented by subclasses
    [NSException raise:NSInternalInconsistencyException
                format:@"Abstract method %@ must be implemented by subclass %@",
                       NSStringFromSelector(_cmd), NSStringFromClass([self class])];
}

@end
