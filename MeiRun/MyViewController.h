//
//  MyViewController.h
//  MeiRun
//
//  Created by mac on 15/5/30.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *userPhotoIMg;
- (IBAction)loginAction:(id)sender;

@end
