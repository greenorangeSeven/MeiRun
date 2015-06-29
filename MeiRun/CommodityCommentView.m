//
//  CommodityCommentView.m
//  MeiRun
//
//  Created by mac on 15/6/11.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "CommodityCommentView.h"
#import "AMRatingControl.h"

@interface CommodityCommentView ()<UITextViewDelegate>
{
    int timeScore;
    int proScore;
    int srScore;
}

@end

@implementation CommodityCommentView

- (void)viewDidLoad {
    [super viewDidLoad];
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    titleLabel.text = @"评价";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForMain];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    //添加边框
    CALayer * layer = [self.commentText layer];
    layer.borderColor = [[UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:1] CGColor];
    layer.borderWidth = 1.0f;
    layer.cornerRadius = 3.0;
    self.commentText.delegate = self;
    
    self.commodityNameLabel.text = self.commodityNameStr;
    self.commodityPriceLabel.text = self.commodityPriceStr;
    [self.commodityImg sd_setImageWithURL:[NSURL URLWithString:self.commodityImgStr]];
    //星级评价
    UIImage *dot, *star;
    dot = [UIImage imageNamed:@"star_nor"];
    star = [UIImage imageNamed:@"star_pro"];
    
    AMRatingControl *timeControl = [[AMRatingControl alloc] initWithLocation:CGPointMake(0, 0) emptyImage:dot solidImage:star andMaxRating:5];
    timeControl.update = @selector(updateScoreRating:);
    timeControl.targer = self;
    timeControl.tag = 1;
    [timeControl setRating:1];
    timeScore = 1;
    
    [self.timelabel addSubview:timeControl];
    
    AMRatingControl *proControl = [[AMRatingControl alloc] initWithLocation:CGPointMake(0, 0) emptyImage:dot solidImage:star andMaxRating:5];
    proControl.update = @selector(updateScoreRating:);
    proControl.targer = self;
    proControl.tag = 2;
    [proControl setRating:1];
    proScore = 1;
    
    [self.proLabel addSubview:proControl];
    
    AMRatingControl *srControl = [[AMRatingControl alloc] initWithLocation:CGPointMake(0, 0) emptyImage:dot solidImage:star andMaxRating:5];
    srControl.update = @selector(updateScoreRating:);
    srControl.targer = self;
    srControl.tag = 3;
    [srControl setRating:1];
    srScore = 1;
    
    [self.serviceLabel addSubview:srControl];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
}

- (void)updateScoreRating:(id)sender
{
    AMRatingControl *amrating = (AMRatingControl *)sender;
    if(amrating.tag == 1)
    {
        timeScore = [amrating rating];
    }
    else if(amrating.tag == 2)
    {
        proScore = [amrating rating];
    }
    else if(amrating.tag == 3)
    {
        srScore = [amrating rating];
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if(!self.hintLabel.hidden)
        self.hintLabel.hidden = YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    
    if(!textView.text || textView.text.length == 0)
    {
        self.hintLabel.hidden = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if (request.hud) {
        [request.hud hide:NO];
        
    }
    [Tool showCustomHUD:@"网络连接超时" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
    if(self.pushBtn.enabled == NO)
    {
        self.pushBtn.enabled = YES;
    }
}

- (void)requestLogin:(ASIHTTPRequest *)request
{
    if (request.hud) {
        [request.hud hide:YES];
    }
    NSLog(@"the :%@",request.responseString);
    [request setUseCookiePersistence:YES];
    if([request.responseString containsString:@"0000"])
    {
        [Tool showCustomHUD:@"已评价" andView:self.view andImage:nil andAfterDelay:1.2];
        [self performSelector:@selector(back) withObject:self afterDelay:1.2];
    }
    else
    {
        [Tool showCustomHUD:@"评价失败请重试" andView:self.view andImage:nil andAfterDelay:1.2];
    }
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)pushAction:(id)sender
{
    self.pushBtn.enabled = NO;
    
    NSString *commentStr = self.commentText.text;
    if(commentStr.length == 0)
    {
        [Tool showCustomHUD:@"请输入评价" andView:self.view andImage:nil andAfterDelay:1.2f];
        return;
    }
    
    //生成登录URL
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:self.orderId forKey:@"orderId"];
    [param setValue:self.commodityId forKey:@"commodityId"];
    UserInfo *userinfo = [[UserModel Instance] getUserInfo];
    [param setValue:userinfo.regUserId forKey:@"r_user_id"];
    [param setValue:commentStr forKey:@"content"];
    [param setValue:[NSString stringWithFormat:@"%i",proScore] forKey:@"pro_sorce"];
    [param setValue:[NSString stringWithFormat:@"%i",srScore] forKey:@"com_sorce"];
    [param setValue:[NSString stringWithFormat:@"%i",timeScore] forKey:@"time_sorce"];
    [param setValue:self.shopId forKey:@"shop_id"];
    
    NSString *commentSign = [Tool serializeSign:[NSString stringWithFormat:@"%@%@", api_base_url, api_addCommodityComment] params:param];
    
    NSString *commentUrl = [NSString stringWithFormat:@"%@%@", api_base_url, api_addCommodityComment];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:commentUrl]];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    [request setPostValue:self.orderId forKey:@"orderId"];
    [request setPostValue:self.commodityId forKey:@"commodityId"];
    [request setPostValue:userinfo.regUserId forKey:@"r_user_id"];
    [request setPostValue:commentStr forKey:@"content"];
    [request setPostValue:[NSString stringWithFormat:@"%i",proScore] forKey:@"pro_sorce"];
    [request setPostValue:[NSString stringWithFormat:@"%i",srScore] forKey:@"com_sorce"];
    [request setPostValue:[NSString stringWithFormat:@"%i",timeScore] forKey:@"time_sorce"];
    [request setPostValue:self.shopId forKey:@"shop_id"];
    
    [request setPostValue:commentSign forKey:@"sign"];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestLogin:)];
    [request startAsynchronous];
    
    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"请稍后..." andView:self.view andHUD:request.hud];
}
@end
