//
//  JumpInputViewController.m
//  GoogleOpt
//
//  Created by jumpapp1 on 2019/10/14.
//  Copyright © 2019年 zb. All rights reserved.
//

#import "JumpInputViewController.h"
#import "JumpCodelistTableViewController.h"

@interface JumpInputViewController ()

//生成验证码
@property (weak, nonatomic) IBOutlet UIButton *getcodeBtn;
//设备码
@property (weak, nonatomic) IBOutlet UITextField *codeL;
//用户名
@property (weak, nonatomic) IBOutlet UITextField *accountL;

@property (strong,nonatomic) NSMutableArray *codeArray;

@end

@implementation JumpInputViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"手动输入验证码";
    
    self.codeArray = [NSMutableArray array];
    
    //本身有值就先加进去
    NSArray *array = [[NSUserDefaults standardUserDefaults] objectForKey:@"codeArray"];
    
    [self.codeArray addObjectsFromArray:array];
    
    self.getcodeBtn.layer.cornerRadius = 5.0;
}

#pragma mark --- 生成设备码

- (IBAction)getcodeAction:(UIButton *)sender {
    
    if(SafeString(self.codeL.text).length < 1){

        [self messageInfo:@"设备码不能为空"];

        return;

    }else if (SafeString(self.accountL.text).length < 1){

        [self messageInfo:@"用户名不能为空"];

        return;
    }
    
    [self numberStr:SafeString(self.codeL.text)];
}


#pragma mark --- 手动输入获取动态码

-(void)numberStr:(NSString *)code{

    NSData *secretData = [code dataUsingEncoding:NSASCIIStringEncoding];
    
    TOTPGenerator *generator = [[TOTPGenerator alloc]initWithSecret:secretData algorithm:kOTPGeneratorSHA1Algorithm digits:6 period:60];
    
    NSString *str = [generator generateOTPForDate:nil];//传nil默认为当前时间
    
    //首页
    NSDictionary *dict = @{@"deviceCode":SafeString(code),@"code":str,@"account":SafeString(self.accountL.text)};
        
    [self.codeArray addObject:dict];
        
    //存入数组并同步
    [[NSUserDefaults standardUserDefaults] setObject:self.codeArray forKey:@"codeArray"];
        
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if(self.isTimer == NO){
        
        [KNotification postNotificationName:@"startTimer" object:nil userInfo:@{@"start":@"1"}];
        
    }
    
    [KNotification postNotificationName:@"JumpCodelistTableViewController" object:nil userInfo:nil];

    [self.navigationController popViewControllerAnimated:YES];
    
}



#pragma mark -- 提示信息

-(void)messageInfo:(NSString *)message{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    
    [alertController addAction:ok];
    
    [self presentViewController:alertController animated:YES completion:nil];

}

@end
