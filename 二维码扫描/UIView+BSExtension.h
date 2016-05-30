//
//  UIView+BSExtension.h
//  BestNotSister
//
//  Created by huhang on 16/3/16.
//  Copyright © 2016年 huhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (BSExtension)

@property (nonatomic,assign)CGFloat x;
@property (nonatomic,assign)CGFloat y;
@property (nonatomic,assign)CGFloat width;
@property (nonatomic,assign)CGFloat height;
@property (nonatomic,assign)CGSize size;
@property (nonatomic,assign)CGFloat centerX;
@property (nonatomic,assign)CGFloat centerY;

//是否展示在window上
- (BOOL)isShowOnKeyWindow;

+ (instancetype)viewFromXib;

@end
