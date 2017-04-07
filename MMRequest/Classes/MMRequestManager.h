//
//  MMRequestManager.h
//  Test
//
//  Created by Shadow on 16/9/1.
//  Copyright © 2016年 Shadow. All rights reserved.
//

#import <Foundation/Foundation.h>

#if __has_include(<MMRequest/MMRequest.h>)
#import <MMRequest/MMBaseRequest.h>
#else
#import "MMBaseRequest.h"
#endif

#import <AFNetworking/AFNetworking.h>

@interface MMRequestManager : NSObject

/**
 Default is YES. If you want to custom 'RequestSerializer', set it to NO.
 */
@property (nonatomic, assign) BOOL shouldReceiveGlobalSerializers;

/**
 'RequestSerializer' for this manager. It always equal to global 'RequestSerializer' after initialization.
 */
@property (nonatomic, strong) AFHTTPRequestSerializer<AFURLRequestSerialization> *requestSerializer;

/**
 'ResponseSerializer' for this manager. It always equal to global 'ResponseSerializer' after initialization.
 */
@property (nonatomic, strong) AFHTTPResponseSerializer<AFURLResponseSerialization> *responseSerializer;

- (void)addRequest:(MMBaseRequest *)request;
- (void)cancelAllRequests;

+ (instancetype)globalManager;

@end
