//
//  PZUtils.m
//  SynoTool
//
//  Created by Piotr on 10/01/2017.
//  Copyright © 2017 Piotr Zagawa. All rights reserved.
//

#import "PZUtils.h"

@implementation PZUtils

static NSObject *formatterLock = nil;
static NSByteCountFormatter *formatter = nil;

+ (void)initialize
{
    if (self == [PZUtils class])
    {
        formatterLock = [NSObject new];
        formatter = [NSByteCountFormatter new];
    }
}

+ (NSString *)formatBytesCount:(NSUInteger)bytesCount
{
    @synchronized (formatterLock)
    {
        return [formatter stringFromByteCount:bytesCount];
    }
}

@end
