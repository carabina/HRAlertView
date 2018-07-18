//
//  ViewController.m
//  HRAlertView
//
//  Created by T-bag on 2018/7/18.
//  Copyright © 2018年 T-bag. All rights reserved.
//

#import "ViewController.h"
#import "HRAlertView.h"

@interface ViewController ()<HRAlertViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *buttonD = [[UIButton alloc] init];
    [buttonD setTitle:@"代理方式" forState:UIControlStateNormal];
    [buttonD setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [buttonD addTarget:self action:@selector(alertD) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttonD];
    
    UIButton *buttonB = [[UIButton alloc] init];
    [buttonB setTitle:@"block方式" forState:UIControlStateNormal];
    [buttonB setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [buttonB addTarget:self action:@selector(alertB) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttonB];
    
    [buttonD mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.mas_equalTo(200);
        make.size.mas_equalTo(CGSizeMake(100, 40));
    }];
    
    [buttonB mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.mas_equalTo(260);
        make.size.mas_equalTo(CGSizeMake(100, 40));
    }];
}

- (void)alertD {
    HRAlertView *alert = [[HRAlertView alloc] initWithTitle:@"温馨提示"
                                                    message:@"您使用代理方式创建alert"
                                                   delegate:self
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"确定", nil];
    [alert show];
}

- (void)alertB {
    HRAlertView *alert = [[HRAlertView alloc] initWithTitle:@"温馨提示" message:@"您使用block方式创建alert"];
    [alert addAction:[HRAlertAction actionWithTitle:@"取消" style:HHRAlertActionStyleCancel handler:nil]];
    [alert addAction:[HRAlertAction actionWithTitle:@"确定" style:HHRAlertActionStyleDefault handler:^{
        NSLog(@"您使用block方式创建alert");
    }]];
    [alert show];
}

- (void)hrAlertView:(HRAlertView *_Nonnull)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSLog(@"您使用代理方式创建alert");
    }
}
@end
