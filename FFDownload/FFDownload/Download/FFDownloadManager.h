//
//  FFDownloadManager.h
//  FFDownload
//
//  Created by 张玲玉 on 16/9/6.
//  Copyright © 2016年 bj.zly.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FFDownloadManager : NSObject

// 全局入口
+ (instancetype)sharedManager;

///  下载 URL 对应的文件
///
///  @param url      URL
///  @param progress 进度回调
///  @param finished 完成回调
- (void)downloadWithURL:(NSURL *)url progress:(void (^)(float progress))progress finished:(void (^)(NSString *targetPath, NSError *error))finished;

///  暂停指定url的操作
- (void)pause:(NSURL *)url;

@end
