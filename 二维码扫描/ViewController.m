//
//  ViewController.m
//  二维码扫描
//
//  Created by huhang on 15/11/27.
//  Copyright (c) 2015年 huhang. All rights reserved.
//

#import "ViewController.h"
#import "HU_ScanViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(self.view.bounds.size.width / 2 - 40, 80, 80, 80);
    button.layer.borderWidth = 1;
    
    [button setTitle:@"扫一扫" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)buttonAction{
  
    HU_ScanViewController *scanVC = [[HU_ScanViewController alloc]init];
    [self.navigationController pushViewController:scanVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
