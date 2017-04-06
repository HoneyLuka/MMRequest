//
//  MMRequestConfiguration.m
//  Test
//
//  Created by Shadow on 16/8/31.
//  Copyright © 2016年 Shadow. All rights reserved.
//

#import "MMRequestConfiguration.h"
#import <pthread.h>

NSString * const kMMRequestGlobalSerializersDidChangedNotification = @"com.mm.global_serializers_did_changed_notification";

@implementation MMRequestConfiguration

+ (instancetype)configuration
{
    static MMRequestConfiguration *requestConfiguration = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        requestConfiguration = [[MMRequestConfiguration alloc]init];
    });
    
    return requestConfiguration;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.requestSerializer = [AFHTTPRequestSerializer serializer];
        self.responseSerializer = [AFJSONResponseSerializer serializer];
    }
    return self;
}

- (void)applyGlobalSerializers
{
    void(^block)(void) = ^ {
        [[NSNotificationCenter defaultCenter]postNotificationName:kMMRequestGlobalSerializersDidChangedNotification object:nil];
    };
    
    if (pthread_main_np()) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

@end
