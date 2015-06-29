//
//  ProtocolView.m
//  MeiRun
//
//  Created by mac on 15/6/11.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "ProtocolView.h"

@interface ProtocolView ()

@end

@implementation ProtocolView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"协议声明";
    NSURL* url = nil;
    NSString* path = nil;
    if(self.type == 1)
    {
        path = [[NSBundle mainBundle] pathForResource:@"meizi" ofType:@"html"];
        url =[NSURL fileURLWithPath:path];
    }
    else
    {
        path = [[NSBundle mainBundle] pathForResource:@"xieyi" ofType:@"html"];
        url =[NSURL fileURLWithPath:path];
    }
    self.webView.scrollView.bounces = NO;
    NSString *htmlStr = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
//    NSURLRequest* request = [NSURLRequest requestWithURL:url] ;
    [self.webView loadHTMLString:htmlStr baseURL:url];
//    [self.webView loadRequest:request];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
