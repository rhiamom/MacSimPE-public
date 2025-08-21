//
//  ClstForm.m
//  MacSimpe
//
//  Created by Catherine Gramze on 8/17/25.
//

#import "ClstForm.h"
#import "CompressedFileList.h"
#import "ClstItem.h"

@interface ClstForm () <NSTableViewDataSource, NSTableViewDelegate>
@end

@implementation ClstForm

// MARK: - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    [self setupDataSource];
}

- (void)setupUI {
    // Configure table view
    if (self.lbclst) {
        [self.lbclst setDataSource:self];
        [self.lbclst setDelegate:self];
        
        // Create single column for the list
        NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:@"ClstItemColumn"];
        [column setTitle:@"Items"];
        [column setMinWidth:200];
        [self.lbclst addTableColumn:column];
    }
    
    // Set initial label values
    if (self.label9) {
        [self.label9 setStringValue:@"Format:"];
        [self.label9 setFont:[NSFont boldSystemFontOfSize:13]];
    }
    
    if (self.label12) {
        [self.label12 setStringValue:@"Compressed File Directory"];
        [self.label12 setFont:[NSFont boldSystemFontOfSize:15]];
    }
    
    if (self.lbformat) {
        [self.lbformat setStringValue:@"---"];
    }
    
    // Configure panel backgrounds
    if (self.panel4) {
        [self.panel4 setWantsLayer:YES];
        [self.panel4.layer setBackgroundColor:[[NSColor controlBackgroundColor] CGColor]];
    }
}

- (void)setupDataSource {
    self.clstDataSource = [[NSMutableArray alloc] init];
}

// MARK: - IPackedFileUI Protocol

- (NSView *)guiHandle {
    return self.clstPanel;
}

- (void)updateGUI:(id<IFileWrapper>)wrp {
    self.wrapper = (CompressedFileList *)wrp;
    
    if (self.wrapper) {
        // Update format label
        [self.lbformat setStringValue:[NSString stringWithFormat:@"%ld", (long)[self.wrapper indexType]]];
        
        // Clear and rebuild data source
        [self.clstDataSource removeAllObjects];
        
        NSArray *items = [self.wrapper items];
        for (id item in items) {
            if (item != nil && [item isKindOfClass:[ClstItem class]]) {
                [self.clstDataSource addObject:item];
            } else {
                // Add error placeholder for nil items
                [self.clstDataSource addObject:@"Error"];
            }
        }
        
        // Reload table
        [self.lbclst reloadData];
    }
}

// MARK: - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [self.clstDataSource count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if (row < 0 || row >= [self.clstDataSource count]) {
        return @"";
    }
    
    id item = [self.clstDataSource objectAtIndex:row];
    
    if ([item isKindOfClass:[ClstItem class]]) {
        // Return the string representation of the ClstItem
        return [item description];
    } else if ([item isKindOfClass:[NSString class]]) {
        // Return error strings directly
        return item;
    }
    
    return @"Unknown Item";
}

// MARK: - NSTableViewDelegate

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    // Handle selection changes if needed
    NSInteger selectedRow = [self.lbclst selectedRow];
    if (selectedRow >= 0 && selectedRow < [self.clstDataSource count]) {
        id selectedItem = [self.clstDataSource objectAtIndex:selectedRow];
        NSLog(@"Selected CLST item: %@", selectedItem);
    }
}

// MARK: - Memory Management

- (void)dealloc {
    // Cleanup if needed
}

@end
