//
//  Message.m
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
// ***************************************************************************

#import "Message.h"
#import "Localization.h"
#import "WaitingScreen.h"
#import "SplashScreen.h"


@interface Message ()
@property (nonatomic, assign) NSInteger buttonCount;
@end

@implementation Message

- (instancetype)init {
    // Create window programmatically since we don't have XIB files
    NSRect windowFrame = NSMakeRect(0, 0, 442, 72);
    NSWindow *window = [[NSWindow alloc] initWithContentRect:windowFrame
                                                   styleMask:NSWindowStyleMaskTitled
                                                     backing:NSBackingStoreBuffered
                                                       defer:NO];
    
    self = [super initWithWindow:window];
    if (self) {
        [self setupUI];
        self.buttonCount = 1;
    }
    return self;
}

- (void)setupUI {
    NSWindow *window = self.window;
    window.title = @"Message";
    window.restorable = NO;
    [window center];
    
    // Create panel2 (top panel with gradient)
    self.panel2 = [[NSView alloc] initWithFrame:NSMakeRect(0, 40, 448, 32)];
    [window.contentView addSubview:self.panel2];
    
    // Create panel1 (bottom panel for buttons)
    self.panel1 = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 448, 40)];
    self.panel1.wantsLayer = YES;
    self.panel1.layer.backgroundColor = [NSColor systemBlueColor].CGColor;
    [window.contentView addSubview:self.panel1];
    
    // Create label1
    self.label1 = [[NSTextField alloc] initWithFrame:NSMakeRect(8, 8, 432, 16)];
    self.label1.stringValue = @"label1";
    self.label1.bordered = NO;
    self.label1.editable = NO;
    self.label1.drawsBackground = NO;
    self.label1.textColor = [NSColor controlTextColor];
    [self.panel2 addSubview:self.label1];
}

+ (NSModalResponse)show:(NSString *)message {
    return [self show:message caption:nil buttons:MessageBoxButtonsOK];
}

+ (NSModalResponse)show:(NSString *)message
                caption:(nullable NSString *)caption
                buttons:(MessageBoxButtons)messageBoxButtons {
    
    BOOL wasRunning = [WaitingScreen running];
    BOOL splashRunning = [Splash running];
    
    if (wasRunning) [WaitingScreen stop];
    if (splashRunning) [[Splash screen] stop];
    
    @try {
        caption = [Localization getString:caption];
        Message *messageDialog = [[Message alloc] init];
        
        // Add buttons based on type
        switch (messageBoxButtons) {
            case MessageBoxButtonsYesNoCancel:
                [messageDialog addButton:[[Localization shared] getString:@"cancel"]
                            dialogResult:NSModalResponseCancel];
                [messageDialog addButton:[[Localization shared] getString:@"no"]
                            dialogResult:CustomModalResponseNo];
                [messageDialog addButton:[[Localization shared] getString:@"yes"]
                            dialogResult:CustomModalResponseYes];
                break;
                
            case MessageBoxButtonsOKCancel:
                [messageDialog addButton:[[Localization shared] getString:@"cancel"]
                            dialogResult:NSModalResponseCancel];
                [messageDialog addButton:[[Localization shared] getString:@"ok"]
                            dialogResult:NSModalResponseOK];
                break;
                
            case MessageBoxButtonsYesNo:
                [messageDialog addButton:[[Localization shared] getString:@"no"]
                            dialogResult:CustomModalResponseNo];
                [messageDialog addButton:[[Localization shared] getString:@"yes"]
                            dialogResult:CustomModalResponseYes];
                break;
                
            case MessageBoxButtonsOK:
            default:
                [messageDialog addButton:[[Localization shared] getString:@"ok"]
                            dialogResult:NSModalResponseOK];
                break;
        }
        
        if (caption != nil) messageDialog.window.title = caption;
        
        // Configure label
        messageDialog.label1.stringValue = message;
        
        // Calculate size needed for text
        NSFont *font = messageDialog.label1.font;
        NSDictionary *attributes = @{NSFontAttributeName: font};
        NSSize maxSize = NSMakeSize(messageDialog.label1.frame.size.width, CGFLOAT_MAX);
        NSRect textRect = [message boundingRectWithSize:maxSize
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                             attributes:attributes];
        
        CGFloat newHeight = MAX(16, textRect.size.height);
        messageDialog.label1.frame = NSMakeRect(8, 8, 432, newHeight);
        
        CGFloat panelHeight = newHeight + 16;
        messageDialog.panel2.frame = NSMakeRect(0, 40, 448, panelHeight);
        messageDialog.panel1.frame = NSMakeRect(0, 0, 448, 40);
        
        CGFloat windowHeight = panelHeight + 40 + 22; // 22 for title bar
        NSRect windowFrame = messageDialog.window.frame;
        windowFrame.size.height = windowHeight;
        [messageDialog.window setFrame:windowFrame display:YES];
        
        NSModalResponse result = [NSApp runModalForWindow:messageDialog.window];
        [messageDialog.window orderOut:nil];
        
        return result;
    }
    @catch (NSException *exception) {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = caption ?: @"Message";
        alert.informativeText = message;
        
        switch (messageBoxButtons) {
            case MessageBoxButtonsYesNoCancel:
                [alert addButtonWithTitle:@"Yes"];
                [alert addButtonWithTitle:@"No"];
                [alert addButtonWithTitle:@"Cancel"];
                break;
            case MessageBoxButtonsOKCancel:
                [alert addButtonWithTitle:@"OK"];
                [alert addButtonWithTitle:@"Cancel"];
                break;
            case MessageBoxButtonsYesNo:
                [alert addButtonWithTitle:@"Yes"];
                [alert addButtonWithTitle:@"No"];
                break;
            default:
                [alert addButtonWithTitle:@"OK"];
                break;
        }
        
        return [alert runModal];
    }
    @finally {
        if (wasRunning) [WaitingScreen wait];
        if (splashRunning) [[Splash screen] setMessage:@""];
    }
}

- (void)addButton:(NSString *)caption dialogResult:(NSModalResponse)dialogResult {
    NSButton *button = [[NSButton alloc] initWithFrame:NSMakeRect(0, 8, 75, 24)];
    button.title = caption;
    button.tag = dialogResult;
    button.target = self;
    button.action = @selector(buttonClick:);
    
    // Position button from right edge
    CGFloat rightMargin = 8;
    CGFloat buttonSpacing = 8;
    CGFloat xPosition = self.panel1.frame.size.width - (button.frame.size.width + rightMargin) * self.buttonCount;
    
    button.frame = NSMakeRect(xPosition, 8, 75, 24);
    [self.panel1 addSubview:button];
    
    self.buttonCount++;
}

- (void)buttonClick:(id)sender {
    NSButton *button = sender;
    self.dialogResult = button.tag;
    [NSApp stopModalWithCode:self.dialogResult];
}

- (MessageBoxResult)mapModalResponseToMessageBoxResult:(NSModalResponse)response {
    switch (response) {
        case NSModalResponseOK:
            return MessageBoxResultOK;
        case NSModalResponseCancel:
            return MessageBoxResultCancel;
        case CustomModalResponseYes:
            return MessageBoxResultYes;
        case CustomModalResponseNo:
            return MessageBoxResultNo;
        default:
            return MessageBoxResultCancel;
    }
}

// Use it when handling the dialog result:
- (void)handleDialogCompletion:(NSModalResponse)response {
    MessageBoxResult result = [self mapModalResponseToMessageBoxResult:response];
}
@end
