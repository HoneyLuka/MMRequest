//
//  MMRequestConfiguration.h
//  Test
//
//  Created by Shadow on 16/8/31.
//  Copyright © 2016年 Shadow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

extern NSString * const kMMRequestGlobalSerializersDidChangedNotification;

@interface MMRequestConfiguration : NSObject

@property (nonatomic, strong) NSString *baseURL;

/**
 Global 'RequestSerializer' for new MMRequestManager. 
 If you want to apply to all managers immediately, call applyGlobalSerializers method.
 Default is AFHTTPRequestSerializer.
 */
@property (nonatomic, copy) AFHTTPRequestSerializer<AFURLRequestSerialization> *requestSerializer;

/**
 Global 'ResponseSerializer' for new MMRequestManager.
 If you want to apply to all managers immediately, call applyGlobalSerializers method.
 Default is AFJSONResponseSerializer.
 */
@property (nonatomic, copy) AFHTTPResponseSerializer<AFURLResponseSerialization> *responseSerializer;

- (void)applyGlobalSerializers;

+ (instancetype)configuration NS_SWIFT_NAME(shared());

@end
