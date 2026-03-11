//
//  RemoteControl.m
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
#import "RemoteControl.h"
#import <AppKit/AppKit.h>
#import "ExceptionForm.h"
#import "Helper.h"
#import "FileTable.h"
#import "IScenegraphFileIndex.h"

@interface RemoteControlMessageQueueItem : NSObject
@property (nonatomic, assign) uint32_t target;
@property (nonatomic, copy) ControlEvent fkt;
@end

@implementation RemoteControlMessageQueueItem
@end

@implementation ControlEventArgs {
    NSArray *_data;
    uint32_t _target;
}

- (instancetype)initWithTarget:(uint32_t)target {
    return [self initWithTarget:target items:@[]];
}

- (instancetype)initWithTarget:(uint32_t)target item:(id)item {
    return [self initWithTarget:target items:(item ? @[ item ] : @[])];
}

- (instancetype)initWithTarget:(uint32_t)target items:(NSArray *)items {
    self = [super init];
    if (self) {
        _target = target;
        _data = items ?: @[];
    }
    return self;
}

- (uint32_t)targetType {
    return _target;
}

- (id)item {
    return (_data.count > 0) ? _data[0] : nil;
}

- (NSArray *)items {
    return _data;
}

@end

@implementation RemoteControl

static NSMutableArray<RemoteControlMessageQueueItem *> *events;

static id _appForm;
static NSWindowStyleMask _savedStyleMask; // not perfect, but keeps parity for restore intent

static ShowDockDelegate sdd;
static OpenPackedFileDelegate opf;
static OpenPackageDelegate op;
static OpenMemoryPackageDelegate omp;

static NSMutableArray<ResourceListSelectionChangedHandler> *resourceHandlers;

+ (void)initialize {
    if (self == [RemoteControl class]) {
        events = [[NSMutableArray alloc] init];
        resourceHandlers = [[NSMutableArray alloc] init];
        _savedStyleMask = 0;
    }
}

// MARK: - Message Queue

+ (void)hookToMessageQueue:(uint32_t)type fkt:(ControlEvent)fkt {
    if (!fkt) return;
    
    RemoteControlMessageQueueItem *mqi = [[RemoteControlMessageQueueItem alloc] init];
    mqi.target = type;
    mqi.fkt = [fkt copy];
    [events addObject:mqi];
}

+ (void)unhookFromMessageQueue:(uint32_t)type fkt:(ControlEvent)fkt {
    if (!fkt) return;
    
    for (NSInteger i = (NSInteger)events.count - 1; i >= 0; i--) {
        RemoteControlMessageQueueItem *mqi = events[(NSUInteger)i];
        if (mqi.target == type) {
            // Block pointer identity comparison (matches “delegate equality” semantics best in Obj-C)
            if (mqi.fkt == fkt) {
                [events removeObjectAtIndex:(NSUInteger)i];
            }
        }
    }
}

+ (void)addMessage:(id)sender eventArgs:(ControlEventArgs *)e {
    if (!e) return;
    
    for (RemoteControlMessageQueueItem *mqi in events) {
        if (mqi.fkt == nil) continue;
        
        if (mqi.target == e.targetType || mqi.target == 0xffffffffu || e.targetType == 0xffffffffu) {
            mqi.fkt(sender, e);
        }
    }
}

// MARK: - Application Window (macOS adaptation)

+ (id)applicationForm {
    return _appForm;
}

+ (void)setApplicationForm:(id)form {
    _appForm = form;
    
    // Capture some “restore” state if it’s a window.
    if ([_appForm isKindOfClass:[NSWindow class]]) {
        NSWindow *w = (NSWindow *)_appForm;
        _savedStyleMask = w.styleMask;
    } else {
        _savedStyleMask = 0;
    }
}

+ (BOOL)visibleForm:(id)form {
    // C# version filtered out tool windows/taskbar invisibles.
    // On macOS we treat “NSWindow that is visible and not a utility panel” as “visible form”.
    if (![form isKindOfClass:[NSWindow class]]) return NO;
    
    NSWindow *w = (NSWindow *)form;
    if (!w) return NO;
    
    // Utility panels are roughly analogous to tool windows.
    if ((w.styleMask & NSWindowStyleMaskUtilityWindow) == NSWindowStyleMaskUtilityWindow) return NO;
    
    return YES;
}

+ (void)showSubForm:(id)form {
    if (!form) return;
    
    BOOL shouldHideMain = [self visibleForm:form];
    if (shouldHideMain) [self hideApplicationForm];
    
    if ([form isKindOfClass:[NSWindow class]]) {
        NSWindow *w = (NSWindow *)form;
        NSWindow *parent = ([_appForm isKindOfClass:[NSWindow class]] ? (NSWindow *)_appForm : nil);
        
        if (parent) {
            [parent beginSheet:w completionHandler:nil];
        } else {
            [w makeKeyAndOrderFront:nil];
            [NSApp runModalForWindow:w];
        }
    }
    
    if (shouldHideMain) [self showApplicationForm];
}

+ (void)hideApplicationForm {
    if (![_appForm isKindOfClass:[NSWindow class]]) return;
    
    NSWindow *w = (NSWindow *)_appForm;
    if (w.isVisible) {
        [w orderOut:nil];
    }
}

+ (void)showApplicationForm {
    if (![_appForm isKindOfClass:[NSWindow class]]) return;
    
    NSWindow *w = (NSWindow *)_appForm;
    if (!w.isVisible) {
        [w makeKeyAndOrderFront:nil];
    }
}

+ (void)minimizeApplicationForm {
    if (![_appForm isKindOfClass:[NSWindow class]]) return;
    
    NSWindow *w = (NSWindow *)_appForm;
    if (!w.isMiniaturized) {
        [w miniaturize:nil];
    }
}

+ (void)restoreApplicationForm {
    if (![_appForm isKindOfClass:[NSWindow class]]) return;
    
    NSWindow *w = (NSWindow *)_appForm;
    if (w.isMiniaturized) {
        [w deminiaturize:nil];
    }
}

// MARK: - Delegates

+ (ShowDockDelegate)showDockFkt { return sdd; }
+ (void)setShowDockFkt:(ShowDockDelegate)fkt { sdd = [fkt copy]; }

+ (OpenPackedFileDelegate)openPackedFileFkt { return opf; }
+ (void)setOpenPackedFileFkt:(OpenPackedFileDelegate)fkt { opf = [fkt copy]; }

+ (OpenPackageDelegate)openPackageFkt { return op; }
+ (void)setOpenPackageFkt:(OpenPackageDelegate)fkt { op = [fkt copy]; }

+ (OpenMemoryPackageDelegate)openMemoryPackageFkt { return omp; }
+ (void)setOpenMemoryPackageFkt:(OpenMemoryPackageDelegate)fkt { omp = [fkt copy]; }

// MARK: - Actions

+ (void)showDock:(id)doc hide:(BOOL)hide {
    if (!sdd) return;
    sdd(doc, hide);
}

+ (BOOL)openPackage:(NSString *)filename {
    if (!op) return NO;
    
    @try {
        return op(filename);
    } @catch (NSException *ex) {
        [ExceptionForm executeWithMessage:[NSString stringWithFormat:@"Unable to open a Package in the SimPE GUI. (file=%@)", filename]
                                exception:ex];
    }
    return NO;
}

+ (BOOL)openMemoryPackage:(id<IPackageFile>)pkg {
    if (!omp) return NO;
    
    @try {
        return omp(pkg);
    } @catch (NSException *ex) {
    id obj = (id)pkg;
    NSString *p = [obj respondsToSelector:@selector(description)] ? [obj description] : @"<package>";
    [ExceptionForm executeWithMessage:[NSString stringWithFormat:@"Unable to open a Package in the SimPE GUI. (package=%@)", p]
                            exception:ex];
}
    return NO;
}

+ (BOOL)openPackedFileWithDescriptor:(id<IPackedFileDescriptor>)pfd
                             package:(id<IPackageFile>)pkg
{
    if (pfd == nil) return NO;
    
    // Try to resolve the descriptor to a file-index item (the normal MacSimPE path)
    NSArray<id<IScenegraphFileIndexItem>> *items = [[FileTable fileIndex] findFileDiscardingGroup:pfd];
    if (items != nil && items.count > 0) {
        return [self openPackedFile:items[0]];
    }
    
    // If we can't resolve it, we don't have a concrete IScenegraphFileIndexItem to open in the UI
    return NO;
}

+ (BOOL)openPackedFile:(id<IScenegraphFileIndexItem>)fii {
    if (!opf) return NO;
    
    @try {
        return opf(fii);
    } @catch (NSException *ex) {
    id obj = (id)fii;
    NSString *s = [obj respondsToSelector:@selector(description)] ? [obj description] : @"<resource>";
    [ExceptionForm executeWithMessage:[NSString stringWithFormat:@"Unable to open a resource in the SimPE GUI. (%@)", s]
                            exception:ex];
}
    return NO;
}

// MARK: - Help

+ (void)showHelp:(NSString *)url {
    if (url.length == 0) return;
    
    NSURL *u = [NSURL URLWithString:url];
    if (!u) u = [NSURL fileURLWithPath:url];
    
    if (u) {
        [[NSWorkspace sharedWorkspace] openURL:u];
    }
}

+ (void)showHelp:(NSString *)url topic:(NSString *)topic {
    if (url.length == 0) return;
    
    NSString *full = url;
    if (topic.length > 0) {
        full = [NSString stringWithFormat:@"%@#%@", url, topic];
    }
    [self showHelp:full];
}

// MARK: - Custom Settings

+ (void)showCustomSettings:(id<ISettings>)settings {
    if (!settings) return;
    
    id obj = (id)settings;
    NSString *title = [obj respondsToSelector:@selector(description)] ? [obj description] : @"Settings";
    
    // We don't have a guaranteed SettingsObject API on macOS yet.
    NSString *msg = @"<no settings object>";
    
    NSAlert *a = [[NSAlert alloc] init];
    a.messageText = title ?: @"Settings";
    a.informativeText = msg;
    [a addButtonWithTitle:@"OK"];
    
    NSWindow *parent = ([_appForm isKindOfClass:[NSWindow class]] ? (NSWindow *)_appForm : nil);
    if (parent) {
        [a beginSheetModalForWindow:parent completionHandler:nil];
    } else {
        [a runModal];
    }
}

// MARK: - ResourceListSelectionChanged

+ (void)addResourceListSelectionChangedHandler:(ResourceListSelectionChangedHandler)handler {
    if (!handler) return;
    [resourceHandlers addObject:[handler copy]];
}

+ (void)removeResourceListSelectionChangedHandler:(ResourceListSelectionChangedHandler)handler {
    if (!handler) return;
    
    for (NSInteger i = (NSInteger)resourceHandlers.count - 1; i >= 0; i--) {
        ResourceListSelectionChangedHandler h = resourceHandlers[(NSUInteger)i];
        if (h == handler) {
            [resourceHandlers removeObjectAtIndex:(NSUInteger)i];
        }
    }
}

+ (void)fireResourceListSelectionChangedHandler:(id)sender eventArgs:(id)e {
    for (ResourceListSelectionChangedHandler h in resourceHandlers) {
        if (h) h(sender, e);
    }
}

@end
