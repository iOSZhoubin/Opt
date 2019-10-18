//
//  JumpPublicAction.m
//  JumpHousekeeper
//
//  Created by jumpapp1 on 2019/1/25.
//  Copyright © 2019年 zhoubin. All rights reserved.
//

#import "JumpPublicAction.h"
#import <Photos/PHPhotoLibrary.h>
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>
#import <CommonCrypto/CommonDigest.h>


@implementation JumpPublicAction

#pragma mark --- 判断用户是否开启了相机的权限

+(BOOL)isopenCamera{
    
    AVAuthorizationStatus authStatus =  [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied){                //没有权限

        return NO;

    }else{
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            //相机可用
            return YES;
            
        }else{
            
            return NO;
        }
    }
}

#pragma mark --- 判断用户是否开启了相册的权限

+(BOOL)isopenPhoto{

    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    
    if (status == PHAuthorizationStatusRestricted ||status == PHAuthorizationStatusDenied) {
        
        return NO;
        
    }else{
        
        return YES;
    }
}


#pragma mark --- 去设置界面开启权限

+(void)openfromSetting{
    
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        
        [[UIApplication sharedApplication] openURL:url];
        
    }
    
}


#pragma mark --- 正则校验手机号码

+(BOOL)isTruePhoneNumber:(NSString *)cellNum{
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189
     */
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    
    /**
     10         * 中国移动：China Mobile
     11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     12         */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    
    /**
     15         * 中国联通：China Unicom
     16         * 130,131,132,152,155,156,175,176,185,186
     17         */
    NSString * CU = @"^1(3[0-2]|5[256]|7[56]|8[56])\\d{8}$";
    
    /**
     20         * 中国电信：China Telecom
     21         * 133,1349,153,177,180,181,189
     22         */
    NSString * CT = @"^1(34[9]|70[0-2]|(3[3]|4[9]|5[3]|7[37]|8[019])\\d)\\d{7}$";

    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    if(([regextestmobile evaluateWithObject:cellNum] == YES)
       || ([regextestcm evaluateWithObject:cellNum] == YES)
       || ([regextestct evaluateWithObject:cellNum] == YES)
       || ([regextestcu evaluateWithObject:cellNum] == YES)){
        return YES;
    }else{
        return NO;
    }
}


//MD5

+(NSString *)md5:(NSString *)string
{
    const char *cStr = [string UTF8String];
    unsigned char result[32];
    CC_MD5(cStr, strlen(cStr), result);
    NSMutableString *ret = [NSMutableString stringWithCapacity:16];
    for (int i = 0; i< 16; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}



// 密码验证
+(BOOL)checkPassWord:(NSString *)passWord{
    NSString *regular = @"^(?![0-9~!@#$%^&*,._-]+$)(?![a-zA-Z~!@#$%^&*,._-]+$)[a-zA-Z0-9~!@#$%^&*,._-]{6,20}";
    NSPredicate *Predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regular];
    BOOL isRight = [Predicate evaluateWithObject:passWord];
    return isRight;
}

#pragma mark - NSData转换十六进制

+(NSString *)convertDataToHexStr:(NSData *)data {
    if (!data || [data length] == 0) {
        return @"";
    }
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
    
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        for (NSInteger i = 0; i < byteRange.length; i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            if ([hexStr length] == 2) {
                [string appendString:hexStr];
            } else {
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];
    
    return string;
    
}

#pragma mark - 十六进制转换NSData
// 16进制转NSData
+(NSData *)convertHexStrToData:(NSString *)str
{
    if (!str || [str length] == 0) {
        return nil;
    }
    
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:20];
    NSRange range;
    if ([str length] % 2 == 0) {
        range = NSMakeRange(0, 2);
    } else {
        range = NSMakeRange(0, 1);
    }
    for (NSInteger i = range.location; i < [str length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [str substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        
        range.location += range.length;
        range.length = 2;
    }
    return hexData;
    
}

/**
 正则判断特殊字符（只允许输入 数字，字母，下划线，中文）
 
 @param str 输入的字符
 @return 是否正确
 */
+(BOOL)specialStr:(NSString *)str
{
    NSString *phoneRegex = @"^[a-zA-Z0-9_]*$";
    
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    
    return [phoneTest evaluateWithObject:str];
}




/**
 判断特殊字符
 
 @param intriduction 输入的字符
 @return YES-通过 NO-不通过
 */
+(BOOL)specialRight:(NSString *)intriduction{
    
    NSString *newStr = [intriduction stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSMutableArray *specialStringArray = [NSMutableArray array];
    
    NSString *string = @"~,￥,#,&,*,<,>,《,》,(,),[,],{,},【,】,^,@,/,￡,¤,|,§,¨,「,」,『,』,￠,￢,￣,（,）,——,+,|,$,€, ,¥,!,%";
    
    BOOL isRight = NO;
    
    NSArray *array = [string componentsSeparatedByString:@","];
    
    [specialStringArray addObjectsFromArray:array];
    
    for (NSInteger i=0; i<specialStringArray.count; i++) {
        
        if ([newStr rangeOfString:specialStringArray[i]].location != NSNotFound) {
            
            isRight = NO;
            
            break;
            
        }else{
            
            isRight = YES;
            
            continue;
        }
    }
    
    return isRight;
}


// 是否是手机
+ (BOOL)deviceIsPhone{
    
    BOOL _isIdiomPhone = YES;// 默认是手机
    UIDevice *currentDevice = [UIDevice currentDevice];
    
    // 项目里只用到了手机和pad所以就判断两项
    // 设备是手机
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        
        _isIdiomPhone = YES;
    }
    // 设备是ipad
    else if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad){
        
        _isIdiomPhone = NO;
    }
    
    return _isIdiomPhone;
}

@end
