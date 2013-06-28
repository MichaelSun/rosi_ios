//
//  Fileutils.m
//  rosi
//
//  Created by michael on 13-6-27.
//  Copyright (c) 2013年 michael. All rights reserved.
//

#import "Fileutils.h"

@implementation Fileutils

+ (NSString*) DocumentFullPath {
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* path = paths[0];
    
    return path;
}

@end
