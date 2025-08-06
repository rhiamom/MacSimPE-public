//
//  ResourceRowViews.h
//  MacSimpe
//
//  Created by Catherine Gramze on 7/28/25.
//
// ***************************************************************************
// *  Copyright (C) 2025 by GramzeSweatShop                                  *
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
// *  along with this program; if not, write to the                          *
// *   Free Software Foundation, Inc.,                                       *
// *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
// ***************************************************************************

#import <Cocoa/Cocoa.h>

@class ResourceGroup;
@class NamedPackedFileDescriptor;

// MARK: - Resource Group

@interface ResourceGroup : NSObject

@property (nonatomic, assign) uint32_t type;
@property (nonatomic, strong) TypeAlias *typeAlias;
@property (nonatomic, strong) NSArray *resources;
@property (nonatomic, assign, readonly) NSInteger count;

- (instancetype)initWithType:(uint32_t)type
                   typeAlias:(TypeAlias *)typeAlias
                   resources:(NSArray *)resources;

@end

// MARK: - Resource Type Row View

@interface ResourceTypeRowView : NSTableCellView

@property (nonatomic, strong) IBOutlet NSImageView *iconImageView;
@property (nonatomic, strong) IBOutlet NSTextField *nameLabel;
@property (nonatomic, strong) IBOutlet NSTextField *countLabel;
@property (nonatomic, strong) ResourceGroup *resourceGroup;

- (void)configureWithResourceGroup:(ResourceGroup *)group;
- (NSImage *)iconForType:(uint32_t)type;
- (NSColor *)colorForType:(uint32_t)type;

@end

// MARK: - Resource File Row View

@interface ResourceFileRowView : NSTableCellView

@property (nonatomic, strong) IBOutlet NSTextField *nameLabel;
@property (nonatomic, strong) IBOutlet NSTextField *detailsLabel;
@property (nonatomic, strong) IBOutlet NSImageView *statusImageView;
@property (nonatomic, strong) NamedPackedFileDescriptor *namedResource;

- (void)configureWithNamedResource:(NamedPackedFileDescriptor *)namedResource;

@end

// MARK: - Empty State View

@interface EmptyStateView : NSView

@property (nonatomic, strong) IBOutlet NSImageView *iconImageView;
@property (nonatomic, strong) IBOutlet NSTextField *titleLabel;
@property (nonatomic, strong) IBOutlet NSTextField *subtitleLabel;
@property (nonatomic, strong) IBOutlet NSStackView *contentStackView;

- (void)configureWithIcon:(NSString *)iconName
                    title:(NSString *)title
                 subtitle:(NSString *)subtitle;

@end
