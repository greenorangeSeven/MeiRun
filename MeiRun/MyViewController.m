//
//  MyViewController.m
//  MeiRun
//
//  Created by mac on 15/5/30.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "MyViewController.h"
#import "LoginView.h"
#import "RegisterView.h"
#import "MyCollectionShopView.h"

@interface MyViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *settings;
}

@end

@implementation MyViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //图片圆形处理
    self.userPhotoIMg.layer.masksToBounds=YES;
    self.userPhotoIMg.layer.cornerRadius=self.userPhotoIMg.frame.size.width/2;    //最重要的是这个地方要设成imgview高的一半
    self.userPhotoIMg.backgroundColor = [UIColor whiteColor];
    
    //设置按钮带圆角
    [self.loginBtn.layer setCornerRadius:4.0f];
    settings = [[NSMutableArray alloc] initWithCapacity:2];
    [settings addObject:@"我的收藏"];
//    [settings addObject:@"我的常用地址"];
    [settings addObject:@"注销"];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.tableView.tableFooterView = [[UIView alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
    UserInfo *userinfo = [[UserModel Instance] getUserInfo];
    if(userinfo)
    {
        self.loginBtn.hidden = YES;
        if(userinfo.photoFull)
        {
            [self.userPhotoIMg sd_setImageWithURL:[NSURL URLWithString:[[UserModel Instance] getUserInfo].photoFull]];
        }
    }
    else
    {
        self.loginBtn.hidden = NO;
        self.userPhotoIMg.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 75.0f;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return settings.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *str = [settings objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingTableIdentifier"];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"SettingTableIdentifier"];
    }
    cell.textLabel.text = str;
    [cell.textLabel setFont:[UIFont fontWithName:@"American Typewriter" size:14.0f]];
    return cell;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.row == 0)
    {
        if(![[UserModel Instance] getUserInfo])
        {
            [Tool noticeLogin:self.view andDelegate:self andTitle:@""];
            return;
        }
        MyCollectionShopView *myShopView = [[MyCollectionShopView alloc] init];
        myShopView.hidesBottomBarWhenPushed =YES;
        [self.navigationController pushViewController:myShopView animated:YES];
    }
//    if(indexPath.row == 1)
//    {
//        if(![[UserModel Instance] getUserInfo])
//        {
//            [Tool noticeLogin:self.view andDelegate:self andTitle:@""];
//            return;
//        }
//    }
    if(indexPath.row == 1)
    {
        [[UserModel Instance] logoutUser];
        self.userPhotoIMg.hidden = YES;
        self.loginBtn.hidden = NO;
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

- (IBAction)loginAction:(id)sender
{
    LoginView *loginView = [[LoginView alloc] init];
    loginView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:loginView animated:YES];
}

@end
