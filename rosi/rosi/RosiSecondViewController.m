//
//  RosiSecondViewController.m
//  rosi
//
//  Created by michael on 13-6-26.
//  Copyright (c) 2013年 michael. All rights reserved.
//

#import "RosiSecondViewController.h"

@interface RosiSecondViewController ()

@end

@implementation RosiSecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"热门下载";
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
