//
//  Commodity.h
//  MeiRun
//
//  Created by mac on 15/6/2.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Commodity : Jastor

@property (copy, nonatomic) NSString *shopName;
@property (copy, nonatomic) NSString *commentCount;
@property (copy, nonatomic) NSString *sorce;
@property (copy, nonatomic) NSString *className;
@property (copy, nonatomic) NSString *isCollection;
@property (copy, nonatomic) NSString *saleCount;
@property (copy, nonatomic) NSString *commodityId;
@property (copy, nonatomic) NSString *commodityName;
@property (copy, nonatomic) NSString *marketPrice;
@property (copy, nonatomic) NSString *price;
@property (copy, nonatomic) NSString *details;
@property (copy, nonatomic) NSString *classId;
@property (copy, nonatomic) NSString *shopId;
@property (copy, nonatomic) NSString *special_condition;
@property (copy, nonatomic) NSString *duration;
@property (copy, nonatomic) NSString *apply_people;
@property (copy, nonatomic) NSString *notes;
@property (copy, nonatomic) NSString *stock;
@property (strong, nonatomic) NSMutableArray *imgList;

@property (strong, nonatomic) NSMutableArray *CommodityClassEO;

@end
