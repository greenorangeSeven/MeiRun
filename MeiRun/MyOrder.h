//
//  MyOrder.h
//  MeiRun
//
//  Created by mac on 15/6/11.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyOrder : Jastor

@property (copy, nonatomic) NSString *shopName;
@property (copy, nonatomic) NSString *stateName;
@property (copy, nonatomic) NSString *regUserName;
@property (copy, nonatomic) NSString *payTypeName;
@property (copy, nonatomic) NSString *sendTimeTypeName;
@property (copy, nonatomic) NSString *commodity_name;
@property (copy, nonatomic) NSString *starttimeStamp;
@property (copy, nonatomic) NSString *payTimeStamp;
@property (copy, nonatomic) NSString *sendTimeStamp;
@property (copy, nonatomic) NSString *orderId;
@property (copy, nonatomic) NSString *starttime;
@property (assign, nonatomic) double totalPrice;
@property (copy, nonatomic) NSString *regUserId;
@property (copy, nonatomic) NSString *remark;
@property (copy, nonatomic) NSString *shopId;
@property (copy, nonatomic) NSString *sendTime;
@property (copy, nonatomic) NSString *receivingUserName;
@property (copy, nonatomic) NSString *receivingAddress;
@property (copy, nonatomic) NSString *phone;
@property (copy, nonatomic) NSString *commodity_id;

@property (strong, nonatomic) NSArray *commodityList;


@end
