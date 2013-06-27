//
//  StringUtils.m
//  rosi
//
//  Created by michael on 13-6-27.
//  Copyright (c) 2013年 michael. All rights reserved.
//

#import "StringUtils.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>

@implementation StringUtils

+ (NSString *)md5Endcode:(NSString *) src {
    const char *cstr = [src UTF8String];
    unsigned char digest[16];
    CC_MD5(cstr, strlen(cstr), digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for (int i=0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

@end
