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
#import "JumpMoreTableViewController.h"
#import "GTMStringEncoding.h"

@interface JumpCodelistTableViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong,nonatomic) NSMutableArray *codeArray;
//占位图
@property (strong,nonatomic) UIView *placeview;

/** 定时器,用weak */
@property (nonatomic, weak) NSTimer *timer;
@property (assign, nonatomic) NSInteger timerNum;
@property (copy,nonatomic) NSString *numStr;
//定时器开启状态
@property (assign, nonatomic) BOOL isTimer;

@property (strong,nonatomic) UITableView *tableView;

@end

@implementation JumpCodelistTableViewController

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    [self refreshView];
}



- (void)viewDidLoad {
    [super viewDidLoad];

    [self placehodelView];
    [self creatView];
}

-(void)creatView{
    
    self.navigationItem.title = @"捷普身份验证器";
    
    self.codeArray = [NSMutableArray array];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAction:)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_more"] style:UIBarButtonItemStyleDone target:self action:@selector(moreAction)];
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kWidth, kHeight)];

    self.tableView.tableFooterView = [[UIView alloc]init];
    
    self.tableView.backgroundColor = BackGroundColor;
    
    self.tableView.delegate = self;
    
    self.tableView.dataSource = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"CodellistTableViewCell" bundle:nil] forCellReuseIdentifier:@"CodellistTableViewCell"];

    
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

-(void)addAction:(UIBarButtonItem *)item{
    
    L2CWeakSelf(self);
    
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"添加" message: nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction: [UIAlertAction actionWithTitle:@"扫描二维码" style: UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        [weakself scanning];
        
    }]];
    
    [alertController addAction: [UIAlertAction actionWithTitle:@"手动输入验证码" style: UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        [weakself inputCode];
        
    }]];
    
    [alertController addAction: [UIAlertAction actionWithTitle:@"取消" style: UIAlertActionStyleCancel handler:nil]];
    
    BOOL isPhone = [JumpPublicAction deviceIsPhone];
    
    if(isPhone){
        
        [self presentViewController:alertController animated:YES completion:nil];

    }else{
        
        UIPopoverPresentationController *popPresenter = [alertController popoverPresentationController];
 
        popPresenter.barButtonItem = item;

        [self presentViewController:alertController animated:YES completion:nil];
    }
  
    
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
    
    cell.indexPath = indexPath;
    
    [cell refreshListWithArray:self.codeArray indexPath:indexPath];
    
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
                
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"codeArray"];
                
                weakself.isTimer = NO;
                
                //将数组清空后关闭定时器
                [weakself.timer invalidate];
                
                weakself.timer = nil;
                
                [weakself refreshView];
            }
            
            [self.tableView reloadData];
            
        }]];
        
        [alertController addAction: [UIAlertAction actionWithTitle:@"取消" style: UIAlertActionStyleCancel handler:nil]];
        
        BOOL isPhone = [JumpPublicAction deviceIsPhone];

        if(isPhone){
            
            [weakself presentViewController:alertController animated:YES completion:nil];

        }else{
            
            CGRect rectInTableView = [self.tableView rectForRowAtIndexPath:indexPath];
            
            CGRect rectInSuperView = [self.tableView convertRect:rectInTableView toView:[self.tableView superview]];
            
            UIPopoverPresentationController *popPresenter = [alertController popoverPresentationController];
            
            popPresenter.sourceView =[self.tableView superview];
            
            popPresenter.sourceRect = rectInSuperView;
            
            popPresenter.permittedArrowDirections = UIPopoverArrowDirectionUp;
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
        
        
    }];
    
    return @[delete];
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


#pragma mark --- 添加计时器

-(void)setTime{
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f  //间隔时间
                                                  target:self
                                                selector:@selector(countdown)
                                                userInfo:nil
                                                 repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];//防止滑动时不计数
}


- (void)countdown{
    
    NSDate *now = [NSDate date];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay |  NSCalendarUnitHour  | NSCalendarUnitMinute | NSCalendarUnitSecond;
    
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    
    int second = (int) [dateComponent second];
    
    self.timerNum = 60 - second;
    
    self.timerNum --;
    
    if (second == 0){
        
        self.timerNum = 59;
        
        [self recalculateNum];
    
    }
    
    self.numStr = [NSString stringWithFormat:@"%ld",(long)self.timerNum];
    
    [KNotification postNotificationName:@"CodellistTableViewCell" object:nil userInfo:@{@"num":self.numStr}];
}

//重新计算数组中存储的动态数字
-(void)recalculateNum{
    
    NSMutableArray *muArray = [NSMutableArray array];
    
    NSArray *array = [[NSUserDefaults standardUserDefaults] objectForKey:@"codeArray"];
    
    if(array.count > 0){
        
        for(NSDictionary *dict in array){
            
            NSString *deviceCode = SafeString(dict[@"deviceCode"]);
            NSString *account = SafeString(dict[@"account"]);
            NSString *deviceName = SafeString(dict[@"deviceName"]);

            NSData *secretData = [self base32Decode:deviceCode];

            TOTPGenerator *generator = [[TOTPGenerator alloc]initWithSecret:secretData algorithm:kOTPGeneratorSHA1Algorithm digits:6 period:60];
            
            NSString *code = [generator generateOTPForDate:nil];//传nil默认为当前时间

            //首页
            
            if(code.length > 0){
               
                NSDictionary *dict = @{
                                       @"deviceCode":SafeString(deviceCode),
                                       @"code":code,
                                       @"account":SafeString(account),
                                       @"deviceName":SafeString(deviceName)
                                       };
                
                [muArray addObject:dict];
            }
        }
        
        self.codeArray = muArray;
        
        //存入数组并同步
        [[NSUserDefaults standardUserDefaults] setObject:self.codeArray forKey:@"codeArray"];
        
        [[NSUserDefaults standardUserDefaults] synchronize];

        [self.tableView reloadData];
        
    }
}

-(NSData *)base32Decode:(NSString *)string {
    
    GTMStringEncoding *coder = [GTMStringEncoding stringEncodingWithString:kBase32Charset];
    
    [coder addDecodeSynonyms:kBase32Synonyms];
    
    [coder ignoreCharacters:kBase32Sep];
    
    return [coder decode:string];
}


#pragma mark --- 更多

-(void)moreAction{
    
    JumpMoreTableViewController *vc = [[JumpMoreTableViewController alloc]init];
    
    [self.navigationController pushViewController:vc animated:YES];
  
}

-(void)refreshView{
    
    NSArray *array = [[NSUserDefaults standardUserDefaults] objectForKey:@"codeArray"];

    if(array.count > 0){
        
        [self.view addSubview:self.tableView];
        
        [self.placeview removeFromSuperview];
        
        [self.tableView reloadData];
        
    }else{
        
        [self.view addSubview:self.placeview];
        
        [self.tableView removeFromSuperview];
    }
}

#pragma mark --- 占位图

-(void)placehodelView{
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGFloat height = kHeight-L2C_StatusBarAndNavigationBarHeight;
    
    self.placeview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kWidth, height)];
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake((kWidth-220)/2, height/2-120, 220, 250)];
    
    imageView.image = [UIImage imageNamed:@"nodata"];
    
    [self.placeview addSubview:imageView];
}

@end
