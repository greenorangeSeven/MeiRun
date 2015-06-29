//
//  OrderViewController.m
//  MeiRun
//
//  Created by mac on 15/5/30.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "OrderViewController.h"
#import "MyOrder.h"
#import "OrderCell.h"
#import "CommodityImg.h"
#import "CommodityCommentView.h"
#import "LoginView.h"
#import "RegisterView.h"
#import <AlipaySDK/AlipaySDK.h>

@interface OrderViewController ()<UITableViewDataSource,UITableViewDelegate,EGORefreshTableHeaderDelegate,MBProgressHUDDelegate>
{
    BOOL isLoading;
    BOOL isLoadOver;
    int allCount;
    BOOL isInit;
    MBProgressHUD *hud;
    //下拉刷新
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    NSMutableArray *orderArray;
    NSString *typeName;
}

@end

@implementation OrderViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    typeName = @"1";
    isInit = true;
    orderArray = [[NSMutableArray alloc] initWithCapacity:20];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    //添加的代码
    if (_refreshHeaderView == nil) {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -320.0f, self.view.frame.size.width, 320)];
        view.delegate = self;
        [self.tableView addSubview:view];
        _refreshHeaderView = view;
    }
    [_refreshHeaderView refreshLastUpdatedDate];
}

- (void)viewWillAppear:(BOOL)animated
{
    isInit = true;
    isLoadOver = NO;
    [orderArray removeAllObjects];
    [self reload:YES];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
}

- (void)reload:(BOOL)noRefresh
{
    if(![[UserModel Instance] getUserInfo])
    {
        [Tool noticeLogin:self.view andDelegate:self andTitle:@""];
        return;
    }
    if (isLoading || isLoadOver)
    {
        return;
    }
    
    if (!noRefresh)
    {
        allCount = 0;
    }
    
    if(isInit)
    {
    }
    
    int pageIndex = allCount/20 + 1;
    
    //生成列表URL
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:@"20"forKey:@"countPerPages"];
    [param setValue:[NSString stringWithFormat:@"%d", pageIndex]  forKey:@"pageNumbers"];
    UserInfo *userinfo = [[UserModel Instance] getUserInfo];
    [param setValue:typeName forKey:@"typeName"];
    //[param setValue:userinfo.regUserId forKey:@"regUserId"];
    [param setValue:userinfo.regUserId forKey:@"regUserId"];
    
    NSString *getCommodityListUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_findOrderByPage] params:param];
    
    [[AFOSCClient sharedClient]getPath:getCommodityListUrl parameters:Nil
                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                   
                                   NSData *data = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
                                   NSError *error;
                                   NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                   NSDictionary *dataJson = [json objectForKey:@"data"];
                                   
                                   NSArray *arry = [dataJson objectForKey:@"resultsList"];
                                   
                                   NSMutableArray *newlist = [NSMutableArray arrayWithArray:[Tool readJsonToObjArray:arry andObjClass:[MyOrder class]]];
                                   
                                   isLoading = NO;
                                   if (!noRefresh)
                                   {
                                       [self clear];
                                   }
                                   
                                   @try {
                                       int count = [newlist count];
                                       allCount += count;
                                       if (count < 20)
                                       {
                                           isLoadOver = YES;
                                       }
                                       [orderArray addObjectsFromArray:newlist];
                                       if(isInit)
                                       {
                                           hud.hidden = YES;
                                           isInit = NO;
                                       }
                                       [self.tableView reloadData];
                                       [self doneLoadingTableViewData];
                                   }
                                   @catch (NSException *exception)
                                   {
                                       [NdUncaughtExceptionHandler TakeException:exception];
                                   }
                                   @finally {
                                       [self doneLoadingTableViewData];
                                   }
                               } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                   //如果是刷新
                                   [self doneLoadingTableViewData];
                                   
                                   if ([UserModel Instance].isNetworkRunning == NO)
                                   {
                                       return;
                                   }
                                   isLoading = NO;
                                   [self.tableView reloadData];
                                   if ([UserModel Instance].isNetworkRunning) {
                                       [Tool showCustomHUD:@"网络不给力" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
                                       hud.hidden = YES;
                                   }
                               }];
    isLoading = YES;
}

- (void)clear
{
    allCount = 0;
    [orderArray removeAllObjects];
    isLoadOver = NO;
}

#pragma 下提刷新
- (void)reloadTableViewDataSource
{
    _reloading = YES;
}

- (void)doneLoadingTableViewData
{
    _reloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
    [self reloadTableViewDataSource];
    [self refresh];
}

// tableView添加拉更新
- (void)egoRefreshTableHeaderDidTriggerToBottom
{
    if (!isLoading) {
    }
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view
{
    return _reloading;
}
- (NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view
{
    return [NSDate date];
}

- (void)refresh
{
    if ([UserModel Instance].isNetworkRunning) {
        isLoadOver = NO;
        [self reload:NO];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([UserModel Instance].isNetworkRunning)
    {
        if (isLoadOver)
        {
            return orderArray.count == 0 ? 1 : orderArray.count + 1;
        }
        else
            return orderArray.count + 1;
    }
    else
        return orderArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([orderArray count] > 0)
    {
        if (indexPath.row < [orderArray count])
        {
            OrderCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"OrderCell"];
            if (!cell)
            {
                NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"OrderCell" owner:self options:nil];
                for (NSObject *o in objects) {
                    if ([o isKindOfClass:[OrderCell class]]) {
                        cell = (OrderCell *)o;
                        break;
                    }
                }
            }
            
            MyOrder *myOrder = [orderArray objectAtIndex:indexPath.row];
            cell.nameLabel.text = myOrder.commodity_name;
            cell.timeLabel.text = [Tool TimestampToDateStr:myOrder.starttimeStamp andFormatterStr:@"yyyy-MM-dd hh:mm"];
            cell.priceLabel.text = [NSString stringWithFormat:@"￥%.2f",myOrder.totalPrice];
            CommodityImg *img = [myOrder.commodityList objectAtIndex:0];
            if(img)
            {
                [cell.orderImg sd_setImageWithURL:[NSURL URLWithString:img.imgUrlFull]];
            }
            
            
            
            //添加边框
            CALayer * layer = [cell.opration layer];
            layer.borderColor = [[UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1] CGColor];
            layer.borderWidth = 1.0f;
            layer.cornerRadius = 3.0;
            if([myOrder.stateName isEqualToString:@"未付款"])
            {
                [cell.opration setTitle:@"付款购买" forState:UIControlStateNormal];
                cell.opration.tag = indexPath.row;
                [cell.opration addTarget:self action:@selector(doPay:) forControlEvents:UIControlEventTouchUpInside];
            }
            else if([myOrder.stateName isEqualToString:@"待评价"])
            {
                [cell.opration setTitle:@"去评价" forState:UIControlStateNormal];
                cell.opration.tag = indexPath.row;
                [cell.opration addTarget:self action:@selector(goComment:) forControlEvents:UIControlEventTouchUpInside];
            }
            else
            {
                [cell.opration setTitle:myOrder.stateName forState:UIControlStateNormal];
            }
            return cell;
        }
        else
        {
            return [[DataSingleton Instance] getLoadMoreCell:tableView andIsLoadOver:isLoadOver andLoadOverString:@"已经加载全部"
                                            andLoadingString:(isLoading ? loadingTip : loadNext20Tip) andIsLoading:isLoading];
        }
    }
    else
    {
        return [[DataSingleton Instance] getLoadMoreCell:tableView andIsLoadOver:isLoadOver andLoadOverString:@"暂无数据" andLoadingString:(isLoading ? loadingTip : loadNext20Tip) andIsLoading:isLoading];
    }
}

- (void)goComment:(id)sender
{
    if(![[UserModel Instance] getUserInfo])
    {
        [Tool noticeLogin:self.view andDelegate:self andTitle:@""];
        return;
    }
    UIButton *btn = sender;
    MyOrder *order = orderArray[btn.tag];
    CommodityCommentView *commentView = [[CommodityCommentView alloc] init];
    CommodityImg *img = order.commodityList[0];
    commentView.commodityImgStr = img.imgUrlFull;
    commentView.commodityNameStr = order.commodity_name;
    commentView.commodityPriceStr = [NSString stringWithFormat:@"￥%.2f",order.totalPrice];
    commentView.commodityId = order.commodity_id;
    commentView.orderId = order.orderId;
    commentView.shopId = order.shopId;
    commentView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:commentView animated:YES];
}

- (void)doPay:(id)sender
{
    if(![[UserModel Instance] getUserInfo])
    {
        [Tool noticeLogin:self.view andDelegate:self andTitle:@""];
        return;
    }
    UIButton *btn = sender;
    MyOrder *order = orderArray[btn.tag];
    NSString *orderNo = order.orderId;
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
        UIWindow *window = [UIApplication sharedApplication].windows[0];
        window.hidden = NO;
        NSLog(@"%@",window);
        [[AlipaySDK defaultService] payOrder:orderStr fromScheme:@"MeiRunAlipay" callback:^(NSDictionary *resultDic)
         {
             NSString *resultState = resultDic[@"resultStatus"];
             if([resultState isEqualToString:ORDER_PAY_OK])
             {
                 [Tool showCustomHUD:@"已付款,请等待发货" andView:self.view andImage:nil andAfterDelay:1.2f];
                 [self reload:NO];
             }
         }];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 161;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)allAction:(id)sender
{
    [self.allBtn setTitleColor:[UIColor colorWithRed:0.93 green:0.35 blue:0.53 alpha:1] forState:UIControlStateNormal];
    [self.allBtn setBackgroundImage:[UIImage imageNamed:@"activity_tab_bg"] forState:UIControlStateNormal];
    [self.inBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.inBtn setBackgroundImage:nil forState:UIControlStateNormal];
    [self.noCommBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.noCommBtn setBackgroundImage:nil forState:UIControlStateNormal];
    
    typeName = @"1";
    isInit = true;
    isLoadOver = NO;
    [orderArray removeAllObjects];
    [self reload:NO];
}

- (IBAction)inAction:(id)sender
{
    [self.inBtn setTitleColor:[UIColor colorWithRed:0.93 green:0.35 blue:0.53 alpha:1] forState:UIControlStateNormal];
    [self.inBtn setBackgroundImage:[UIImage imageNamed:@"activity_tab_bg"] forState:UIControlStateNormal];
    [self.allBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.allBtn setBackgroundImage:nil forState:UIControlStateNormal];
    [self.noCommBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.noCommBtn setBackgroundImage:nil forState:UIControlStateNormal];
    
    typeName = @"2";
    isInit = true;
    isLoadOver = NO;
    [orderArray removeAllObjects];
    [self reload:NO];
}

- (IBAction)noCommAction:(id)sender
{
    [self.noCommBtn setTitleColor:[UIColor colorWithRed:0.93 green:0.35 blue:0.53 alpha:1] forState:UIControlStateNormal];
    [self.noCommBtn setBackgroundImage:[UIImage imageNamed:@"activity_tab_bg"] forState:UIControlStateNormal];
    [self.inBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.inBtn setBackgroundImage:nil forState:UIControlStateNormal];
    [self.allBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.allBtn setBackgroundImage:nil forState:UIControlStateNormal];
    
    typeName = @"3";
    isInit = true;
    isLoadOver = NO;
    [orderArray removeAllObjects];
    [self reload:NO];
}

@end
