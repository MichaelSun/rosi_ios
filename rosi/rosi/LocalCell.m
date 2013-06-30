//
//  LocalCell.m
//  rosi
//
//  Created by michael on 13-6-26.
//  Copyright (c) 2013年 michael. All rights reserved.
//

#import "LocalCell.h"

@interface LocalCell()

@property (strong, nonatomic) NSString* coverImageUrl;

@end

@implementation LocalCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) updateAlbumImage:(NSString *) coverImageUrl desc:(NSString *) desc count:(NSString *) count {
    if (coverImageUrl != nil) {
        if (_coverImageUrl == nil || ![_coverImageUrl isEqualToString:coverImageUrl]) {
            _coverImageUrl = coverImageUrl;
            [_coverImage setImageFromURL:[NSURL URLWithString:_coverImageUrl]];
        }
    } else {
        [_coverImage setImage:nil];
        _coverImageUrl = nil;
    }
    
    self.desc.text = desc;
    self.downloadCount.text = [NSString stringWithFormat:@"下载次数:%@" , count];
}

@end
