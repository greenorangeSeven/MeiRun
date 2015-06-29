//
//  TypeCell.m
//  MeiRun
//
//  Created by mac on 15/6/3.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "TypeCell.h"

@implementation TypeCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 初始化时加载collectionCell.xib文件
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"TypeCell" owner:self options:nil];
        
        // 如果路径不存在，return nil
        if (arrayOfViews.count < 1)
        {
            return nil;
        }
        // 如果xib中view不属于UICollectionViewCell类，return nil
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UICollectionViewCell class]])
        {
            return nil;
        }
        // 加载nib
        self = [arrayOfViews objectAtIndex:0];
    }
    return self;
}

- (void)awakeFromNib
{
    [self.typeBtn.layer setMasksToBounds:YES];
    [self.typeBtn.layer setCornerRadius:4.0]; //设置矩圆角半径
    self.typeBtn.layer.borderWidth = 1.0f;
    self.typeBtn.layer.borderColor = [[UIColor colorWithRed:0.92 green:0.56 blue:0.65 alpha:1] CGColor];
}

@end
