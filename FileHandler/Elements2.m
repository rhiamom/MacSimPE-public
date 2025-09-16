//
//  Elements2.m
//  MacSimpe
//
//  Created by Catherine Gramze on 9/5/25.
//
// ***************************************************************************
// *   Copyright (C) 2005 by Ambertation                                     *
// *   quaxi@ambertation.de                                                  *
// *                                                                         *
// *   Objective-C translation Copyright (C) 2025                            *
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

#import "Elements2.h"
#import "IFileWrapperSaveExtension.h"
#import "CpfItem.h"
#import "CpfWrapper.h"
#import "NrefWrapper.h"
#import "Helper.h"
#import "Localization.h"
#import "MetaData.h"
#import "ExceptionForm.h"
#import <AppKit/AppKit.h>

@implementation Elements2

@synthesize wrapper, fkt, cpfPanel, nrefPanel, cpfNameEditingFlag, cpfAutoChangeInProgress, nrefTextChangeEnabled;

- (instancetype)init {
    self = [super initWithWindowNibName:@"Elements2"];
    if (self) {
        self.cpfNameEditingFlag = NO;
        self.cpfAutoChangeInProgress = NO;
        self.nrefTextChangeEnabled = YES;
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    // Additional window setup can be done here
}

#pragma mark - CPF Actions

- (IBAction)cpfItemSelect:(id)sender {
    if (self.cpfNameEditingFlag) return;
    [llcpfchange setEnabled:NO];
    if ([lbcpf selectedRow] < 0) return;
    [llcpfchange setEnabled:YES];
    
    self.cpfNameEditingFlag = YES;
    @try {
        CpfItem *item = [lbcpf.dataSource tableView:lbcpf
                          objectValueForTableColumn:nil
                                                row:[lbcpf selectedRow]];
        [rtbcpfname setString:[item name]];
        
        // Set combo box selection
        [cbtype selectItemAtIndex:-1];
        NSInteger itemCount = [cbtype numberOfItems];
        for (NSInteger i = 0; i < itemCount; i++) {
            DataTypes type = (DataTypes)[[cbtype itemAtIndex:i] tag];
            if (type == [item datatype]) {
                [cbtype selectItemAtIndex:i];
                break;
            }
        }
        
        // Set value based on data type
        switch ([item datatype]) {
            case DataTypesSingle: {
                [rtbcpf setString:[NSString stringWithFormat:@"%f", [item singleValue]]];
                break;
            }
            case DataTypesInteger: {
                [rtbcpf setString:[NSString stringWithFormat:@"0x%@",
                                   [Helper hexString:[item integerValue]]]];
                break;
            }
            case DataTypesUInteger: {
                [rtbcpf setString:[NSString stringWithFormat:@"0x%@",
                                   [Helper hexStringUInt:[item uintegerValue]]]];
                break;
            }
            case DataTypesBoolean: {
                [rtbcpf setString:[item booleanValue] ? @"1" : @"0"];
                break;
            }
            default: {
                [rtbcpf setString:[item stringValue]];
                break;
            }
        }
    } @catch (NSException *ex) {
        [ExceptionForm showError:[[Localization shared] getString:@"errconvert"]
                     withDetails:[ex description]
                       exception:ex];
    } @finally {
        self.cpfNameEditingFlag = NO;
    }
}

- (IBAction)cpfChange:(id)sender {
    if ([cbtype indexOfSelectedItem] < 0) {
        [cbtype selectItemAtIndex:[cbtype numberOfItems] - 1];
    }
    
    CpfItem *item;
    if ([lbcpf selectedRow] < 0) {
        item = [[CpfItem alloc] init];
    } else {
        item = [lbcpf.dataSource tableView:lbcpf
                 objectValueForTableColumn:nil
                                       row:[lbcpf selectedRow]];
    }
    
    [item setName:[rtbcpfname string]];
    [item setDatatype:(DataTypes)[[cbtype selectedItem] tag]];
    
    switch ([item datatype]) {
        case DataTypesInteger: {
            @try {
                NSString *hexString = [[rtbcpf string] stringByReplacingOccurrencesOfString:@"0x" withString:@""];
                NSScanner *scanner = [NSScanner scannerWithString:hexString];
                unsigned int value;
                [scanner scanHexInt:&value];
                [item setIntegerValue:(int32_t)value];
            } @catch (NSException *ex) {
                [item setIntegerValue:0];
            }
            break;
        }
        case DataTypesUInteger: {
            @try {
                NSString *hexString = [[rtbcpf string] stringByReplacingOccurrencesOfString:@"0x" withString:@""];
                NSScanner *scanner = [NSScanner scannerWithString:hexString];
                unsigned int value;
                [scanner scanHexInt:&value];
                [item setUintegerValue:value];
            } @catch (NSException *ex) {
                [item setUintegerValue:0];
            }
            break;
        }
        case DataTypesSingle: {
            @try {
                float value = [[rtbcpf string] floatValue];
                [item setSingleValue:value];
            } @catch (NSException *ex) {
                [item setSingleValue:0.0f];
            }
            break;
        }
        case DataTypesBoolean: {
            @try {
                NSString *boolString = [[rtbcpf string] lowercaseString];
                BOOL value = [boolString isEqualToString:@"1"] ||
                [boolString isEqualToString:@"true"] ||
                [boolString isEqualToString:@"yes"];
                [item setBooleanValue:value];
            } @catch (NSException *ex) {
                [item setBooleanValue:NO];
            }
            break;
        }
        default: {
            [item setStringValue:[rtbcpf string]];
            break;
        }
    }
    
    if ([lbcpf selectedRow] < 0) {
        // Add new item to data source
        Cpf *cpf = (Cpf *)wrapper;
        [cpf addItem:item allowDuplicate:NO];
        [cpf setChanged:YES];
    }
    
    [self cpfUpdate];
}

- (IBAction)addCpf:(id)sender {
    CpfItem *item = [[CpfItem alloc] init];
    [item setName:@"New Item"];
    [item setDatatype:DataTypesString];
    [item setStringValue:@""];
    
    Cpf *cpf = (Cpf *)wrapper;
    [cpf addItem:item allowDuplicate:YES];
    [cpf setChanged:YES];
    
    [self cpfUpdate];
    
    // Select the new item
    NSInteger newIndex = [[cpf items] count] - 1;
    [lbcpf selectRowIndexes:[NSIndexSet indexSetWithIndex:newIndex] byExtendingSelection:NO];
    [self cpfItemSelect:nil];
}

- (IBAction)cpfCommit:(id)sender {
    @try {
        [wrapper synchronizeUserData];
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:[[Localization shared] getString:@"commited"]];
        [alert runModal];
    } @catch (NSException *ex) {
        [ExceptionForm showError:[[Localization shared] getString:@"errwritingfile"]
                     withDetails:[ex description]
                       exception:ex];
    }
}

- (IBAction)btprevClick:(id)sender {
    @try {
        Cpf *cpf = (Cpf *)wrapper;
        self.fkt(cpf, [cpf package]);
    } @catch (NSException *ex) {
        [ExceptionForm showError:@""
                     withDetails:[ex description]
                       exception:ex];
    }
}

- (IBAction)deleteCpf:(id)sender {
    if ([lbcpf selectedRow] < 0) return;
    
    CpfItem *item = [lbcpf.dataSource tableView:lbcpf
                      objectValueForTableColumn:nil
                                            row:[lbcpf selectedRow]];
    
    Cpf *cpf = (Cpf *)wrapper;
    NSMutableArray *items = [NSMutableArray arrayWithArray:[cpf items]];
    [items removeObject:item];
    [cpf setItems:items];
    [cpf setChanged:YES];
    
    [self cpfUpdate];
}

- (IBAction)cpfAutoChange:(id)sender {
    [self cpfAutoChange];
}

- (void)cpfAutoChange {
    if (self.cpfAutoChangeInProgress) return;
    if ([lbcpf selectedRow] < 0) return;
    
    self.cpfAutoChangeInProgress = YES;
    @try {
        [self cpfChange:nil];
    } @finally {
        self.cpfAutoChangeInProgress = NO;
    }
}

#pragma mark - NREF Actions

- (IBAction)tbnrefTextChanged:(id)sender {
    @try {
        NrefWrapper *wrp = (NrefWrapper *)wrapper;
        [tbnrefhash setStringValue:[NSString stringWithFormat:@"0x%@",
                                    [Helper hexStringUInt:[wrp group]]]];
        
        if (self.nrefTextChangeEnabled) { // allow event execution
            [wrp setFileName:[tbNref stringValue]];
            [wrp setChanged:YES];
        }
        [tbnrefhash setStringValue:[NSString stringWithFormat:@"0x%@",
                                    [Helper hexStringUInt:[wrp group]]]];
    } @catch (NSException *ex) {
        [ExceptionForm showError:@""
                     withDetails:[ex description]
                       exception:ex];
    }
}

- (IBAction)nrefCommit:(id)sender {
    @try {
        [wrapper synchronizeUserData];
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:[[Localization shared] getString:@"commited"]];
        [alert runModal];
    } @catch (NSException *ex) {
        [ExceptionForm showError:[[Localization shared] getString:@"errwritingfile"]
                     withDetails:[ex description]
                       exception:ex];
    }
}

#pragma mark - Helper Methods

- (void)cpfUpdate {
    // Trigger table view to reload data
    [lbcpf reloadData];
    
    // Update UI state
    [llcpfchange setEnabled:[lbcpf selectedRow] >= 0];
    [llcpfadd setEnabled:YES];
}

@end
