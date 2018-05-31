//
//  MMBaseRequest.h
//  Test
//
//  Created by Shadow on 16/8/31.
//  Copyright © 2016年 Shadow. All rights reserved.
//

#if __has_include(<MMRequest/MMRequest.h>)
#import <MMRequest/MMBaseResponse.h>
#else
#import "MMBaseResponse.h"
#endif

#import <UIKit/UIKit.h>
#import <YYModel/YYModel.h>

@class MMBaseRequest;
typedef void(^MMRequestOnFinishBlock)(MMBaseRequest *request, id response);
typedef void(^MMRequestOnErrorBlock)(MMBaseRequest *request, NSError *error);

typedef void(^MMRequestHandleErrorBlock)(MMBaseRequest *request, NSURLResponse *response, id responseObject, NSError *error);

typedef NS_ENUM(NSUInteger, MMRequestMethod) {
  MMRequestMethodGet,
  MMRequestMethodPost,
  MMRequestMethodHead,
  MMRequestMethodPut,
  MMRequestMethodDelete,
  MMRequestMethodPatch,
};

@interface MMBaseRequest : NSObject

@property (nonatomic, strong) NSURLSessionTask *task;

@property (nonatomic, copy) MMRequestOnFinishBlock onFinish;
@property (nonatomic, copy) MMRequestOnErrorBlock onError __attribute__((deprecated("use onErrorHandle instead")));

@property (nonatomic, copy) MMRequestHandleErrorBlock onErrorHandle;

- (void)onFinish:(MMRequestOnFinishBlock)onFinish onError:(MMRequestOnErrorBlock)onError __attribute__((deprecated("use onFinish:onErrorHandle: instead")));

- (void)onFinish:(MMRequestOnFinishBlock)onFinish onErrorHandle:(MMRequestHandleErrorBlock)onErrorHandle;

- (BOOL)isRequesting;

/**
 Request in global manager immediately.
 */
- (void)request;

- (void)cancel;

#pragma mark - Subclass override

- (NSString *)requestURL;

- (NSDictionary *)requestParams;

/**
 If not implement, will return raw data in onFinish().
 */
- (Class)responseClass;

/**
 Default is GET.
 */
- (MMRequestMethod)requestMethod;

/**
 If you want to modify request before sending, implement this method.
 
 @return Request you want to send.
 */
- (NSURLRequest *)modifyRequest:(NSMutableURLRequest *)request;

/**
 Default is YES.
 */
- (BOOL)useBaseURL;

/**
 Default is YES.
 */
- (BOOL)isValid;

@end
