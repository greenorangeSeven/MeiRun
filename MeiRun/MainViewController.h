//
//  MainViewController.h
//  MeiRun
//
//  Created by mac on 15/5/28.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *advImg;
- (IBAction)orderServiceAction:(id)sender;
- (IBAction)meiJie:(id)sender;

- (IBAction)meiJiaAction:(id)sender;
- (IBAction)meiRongAction:(id)sender;
- (IBAction)zaoxingAction:(id)sender;

@end
