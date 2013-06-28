//
//  LocalCell.h
//  rosi
//
//  Created by michael on 13-6-26.
//  Copyright (c) 2013年 michael. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MKNetworkKit/MKNetworkKit.h"

@interface LocalCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *coverImage;
@property (weak, nonatomic) IBOutlet UILabel *desc;
@property (weak, nonatomic) IBOutlet UILabel *downloadCount;
@property (weak, nonatomic) IBOutlet UIProgressView *downlaodProgress;
@property (weak, nonatomic) IBOutlet UIView *textRegionView;
@property (weak, nonatomic) IBOutlet UILabel *status;

- (void) updateAlbumImage:(NSString *) coverImageUrl desc:(NSString *) desc count:(NSString *) count;

@end
