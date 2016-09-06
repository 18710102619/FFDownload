//
//  AppDelegate.m
//  FFDownload
//
//  Created by 张玲玉 on 16/9/6.
//  Copyright © 2016年 bj.zly.com. All rights reserved.
//

#import "AppDelegate.h"
#import "FFDownloadController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
   
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController=[[UINavigationController alloc]initWithRootViewController:[[FFDownloadController alloc]initWithNibName:@"FFDownloadController" bundle:nil]];
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
