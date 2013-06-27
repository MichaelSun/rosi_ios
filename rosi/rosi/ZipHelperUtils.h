//
//  ZipHelperUtils.h
//  rosi
//
//  Created by michael on 13-6-27.
//  Copyright (c) 2013年 michael. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZipHelperUtils : NSObject

+ (BOOL)unzipFile:(NSString *) fileFullPath targetDir:(NSString *) targetDirFullPath forceOverWrite:(BOOL) overWrite;

+ (NSString*)unzipReturnUnzipFile:(NSString *) inputFileFullPath targetDir:(NSString *) targetDirFullPath forceOverWrite:(BOOL) overWrite;

@end
