//
//  AlbumEngin.m
//  rosi
//
//  Created by michael on 13-6-26.
//  Copyright (c) 2013年 michael. All rights reserved.
//

#import "AlbumEngin.h"
#import "Fileutils.h"
#import "StringUtils.h"

@implementation AlbumEngine

NSString* FIRST_PAGE_DATA_FILE = @"firstPage.json";

- (void) albumUrl:(NSString*) url completionHandler:(AlbumJsonDictBlock) callback postParams:(NSDictionary*) params errorHandler:(MKNKErrorBlock) errorCallBack forceLoad:(BOOL) forceLoad {
    if (url == nil || callback == nil) {
        return;
    }

    NSString* docPath = [Fileutils DocumentFullPath];
    NSString* urlMD5 = [StringUtils md5Endcode:url];
    NSString* cacheFilePath = [[NSString alloc] initWithFormat:@"%@/%@-%@", docPath, urlMD5, FIRST_PAGE_DATA_FILE];
    if (!forceLoad) {
        NSData* content = [NSData dataWithContentsOfFile:cacheFilePath];
        if (content != nil) {
            id jsonObject = [NSJSONSerialization JSONObjectWithData:content options:NSJSONReadingAllowFragments error:nil];
            if (jsonObject != nil) {
                NSLog(@"Loading the JSON cache data from %@, content data = %@", cacheFilePath, [[NSString alloc] initWithData:content encoding:NSUTF8StringEncoding]);
                callback(jsonObject);
                return;
            }
        }
    }
    
    MKNetworkOperation* op = [self operationWithPath:[url mk_urlEncodedString] params:params httpMethod:@"post"];
    if (op != nil) {
        [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
            NSString* valueString = [completedOperation responseString];
            NSLog(@"%@", valueString);
            
            [completedOperation responseJSONWithCompletionHandler:^(id jsonObject) {
                NSString* page = params[@"page"];
                if ([page isEqualToString:@"0"] && jsonObject != nil) {
                    NSData* content = [NSJSONSerialization dataWithJSONObject:jsonObject options:NSJSONWritingPrettyPrinted error:nil];
                    if (content != nil) {
                        NSLog(@"success convert the JSON objt to content : %@",  [[NSString alloc] initWithData:content encoding:NSUTF8StringEncoding]);
                        [content writeToFile:cacheFilePath atomically:YES];
                    }
                }
                
                callback(jsonObject);
            }];
        } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
            errorCallBack(error);
        }];
        
        [self enqueueOperation:op];
    }
}

- (MKNetworkOperation *) createDownloadOpWithUrl:(NSString *) downloadUrl toFile:(NSString *) localFile {
    MKNetworkOperation* op = [self operationWithURLString:downloadUrl];
    
    [op addDownloadStream:[NSOutputStream outputStreamToFileAtPath:localFile append:NO]];
    
    [self enqueueOperation:op];
    
    return op;
}

- (NSString*) cacheDirectoryName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    NSString *cacheDirectoryName = [documentsDirectory stringByAppendingPathComponent:@"RosiImages"];
    return cacheDirectoryName;
}

@end
