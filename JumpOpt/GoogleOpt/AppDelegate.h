//
//  AppDelegate.h
//  GoogleOpt
//
//  Created by jumpapp1 on 2019/10/13.
//  Copyright © 2019年 zb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

