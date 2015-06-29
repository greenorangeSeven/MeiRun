//
//  AppDelegate.m
//  BowlKitchen
//
//  Created by mac on 15/3/9.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "AppDelegate.h"
#import "XGPush.h"
#import "XGSetting.h"
#import "CheckNetwork.h"
#import "UserModel.h"
#import "StartView.h"
#import "IQKeyboardManager.h"
#import <AlipaySDK/AlipaySDK.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    IQKeyboardManager *manager = [IQKeyboardManager sharedManager];
    manager.enable = YES;
//    manager.shouldResignOnTouchOutside = YES;
//    manager.shouldToolbarUsesTextFieldTintColor = YES;
//    manager.enableAutoToolbar = YES;
    
    //将状态栏文字设为白色(需要在info.plist里面添加View controller-based status bar appearance no)
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    //检查网络是否存在 如果不存在 则弹出提示
    [UserModel Instance].isNetworkRunning = [CheckNetwork isExistenceNetwork];
    
    //设置应用导航栏的背景颜色
    UINavigationBar.appearance.barTintColor = [UIColor colorWithRed:1 green:0.23 blue:0.47 alpha:1];
    
    //设置应用导航栏的title颜色
    [UINavigationBar.appearance setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIColor colorWithRed:1 green:1 blue:1 alpha:1],NSForegroundColorAttributeName,
//                                    [UIColor colorWithRed:0 green:0.7 blue:0.8 alpha:1], UITextAttributeTextShadowColor,
//                                    [NSValue valueWithUIOffset:UIOffsetMake(0, 0)], UITextAttributeTextShadowOffset,
//                                    [UIFont fontWithName:@"Arial-Bold" size:0.0], UITextAttributeFont,
                                                                     nil]];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    //不是第一次启动
    if([prefs integerForKey:@"launch"] == 1)
    {
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        UIStoryboard *storyBoard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UITabBarController *tabbarController = [storyBoard instantiateInitialViewController];
        
        //故事板中设置选择图片颜色的方法不可用,这里在代码中设置
        [tabbarController tabBar].tintColor = [UIColor colorWithRed:1 green:0.42 blue:0.61 alpha:1];
        self.window.rootViewController = tabbarController;
        [self.window makeKeyAndVisible];
    }
    else
    {
        [prefs setInteger:1 forKey:@"launch"];
        [prefs synchronize];
        //启动页
        StartView *startPage = [[StartView alloc] initWithNibName:@"StartView" bundle:nil];
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        self.window.rootViewController = startPage ;
        [self.window makeKeyAndVisible];
    }

    return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    //跳转支付宝钱包进行支付，处理支付结果
    [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
        NSLog(@"result = %@",resultDic);
    }];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.greenorange.BowlKitchen" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
