//
//  FFDownloadOperation.h
//  FFDownload
//
//  Created by 张玲玉 on 16/9/6.
//  Copyright © 2016年 bj.zly.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FFDownloadOperation : NSOperation

+ (instancetype)downloadOperation:(void (^)(float progress))progress finished:(void (^)(NSString *targetPath, NSError *error))finished;

/// 当前下载 URL
@property(nonatomic,strong)NSURL *url;

/// 下载指定 URL
- (void)download:(NSURL *)url;

/// 暂停下载
- (void)pause;

@end
