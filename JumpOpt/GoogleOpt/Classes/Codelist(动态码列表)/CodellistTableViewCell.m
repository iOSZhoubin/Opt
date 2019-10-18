//
//  CodellistTableViewCell.m
//  GoogleOpt
//
//  Created by jumpapp1 on 2019/10/14.
//  Copyright © 2019年 zb. All rights reserved.
//

#import "CodellistTableViewCell.h"

@interface CodellistTableViewCell()

//动态码
@property (weak, nonatomic) IBOutlet UILabel *codeL;
//用户名
@property (weak, nonatomic) IBOutlet UILabel *accountL;
//倒计时
@property (weak, nonatomic) IBOutlet UILabel *timeL;
//设备名称
@property (weak, nonatomic) IBOutlet UILabel *deviceName;

@end

@implementation CodellistTableViewCell


- (void)awakeFromNib {
    [super awakeFromNib];
    
    [KNotification addObserver:self selector:@selector(notifi:) name:@"CodellistTableViewCell" object:nil];

}

- (void)notifi:(NSNotification *)note{
    
    NSDictionary *dict = note.userInfo;
    
    self.timeL.text = SafeString(dict[@"num"]);
    
    NSInteger num = [self.timeL.text integerValue];
    
    if(num == 0){
    
        NSMutableArray *muarray = [NSMutableArray array];
        
        NSArray *array1 = [[NSUserDefaults standardUserDefaults] objectForKey:@"codeArray"];
        
        [muarray addObjectsFromArray:array1];
        
        if(muarray.count > 0){
            
            [self refreshListWithArray:muarray indexPath:self.indexPath];
            
        }
    }
}


-(void)refreshListWithArray:(NSMutableArray *)array indexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *dict = array[indexPath.row];
    
    self.codeL.text = SafeString(dict[@"code"]);
    
    self.accountL.text = SafeString(dict[@"deviceName"]);
    
    self.deviceName.text = SafeString(dict[@"account"]);
}



@end
