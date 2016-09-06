//
//  FFProgressButton.h
//  FFKit
//
//  Created by 张玲玉 on 16/4/27.
//  Copyright © 2016年 bj.zly.com. All rights reserved.
//

#import <UIKit/UIKit.h>

// IB_DESIGNABLE 表示这个类可以在 `IB` 中设计
// IBInspectable 表示属性可以在 `IB` 中定义
// IB - 精通 Interface Builder

IB_DESIGNABLE
@interface FFProgressButton : UIButton

/// 进度 0~1
@property(nonatomic,assign)IBInspectable float progress;
/// 线条宽度
@property(nonatomic,assign)IBInspectable CGFloat lineWidth;
/// 线条颜色
@property(nonatomic,strong)IBInspectable UIColor *lineColor;

@end
