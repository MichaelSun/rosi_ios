//
//  AlbumEngin.m
//  rosi
//
//  Created by michael on 13-6-26.
//  Copyright (c) 2013年 michael. All rights reserved.
//

#import "AlbumEngin.h"

@implementation AlbumEngine

- (void) albumUrl:(NSString*) url completionHandler:(AlbumJsonDictBlock) callback postParams:(NSDictionary*) params errorHandler:(MKNKErrorBlock) errorCallBack {
    if (url == nil || callback == nil) {
        return;
    }

    MKNetworkOperation* op = [self operationWithPath:[url mk_urlEncodedString] params:params httpMethod:@"post"];
    if (op != nil) {
        [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
            NSString* valueString = [completedOperation responseString];
            NSLog(@"%@", valueString);
            
            [completedOperation responseJSONWithCompletionHandler:^(id jsonObject) {
                callback(jsonObject);
            }];
        } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
            errorCallBack(error);
        }];
        
        [self enqueueOperation:op];
    }
}

- (NSString*) cacheDirectoryName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    NSString *cacheDirectoryName = [documentsDirectory stringByAppendingPathComponent:@"RosiImages"];
    return cacheDirectoryName;
}

@end
