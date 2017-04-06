//
//  MMBaseRequest.h
//  Test
//
//  Created by Shadow on 16/8/31.
//  Copyright © 2016年 Shadow. All rights reserved.
//

#import "MMBaseResponse.h"
#import <UIKit/UIKit.h>

@class MMBaseRequest;
typedef void(^MMRequestOnFinishBlock)(MMBaseRequest *request, id response);
typedef void(^MMRequestOnErrorBlock)(MMBaseRequest *request, NSError *error);

typedef NS_ENUM(NSUInteger, MMRequestMethod) {
  MMRequestMethodGet,
  MMRequestMethodPost,
  MMRequestMethodHead,
  MMRequestMethodPut,
  MMRequestMethodDelete,
  MMRequestMethodPatch,
};

@protocol MMRequestCustomProtocol <NSObject>

@required
- (NSString *)requestURL;

@optional
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

@interface MMBaseRequest : NSObject <MMRequestCustomProtocol>

@property (nonatomic, strong) NSURLSessionTask *task;

@property (nonatomic, copy) MMRequestOnFinishBlock onFinish;
@property (nonatomic, copy) MMRequestOnErrorBlock onError;

- (void)onFinish:(MMRequestOnFinishBlock)onFinish onError:(MMRequestOnErrorBlock)onError;

- (BOOL)isRequesting;

/**
 Request in global manager immediately.
 */
- (void)request;

- (void)cancel;

@end
