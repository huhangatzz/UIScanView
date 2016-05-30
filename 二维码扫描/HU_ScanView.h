//
//  HU_ScanView.h
//  二维码扫描
//
//  Created by huhang on 15/11/27.
//  Copyright (c) 2015年 huhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HU_ScanView;
typedef void(^returnScanResult)(HU_ScanView *,NSString *);

@interface HU_ScanView : UIView

@property (nonatomic,strong)returnScanResult returnScanResult;

+ (instancetype)showScanView;

//开始扫描
- (void)startScan;
//结束扫描
- (void)stopScan;

@end
