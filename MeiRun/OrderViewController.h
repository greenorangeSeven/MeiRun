//
//  OrderViewController.h
//  MeiRun
//
//  Created by mac on 15/5/30.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *allBtn;
@property (weak, nonatomic) IBOutlet UIButton *inBtn;
@property (weak, nonatomic) IBOutlet UIButton *noCommBtn;

- (IBAction)allAction:(id)sender;
- (IBAction)inAction:(id)sender;
- (IBAction)noCommAction:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
