//
//  ProtocolView.h
//  MeiRun
//
//  Created by mac on 15/6/11.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProtocolView : UIViewController
@property int type; //1:免责声明,2:平台协议
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end
