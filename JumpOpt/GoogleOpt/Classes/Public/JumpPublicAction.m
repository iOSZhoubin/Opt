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

@end
