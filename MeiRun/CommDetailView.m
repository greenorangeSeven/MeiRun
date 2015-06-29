//
//  CommDetailView.m
//  BBK
//
//  Created by Seven on 14-12-9.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "OrderCommoditySubmit.h"
#import "OrderSubmitVO.h"
#import "CommDetailView.h"
#import "AppDelegate.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import <AlipaySDK/AlipaySDK.h>
#import "RegisterView.h"
#import "LoginView.h"

@interface CommDetailView ()
{
    MBProgressHUD *hud;
    UIWebView *phoneWebView;
    int isCollectioned;//1:未知，2:已收藏，3:未收藏
}

@end

@implementation CommDetailView

- (void)viewDidLoad {
    [super viewDidLoad];
    isCollectioned = 0;
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.text = self.titleStr;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = UITextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"back_bg"] forState:UIControlStateNormal];
    [button setTitle:@"返回" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(2, 0, 0, -6)];
    [button sizeToFit];
    button.frame = CGRectMake(0, 0, button.frame.size.width, button.frame.size.height);
    [button addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = leftItem;
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"正在加载" andView:self.view andHUD:hud];
    //WebView的背景颜色去除
    [Tool clearWebViewBackground:self.webView];
    //    [self.webView setScalesPageToFit:YES];
    [self.webView sizeToFit];
    if(self.commodityId)
    {
        if([[UserModel Instance] getUserInfo])
        {
            isCollectioned = 1;
            [self isConllection];
        }
        else
        {
            UIButton *rBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 38, 22)];
            [rBtn addTarget:self action:@selector(doCollection:) forControlEvents:UIControlEventTouchUpInside];
            [rBtn setTitle:@"收藏" forState:UIControlStateNormal];
            rBtn.titleLabel.font = [UIFont systemFontOfSize: 13.0];
            UIBarButtonItem *btnTel = [[UIBarButtonItem alloc]initWithCustomView:rBtn];
            self.navigationItem.rightBarButtonItem = btnTel;
        }
    }
    else
    {
        NSURL *url = [[NSURL alloc]initWithString:self.urlStr];
        [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    }
    self.webView.delegate = self;
    if(self.frameView)
    {
        self.webView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.frameView.frame.size.height);
    }
}

- (void)back:(id)sender
{
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
        
    }
}

- (void)doCollection:(id)sender
{
    //判断是否已经登录,没有登录则登录
    if(![[UserModel Instance] getUserInfo])
    {
        [Tool noticeLogin:self.view andDelegate:self andTitle:@""];
        return;
    }
    if(isCollectioned <= 1)
    {
        [self isConllection];
    }
    //判断是否已经收藏
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:self.commodityId forKey:@"commodityId"];
    UserInfo *userinfo = [[UserModel Instance] getUserInfo];
    [param setValue:userinfo.regUserId forKey:@"regUserId"];
    NSString *createRegCodeListUrl = nil;
    if(isCollectioned == 3)
    {
        createRegCodeListUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_addCollection] params:param];
    }
    else if(isCollectioned == 2)
    {
        createRegCodeListUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_delCollection] params:param];
    }
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:createRegCodeListUrl]];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestCollection:)];
    [request startSynchronous];
    
    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
    //[Tool showHUD:@"请稍后" andView:self.view andHUD:request.hud];
}

- (void)isConllection
{
    //判断是否已经收藏
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:self.commodityId forKey:@"commodityId"];
    UserInfo *userinfo = [[UserModel Instance] getUserInfo];
    [param setValue:userinfo.regUserId forKey:@"regUserId"];
    NSString *createRegCodeListUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_isCollection] params:param];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:createRegCodeListUrl]];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestIsCollection:)];
    [request startAsynchronous];
    
    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"请稍后" andView:self.view andHUD:request.hud];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if(!request.hud)
    {
        [request.hud hide:YES];
    }
    [Tool showCustomHUD:@"网络连接超时" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
}

- (void)requestIsCollection:(ASIHTTPRequest *)request
{
    if (request.hud)
    {
        [request.hud hide:YES];
    }
    
    [request setUseCookiePersistence:YES];
    if(isCollectioned == 1)
    {
        //生成列表URL
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:AppSecret forKey:@"accessId"];
        [param setValue:self.commodityId forKey:@"commodityId"];
        [param setValue:self.shop_id forKey:@"shop_id"];
        NSString *getCommodityListUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_findCommodityDetails] params:param];
        NSURL *url = [[NSURL alloc]initWithString:getCommodityListUrl];
        
        [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
        JSContext *context = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
        
        context[@"orderCommodity"] = ^(NSString *time, NSString *address)
        {
            //判断是否已经登录,没有登录则登录
            if(![[UserModel Instance] getUserInfo])
            {
                [Tool noticeLogin:self.view andDelegate:self andTitle:@""];
                return;
            }
            
            [self doCreateOrderNo:time andAddress:address];
        };
    }
    //未收藏
    if([request.responseString containsString:@"0002"])
    {
        UIButton *rBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 48, 22)];
        [rBtn addTarget:self action:@selector(doCollection:) forControlEvents:UIControlEventTouchUpInside];
        [rBtn setTitle:@"收藏" forState:UIControlStateNormal];
        rBtn.titleLabel.font = [UIFont systemFontOfSize: 15.0];
        UIBarButtonItem *btnTel = [[UIBarButtonItem alloc]initWithCustomView:rBtn];
        self.navigationItem.rightBarButtonItem = btnTel;
        if(isCollectioned == 0)
        {
            isCollectioned = 3;
            [self doCollection:btnTel];
        }
        isCollectioned = 3;
    }
    //已收藏
    else if([request.responseString containsString:@"0001"])
    {
        UIButton *rBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 68, 22)];
        [rBtn addTarget:self action:@selector(doCollection:) forControlEvents:UIControlEventTouchUpInside];
        [rBtn setTitle:@"取消收藏" forState:UIControlStateNormal];
        rBtn.titleLabel.font = [UIFont systemFontOfSize: 15.0];
        UIBarButtonItem *btnTel = [[UIBarButtonItem alloc]initWithCustomView:rBtn];
        self.navigationItem.rightBarButtonItem = btnTel;
        if(isCollectioned == 0)
        {
            isCollectioned = 2;
            [self doCollection:btnTel];
        }
        isCollectioned = 2;
    }
    
}

- (void)requestCollection:(ASIHTTPRequest *)request
{
    if (request.hud)
    {
        [request.hud hide:YES];
    }
    
    [request setUseCookiePersistence:YES];
    if([request.responseString containsString:@"0000"])
    {
        if(isCollectioned == 2)
        {
            isCollectioned = 3;
            UIButton *rBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 48, 22)];
            [rBtn addTarget:self action:@selector(doCollection:) forControlEvents:UIControlEventTouchUpInside];
            [rBtn setTitle:@"收藏" forState:UIControlStateNormal];
            rBtn.titleLabel.font = [UIFont systemFontOfSize: 15.0];
            UIBarButtonItem *btnTel = [[UIBarButtonItem alloc]initWithCustomView:rBtn];
            self.navigationItem.rightBarButtonItem = btnTel;
        }
        else if(isCollectioned == 3)
        {
            isCollectioned = 2;
            UIButton *rBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 68, 22)];
            [rBtn addTarget:self action:@selector(doCollection:) forControlEvents:UIControlEventTouchUpInside];
            [rBtn setTitle:@"取消收藏" forState:UIControlStateNormal];
            rBtn.titleLabel.font = [UIFont systemFontOfSize: 15.0];
            UIBarButtonItem *btnTel = [[UIBarButtonItem alloc]initWithCustomView:rBtn];
            self.navigationItem.rightBarButtonItem = btnTel;
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"登录"]) {
        LoginView *loginView = [[LoginView alloc] init];
        [self.navigationController pushViewController:loginView animated:YES];
    }
    else if([buttonTitle isEqualToString:@"注册"])
    {
        RegisterView *regView = [[RegisterView alloc] init];
        [self.navigationController pushViewController:regView animated:YES];
    }
}

- (void)closeAction
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webViewP
{
    if (hud != nil)
    {
        [hud hide:YES];
    }
}

#pragma 浏览器链接处理
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if([request.URL.absoluteString hasPrefix:@"http://tel:"])
    {
        NSURL *phoneUrl = [NSURL URLWithString:[request.URL.absoluteString substringFromIndex:[request.URL.absoluteString rangeOfString:@"tel:"].location]];
        if (!phoneWebView) {
            phoneWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
        }
        [phoneWebView loadRequest:[NSURLRequest requestWithURL:phoneUrl]];
        return NO;
    }
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [self.webView stopLoading];
}

- (void)doCreateOrderNo:(NSString *)time andAddress: (NSString *)address
{
    
    OrderCommoditySubmit *ocs = [[OrderCommoditySubmit alloc] init];
    ocs.commodityId = self.commodityId;
    ocs.num = 1;
    
    UserInfo *userInfo = [[UserModel Instance] getUserInfo];
    
    OrderSubmitVO *ovo = [[OrderSubmitVO alloc] init];
    ovo.regUserId = userInfo.regUserId;
    ovo.remark = @"";
    ovo.receivingUserName = userInfo.regUserName;
    ovo.receivingAddress = address;
    ovo.phone = userInfo.mobileNo;
    ovo.payTypeId = 0;
    ovo.sendTime = time;
    ovo.shopId = self.shop_id;
    ovo.commodityList = [NSArray arrayWithObjects:ocs, nil];
    NSString *orderJson = [Tool readObjToJson:ovo];
    
    //生成订单提交URL
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:orderJson forKey:@"orderJson"];
    
    NSString *orderSubmitSign = [Tool serializeSign:[NSString stringWithFormat:@"%@%@", api_base_url, api_orderSubmit] params:param];
    
    NSString *orderSubmitUrl = [NSString stringWithFormat:@"%@%@", api_base_url, api_orderSubmit];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:orderSubmitUrl]];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    [request setPostValue:orderJson forKey:@"orderJson"];
    [request setPostValue:orderSubmitSign forKey:@"sign"];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(requestCCFailed:)];
    [request setDidFinishSelector:@selector(requestOrder:)];
    [request startAsynchronous];
    
    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"正在提交订单" andView:self.view andHUD:request.hud];
    
}

- (void)requestCCFailed:(ASIHTTPRequest *)request
{
    if (request.hud)
    {
        [request.hud hide:NO];
    }
    [Tool showCustomHUD:@"网络连接超时" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
}

- (void)requestOrder:(ASIHTTPRequest *)request
{
    if (request.hud)
    {
        [request.hud hide:YES];
    }
    
    [request setUseCookiePersistence:YES];
    NSData *data = [request.responseString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    NSString *state = [[json objectForKey:@"header"] objectForKey:@"state"];
    if ([state isEqualToString:@"0000"] == NO) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"错误提示"
                                                     message:[[json objectForKey:@"header"] objectForKey:@"msg"]
                                                    delegate:nil
                                           cancelButtonTitle:@"确定"
                                           otherButtonTitles:nil];
        [av show];
        return;
    }
    else
    {
        
        [Tool showHUD:@"正在支付" andView:self.view andHUD:hud];
        [self doPay:[[json objectForKey:@"header"] objectForKey:@"msg"]];
        
    }
}

- (void)doPay:(NSString *)orderNo
{
    
    //生成支付宝订单URL
    NSString *createOrderUrl = [NSString stringWithFormat:@"%@%@", api_base_url, api_createAlipayParams];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:createOrderUrl]];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    [request setPostValue:orderNo forKey:@"orderId"];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(requestPayFailed:)];
    [request setDidFinishSelector:@selector(requestCreate:)];
    [request startAsynchronous];
    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
    
}

- (void)requestPayFailed:(ASIHTTPRequest *)request
{
    if (hud)
    {
        [hud hide:NO];
    }
    [Tool showCustomHUD:@"网络连接超时" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
}

- (void)requestCreate:(ASIHTTPRequest *)request
{
    if (hud)
    {
        [hud hide:YES];
    }
    
    [request setUseCookiePersistence:YES];
    NSData *data = [request.responseString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    NSString *state = [json objectForKey:@"state"];
    if ([state isEqualToString:@"0000"] == NO) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"错误提示"
                                                     message:[[json objectForKey:@"header"] objectForKey:@"msg"]
                                                    delegate:nil
                                           cancelButtonTitle:@"确定"
                                           otherButtonTitles:nil];
        [av show];
        return;
    }
    else
    {
        NSString *orderStr = [json objectForKey:@"msg"];
        [[AlipaySDK defaultService] payOrder:orderStr fromScheme:@"MeiRunAlipay" callback:^(NSDictionary *resultDic)
         {
             NSString *resultState = resultDic[@"resultStatus"];
             if([resultState isEqualToString:ORDER_PAY_OK])
             {
                 [Tool showCustomHUD:@"已付款,请等待发货" andView:self.view andImage:nil andAfterDelay:1.2f];
                 [self performSelector:@selector(backToBuy) withObject:self afterDelay:1.2f];
             }
         }];
    }
}

- (void)backToBuy
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
    
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
