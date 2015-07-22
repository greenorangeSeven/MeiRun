//
//  NewDetailView.h
//  BowlKitchen
//
//  Created by mac on 15/3/31.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <UIKit/UIKit.h>
@class News;

@interface NewDetailView : UIViewController<UIWebViewDelegate>

@property (weak, nonatomic) UIView *frameView;

@property (copy, nonatomic) NSString *present;
@property (copy, nonatomic) NSString *titleStr;
@property (copy, nonatomic) NSString *urlStr;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end
