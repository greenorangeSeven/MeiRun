//
//  OrderServiceView.h
//  MeiRun
//
//  Created by mac on 15/6/23.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderServiceView : UIViewController
@property (weak, nonatomic) IBOutlet UIView *zaoxingView;
@property (weak, nonatomic) IBOutlet UIView *meijiaView;
@property (weak, nonatomic) IBOutlet UIView *meijieView;
@property (weak, nonatomic) IBOutlet UIView *meirongView;

- (IBAction)backAction:(id)sender;

@end
