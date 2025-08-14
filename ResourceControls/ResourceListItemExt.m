//
//  ResourceListItemExt.m
//  MacSimpe
//
//  Created by Catherine Gramze on 7/29/25.
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

#import "ResourceListItemExt.h"
#import "NamedPackedFileDescriptor.h"
#import "ResourceViewManager.h"
#import "IPackedFileDescriptor.h"
#import "Helper.h"
#import "Registry.h"
#import "MetaData.h"

@interface ResourceListItemExt ()
@property (nonatomic, strong) NSArray<NSString *> *subItems;
@property (nonatomic, assign) NSInteger imageIndex;
@end

@implementation ResourceListItemExt

static NSFont *regularFont = nil;
static NSFont *strikeFont = nil;

- (instancetype)initWithNamedPackedFileDescriptor:(NamedPackedFileDescriptor *)pfd
                                          manager:(ResourceViewManager *)manager
                                          visible:(BOOL)visible {
    self = [super init];
    if (self) {
        _visible = visible;
        _pfd = pfd;
        _manager = manager;
        
        if (regularFont == nil) {
            regularFont = [NSFont systemFontOfSize:[NSFont systemFontSize]];
            NSFontDescriptor *descriptor = [regularFont.fontDescriptor fontDescriptorWithSymbolicTraits:NSFontDescriptorTraitBold];
            strikeFont = [NSFont fontWithDescriptor:descriptor size:regularFont.pointSize];
        }
        
        [self setupSubItems];
        
        self.imageIndex = [ResourceViewManager getIndexForResourceType:[[pfd descriptor] type]];
        
        [self changeDescription:YES];
    }
    return self;
}

- (void)dealloc {
    [self freeResources];
}

- (void)setupSubItems {
    NSMutableArray<NSString *> *subitems = [[NSMutableArray alloc] initWithCapacity:7];
    
    subitems[0] = self.visible ? [self.pfd getRealName] : [[self.pfd descriptor] toResListString]; // Name
    subitems[1] = [self getExtText]; // Type
    subitems[2] = [NSString stringWithFormat:@"0x%@", [Helper hexString:[[self.pfd descriptor] group]]]; // Group
    subitems[3] = [NSString stringWithFormat:@"0x%@", [Helper hexString:[[self.pfd descriptor] subtype]]]; // InstHi
    
    // Inst
    if ([Registry.windowsRegistry resourceListInstanceFormatHexOnly]) {
        subitems[4] = [NSString stringWithFormat:@"0x%@", [Helper hexString:[[self.pfd descriptor] instance]]];
    } else if ([Registry.windowsRegistry resourceListInstanceFormatDecOnly]) {
        subitems[4] = [NSString stringWithFormat:@"%d", (int)[[self.pfd descriptor] instance]];
    } else {
        subitems[4] = [NSString stringWithFormat:@"0x%@ (%d)",
                      [Helper hexString:[[self.pfd descriptor] instance]],
                      (int)[[self.pfd descriptor] instance]];
    }
    
    subitems[5] = [NSString stringWithFormat:@"0x%@", [Helper hexString:[[self.pfd descriptor] offset]]];
    subitems[6] = [NSString stringWithFormat:@"0x%@", [Helper hexString:[[self.pfd descriptor] size]]];
    
    self.subItems = [subitems copy];
}

- (NSString *)getExtText {
    if ([[Registry windowsRegistry] resourceListExtensionFormat] == ResourceListExtensionFormatsShort) {
        TypeAlias *typeAlias = [MetaData findTypeAlias:[[self.pfd descriptor] type]];
        return [typeAlias shortName];
    }
    if ([[Registry windowsRegistry] resourceListExtensionFormat] == ResourceListExtensionFormatsLong) {
        TypeAlias *typeAlias = [MetaData findTypeAlias:[[self.pfd descriptor] type]];
        return [typeAlias name];
    }
    if ([[Registry windowsRegistry] resourceListExtensionFormat] == ResourceListExtensionFormatsHex) {
        return [NSString stringWithFormat:@"0x%@", [Helper hexString:[[self.pfd descriptor] type]]];
    }
    
    return @"";
}

- (void)setVisible:(BOOL)visible {
    if (_visible != visible) {
        _visible = visible;
        if (_visible) {
            [self changeDescription:NO];
        }
    }
}

- (void)freeResources {
    // Event handler cleanup would go here if needed
}

- (void)changeDescription:(BOOL)justFont {
    if (!justFont) {
        [self.pfd resetRealName];
        
        NSMutableArray<NSString *> *mutableSubItems = [self.subItems mutableCopy];
        
        if (self.visible) {
            mutableSubItems[0] = [self.pfd getRealName];
        } else {
            mutableSubItems[0] = [[self.pfd descriptor] toResListString];
        }
        
        if ([Registry.windowsRegistry resourceListShowExtensions]) {
            mutableSubItems[1] = [self getExtText];
        }
        
        mutableSubItems[2] = [NSString stringWithFormat:@"0x%@", [Helper hexString:[[self.pfd descriptor] group]]];
        mutableSubItems[3] = [NSString stringWithFormat:@"0x%@", [Helper hexString:[[self.pfd descriptor] subtype]]];
        
        if ([Registry.windowsRegistry resourceListInstanceFormatHexOnly]) {
            mutableSubItems[4] = [NSString stringWithFormat:@"0x%@", [Helper hexString:[[self.pfd descriptor] instance]]];
        } else if ([Registry.windowsRegistry resourceListInstanceFormatDecOnly]) {
            mutableSubItems[4] = [NSString stringWithFormat:@"%d", (int)[[self.pfd descriptor] instance]];
        } else {
            mutableSubItems[4] = [NSString stringWithFormat:@"0x%@ (%d)",
                                [Helper hexString:[[self.pfd descriptor] instance]],
                                (int)[[self.pfd descriptor] instance]];
        }
        
        mutableSubItems[5] = [NSString stringWithFormat:@"0x%@", [Helper hexString:[[self.pfd descriptor] offset]]];
        mutableSubItems[6] = [NSString stringWithFormat:@"0x%@", [Helper hexString:[[self.pfd descriptor] size]]];
        
        self.subItems = [mutableSubItems copy];
    }
    
    // Font and color styling would be applied to table view cells when displayed
    // This is handled differently in Cocoa than WinForms
}

@end
