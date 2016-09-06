//
//  FFDownloadManager.m
//  FFDownload
//
//  Created by 张玲玉 on 16/9/6.
//  Copyright © 2016年 bj.zly.com. All rights reserved.
//

#import "FFDownloadManager.h"
#import "FFDownloadOperation.h"

@interface FFDownloadManager ()

@property(nonatomic,strong)NSMutableDictionary *operationCache;
/// 全局下载队列
@property(nonatomic,strong)NSOperationQueue *queue;

@end

@implementation FFDownloadManager

- (NSMutableDictionary *)operationCache
{
    if (_operationCache==nil) {
        _operationCache=[NSMutableDictionary dictionary];
    }
    return _operationCache;
}

- (NSOperationQueue *)queue
{
    if (_queue==nil) {
        _queue=[[NSOperationQueue alloc]init];
        _queue.maxConcurrentOperationCount=2;
    }
    return _queue;
}

+ (instancetype)sharedManager
{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance=[[self alloc]init];
    });
    return instance;
}

/**
 block 可以当作参数传递
 */
- (void)downloadWithURL:(NSURL *)url progress:(void (^)(float))progress finished:(void (^)(NSString *, NSError *))finished
{
    // 0、判断是否在缓存中，如果有直接返回
    if(self.operationCache[url]!=nil) {
        NSLog(@"正在玩命下载中...稍安勿躁");
        return;
    }
    
    // 1、实例化下载操作
    FFDownloadOperation *downloader=[FFDownloadOperation downloadOperation:progress finished:^(NSString *targetPath, NSError *error) {
        // 执行至此，下载操作已经完成，从缓冲池删除下载操作
        // self 是一个单例（静态变量，保存在静态区）
        [self.operationCache removeObjectForKey:url];
        finished(targetPath,error);
    }];
    
    // 2、添加到缓冲池中
    [self.operationCache setObject:downloader forKey:url];
    
    // 3、开始下载
    // 设置url
    downloader.url=url;
    
    // 4、将操作添加到队列
    [self.queue addOperation:downloader];
}

- (void)pause:(NSURL *)url
{
    // 1、从缓冲区获取操作
    FFDownloadOperation *downloader=self.operationCache[url];
    
    if (downloader==nil) {
        NSLog(@"没有要暂停的下载操作");
        return;
    }
    
    // 2、如果有，取消操作
    [downloader pause];
    
    // 3、从缓冲池删除
    [self.operationCache removeObjectForKey:url];
}

@end
