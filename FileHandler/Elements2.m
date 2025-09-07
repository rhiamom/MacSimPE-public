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
#import "Nref.h"
#import "Helper.h"
#import "Localization.h"
#import "DataTypes.h"
#import "ExceptionForm.h"
#import <AppKit/AppKit.h>

@implementation Elements2

@synthesize wrapper, fkt, cpfPanel, nrefPanel;

- (instancetype)init {
    self = [super initWithWindowNibName:@"Elements2"];
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
}

#pragma mark - CPF Actions

- (IBAction)cpfItemSelect:(id)sender {
    if ([rtbcpfname tag] != 0) return;
    [llcpfchange setEnabled:NO];
    if ([lbcpf selectedRow] < 0) return;
    [llcpfchange setEnabled:YES];
    
    [rtbcpfname setTag:1];
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
                                  [Helper hexString:[item uIntegerValue]]]];
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
                       exception:ex];
    } @finally {
        [rtbcpfname setTag:0];
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
                [item setUIntegerValue:value];
            } @catch (NSException *ex) {
                [item setUIntegerValue:0];
            }
            break;
        }
        case DataTypesSingle: {
            @try {
                [item setSingleValue:[[rtbcpf string] floatValue]];
            } @catch (NSException *ex) {
                [item setSingleValue:0.0f];
            }
            break;
        }
        case DataTypesBoolean: {
            @try {
                NSInteger value = [[rtbcpf string] integerValue];
                [item setBooleanValue:(value != 0)];
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
        [lbcpf.dataSource addObject:item];
        [item release];
    } else {
        [lbcpf.dataSource replaceObjectAtIndex:[lbcpf selectedRow] withObject:item];
    }
    [lbcpf reloadData];
    
    if (wrapper != nil) {
        [wrapper setChanged:YES];
    }
}

- (IBAction)addCpf:(id)sender {
    [lbcpf deselectAll:nil];
    [self cpfChange:nil];
    [lbcpf selectRowIndexes:[NSIndexSet indexSetWithIndex:[lbcpf numberOfRows] - 1]
       byExtendingSelection:NO];
    [self cpfUpdate];
}

- (void)cpfUpdate {
    Cpf *wrp = (Cpf *)wrapper;
    
    NSMutableArray *items = [NSMutableArray array];
    NSInteger rowCount = [lbcpf numberOfRows];
    for (NSInteger i = 0; i < rowCount; i++) {
        CpfItem *item = [lbcpf.dataSource tableView:lbcpf
                            objectValueForTableColumn:nil
                                                  row:i];
        [items addObject:item];
    }
    [wrp setItems:items];
}

- (IBAction)cpfCommit:(id)sender {
    @try {
        if ([lbcpf selectedRow] >= 0) {
            [self cpfChange:nil];
        }
        [self cpfUpdate];
        Cpf *wrp = (Cpf *)wrapper;
        
        [wrp synchronizeUserData];
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:[[LocalizationManager sharedManager] getString:@"commited"]];
        [alert runModal];
        [alert release];
    } @catch (NSException *ex) {
        [Helper exceptionMessage:[[Localization shared] getString:@"errwritingfile"]
                       exception:ex];
    }
}

- (IBAction)deleteCpf:(id)sender {
    if ([lbcpf selectedRow] < 0) return;
    
    CpfItem *item = [lbcpf.dataSource tableView:lbcpf
                        objectValueForTableColumn:nil
                                              row:[lbcpf selectedRow]];
    [lbcpf.dataSource removeObject:item];
    [lbcpf reloadData];
    [self cpfUpdate];
    if (wrapper != nil) {
        [wrapper setChanged:YES];
    }
}

- (IBAction)btprevClick:(id)sender {
    if (self.fkt == nil) return;
    @try {
        Cpf *cpf = (Cpf *)wrapper;
        self.fkt(cpf, [cpf package]);
    } @catch (NSException *ex) {
        [Helper exceptionMessage:@"" exception:ex];
    }
}

- (IBAction)cpfAutoChange:(id)sender {
    [self cpfAutoChange];
}

- (void)cpfAutoChange {
    if ([rtbcpfname tag] != 0) return;
    if ([lbcpf selectedRow] < 0) return;
    
    [rtbcpfname setTag:1];
    @try {
        [self cpfChange:nil];
    } @finally {
        [rtbcpfname setTag:0];
    }
}

#pragma mark - NREF Actions

- (IBAction)tbnrefTextChanged:(id)sender {
    @try {
        Nref *wrp = (Nref *)wrapper;
        [tbnrefhash setStringValue:[NSString stringWithFormat:@"0x%@",
                                   [Helper hexString:[wrp group]]]];
        
        if ([tbNref tag] == nil) { // allow event execution
            [wrp setFileName:[tbNref stringValue]];
            [wrp setChanged:YES];
        }
        [tbnrefhash setStringValue:[NSString stringWithFormat:@"0x%@",
                                   [Helper hexString:[wrp group]]]];
    } @catch (NSException *ex) {
        [Helper exceptionMessage:@"" exception:ex];
    }
}

- (IBAction)nrefCommit:(id)sender {
    @try {
        [wrapper synchronizeUserData];
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:[[LocalizationManager sharedManager] getString:@"commited"]];
        [alert runModal];
        [alert release];
    } @catch (NSException *ex) {
        [Helper exceptionMessage:[[LocalizationManager sharedManager] getString:@"errwritingfile"]
                       exception:ex];
    }
}

@end
