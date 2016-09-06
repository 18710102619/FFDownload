//
//  FFDownloadController.m
//  FFKit
//
//  Created by 张玲玉 on 16/4/29.
//  Copyright © 2016年 bj.zly.com. All rights reserved.
//

#import "FFDownloadController.h"
#import "FFDownloadManager.h"
#import "FFProgressButton.h"

@interface FFDownloadController ()

@property (weak, nonatomic) IBOutlet FFProgressButton *progressButton;

@property (nonatomic, strong) NSURL *url;

@end

@implementation FFDownloadController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pause {
    
    [[FFDownloadManager sharedManager] pause:self.url];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    NSString *urlString = @"http://10.252.158.241/index_mov%201.mp4";
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *url = [NSURL URLWithString:urlString];
    self.url = url;
    
    // 实例化下载操作 - 定义并且传递 block 参数！
    [[FFDownloadManager sharedManager] downloadWithURL:url progress:^(float progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.progressButton.progress = progress;
        });
    } finished:^(NSString *targetPath, NSError *error) {
        NSLog(@"%@ %@ %@", targetPath, error, [NSThread currentThread]);
    }];
}

@end
