//
//  ShopViewController.h
//  MeiRun
//
//  Created by mac on 15/6/1.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShopViewController : UIViewController

@property (copy, nonatomic) NSString *titleStr;
@property (copy, nonatomic) NSString *typeId;

@property (weak, nonatomic) IBOutlet UICollectionView *typeCollView;
@property (weak, nonatomic) IBOutlet UIButton *zongheBtn;
@property (weak, nonatomic) IBOutlet UIView *sortView;
@property (weak, nonatomic) IBOutlet UIButton *xiaoliangBtn;
@property (weak, nonatomic) IBOutlet UIButton *priceBtn;
@property (weak, nonatomic) IBOutlet UICollectionView *shopCollView;
- (IBAction)zongheSortAction:(id)sender;
- (IBAction)xiaoliangSortAction:(id)sender;

- (IBAction)priceSortAction:(id)sender;


@end
