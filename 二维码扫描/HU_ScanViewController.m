//
//  HU_ScanViewController.m
//  二维码扫描
//
//  Created by huhang on 15/11/27.
//  Copyright (c) 2015年 huhang. All rights reserved.
//

#import "HU_ScanViewController.h"
#import "HU_ScanView.h"
@interface HU_ScanViewController ()

@end

@implementation HU_ScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    HU_ScanView *scanView = [HU_ScanView showScanView];
    [self.view addSubview:scanView];
    
    scanView.returnScanResult = ^(HU_ScanView *view,NSString *str){
     
        [view stopScan];
        NSURL *url = [NSURL URLWithString:str];
        [[UIApplication sharedApplication] openURL:url];
        [self.navigationController popViewControllerAnimated:YES];
    };
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
