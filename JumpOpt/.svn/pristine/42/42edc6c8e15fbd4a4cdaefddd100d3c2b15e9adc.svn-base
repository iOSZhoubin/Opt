//
//  JumpFirstPageViewController.m
//  GoogleOpt
//
//  Created by jumpapp1 on 2019/10/13.
//  Copyright © 2019年 zb. All rights reserved.
//

#import "JumpFirstPageViewController.h"
#import "JumpCodelistTableViewController.h"

@interface JumpFirstPageViewController ()

//开始设置按钮
@property (weak, nonatomic) IBOutlet UIButton *startSet;

@end

@implementation JumpFirstPageViewController


-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    //登录界面隐藏navigationBar
    self.navigationController.navigationBarHidden = YES;
    
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}


#pragma mark --- 开始设置

- (IBAction)setAction:(UIButton *)sender {
  
    JumpCodelistTableViewController *vc = [[JumpCodelistTableViewController alloc]init];
    
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
    
    AppDelegate *appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    appdelegate.window.rootViewController = nav;
    
}




@end
