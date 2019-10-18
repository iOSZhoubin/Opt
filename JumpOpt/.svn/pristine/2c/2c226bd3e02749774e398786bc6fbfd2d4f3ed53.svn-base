//
//  JumpMoreTableViewController.m
//  GoogleOpt
//
//  Created by jumpapp1 on 2019/10/17.
//  Copyright © 2019年 zb. All rights reserved.
//

#import "JumpMoreTableViewController.h"
#import "JumpPrivacyViewController.h"
#import "JumpSupportViewController.h"

@interface JumpMoreTableViewController ()

@end

@implementation JumpMoreTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"捷普身份验证器";
}

#pragma mark - Table view data source

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 57;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifier = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    NSArray *title = @[@"隐私协议",@"关于我们"];
    
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    
    cell.textLabel.text = title[indexPath.row];
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if(indexPath.row == 0){
        
        JumpPrivacyViewController *vc = [[JumpPrivacyViewController alloc]init];
        
        [self.navigationController pushViewController:vc animated:YES];
        
    }else{
        
        JumpSupportViewController *vc = [[JumpSupportViewController alloc]init];
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
