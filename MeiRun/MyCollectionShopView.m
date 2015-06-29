//
//  ShopViewController.m
//  MeiRun
//
//  Created by mac on 15/6/1.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "MyCollectionShopView.h"
#import "Commodity.h"
#import "CommodityCell.h"
#import "ImgInfo.h"
#import "CommodityClass.h"
#import "TypeCell.h"
#import "CommDetailView.h"

@interface MyCollectionShopView ()<UICollectionViewDataSource,UICollectionViewDelegate,EGORefreshTableHeaderDelegate,MBProgressHUDDelegate>
{
    BOOL isLoading;
    BOOL isLoadOver;
    BOOL isInit;
    BOOL isSubClass;
    int allCount;
    
    MBProgressHUD *hud;
    
    //下拉刷新
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    NSMutableArray *commodityArray;
    NSMutableArray *typeArray;
    NSString *sortStr;
}

@end

@implementation MyCollectionShopView

- (void)viewDidLoad
{
    [super viewDidLoad];
    isInit = YES;
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    commodityArray = [[NSMutableArray alloc] initWithCapacity:20];
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    titleLabel.text = @"我的收藏";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForMain];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    //
    //    self.edgesForExtendedLayout = UIRectEdgeNone;
    //    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //标识两个collectionview以便在代理方法中识别
    
    self.shopCollView.dataSource = self;
    self.shopCollView.delegate = self;
    
    [self.shopCollView registerClass:[CommodityCell class] forCellWithReuseIdentifier:@"CommodityCell"];
    
    //添加的代码
    if (_refreshHeaderView == nil) {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -320.0f, self.view.frame.size.width, 320)];
        view.delegate = self;
        [self.shopCollView addSubview:view];
        _refreshHeaderView = view;
    }
    [_refreshHeaderView refreshLastUpdatedDate];
    [self reload:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (void)reload:(BOOL)noRefresh
{
    
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
        hud.hidden = NO;
        [Tool showHUD:@"请稍后" andView:self.view andHUD:hud];
    }
    
    int pageIndex = allCount/20 + 1;
    
    //生成列表URL
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:[NSString stringWithFormat:@"%d", pageIndex] forKey:@"countPerPages"];
    [param setValue:@"20" forKey:@"pageNumbers"];
    UserInfo *userinfo = [[UserModel Instance] getUserInfo];
    [param setValue:userinfo.regUserId forKey:@"regUserId"];
    
    NSString *getCommodityListUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_findCollectionByPage] params:param];
    
    [[AFOSCClient sharedClient]getPath:getCommodityListUrl parameters:Nil
                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                   
                                   if(![operation.responseString containsString:@"resultsList"])
                                   {
                                       [Tool showCustomHUD:@"网络不给力" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
                                       hud.hidden = YES;
                                       return;
                                   }
                                   NSData *data = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
                                   NSError *error;
                                   NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                   NSDictionary *dataJson = [json objectForKey:@"data"];
                                   
                                   NSArray *arry = [dataJson objectForKey:@"resultsList"];
                                   
                                   NSMutableArray *newlist = [NSMutableArray arrayWithArray:[Tool readJsonToObjArray:arry andObjClass:[Commodity class]]];
                                   
                                   isLoading = NO;
                                   if (!noRefresh)
                                   {
                                       [self clear];
                                   }
                                   
                                   @try {
                                       int count = [newlist count];
                                       allCount += count;
                                       if (allCount == 0) {
                                           [Tool showCustomHUD:@"您暂无收藏" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
                                       }
                                       if (count < 20)
                                       {
                                           isLoadOver = YES;
                                       }
                                       [commodityArray addObjectsFromArray:newlist];
                                       Commodity *comm = nil;
                                       if(commodityArray.count > 0)
                                       {
                                           comm = commodityArray[0];
                                       }
                                       if(isInit)
                                       {
                                           hud.hidden = YES;
                                           isInit = NO;
                                       }
                                       [self.shopCollView reloadData];
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
                                   [self.shopCollView reloadData];
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
    [commodityArray removeAllObjects];
    isLoadOver = NO;
}

//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    return [commodityArray count];
    
}

//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CommodityCell *cell = [self.shopCollView dequeueReusableCellWithReuseIdentifier:@"CommodityCell" forIndexPath:indexPath];
    if (!cell) {
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"CommodityCell" owner:self options:nil];
        for (NSObject *o in objects) {
            if ([o isKindOfClass:[CommodityCell class]]) {
                cell = (CommodityCell *)o;
                break;
            }
        }
    }
    int indexRow = [indexPath row];
    Commodity *comm = [commodityArray objectAtIndex:indexRow];
    ImgInfo *imgInfo = comm.imgList[0];
    NSString *imgUrl = imgInfo.imgUrlFull;
    [cell.img sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"loadingpic"]];
    
    cell.name.text = comm.commodityName;
    cell.price.text = [NSString stringWithFormat:@"%@%@",@"￥",comm.price];
    cell.num.text = [NSString stringWithFormat:@"%@%@",comm.saleCount,@"人做过"];
    return cell;
}

#pragma mark --UICollectionViewDelegateFlowLayout
//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    return CGSizeMake(150, 212);
    
}

//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    
    return UIEdgeInsetsMake(5, 5, 5, 5);
    
    
}

#pragma mark --UICollectionViewDelegate
//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    Commodity *commodity = commodityArray[indexPath.row];
    CommDetailView *commDetailView = [[CommDetailView alloc] init];
    commDetailView.hidesBottomBarWhenPushed = YES;
    commDetailView.commodityId = commodity.commodityId;
    commDetailView.shop_id = commodity.shopId;
    commDetailView.titleStr = commodity.commodityName;
    
    [self.navigationController pushViewController:commDetailView animated:YES];
    
}


//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma 下提刷新
- (void)reloadTableViewDataSource
{
    _reloading = YES;
}

- (void)doneLoadingTableViewData
{
    _reloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.shopCollView];
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
    
}
@end
