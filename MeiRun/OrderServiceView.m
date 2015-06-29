//
//  OrderServiceView.m
//  MeiRun
//
//  Created by mac on 15/6/23.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "OrderServiceView.h"
#import "ShopViewController.h"

@interface OrderServiceView ()

@end

@implementation OrderServiceView

- (void)viewDidLoad
{
    [super viewDidLoad];
//    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
//    
//    UIVisualEffectView *effectview = [[UIVisualEffectView alloc] initWithEffect:blur];
//    
//    effectview.frame =CGRectMake(0,0, self.view.frame.size.width,self.view.frame.size.height);
//    
//    [self.view addSubview:effectview];
    
    UITapGestureRecognizer *zaoxingGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zaoxing:)];
    [self.zaoxingView addGestureRecognizer:zaoxingGesture];
    
    UITapGestureRecognizer *meiJieGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(meiJie:)];
    [self.meijieView addGestureRecognizer:meiJieGesture];
    
    UITapGestureRecognizer *meiJiaGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(meiJia:)];
    [self.meijiaView addGestureRecognizer:meiJiaGesture];
    
    UITapGestureRecognizer *meiRongGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(meiRong:)];
    [self.meirongView addGestureRecognizer:meiRongGesture];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)meiJie:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"orderService" object:nil userInfo:@{@"tag":@"1"}];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)meiJia:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"orderService" object:nil userInfo:@{@"tag":@"2"}];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)meiRong:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"orderService" object:nil userInfo:@{@"tag":@"3"}];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)zaoxing:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"orderService" object:nil userInfo:@{@"tag":@"4"}];
    [self dismissViewControllerAnimated:YES completion:nil];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)backAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
