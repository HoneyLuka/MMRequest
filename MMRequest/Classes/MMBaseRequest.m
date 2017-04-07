//
//  MMBaseRequest.m
//  Test
//
//  Created by Shadow on 16/8/31.
//  Copyright © 2016年 Shadow. All rights reserved.
//

#import "MMBaseRequest.h"

#if __has_include(<MMRequest/MMRequest.h>)
#import <MMRequest/MMRequestManager.h>
#else
#import "MMRequestManager.h"
#endif

@interface MMBaseRequest ()

@end

@implementation MMBaseRequest

- (void)onFinish:(MMRequestOnFinishBlock)onFinish onError:(MMRequestOnErrorBlock)onError
{
    self.onFinish = onFinish;
    self.onError = onError;
}

- (void)request
{
    [[MMRequestManager globalManager]addRequest:self];
}

- (void)cancel
{
    if (![self isRequesting]) {
        return;
    }
    
    [self.task cancel];
    self.task = nil;
}

- (BOOL)isRequesting
{
    if (!self.task) {
        return NO;
    }
    
    return (self.task.state == NSURLSessionTaskStateRunning ||
            self.task.state == NSURLSessionTaskStateSuspended);
}

#pragma mark - For override

- (NSString *)requestURL
{
    NSAssert(NO, @"should use subclass");
    return nil;
}

- (BOOL)useBaseURL
{
    return YES;
}

- (BOOL)isValid
{
    return YES;
}

- (MMRequestMethod)requestMethod
{
    return MMRequestMethodGet;
}

- (NSDictionary *)requestParams
{
    return nil;
}

- (Class)responseClass
{
    return nil;
}

@end
