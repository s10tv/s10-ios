//
//  XLFormExtensions.h
//  Taylr
//
//  Created by Tony Xiao on 4/16/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

#import <XLForm/XLForm.h>

@interface XLFormRowDescriptor (Private)

@property XLFormBaseCell * cell;
- (void)configureCellAtCreationTime;
-(instancetype)initWithTag:(NSString *)tag rowType:(NSString *)rowType title:(NSString *)title;
@end

@interface XLFormPrototypeRowDescriptor : XLFormRowDescriptor

@property (nonatomic, strong) NSString *cellReuseIdentifier;

- (instancetype)initWithCellReuseIdentifier:(NSString *)cellReuseIdentifier;

@end

// Properly handle viewDidLoad when tableview == superview
@interface XLFormTableViewController : XLFormViewController

@end