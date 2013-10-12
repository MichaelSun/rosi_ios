//
//  YMWallSpotForUser.h
//  YouMiSDK
//
//  Created by 陈建峰 on 13-10-11.
//  Copyright (c) 2013年 YouMi Mobile Co. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YMWallSpotForUser : UIView
/*
 *设置偏移量
 *插播大小已经固定，只提供设置偏移量的接口
 */
- (void)setViewOffsetX:(int)x y:(int)y;

/*
 *加载插播
 *在每次显示前都要调用这个接口。
 */
//注意：调用下面的接口前，应该先调用[YouMiWallSpot isReady]，判断插播是否已经准备好，返回true时才调用下面的接口。
- (void)loadData;

@end
