//
//  CodellistTableViewCell.h
//  GoogleOpt
//
//  Created by jumpapp1 on 2019/10/14.
//  Copyright © 2019年 zb. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CodellistTableViewCell : UITableViewCell

-(void)refreshListWithArray:(NSMutableArray *)array row:(NSInteger)row;

@end

NS_ASSUME_NONNULL_END
