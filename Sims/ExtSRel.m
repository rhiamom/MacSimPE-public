//
//  ExtSRel.m
//  MacSimpe
//
//  Created by Catherine Gramze on 9/17/25.
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

#import "ExtSRel.h"
#import "ExtSDesc.h"
#import "IWrapperInfo.h"
#import "AbstractWrapperInfo.h"
#import "IProviderRegistry.h"
#import "FileTable.h"
#import "MetaData.h"
#import "TypeAlias.h"
#import "Localization.h"
#import "IPackedFileDescriptorBasic.h"
#import "IPackedFileDescriptor.h"
#import "ISimDescriptionProvider.h"

@interface ExtSRel ()

// MARK: - Private Properties (matching C# private fields)
@property (nonatomic, strong, nullable) ExtSDesc *src;
@property (nonatomic, strong, nullable) ExtSDesc *dst;

@end

@implementation ExtSRel

// MARK: - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        // Additional initialization if needed
    }
    return self;
}

// MARK: - AbstractWrapper Overrides

- (id<IWrapperInfo>)createWrapperInfo {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *imagePath = [bundle pathForResource:@"srel" ofType:@"png"];
    NSImage *icon = nil;
    if (imagePath) {
        icon = [[NSImage alloc] initWithContentsOfFile:imagePath];
    }
    
    return [[AbstractWrapperInfo alloc] initWithName:@"Extended Sim Relation Wrapper"
                                              author:@"Quaxi"
                                         description:@"This File Contains the Relationship states for two Sims."
                                             version:2
                                               icon:icon];
}

- (id<IPackedFileUI>)createDefaultUIHandler {
    // This will return the ExtSrel UI class when it's translated
    // For now, return nil - the UI class will be provided later
    return nil; // TODO: return [[ExtSrelUI alloc] init]; when ExtSrelUI is translated
}

// MARK: - Instance Properties

- (uint32_t)targetSimInstance {
    if (self.fileDescriptor == nil) {
        return 0;
    }
    return (self.fileDescriptor.instance & 0xFFFF);
}

- (uint32_t)sourceSimInstance {
    if (self.fileDescriptor == nil) {
        return 0;
    }
    return ((self.fileDescriptor.instance >> 16) & 0xFFFF);
}

// MARK: - Sim Description Access

- (ExtSDesc *)sourceSim {
    if (self.src == nil) {
        self.src = [self getDescriptionByInstance:self.sourceSimInstance];
    } else if (self.src.fileDescriptor.instance != self.sourceSimInstance) {
        self.src = [self getDescriptionByInstance:self.sourceSimInstance];
    }
    
    return self.src;
}

- (ExtSDesc *)targetSim {
    if (self.dst == nil) {
        self.dst = [self getDescriptionByInstance:self.targetSimInstance];
    } else if (self.dst.fileDescriptor.instance != self.targetSimInstance) {
        self.dst = [self getDescriptionByInstance:self.targetSimInstance];
    }
    
    return self.dst;
}

// MARK: - Sim Names

- (NSString *)sourceSimName {
    ExtSDesc *sourceSim = self.sourceSim;
    if (sourceSim != nil) {
        return [NSString stringWithFormat:@"%@ %@", sourceSim.simName, sourceSim.simFamilyName];
    }
    return [Localization getString:@"Unknown"];
}

- (NSString *)targetSimName {
    ExtSDesc *targetSim = self.targetSim;
    if (targetSim != nil) {
        return [NSString stringWithFormat:@"%@ %@", targetSim.simName, targetSim.simFamilyName];
    }
    return [Localization getString:@"Unknown"];
}

// MARK: - Image Composition

- (NSImage *)image {
    // Create composite bitmap matching C# version (356x256)
    NSSize imageSize = NSMakeSize(356, 256);
    NSImage *compositeImage = [[NSImage alloc] initWithSize:imageSize];
    
    [compositeImage lockFocus];
    
    // Get source sim image
    NSImage *sourceImage = nil;
    ExtSDesc *sourceSim = self.sourceSim;
    if (sourceSim != nil && sourceSim.image != nil && sourceSim.image.size.width > 8) {
        sourceImage = sourceSim.image;
        // TODO: Apply knockout image processing when GraphicRoutines is translated
    }
    if (sourceImage == nil) {
        sourceImage = [self getDefaultSimImage:@"noone.png"];
    }
    
    // Get target sim image
    NSImage *targetImage = nil;
    ExtSDesc *targetSim = self.targetSim;
    if (targetSim != nil && targetSim.image != nil && targetSim.image.size.width > 8) {
        targetImage = targetSim.image;
        // TODO: Apply knockout image processing when GraphicRoutines is translated
    }
    if (targetImage == nil) {
        targetImage = [self getDefaultSimImage:@"noone.png"];
    }
    
    // Draw images with offset (matching C# layout)
    const CGFloat offsetY = 32;
    
    // Draw source sim (left side) - matching C# Rectangle(0, offsety, 256, 256-offsety)
    NSRect sourceRect = NSMakeRect(0, offsetY, 256, 256 - offsetY);
    NSRect sourceFromRect = NSMakeRect(0, 0, sourceImage.size.width, sourceImage.size.height - offsetY);
    [sourceImage drawInRect:sourceRect
                   fromRect:sourceFromRect
                  operation:NSCompositingOperationSourceOver
                   fraction:1.0];
    
    // Draw target sim (right side, overlapping) - matching C# Rectangle(100, 0, 256, 256)
    NSRect targetRect = NSMakeRect(100, 0, 256, 256);
    NSRect targetFromRect = NSMakeRect(0, 0, targetImage.size.width, targetImage.size.height);
    [targetImage drawInRect:targetRect
                   fromRect:targetFromRect
                  operation:NSCompositingOperationSourceOver
                   fraction:1.0];
    
    [compositeImage unlockFocus];
    
    return compositeImage;
}

// MARK: - Sim Lookup

- (ExtSDesc *)getDescriptionByInstance:(uint32_t)instance {
    // Matching C# code: FileTable.ProviderRegistry.SimDescriptionProvider.FindSim((ushort)inst)
    id<IProviderRegistry> providerRegistry = [FileTable providerRegistry];
    if (providerRegistry != nil && providerRegistry.simDescriptionProvider != nil) {
        ExtSDesc *simDesc = (ExtSDesc *)[providerRegistry.simDescriptionProvider findSim:(uint16_t)instance];
        return simDesc;
    }
    
    // The C# code has unreachable code for package-based lookup - commented out for now
    return nil;
}

// MARK: - Resource Naming

- (NSString *)getResourceName:(TypeAlias *)typeAlias {
    if (!self.processed) {
        [self processData:self.fileDescriptor package:self.package];
    }
    
    NSString *towards = [Localization getString:@"towards"];
    return [NSString stringWithFormat:@"%@ %@ %@", self.sourceSimName, towards, self.targetSimName];
}

// MARK: - Private Helper Methods

- (NSImage *)getDefaultSimImage:(NSString *)filename {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *name = [filename stringByDeletingPathExtension];
    NSString *extension = [filename pathExtension];
    NSString *imagePath = [bundle pathForResource:name ofType:extension];
    if (imagePath != nil) {
        return [[NSImage alloc] initWithContentsOfFile:imagePath];
    }
    
    // Fallback: create a simple placeholder
    NSImage *placeholder = [[NSImage alloc] initWithSize:NSMakeSize(128, 128)];
    [placeholder lockFocus];
    [[NSColor grayColor] setFill];
    NSRectFill(NSMakeRect(0, 0, 128, 128));
    [placeholder unlockFocus];
    
    return placeholder;
}

@end
