//
//  CommodityCommentView.h
//  MeiRun
//
//  Created by mac on 15/6/11.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommodityCommentView : UIViewController

@property (copy, nonatomic) NSString *commodityId;
@property (copy, nonatomic) NSString *orderId;
@property (copy, nonatomic) NSString *shopId;
@property (copy, nonatomic) NSString *commodityImgStr;
@property (copy, nonatomic) NSString *commodityNameStr;
@property (copy, nonatomic) NSString *commodityPriceStr;

@property (weak, nonatomic) IBOutlet UILabel *commodityNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *commodityPriceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *commodityImg;

@property (weak, nonatomic) IBOutlet UILabel *timelabel;
@property (weak, nonatomic) IBOutlet UILabel *proLabel;
@property (weak, nonatomic) IBOutlet UILabel *serviceLabel;
@property (weak, nonatomic) IBOutlet UIButton *pushBtn;
@property (weak, nonatomic) IBOutlet UILabel *hintLabel;
- (IBAction)pushAction:(id)sender;

@property (weak, nonatomic) IBOutlet UITextView *commentText;
@end
