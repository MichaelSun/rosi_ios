//
//  YouMiWallSpot.h
//  YouMiSDK
//
//  Created by 陈建峰 on 13-9-4.
//  Copyright (c) 2013年 YouMi Mobile Co. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum{
    kYouMiWallSpotStylePhone = 0,
    kYouMiWallSpotStylePad
} YouMiWallSpotStyle;

@interface YouMiWallSpot : NSObject

//积分插播的状态
+ (BOOL)isReady;

//展示插播
+ (void)showSpotViewWithBlock:(void(^)())dismiss;
@end
