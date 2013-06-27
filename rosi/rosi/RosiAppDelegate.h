//
//  RosiAppDelegate.h
//  rosi
//
//  Created by michael on 13-6-26.
//  Copyright (c) 2013年 michael. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlbumEngin.h"

#define ApplicationDelegate ((RosiAppDelegate *)[UIApplication sharedApplication].delegate)

@interface RosiAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) AlbumEngine* albumEngine;

@end
