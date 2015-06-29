//
//  MainViewController.m
//  MeiRun
//
//  Created by mac on 15/5/28.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "MainViewController.h"
#import "SGFocusImageFrame.h"
#import "SGFocusImageItem.h"
#import "Advertisement.h"
#import "CommDetailView.h"
#import "ShopViewController.h"
#import "OrderServiceView.h"

@interface MainViewController ()<SGFocusImageFrameDelegate>
{
    NSMutableArray *advDatas;
    SGFocusImageFrame *bannerView;
    UIWebView *phoneWebView;
    int advIndex;
}

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIButton *rBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 21, 19)];
    [rBtn addTarget:self action:@selector(telAction:) forControlEvents:UIControlEventTouchUpInside];
    [rBtn setImage:[UIImage imageNamed:@"head_tel"] forState:UIControlStateNormal];
    UIBarButtonItem *btnTel = [[UIBarButtonItem alloc]initWithCustomView:rBtn];
    self.navigationItem.rightBarButtonItem = btnTel;
    
    [self getADVData];
}

- (void)getADVData
{
    //如果有网络连接
    if ([UserModel Instance].isNetworkRunning) {
        //生成获取广告URL
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:@"1143295314314900" forKey:@"typeId"];
        [param setValue:@"1" forKey:@"timeCon"];
        NSString *getADDataUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_findAdInfoList] params:param];
        [[AFOSCClient sharedClient]getPath:getADDataUrl parameters:Nil
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       @try {
                                           NSData *data = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
                                           NSError *error;
                                           NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                           NSArray *array = [json objectForKey:@"data"];
                                           advDatas = [NSMutableArray arrayWithArray:[Tool readJsonToObjArray:array andObjClass:[Advertisement class]]];
                                           
                                           int length = [advDatas count];
                                           
                                           NSMutableArray *itemArray = [NSMutableArray arrayWithCapacity:length+2];
                                           if (length > 1)
                                           {
                                               Advertisement *adv = [advDatas objectAtIndex:length-1];
                                               SGFocusImageItem *item = [[SGFocusImageItem alloc] initWithTitle:@"" image:adv.imgUrlFull tag:-1];
                                               [itemArray addObject:item];
                                           }
                                           for (int i = 0; i < length; i++)
                                           {
                                               Advertisement *adv = [advDatas objectAtIndex:i];
                                               SGFocusImageItem *item = [[SGFocusImageItem alloc] initWithTitle:@"" image:adv.imgUrlFull tag:-1];
                                               [itemArray addObject:item];
                                               
                                           }
                                           //添加第一张图 用于循环
                                           if (length >1)
                                           {
                                               Advertisement *adv = [advDatas objectAtIndex:0];
                                               SGFocusImageItem *item = [[SGFocusImageItem alloc] initWithTitle:@"" image:adv.imgUrlFull tag:-1];
                                               [itemArray addObject:item];
                                           }
                                           
                                           bannerView = [[SGFocusImageFrame alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.advImg.frame.size.height) delegate:self imageItems:itemArray isAuto:YES];
                                           [bannerView scrollToIndex:0];
                                           [self.advImg addSubview:bannerView];
                                       }
                                       @catch (NSException *exception) {
                                           [NdUncaughtExceptionHandler TakeException:exception];
                                       }
                                       @finally {
                                           //                                           if (hud != nil) {
                                           //                                               [hud hide:YES];
                                           //                                           }
                                       }
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       if ([UserModel Instance].isNetworkRunning == NO) {
                                           return;
                                       }
                                       if ([UserModel Instance].isNetworkRunning) {
                                           [Tool ToastNotification:@"错误 网络无连接" andView:self.view andLoading:NO andIsBottom:NO];
                                       }
                                   }];
    }
}

//顶部图片滑动点击委托协议实现事件
- (void)foucusImageFrame:(SGFocusImageFrame *)imageFrame didSelectItem:(SGFocusImageItem *)item
{
    NSLog(@"%s \n click===>%@",__FUNCTION__,item.title);
    Advertisement *adv = (Advertisement *)[advDatas objectAtIndex:advIndex];
    if (adv)
    {
        CommDetailView *detailView = [[CommDetailView alloc] init];
        detailView.titleStr = @"广告详情";
        detailView.urlStr = [NSString stringWithFormat:@"%@/app/adDetail.htm?adId=%@",api_base_url,adv.adId];
        detailView.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:detailView animated:YES];
    }
}

//顶部图片自动滑动委托协议实现事件
- (void)foucusImageFrame:(SGFocusImageFrame *)imageFrame currentItem:(int)index;
{
    //    NSLog(@"%s \n scrollToIndex===>%d",__FUNCTION__,index);
    advIndex = index;
}

- (void)telAction:(id)sender
{
    NSURL *phoneUrl = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", @"0731-84010713"]];
    phoneWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
    [phoneWebView loadRequest:[NSURLRequest requestWithURL:phoneUrl]];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (IBAction)orderServiceAction:(id)sender
{
    OrderServiceView *viewController = [[OrderServiceView alloc] init];
    [self presentViewController:viewController animated:YES completion:nil];
}

- (IBAction)meiJie:(id)sender
{
    ShopViewController *shopView = [[UIStoryboard storyboardWithName:@"MainPage" bundle:nil] instantiateViewControllerWithIdentifier:@"ShopViewController"];
    shopView.titleStr = @"美睫";
    shopView.typeId = @"1143260566727500";
    shopView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:shopView animated:YES];
}

- (IBAction)meiJiaAction:(id)sender
{
    ShopViewController *shopView = [[UIStoryboard storyboardWithName:@"MainPage" bundle:nil] instantiateViewControllerWithIdentifier:@"ShopViewController"];
    shopView.titleStr = @"美甲";
    shopView.typeId = @"1143260574016700";
    shopView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:shopView animated:YES];
}

- (IBAction)meiRongAction:(id)sender
{
    ShopViewController *shopView = [[UIStoryboard storyboardWithName:@"MainPage" bundle:nil] instantiateViewControllerWithIdentifier:@"ShopViewController"];
    shopView.titleStr = @"美容";
    shopView.typeId = @"1143260584421400";
    shopView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:shopView animated:YES];
}

- (IBAction)zaoxingAction:(id)sender
{
    ShopViewController *shopView = [[UIStoryboard storyboardWithName:@"MainPage" bundle:nil] instantiateViewControllerWithIdentifier:@"ShopViewController"];
    shopView.titleStr = @"化妆造型";
    shopView.typeId = @"1143260595553400";
    shopView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:shopView animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
    
}
@end
