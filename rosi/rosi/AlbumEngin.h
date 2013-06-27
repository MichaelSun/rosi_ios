//
//  AlbumEngin.h
//  rosi
//
//  Created by michael on 13-6-26.
//  Copyright (c) 2013年 michael. All rights reserved.
//

#import "MKNetworkEngine.h"

typedef void (^AlbumJsonDictBlock)(NSMutableDictionary* album);

@interface AlbumEngine : MKNetworkEngine

- (void) albumUrl:(NSString*) url completionHandler:(AlbumJsonDictBlock) callback postParams:(NSDictionary*) params errorHandler:(MKNKErrorBlock) error;

@end
