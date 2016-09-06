//
//  FFProgressButton.m
//  FFKit
//
//  Created by 张玲玉 on 16/4/27.
//  Copyright © 2016年 bj.zly.com. All rights reserved.
//

#import "FFProgressButton.h"

@implementation FFProgressButton

- (void)drawRect:(CGRect)rect
{
    // 贝塞尔路径
    /*
     1、中心点
     2、半径
     3、起始角度
     4、结束角度
     5、顺时针
     */
    CGSize size=rect.size;
    CGPoint center=CGPointMake(size.width*0.5, size.height*0.5);
    CGFloat radius=(MIN(size.width, size.height)-self.lineWidth)*0.5;
    CGFloat startAngle=-M_PI_2;
    CGFloat endAngle=2*M_PI *self.progress+startAngle;
    UIBezierPath *path=[UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    
    // 设置绘制属性
    [self.lineColor setStroke];
    path.lineWidth=self.lineWidth;
    path.lineCapStyle=kCGLineJoinRound;
    
    // 绘制边线路径
    [path stroke];
}

- (void)setProgress:(float)progress
{
    _progress=progress;
    
    // 设置进度文字
    [self setTitle:[NSString stringWithFormat:@"%.01f%%", _progress*100] forState:UIControlStateNormal];
    // 调用drawRect
    [self setNeedsDisplay];
}

@end
