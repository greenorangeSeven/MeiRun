//
//  Tool.m
//  oschina
//
//  Created by wangjun on 12-3-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Tool.h"
#import "Topic.h"
#import "TopicFull.h"
#import "TopicReply.h"
#import "TopicType.h"

@implementation Tool

+ (UIAlertView *)getLoadingView:(NSString *)title andMessage:(NSString *)message
{
    UIAlertView *progressAlert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityView.frame = CGRectMake(121, 80, 37, 37);
    [progressAlert addSubview:activityView];
    [activityView startAnimating];
    return progressAlert;
}

+ (NSString *)getBBSIndex:(int)index
{
    if (index < 0) {
        return @"";
    }
    return [NSString stringWithFormat:@"%d楼", index+1];
}

+ (void)toTableViewBottom:(UITableView *)tableView isBottom:(BOOL)isBottom
{
    if (isBottom) {
        NSUInteger sectionCount = [tableView numberOfSections];
        if (sectionCount) {
            NSUInteger rowCount = [tableView numberOfRowsInSection:0];
            if (rowCount) {
                NSUInteger ii[2] = {0, rowCount - 1};
                NSIndexPath * indexPath = [NSIndexPath indexPathWithIndexes:ii length:2];
                [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:isBottom ? UITableViewScrollPositionBottom : UITableViewScrollPositionTop animated:YES];
            }
        }
    }
    else
    {
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

+ (NSString *)getCommentLoginNoticeByCatalog:(int)catalog
{
    switch (catalog) {
        case 1:
        case 3:
            return @"请先登录后发表评论";
        case 2:
            return @"请先登录后再回帖或评论";
        case 4:
            return @"请先登录后发留言";
    }
    return @"请先登录后发表评论";
}

+ (void)borderView:(UIView *)view
{
    view.layer.borderColor = [[UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0] CGColor];
    view.layer.borderWidth = 1;
    view.layer.masksToBounds = YES;
    view.clipsToBounds = YES;
}

+ (void)roundTextView:(UIView *)txtView andBorderWidth:(float)width andCornerRadius:(float)radius
{
    txtView.layer.borderColor = [[UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:1.0] CGColor];
    txtView.layer.borderWidth = width;
    txtView.layer.cornerRadius = radius;
    txtView.layer.masksToBounds = YES;
    txtView.clipsToBounds = YES;
}

+ (void)roundView:(UIView *)view andCornerRadius:(float)radius
{
    view.layer.cornerRadius = radius;
    view.layer.masksToBounds = YES;
    view.clipsToBounds = YES;
}

+ (void)playAudio:(BOOL)isAlert
{
    NSString * path = [NSString stringWithFormat:@"%@%@",[[NSBundle mainBundle] resourcePath], isAlert ? @"/alertsound.wav" : @"/soundeffect.wav"];
    SystemSoundID soundID;
    NSURL * filePath = [NSURL fileURLWithPath:path isDirectory:NO];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)filePath, &soundID);
    AudioServicesPlaySystemSound(soundID);
}

+ (UIColor *)getColorForCell:(int)row
{
    return row % 2 ?
    [UIColor colorWithRed:235.0/255.0 green:242.0/255.0 blue:252.0/255.0 alpha:1.0]:
    [UIColor colorWithRed:248.0/255.0 green:249.0/255.0 blue:249.0/255.0 alpha:1.0];
}

+ (UIColor *)getColorForMain
{
    return [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
}

+ (void)clearWebViewBackground:(UIWebView *)webView
{
    UIWebView *web = webView;
    for (id v in web.subviews) {
        if ([v isKindOfClass:[UIScrollView class]]) {
            [v setBounces:NO];
        }
    }
}

+ (void)doSound:(id)sender
{
    NSError *err;
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"soundeffect" ofType:@"wav"]] error:&err];
    player.volume = 1;
    player.numberOfLoops = 1;
    [player prepareToPlay];
    [player play];
}

+ (NSString *)getAppClientString:(int)appClient
{
    switch (appClient) {
        case 1:
            return @"";
        case 2:
            return @"来自手机";
        case 3:
            return @"来自手机";
        case 4:
            return @"来自iPhone";
        case 5:
            return @"来自手机";
        default:
            return @"";
    }
}

+ (void)ReleaseWebView:(UIWebView *)webView
{
    [webView stopLoading];
    [webView setDelegate:nil];
    webView = nil;
}

+ (void)noticeLogin:(UIView *)view andDelegate:(id)delegate andTitle:(NSString *)title
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"请先登录或注册" delegate:delegate cancelButtonTitle:@"返回" destructiveButtonTitle:nil otherButtonTitles:@"登录", @"注册", nil];
    [sheet showInView:[UIApplication sharedApplication].keyWindow];
}

+ (NSString *)intervalSinceNow: (NSString *) theDate
{
    NSDateFormatter *date=[[NSDateFormatter alloc] init];
    [date setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *d=[date dateFromString:theDate];
    NSTimeInterval late=[d timeIntervalSince1970]*1;
    
    
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval now=[dat timeIntervalSince1970]*1;
    NSString *timeString=@"";
    NSTimeInterval cha=now-late;
    
    if (cha/3600<1) {
        if (cha/60<1) {
            timeString = @"1";
        }
        else
        {
            timeString = [NSString stringWithFormat:@"%f", cha/60];
            timeString = [timeString substringToIndex:timeString.length-7];
        }
        
        timeString=[NSString stringWithFormat:@"%@分钟前", timeString];
    }
    else if (cha/3600>1&&cha/86400<1) {
        timeString = [NSString stringWithFormat:@"%f", cha/3600];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@小时前", timeString];
    }
    else if (cha/86400>1&&cha/864000<1)
    {
        timeString = [NSString stringWithFormat:@"%f", cha/86400];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@天前", timeString];
    }
    else
    {
        //        timeString = [NSString stringWithFormat:@"%d-%"]
        NSArray *array = [theDate componentsSeparatedByString:@" "];
        //        return [array objectAtIndex:0];
        timeString = [array objectAtIndex:0];
    }
    return timeString;
}

+ (BOOL)isToday:(NSString *) theDate
{
    NSDateFormatter *date=[[NSDateFormatter alloc] init];
    [date setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *d=[date dateFromString:theDate];
    NSTimeInterval late=[d timeIntervalSince1970]*1;
    
    
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval now=[dat timeIntervalSince1970]*1;
    NSTimeInterval cha=now-late;
    
    if (cha/86400<1) {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (float) heightForString:(UITextView *)textView andWidth:(float)width{
    CGSize sizeToFit = [textView sizeThatFits:CGSizeMake(width, MAXFLOAT)];
    return sizeToFit.height;
}

+ (int)getDaysCount:(int)year andMonth:(int)month andDay:(int)day
{
    return year*365 + month * 31 + day;
}

+ (UIColor *)getBackgroundColor
{
    //    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"fb_bg.jpg"]];
    return [UIColor colorWithRed:234.0/255 green:234.0/255 blue:234.0/255 alpha:1.0];
}
+ (UIColor *)getCellBackgroundColor
{
    return [UIColor colorWithRed:235.0/255 green:235.0/255 blue:243.0/255 alpha:1.0];
}

+ (void)saveCache:(int)type andID:(int)_id andString:(NSString *)str
{
    NSUserDefaults * setting = [NSUserDefaults standardUserDefaults];
    NSString * key = [NSString stringWithFormat:@"detail-%d-%d",type, _id];
    [setting setObject:str forKey:key];
    [setting synchronize];
}
+ (NSString *)getCache:(int)type andID:(int)_id
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"detail-%d-%d",type, _id];
    
    NSString *value = [settings objectForKey:key];
    return value;
}

+ (void)deleteAllCache
{
}

+ (NSString *)getHTMLString:(NSString *)html
{
    return html;
}

+ (void)showHUD:(NSString *)text andView:(UIView *)view andHUD:(MBProgressHUD *)hud
{
    [view addSubview:hud];
    hud.labelText = text;
    //    hud.dimBackground = YES;
    hud.square = YES;
    [hud show:YES];
}

+ (void)showCustomHUD:(NSString *)text andView:(UIView *)view andImage:(NSString *)image andAfterDelay:(int)second
{
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:view];
    [view addSubview:HUD];
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:image]] ;
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.labelText = text;
    [HUD show:YES];
    [HUD hide:YES afterDelay:second];
}

+ (UIImage *)scale:(UIImage *)sourceImg toSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [sourceImg drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage * scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}
+ (CGSize)scaleSize:(CGSize)sourceSize
{
    float width = sourceSize.width;
    float height = sourceSize.height;
    if (width >= height) {
        return CGSizeMake(800, 800 * height / width);
    }
    else
    {
        return CGSizeMake(800 * width / height, 800);
    }
}

+ (NSString *)getOSVersion
{
    return [NSString stringWithFormat:@"GreenOrange.com/%@/%@/%@/%@",AppVersion,[UIDevice currentDevice].systemName,[UIDevice currentDevice].systemVersion, [UIDevice currentDevice].model];
}

//利用正则表达式验证
+ (BOOL)isValidateEmail:(NSString *)email {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

+ (void)ToastNotification:(NSString *)text andView:(UIView *)view andLoading:(BOOL)isLoading andIsBottom:(BOOL)isBottom
{
    GCDiscreetNotificationView *notificationView = [[GCDiscreetNotificationView alloc] initWithText:text showActivity:isLoading inPresentationMode:isBottom?GCDiscreetNotificationViewPresentationModeBottom:GCDiscreetNotificationViewPresentationModeTop inView:view];
    [notificationView show:YES];
    [notificationView hideAnimatedAfter:2.6];
}
+ (void)CancelRequest:(ASIHTTPRequest *)request
{
    if (request != nil) {
        [request cancel];
        [request clearDelegatesAndCancel];
    }
}
+ (NSDate *)NSStringDateToNSDate:(NSString *)string
{
    NSDateFormatter *f = [NSDateFormatter new];
    [f setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [f setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate * d = [f dateFromString:string];
    return d;
}

+ (NSString *)TimestampToDateStr:(NSString *)timestamp andFormatterStr:(NSString *)formatter
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formatter];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[timestamp longLongValue]];
    return [dateFormatter stringFromDate:confromTimesp];
}

+ (NSString *)GenerateTags:(NSMutableArray *)tags
{
    if (tags == nil || tags.count == 0) {
        return @"";
    }
    else
    {
        NSString *result = @"";
        for (NSString *t in tags) {
            result = [NSString stringWithFormat:@"%@<a style='background-color: #BBD6F3;border-bottom: 1px solid #3E6D8E;border-right: 1px solid #7F9FB6;color: #284A7B;font-size: 12pt;-webkit-text-size-adjust: none;line-height: 2.4;margin: 2px 2px 2px 0;padding: 2px 4px;text-decoration: none;white-space: nowrap;' href='http://www.oschina.net/question/tag/%@' >&nbsp;%@&nbsp;</a>&nbsp;&nbsp;",result,t,t];
        }
        return result;
    }
}

+ (void)saveCache:(NSString *)catalog andType:(int)type andID:(int)_id andString:(NSString *)str
{
    NSUserDefaults * setting = [NSUserDefaults standardUserDefaults];
    NSString * key = [NSString stringWithFormat:@"%@-%d-%d",catalog,type, _id];
    [setting setObject:str forKey:key];
    [setting synchronize];
}
+ (NSString *)getCache:(NSString *)catalog andType:(int)type andID:(int)_id
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"%@-%d-%d",catalog,type, _id];
    
    NSString *value = [settings objectForKey:key];
    return value;
}

+ (NSString *)notRounding:(float)price afterPoint:(int)position
{
    NSDecimalNumberHandler* roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown scale:position raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    NSDecimalNumber *ouncesDecimal;
    NSDecimalNumber *roundedOunces;
    
    ouncesDecimal = [[NSDecimalNumber alloc] initWithFloat:price];
    roundedOunces = [ouncesDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
    return [NSString stringWithFormat:@"%@",roundedOunces];
}

+ (NSString* )databasePath
{
    NSString* path=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* dbPath=[path stringByAppendingPathComponent:@"shopcar.db"];
    return dbPath;
}

//平台接口生成验签
+ (NSDictionary *)parseQueryString:(NSString *)query {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:6];
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    
    for (NSString *pair in pairs) {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        
        if ([elements count] <= 1) {
            return nil;
        }
        
        NSString *key = [[elements objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *val = [[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [dict setObject:val forKey:key];
    }
    return dict;
}
//平台接口生成验签
+ (NSString *)serializeURL:(NSString *)baseURL params:(NSDictionary *)params
{
    NSURL* parsedURL = [NSURL URLWithString:[baseURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionaryWithDictionary:[self parseQueryString:[parsedURL query]]];
    if (params) {
        [paramsDic setValuesForKeysWithDictionary:params];
    }
    
    NSMutableString *signString = [NSMutableString stringWithString:@""];
    NSMutableString *paramsString = [NSMutableString stringWithString:@""];
    NSArray *sortedKeys = [[paramsDic allKeys] sortedArrayUsingSelector: @selector(compare:)];
    for (NSString *key in sortedKeys)
    {
        [signString appendFormat:@"%@%@", key, [paramsDic objectForKey:key]];
        [paramsString appendFormat:@"%@=%@&", key, [paramsDic objectForKey:key]];
    }
    [signString appendString:AppSecret];
    
    //去掉最后一个&符号
    paramsString = [NSMutableString stringWithString:[paramsString substringToIndex:paramsString.length - 1]];
    
    NSString *signStringUTF8 = [signString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    NSData *stringBytes = [signStringUTF8 dataUsingEncoding: NSUTF8StringEncoding];
    if (CC_MD5([stringBytes bytes], [stringBytes length], digest)) {
        /* SHA-1 hash has been calculated and stored in 'digest'. */
        NSMutableString *digestString = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
        for (int i=0; i<CC_MD5_DIGEST_LENGTH; i++) {
            unsigned char aChar = digest[i];
            [digestString appendFormat:@"%02X", aChar];
        }
        [paramsString appendFormat:@"&sign=%@", [digestString lowercaseString]];
        return [NSString stringWithFormat:@"%@://%@:%@%@?%@", [parsedURL scheme], [parsedURL host], [parsedURL port], [parsedURL path], [paramsString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    } else {
        return nil;
    }
}

//平台接口生成验签Sign中文转UFT-8
+ (NSString *)serializeUFT8Sign:(NSString *)baseURL params:(NSDictionary *)params
{
    NSURL* parsedURL = [NSURL URLWithString:[baseURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionaryWithDictionary:[self parseQueryString:[parsedURL query]]];
    if (params) {
        [paramsDic setValuesForKeysWithDictionary:params];
    }
    
    NSMutableString *signString = [NSMutableString stringWithString:@""];
    NSArray *sortedKeys = [[paramsDic allKeys] sortedArrayUsingSelector: @selector(compare:)];
    for (NSString *key in sortedKeys) {
        [signString appendFormat:@"%@%@", key, [paramsDic objectForKey:key]];
    }
    [signString appendString:AppSecret];
    NSString *signStringUTF8 = [signString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    NSData *stringBytes = [signStringUTF8 dataUsingEncoding: NSUTF8StringEncoding];
    if (CC_MD5([stringBytes bytes], [stringBytes length], digest)) {
        /* SHA-1 hash has been calculated and stored in 'digest'. */
        NSMutableString *digestString = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
        for (int i=0; i<CC_MD5_DIGEST_LENGTH; i++) {
            unsigned char aChar = digest[i];
            [digestString appendFormat:@"%02X", aChar];
        }
        return [digestString lowercaseString];
    } else {
        return nil;
    }
}

//平台接口生成验签Sign中文
+ (NSString *)serializeSign:(NSString *)baseURL params:(NSDictionary *)params
{
    NSURL* parsedURL = [NSURL URLWithString:[baseURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionaryWithDictionary:[self parseQueryString:[parsedURL query]]];
    if (params) {
        [paramsDic setValuesForKeysWithDictionary:params];
    }
    
    NSMutableString *signString = [NSMutableString stringWithString:@""];
    NSArray *sortedKeys = [[paramsDic allKeys] sortedArrayUsingSelector: @selector(compare:)];
    for (NSString *key in sortedKeys)
    {
        [signString appendFormat:@"%@%@", key, [paramsDic objectForKey:key]];
    }
    
    [signString appendString:AppSecret];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    NSData *stringBytes = [signString dataUsingEncoding: NSUTF8StringEncoding];
    if (CC_MD5([stringBytes bytes], [stringBytes length], digest)) {
        /* SHA-1 hash has been calculated and stored in 'digest'. */
        NSMutableString *digestString = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
        for (int i=0; i<CC_MD5_DIGEST_LENGTH; i++) {
            unsigned char aChar = digest[i];
            [digestString appendFormat:@"%02X", aChar];
        }
        return [digestString lowercaseString];
    } else {
        return nil;
    }
}

+ (NSDictionary*)getObjectData:(id)obj
{
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    unsigned int propsCount;
    objc_property_t *props = class_copyPropertyList([obj class], &propsCount);
    
    for(int i = 0;i < propsCount; i++)
    {
        objc_property_t prop = props[i];
        NSString *propName = [NSString stringWithUTF8String:property_getName(prop)];
        id value = [obj valueForKey:propName];
        if(value == nil)
        {
            value = [NSNull null];
        }
        else
        {
            value = [self getObjectInternal:value];
        }
        
        [dic setObject:value forKey:propName];
    }
    return dic;
}

+(NSData*)getJSON:(id)obj options:(NSJSONWritingOptions)options error:(NSError**)error
{
    
    return [NSJSONSerialization dataWithJSONObject:[self getObjectData:obj] options:options error:error];
}



+(id)getObjectInternal:(id)obj
{
    if([obj isKindOfClass:[NSString class]]
       ||
       [obj isKindOfClass:[NSNumber class]]
       ||
       [obj isKindOfClass:[NSNull class]])
    {
        return obj;
    }
    
    if([obj isKindOfClass:[NSArray class]])
    {
        NSArray *objarr = obj;
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:objarr.count];
        for(int i = 0;i < objarr.count; i++)
        {
            [arr
             setObject:[self getObjectInternal:[objarr objectAtIndex:i]] atIndexedSubscript:i];
        }
        return arr;
    }
    
    if([obj isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *objdic = obj;
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:[objdic count]];
        
        for(NSString *key in objdic.allKeys)
        {
            [dic
             setObject:[self getObjectInternal:[objdic objectForKey:key]] forKey:key];
        }
        return dic;
    }
    return [self getObjectData:obj];
}

+ (NSString *)readObjToJson:(id)obj
{
    NSData *jsonData = [self getJSON:obj options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonText = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    return jsonText;
}

+ (id) readJsonToObj:(NSString *)json andObjClass:(Class)objClass
{
    Jastor *obj = [[objClass alloc] initWithDictionary:[self dictionaryWithJsonString:json]];
    return obj;
}

+ (id)readJsonDicToObj:(NSDictionary *)jsonDic andObjClass:(Class)objClass
{
    Jastor *obj = [[objClass alloc] initWithDictionary:jsonDic];
    return obj;
}

+ (NSArray *)readJsonToObjArray:(NSArray *)jsonArray andObjClass:(Class)objClass
{
    NSMutableArray *objArray = [[NSMutableArray alloc] init];
    for(NSDictionary *dic in jsonArray)
    {
        Jastor *obj = [[objClass alloc] initWithDictionary:dic];
        [objArray addObject:obj];
    }
    
    return objArray;
}

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSLog(@"the json:%@",jsonString);
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

//去掉字符串中的html标签
+(NSString *)filterHTML:(NSString *)html
{
    NSScanner * scanner = [NSScanner scannerWithString:html];
    NSString * text = nil;
    while([scanner isAtEnd]==NO)
    {
        //找到标签的起始位置
        [scanner scanUpToString:@"<" intoString:nil];
        //找到标签的结束位置
        [scanner scanUpToString:@">" intoString:&text];
        //替换字符
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>",text] withString:@""];
    }
    return html;
}

//计算文字的高度
+(int)getTextHeight:(int)width andUIFont:(UIFont *)font andText:(NSString *)txt
{
    float fPadding = 16.0;
    CGSize constraint = CGSizeMake(width - 10 - fPadding, CGFLOAT_MAX);
//    CGSize size = [txt boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size;
     CGSize size = [txt sizeWithFont:font constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    float fHeight = size.height + 16.0;
    return fHeight;
}

/**
 @method 获取指定宽度情况ixa，字符串value的高度
 @param value 待计算的字符串
 @param fontSize 字体的大小
 @param andWidth 限制字符串显示区域的宽度
 @result float 返回的高度
 */
+ (float) heightForString:(NSString *)value fontSize:(float)fontSize andWidth:(float)width
{
    CGSize sizeToFit = [value sizeWithFont:[UIFont systemFontOfSize:fontSize] constrainedToSize:CGSizeMake(width - 16, CGFLOAT_MAX) lineBreakMode:UILineBreakModeTailTruncation];//此处的换行类型（lineBreakMode）可根据自己的实际情况进行设置
    return sizeToFit.height;
}

//解析社区朋友圈
+ (NSMutableArray *)readJsonStrToTopicArray:(NSString *)str
{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *topicJsonDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ( topicJsonDic == nil || [topicJsonDic count] <= 0) {
        return nil;
    }
    NSString *state = [[topicJsonDic objectForKey:@"header"] objectForKey:@"state"];
    if ([state isEqualToString:@"0000"] == YES) {
        NSArray *topicArrayJson = [[topicJsonDic objectForKey:@"data"] objectForKey:@"resultsList"];
        NSMutableArray *topicArray = [RMMapper mutableArrayOfClass:[Topic class] fromArrayOfDictionary:topicArrayJson];
        for (Topic *exp in topicArray) {
            exp.starttime = [Tool intervalSinceNow:[Tool TimestampToDateStr:[exp.starttimeStamp stringValue] andFormatterStr:@"yyyy-MM-dd HH:mm:ss"]];
            exp.contentHeight = [self heightForString:exp.content fontSize:14.0 andWidth:236.0];
            //            exp.contentHeight = [self getTextHeight:236 andUIFont:[UIFont fontWithName:@"Arial-BoldItalicMT" size:14] andText:exp.content];
            if (exp.contentHeight < 21)
            {
                exp.contentHeight = 21;
            }
            else
            {
                exp.contentHeight += 3;
            }
            int imgCount = [exp.imgUrlList count];
            if (imgCount > 0) {
                int row = 0;
                if (imgCount % 3 > 0) {
                    row = imgCount / 3 + 1;
                }
                else
                {
                    row = imgCount / 3;
                }
                exp.imageViewHeight = 70 * row;
            }
            else
            {
                exp.imageViewHeight = 0;
            }
            
            if (exp.contentHeight > 30) {
                exp.viewAddHeight += exp.contentHeight - 21;
            }
            if (exp.imageViewHeight > 70) {
                exp.viewAddHeight += exp.imageViewHeight - 70;
            }
        }
        return topicArray;
    }
    else
    {
        return nil;
    }
}

//解析社区朋友圈（带评论）
+ (NSMutableArray *)readJsonStrToTopicFullArray:(NSString *)str
{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *topicJsonDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ( topicJsonDic == nil || [topicJsonDic count] <= 0) {
        return nil;
    }
    NSString *state = [[topicJsonDic objectForKey:@"header"] objectForKey:@"state"];
    if ([state isEqualToString:@"0000"] == YES) {
        NSArray *topicArrayJson = [[topicJsonDic objectForKey:@"data"] objectForKey:@"resultsList"];
        NSMutableArray *topicArray = [RMMapper mutableArrayOfClass:[TopicFull class] fromArrayOfDictionary:topicArrayJson];
        for (TopicFull *topic in topicArray) {
            topic.replyList = [RMMapper mutableArrayOfClass:[TopicReply class] fromArrayOfDictionary:topic.replyList];
            topic.replyHeight = 0;
            for(TopicReply *reply in topic.replyList)
            {
                reply.replyContent = [NSString stringWithFormat:@"%@：%@",reply.nickName, reply.replyContent];
                reply.contentHeight = [self heightForString:reply.replyContent fontSize:14.0 andWidth:232.0] + 3;
                topic.replyHeight += reply.contentHeight;
                
                reply.replyContentAttr = [[NSMutableAttributedString alloc] initWithString:reply.replyContent];
                [reply.replyContentAttr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:236.0/255.0 green:119.0/255.0 blue:36.0/255.0 alpha:1.0] range:NSMakeRange(0, [reply.nickName length] + 1)];
            }
            
            topic.starttime = [Tool intervalSinceNow:[Tool TimestampToDateStr:topic.starttimeStamp  andFormatterStr:@"yyyy-MM-dd HH:mm:ss"]];
            topic.contentHeight = [self heightForString:topic.content fontSize:14.0 andWidth:236.0];
            
            if (topic.contentHeight < 21)
            {
                topic.contentHeight = 21;
            }
            else
            {
                topic.contentHeight += 3;
            }
            int imgCount = [topic.imgUrlList count];
            if (imgCount > 0) {
                int row = 0;
                if (imgCount % 3 > 0) {
                    row = imgCount / 3 + 1;
                }
                else
                {
                    row = imgCount / 3;
                }
                topic.imageViewHeight = 70 * row;
            }
            else
            {
                topic.imageViewHeight = 0;
            }
            
            
            topic.viewAddHeight += topic.contentHeight;
            
            topic.viewAddHeight += topic.imageViewHeight;
            
            topic.viewAddHeight += topic.replyHeight;
        }
        return topicArray;
    }
    else
    {
        return nil;
    }
}

//解析朋友圈类型JSON
+ (NSMutableArray *)readJsonStrToTopicTypeArray:(NSString *)str
{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *typeJsonDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ( typeJsonDic == nil || [typeJsonDic count] <= 0) {
        return nil;
    }
    NSString *state = [[typeJsonDic objectForKey:@"header"] objectForKey:@"state"];
    if ([state isEqualToString:@"0000"] == YES) {
        NSArray *typeArrayJson = [typeJsonDic objectForKey:@"data"];
        NSMutableArray *typeArray = [RMMapper mutableArrayOfClass:[TopicType class] fromArrayOfDictionary:typeArrayJson];
        return typeArray;
    }
    else
    {
        return nil;
    }
}

@end
