//
//  Commodity.m
//  MeiRun
//
//  Created by mac on 15/6/2.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "Commodity.h"
#import "ImgInfo.h"
#import "CommodityClass.h"

@implementation Commodity

+ (Class) imgList_class
{
    return [ImgInfo class];
}

+ (Class) CommodityClassEO_class
{
    return[CommodityClass class];
}

@end
