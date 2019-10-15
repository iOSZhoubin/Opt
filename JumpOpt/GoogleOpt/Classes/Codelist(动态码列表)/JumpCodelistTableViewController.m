//
//  JumpCodelistTableViewController.m
//  GoogleOpt
//
//  Created by jumpapp1 on 2019/10/14.
//  Copyright © 2019年 zb. All rights reserved.
//

#import "JumpCodelistTableViewController.h"
#import "ScanningDeviceViewController.h"
#import "JumpInputViewController.h"
#import "CodellistTableViewCell.h"

@interface JumpCodelistTableViewController ()

@property (strong,nonatomic) NSMutableArray *codeArray;
/** 定时器,用weak */
@property (nonatomic, weak) NSTimer *timer;
@property (assign, nonatomic) NSInteger timerNum;
@property (copy,nonatomic) NSString *numStr;
@property (assign, nonatomic) NSInteger index;
//定时器开启状态
@property (assign, nonatomic) BOOL isTimer;

@end

@implementation JumpCodelistTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Jump Authenticator";
    
    self.tableView.tableFooterView = [[UIView alloc]init];
    
    self.view.backgroundColor = BackGroundColor;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"CodellistTableViewCell" bundle:nil] forCellReuseIdentifier:@"CodellistTableViewCell"];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAction)];
    
    self.codeArray = [NSMutableArray array];
    
    //本身有值就先加进去
    NSArray *array = [[NSUserDefaults standardUserDefaults] objectForKey:@"codeArray"];
        
    [self.codeArray addObjectsFromArray:array];
    
    [self recalculateNum];//第一次进来直接将所有数字重置
    
    if(self.codeArray.count > 0){
        
        self.isTimer = YES;
        
        [self setTime];//有数据时才开启定时器，否则在手动输入和扫描后才开启

    }else{
        
        self.isTimer = NO;
    }
    
    [KNotification addObserver:self selector:@selector(notifi:) name:@"JumpCodelistTableViewController" object:nil];
    
    [KNotification addObserver:self selector:@selector(notifi1:) name:@"startTimer" object:nil];
}

- (void)notifi1:(NSNotification *)note{
    
    self.isTimer = YES;

    [self setTime];
}

- (void)notifi:(NSNotification *)note{
    
    self.codeArray = [NSMutableArray array];

    //本身有值就先加进去
    NSArray *array = [[NSUserDefaults standardUserDefaults] objectForKey:@"codeArray"];
    
    [self.codeArray addObjectsFromArray:array];
    
    [self.tableView reloadData];
}

#pragma mark --- 增加

-(void)addAction{
    
    L2CWeakSelf(self);
    
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"设置" message: nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction: [UIAlertAction actionWithTitle:@"扫描二维码" style: UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        [weakself scanning];
        
    }]];
    
    [alertController addAction: [UIAlertAction actionWithTitle:@"手动输入验证码" style: UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        [weakself inputCode];
        
    }]];
    
    [alertController addAction: [UIAlertAction actionWithTitle:@"取消" style: UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark --- 扫描条形码

-(void)scanning{
    
    ScanningDeviceViewController *vc = [[ScanningDeviceViewController alloc]init];
    
    vc.isTimer = self.isTimer;
    
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark --- 手动输入验证码

-(void)inputCode{
    
    JumpInputViewController *vc = [[JumpInputViewController alloc]init];
    
    vc.isTimer = self.isTimer;
    
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - Table view data source

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 120;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSArray *array = [[NSUserDefaults standardUserDefaults] objectForKey:@"codeArray"];

    return array.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CodellistTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CodellistTableViewCell" forIndexPath:indexPath];
    
    self.index = indexPath.row;
    
    [cell refreshListWithArray:self.codeArray row:indexPath.row];
    
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    L2CWeakSelf(self);
    
    UITableViewRowAction *delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"确认删除?" message: nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        [alertController addAction: [UIAlertAction actionWithTitle:@"确认" style: UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            
            [weakself.codeArray removeObjectAtIndex:indexPath.row];
            
            //存入数组并同步
            [[NSUserDefaults standardUserDefaults] setObject:self.codeArray forKey:@"codeArray"];
            
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            if(weakself.codeArray.count < 1){
                
                weakself.isTimer = NO;
                
                //将数组清空后关闭定时器
                [weakself.timer invalidate];
                
                weakself.timer = nil;
            }
            
            [self.tableView reloadData];
            
        }]];
        
        [alertController addAction: [UIAlertAction actionWithTitle:@"取消" style: UIAlertActionStyleCancel handler:nil]];
        
        [weakself presentViewController:alertController animated:YES completion:nil];
        
    }];
    
    return @[delete];
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


#pragma mark --- 添加计时器

-(void)setTime{
    
    self.timerNum = 60;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f  //间隔时间
                                                  target:self
                                                selector:@selector(countdown)
                                                userInfo:nil
                                                 repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];//防止滑动时不计数
}


- (void)countdown{
    
    self.timerNum --;
    
    if (self.timerNum < 0){
        
        self.timerNum = 60;
        
        [self recalculateNum];
    }
    
    self.numStr = [NSString stringWithFormat:@"%ld",(long)self.timerNum];
    
    NSString *row = [NSString stringWithFormat:@"%ld",(long)self.index];
    
    [KNotification postNotificationName:@"CodellistTableViewCell" object:nil userInfo:@{@"num":self.numStr,@"row":row}];

}

//重新计算数组中存储的动态数字
-(void)recalculateNum{
    
    NSMutableArray *muArray = [NSMutableArray array];
    
    NSArray *array = [[NSUserDefaults standardUserDefaults] objectForKey:@"codeArray"];
    
    if(array.count > 0){
        
        for(NSDictionary *dict in array){
            
            NSString *deviceCode = SafeString(dict[@"deviceCode"]);
            NSString *account = SafeString(dict[@"account"]);
            
            NSData *secretData = [deviceCode dataUsingEncoding:NSASCIIStringEncoding];
            
            TOTPGenerator *generator = [[TOTPGenerator alloc]initWithSecret:secretData algorithm:kOTPGeneratorSHA1Algorithm digits:6 period:60];
            
            NSString *code = [generator generateOTPForDate:nil];//传nil默认为当前时间
            
            //首页
            NSDictionary *dict = @{@"deviceCode":SafeString(deviceCode),@"code":code,@"account":SafeString(account)};
            
            [muArray addObject:dict];
        }
        
        self.codeArray = muArray;
        
        //存入数组并同步
        [[NSUserDefaults standardUserDefaults] setObject:self.codeArray forKey:@"codeArray"];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self.tableView reloadData];
        
    }
}



@end
