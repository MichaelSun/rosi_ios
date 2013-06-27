//
//  ZipHelperUtils.m
//  rosi
//
//  Created by michael on 13-6-27.
//  Copyright (c) 2013年 michael. All rights reserved.
//

#import "ZipHelperUtils.h"
#import "Objective-Zip/ZipFile.h"
#import "Objective-Zip/ZipException.h"
#import "Objective-Zip/FileInZipInfo.h"
#import "Objective-Zip/ZipWriteStream.h"
#import "Objective-Zip/ZipReadStream.h"

@implementation ZipHelperUtils

+ (NSMutableArray*)unzipReturnUnzipFile:(NSString *) inputFileFullPath targetDir:(NSString *) targetDirFullPath forceOverWrite:(BOOL) overWrite {
    if ([ZipHelperUtils unzipFile:inputFileFullPath targetDir:targetDirFullPath forceOverWrite:overWrite]) {
        NSFileManager* fm = [NSFileManager defaultManager];
        NSArray* files = [fm subpathsAtPath:targetDirFullPath];
        NSMutableArray* ret = [[NSMutableArray alloc] init];
        for (NSString* filename in files) {
            [ret addObject:[targetDirFullPath stringByAppendingPathComponent:filename]];
        }
        
        return ret;
    }
    
    return nil;
}

+ (BOOL)unzipFile:(NSString *) fileFullPath targetDir:(NSString *) targetDirFullPath forceOverWrite:(BOOL) overWrite {
    NSFileManager* fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:fileFullPath]) {
        if (![fm fileExistsAtPath:targetDirFullPath]) {
            if (![fm createDirectoryAtPath:targetDirFullPath withIntermediateDirectories:YES attributes:nil error:nil]) {
                return NO;
            }
        }
        
        ZipFile* unzipFile = [[ZipFile alloc] initWithFileName:fileFullPath mode:ZipFileModeUnzip];
        NSArray* fileinfos = [unzipFile listFileInZipInfos];
        for (FileInZipInfo* info in fileinfos) {
            NSString* filename = [[NSString alloc] initWithFormat:@"%@", info.name];
            if ([filename characterAtIndex:([filename length] - 1)] == '/') {
                //current zip file info is a dir
                NSString* dirName = [targetDirFullPath stringByAppendingPathComponent:filename];
                if (![fm createDirectoryAtPath:dirName withIntermediateDirectories:YES attributes:nil error:nil]) {
                    return NO;
                }
                continue;
            }
            
            [unzipFile locateFileInZip:info.name];
            NSString* unzipSubFileFullPath = [targetDirFullPath stringByAppendingPathComponent:filename];
            if (overWrite || ![fm fileExistsAtPath:unzipSubFileFullPath]) {
                [fm createFileAtPath:unzipSubFileFullPath contents:nil attributes:nil];
                NSFileHandle* file = [NSFileHandle fileHandleForReadingAtPath:unzipSubFileFullPath];
                NSMutableData* buffer = [[NSMutableData alloc] initWithLength:1024];
                
                ZipReadStream* rs = [unzipFile readCurrentFileInZip];
                do {
                    //reset buffer length
                    [buffer setLength:1024];
                    int byteRead = [rs readDataWithBuffer:buffer];
                    if (byteRead > 0) {
                        [buffer setLength:byteRead];
                        [file writeData:buffer];
                    } else {
                        break;
                    }
                } while(YES);
                
                [file closeFile];
                [rs finishedReading];
            }
        }
        
        return YES;
    }
    
    return NO;
}

@end
