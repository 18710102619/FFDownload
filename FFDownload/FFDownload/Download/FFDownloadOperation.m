//
//  FFDownloadOperation.m
//  FFDownload
//
//  Created by 张玲玉 on 16/9/6.
//  Copyright © 2016年 bj.zly.com. All rights reserved.
//

#import "FFDownloadOperation.h"

@interface FFDownloadOperation ()<NSURLConnectionDataDelegate>

/// 文件总大小
@property(nonatomic,assign)long long expectedContentLength;
/// 当前接受大小
@property(nonatomic,assign)long long fileSize;
/// 下载目标路径
@property(nonatomic,copy)NSString *targetPath;
/// 文件流
@property(nonatomic,strong)NSOutputStream *fileStream;
/// 当前下载的网络连接
@property(nonatomic,strong)NSURLConnection *connection;

@property(nonatomic,copy) void (^progressBlock)(float);
@property(nonatomic,copy) void (^finishedBlock)(NSString *, NSError *);

@end

@implementation FFDownloadOperation

/**
 *  如果 block 在当前方法不执行，可以使用属性记录
 */
+ (instancetype)downloadOperation:(void (^)(float progress))progress finished:(void (^)(NSString *targetPath, NSError *error))finished
{
    // 断言，要求必须传入完成回调，progress可选
    NSAssert(finished!=nil, @"必须传入完成回调方法");
    
    FFDownloadOperation *obj=[[self alloc]init];
    
    // 记录block
    obj.progressBlock=progress;
    obj.finishedBlock=finished;
    
    return obj;
}

- (void)main
{
    @autoreleasepool {
        [self download:self.url];
    }
}

- (void)pause
{
    [self.connection cancel];
}

- (void)download:(NSURL *)url
{
    // 1、检查服务器信息
    [self checkServerFileInfo:url];
    
    // 2、检查本地文件
    self.fileSize=[self checkLocalFileInfo];
    NSLog(@"%lld %@", self.fileSize, [NSThread currentThread]);
    
    // 如果服务器和本地同样大小，判断文件下载完毕，直接返回
    if(self.fileSize==self.expectedContentLength) {
        NSLog(@"下载完毕");
        // 判断进度回调是否存在
        if(self.progressBlock!=nil) {
            self.progressBlock(1);
        }
        // 做主线程回调，通知调用方，下载完成
        dispatch_async(dispatch_get_main_queue(), ^{
            self.finishedBlock(self.targetPath,nil);
        });
        return;
    }
    
    // 断点续传，一定不能使用缓存
    // NSURLRequestReloadIgnoringCacheData 忽略缓存直接从原始地址下载
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:15.0];
    
    // range头
    NSString *range=[NSString stringWithFormat:@"bytes=%lld-",self.fileSize];
    [request setValue:range forKey:@"Range"];
    
    NSLog(@"start %@",[NSThread currentThread]);
    // 建立连接，立即启动
    self.connection=[NSURLConnection connectionWithRequest:request delegate:self];
    
    // 启动 runloop - 死循环，好启动，不好关闭！
    // NSURLConnection 一旦网络连接断开，runloop 会自动停止！
    [[NSRunLoop currentRunLoop]run];
}

#pragma mark - 私有方法

/// 检查服务器文件信息
- (void)checkServerFileInfo:(NSURL *)url
{
    // head 请求
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod=@"HEAD";
    
    // 同步方法
    NSURLResponse *response=nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    
    // 得到响应
    // 1、目标文件大小
    self.expectedContentLength=response.expectedContentLength;
    // 2、目标文件路径
    self.targetPath=[NSTemporaryDirectory() stringByAppendingPathComponent:response.suggestedFilename];
}

/// 检查本地文件信息
/**
 检查本地是否存在文件
 如果存在检查本地文件大小
 如果小于服务器的文件，从当前文件大小开始下载
 如果等于服务器的文件，下载完成
 如果小于服务器的文件，直接删除，重新下载
 */
- (long long)checkLocalFileInfo
{
    long long fileSize=0;
    NSFileManager *mgr=[NSFileManager defaultManager];
    // 检查本地是否存在文件
    if ([mgr fileExistsAtPath:self.targetPath]) {
        // 文件存在，检查文件属性
        NSDictionary *dic=[mgr attributesOfItemAtPath:self.targetPath error:nil];
        NSLog(@"%@",dic);
        fileSize=dic.fileSize;
    }
    if (fileSize > self.expectedContentLength) {
        [mgr removeItemAtPath:self.targetPath error:nil];
        fileSize=0;
    }
    return fileSize;
}

#pragma mark - NSURLConnectionDataDelegate

// 1、接收到服务器响应（状态行/响应头）
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // 断点续传的响应头状态码是 206
    NSLog(@"%@",response);
    // 创建并且打开流
    self.fileStream=[[NSOutputStream alloc]initToFileAtPath:self.targetPath append:YES];
    [self.fileStream open];
}

// 2、接收到二进制数据（可能请求多次）- 所有的 data 都是按照文件原有的顺序传递到客户端的！
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    self.fileSize+=data.length;
    float progress=(float)self.fileSize/self.expectedContentLength;
    // 拼接数据
    [self.fileStream write:data.bytes maxLength:data.length];
    // 异步回调 - 判断
    if(self.progressBlock!=nil) {
        self.progressBlock(progress);
    }
}

// 3、网络请求结束（断开连接）
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // 关闭流
    [self.fileStream close];
    // 主线程回调
    dispatch_async(dispatch_get_main_queue(), ^{
        self.finishedBlock(self.targetPath,nil);
    });
}

// 4、网络连接错误，任何的网络访问都有可能出错
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // 关闭流
    [self.fileStream close];
    // 主线程回调
    dispatch_async(dispatch_get_main_queue(), ^{
        self.finishedBlock(nil,error);
    });
}

@end
