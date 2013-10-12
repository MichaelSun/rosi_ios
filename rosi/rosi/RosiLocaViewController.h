//
//  RosiLocaViewController.h
//  rosi
//
//  Created by michael on 13-6-26.
//  Copyright (c) 2013年 michael. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Libraries/MBProgressHUD/MBProgressHUD.h"
#import "MWPhotoBrowser.h"

@interface RosiLocaViewController : UITableViewController <MBProgressHUDDelegate, MWPhotoBrowserDelegate>

@property (strong, nonatomic) NSString* restApi;

@end
