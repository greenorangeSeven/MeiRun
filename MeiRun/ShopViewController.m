//
//  ShopViewController.m
//  MeiRun
//
//  Created by mac on 15/6/1.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "ShopViewController.h"
#import "Commodity.h"
#import "CommodityCell.h"
#import "ImgInfo.h"
#import "CommodityClass.h"
#import "TypeCell.h"
#import "CommDetailView.h"
#import "ProtocolView.h"

@interface ShopViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,EGORefreshTableHeaderDelegate,MBProgressHUDDelegate>
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

@implementation ShopViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    isInit = YES;
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    commodityArray = [[NSMutableArray alloc] initWithCapacity:20];
    self.navigationItem.title = self.titleStr;
    
    UIButton *rBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 58, 22)];
    [rBtn addTarget:self action:@selector(showStatement:) forControlEvents:UIControlEventTouchUpInside];
    [rBtn setTitle:@"免责声明" forState:UIControlStateNormal];
    rBtn.titleLabel.font = [UIFont systemFontOfSize: 13.0];
    UIBarButtonItem *btnTel = [[UIBarButtonItem alloc]initWithCustomView:rBtn];
    self.navigationItem.rightBarButtonItem = btnTel;
    
    //
//    self.edgesForExtendedLayout = UIRectEdgeNone;
//    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //标识两个collectionview以便在代理方法中识别
    self.typeCollView.tag = 1;
    self.shopCollView.tag = 2;
    
    self.typeCollView.dataSource = self;
    self.typeCollView.delegate = self;
    
    self.shopCollView.dataSource = self;
    self.shopCollView.delegate = self;
    
    [self.typeCollView registerClass:[TypeCell class] forCellWithReuseIdentifier:@"TypeCell"];
    
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

- (void)showStatement:(id)sender
{
    ProtocolView *protocolView = [[ProtocolView alloc] init];
    protocolView.type = 1;
    [self.navigationController pushViewController:protocolView animated:YES];
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
    [param setValue:AppSecret forKey:@"accessId"];
    [param setValue:[NSString stringWithFormat:@"%d", pageIndex] forKey:@"countPerPages"];
    [param setValue:@"20" forKey:@"pageNumbers"];
    [param setValue:self.typeId forKey:@"classId"];
    if(sortStr)
    {
        [param setValue:sortStr forKey:@"sort"];
    }
    NSString *getCommodityListUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_findCommodityByPage] params:param];
    
    [[AFOSCClient sharedClient]getPath:getCommodityListUrl parameters:Nil
                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                   
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
                                       
                                       if(comm)
                                       {
                                           //判断是否存在子分类
                                           if(comm.CommodityClassEO &&
                                              comm.CommodityClassEO.count > 0)
                                           {
                                               typeArray = comm.CommodityClassEO;
                                               [self.typeCollView reloadData];
                                           }
                                           else if(!isSubClass)
                                           {
                                               [self hiddenSortTypeView];
                                           }
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

#pragma mark 隐藏子类别View和排序View
- (void)hiddenSortTypeView
{
    self.typeCollView.hidden = YES;
    self.sortView.frame = CGRectMake(self.typeCollView.frame.origin.x, self.typeCollView.frame.origin.y, self.sortView.frame.size.width, self.sortView.frame.size.height);
    self.shopCollView.frame = CGRectMake(self.shopCollView.frame.origin.x, self.sortView.frame.origin.y + self.sortView.frame.size.height + 1, self.shopCollView.frame.size.width, self.view.frame.size.height - (self.sortView.frame.origin.y + self.sortView.frame.size.height + 10));
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
    if(collectionView == self.typeCollView)
    {
        return [typeArray count];
    }
    else
    {
        return [commodityArray count];
    }
}

//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //判断如果是类型collectionview
    if(collectionView == self.typeCollView)
    {
        TypeCell *cell = (TypeCell *)[self.typeCollView dequeueReusableCellWithReuseIdentifier:@"TypeCell" forIndexPath:indexPath];
        if (!cell) {
            NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"TypeCell" owner:self options:nil];
            for (NSObject *o in objects) {
                if ([o isKindOfClass:[TypeCell class]]) {
                    cell = (TypeCell *)o;
                    break;
                }
            }
        }
        
        CommodityClass *class = [typeArray objectAtIndex:indexPath.row];
        [cell.typeBtn setTitle:class.className forState:UIControlStateNormal];
        return cell;
    }
    else
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
}

#pragma mark --UICollectionViewDelegateFlowLayout
//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(collectionView == self.typeCollView)
    {
        return CGSizeMake(88, 42);
    }
    else
    {
        return CGSizeMake(150, 212);
    }
}

//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if(collectionView == self.typeCollView)
    {
        return UIEdgeInsetsMake(10, 5, 10, 5);
    }
    else
    {
        if(IS_IPHONE_6)
        {
            return UIEdgeInsetsMake(5, 18, 5, 18);
        }
        else
        {
            return UIEdgeInsetsMake(5, 5, 5, 5);
        }
    }
    
}

#pragma mark --UICollectionViewDelegate
//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(collectionView == self.typeCollView)
    {
        CommodityClass *class = typeArray[indexPath.row];
        self.typeId = class.classId;
        isInit = YES;
        isLoadOver = NO;
        isSubClass = YES;
        [commodityArray removeAllObjects];
        [self reload:YES];
    }
    else if(collectionView == self.shopCollView)
    {
        Commodity *commodity = commodityArray[indexPath.row];
        CommDetailView *commDetailView = [[CommDetailView alloc] init];
        commDetailView.hidesBottomBarWhenPushed = YES;
        commDetailView.commodityId = commodity.commodityId;
        commDetailView.shop_id = commodity.shopId;
        commDetailView.titleStr = commodity.commodityName;
        
        [self.navigationController pushViewController:commDetailView animated:YES];
    }
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
    if (!isLoading)
    {
        
        [self reload:YES];
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
    if ([UserModel Instance].isNetworkRunning)
    {
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

- (IBAction)zongheSortAction:(id)sender
{
    [self.zongheBtn setTitleColor:[UIColor colorWithRed:0.93 green:0.35 blue:0.53 alpha:1] forState:UIControlStateNormal];
    [self.zongheBtn setBackgroundImage:[UIImage imageNamed:@"activity_tab_bg"] forState:UIControlStateNormal];
    [self.xiaoliangBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.xiaoliangBtn setBackgroundImage:nil forState:UIControlStateNormal];
    [self.priceBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.priceBtn setBackgroundImage:nil forState:UIControlStateNormal];
    [self.price2Btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.price2Btn setBackgroundImage:nil forState:UIControlStateNormal];
    
    sortStr = nil;
    isInit = YES;
    isLoadOver = NO;
    [commodityArray removeAllObjects];
    [self reload: NO];
}

- (IBAction)xiaoliangSortAction:(id)sender
{
    [self.xiaoliangBtn setTitleColor:[UIColor colorWithRed:0.93 green:0.35 blue:0.53 alpha:1] forState:UIControlStateNormal];
    [self.xiaoliangBtn setBackgroundImage:[UIImage imageNamed:@"activity_tab_bg"] forState:UIControlStateNormal];
    [self.zongheBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.zongheBtn setBackgroundImage:nil forState:UIControlStateNormal];
    [self.priceBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.priceBtn setBackgroundImage:nil forState:UIControlStateNormal];
    [self.price2Btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.price2Btn setBackgroundImage:nil forState:UIControlStateNormal];
    
    sortStr = @"sale_count-desc";
    isInit = YES;
    isLoadOver = NO;
    [commodityArray removeAllObjects];
    [self reload:NO];
}

- (IBAction)priceSortAction:(id)sender
{
    [self.priceBtn setTitleColor:[UIColor colorWithRed:0.93 green:0.35 blue:0.53 alpha:1] forState:UIControlStateNormal];
    [self.priceBtn setBackgroundImage:[UIImage imageNamed:@"activity_tab_bg"] forState:UIControlStateNormal];
    [self.zongheBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.zongheBtn setBackgroundImage:nil forState:UIControlStateNormal];
    [self.xiaoliangBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.xiaoliangBtn setBackgroundImage:nil forState:UIControlStateNormal];
    [self.price2Btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.price2Btn setBackgroundImage:nil forState:UIControlStateNormal];
    
    sortStr = @"price-asc";
    isInit = YES;
    isLoadOver = NO;
    [commodityArray removeAllObjects];
    [self reload:NO];
}

- (IBAction)priceSort2Action:(id)sender
{
    [self.price2Btn setTitleColor:[UIColor colorWithRed:0.93 green:0.35 blue:0.53 alpha:1] forState:UIControlStateNormal];
    [self.price2Btn setBackgroundImage:[UIImage imageNamed:@"activity_tab_bg"] forState:UIControlStateNormal];
    [self.zongheBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.zongheBtn setBackgroundImage:nil forState:UIControlStateNormal];
    [self.xiaoliangBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.xiaoliangBtn setBackgroundImage:nil forState:UIControlStateNormal];
    [self.priceBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.priceBtn setBackgroundImage:nil forState:UIControlStateNormal];
    
    sortStr = @"price-desc";
    isInit = YES;
    isLoadOver = NO;
    [commodityArray removeAllObjects];
    [self reload:NO];
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
