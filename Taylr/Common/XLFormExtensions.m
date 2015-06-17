//
//  XLFormExtensions.m
//  Taylr
//
//  Created by Tony Xiao on 4/16/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

#import "XLFormExtensions.h"

@interface XLFormRowDescriptor (Private)

@property XLFormBaseCell * cell;
- (void)configureCellAtCreationTime;

@end

@implementation XLFormPrototypeRowDescriptor

- (instancetype)initWithCellReuseIdentifier:(NSString *)cellReuseIdentifier {
    if (self = [super initWithTag:nil rowType:nil title:nil]) {
        _cellReuseIdentifier = cellReuseIdentifier;
    }
    return self;
}

-(XLFormBaseCell *)cellForFormController:(XLFormViewController *)formController {
    NSAssert(self.cellReuseIdentifier, @"Prototype Row must have a valid cellReuseIdentifier");
    if (!self.cell) {
        // TODO: Use version of dequeue that take into account indexPath
        self.cell = [formController.tableView dequeueReusableCellWithIdentifier:self.cellReuseIdentifier];
        [self configureCellAtCreationTime];
    }
    return self.cell;
}

@end


@implementation XLFormTableViewController

// Hacks to work around the issue where XLFormViewController tries to add TableView as subview of view
// and causing a crash because view cannot add itself as the subview
- (void)viewDidLoad {
    NSAssert(self.view == self.tableView, @"XLFormTableViewController view must == tableview");
    self.view = [[UIView alloc] init];
    [super viewDidLoad];
    [self.tableView removeFromSuperview];
    self.view = self.tableView;
}

@end