//
//  MMRequestManager.m
//  Test
//
//  Created by Shadow on 16/9/1.
//  Copyright © 2016年 Shadow. All rights reserved.
//

#import "MMRequestManager.h"
#import "MMRequestConfiguration.h"
#import "YYModel.h"

NSString *const kMMRequestErrorDomain = @"com.mm.error";
const NSInteger kMMRequestErrorCode = -666666;

#define MM_REQUEST_ERROR [NSError errorWithDomain:kMMRequestErrorDomain code:kMMRequestErrorCode userInfo:nil]

typedef void(^MMRequestManagerSuccessBlock)(NSURLSessionDataTask *task, NSURLResponse *response, id responseObject);
typedef void(^MMRequestManagerFailBlock)(NSURLSessionDataTask *task, NSURLResponse *response, id responseObject, NSError  *error);

@interface MMRequestManager ()

@property (nonatomic, strong) AFHTTPSessionManager *manager;

@end

@implementation MMRequestManager

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

+ (instancetype)globalManager
{
    static MMRequestManager *requestManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        requestManager = [[MMRequestManager alloc]init];
    });
    
    return requestManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.manager = [AFHTTPSessionManager manager];
        
        self.manager.requestSerializer = [[MMRequestConfiguration configuration].requestSerializer copy];
        self.manager.responseSerializer = [[MMRequestConfiguration configuration].responseSerializer copy];
        
        self.shouldReceiveGlobalSerializers = YES;
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(globalSerializersDidChanged)
         name:kMMRequestGlobalSerializersDidChangedNotification
         object:nil];
    }
    return self;
}

- (void)setRequestSerializer:(AFHTTPRequestSerializer<AFURLRequestSerialization> *)requestSerializer
{
    self.manager.requestSerializer = requestSerializer;
}

- (AFHTTPRequestSerializer<AFURLRequestSerialization> *)requestSerializer
{
    return self.manager.requestSerializer;
}

- (void)setResponseSerializer:(AFHTTPResponseSerializer<AFURLResponseSerialization> *)responseSerializer
{
    self.manager.responseSerializer = responseSerializer;
}

- (AFHTTPResponseSerializer<AFURLResponseSerialization> *)responseSerializer
{
    return self.manager.responseSerializer;
}

#pragma mark - Request

- (void)addRequest:(MMBaseRequest *)request
{
    if (![self requestIsValid:request]) {
        [self requestFailed:nil response:nil responseObject:nil error:MM_REQUEST_ERROR withRequest:nil];
        return;
    }
    
    if (request.isRequesting) {
        [request cancel];
    }
    
    NSString *baseURL = [MMRequestConfiguration configuration].baseURL;
    if (!baseURL || !request.useBaseURL) {
        baseURL = @"";
    }
    
    NSString *relativeURL = request.requestURL;
    
    if ([baseURL hasSuffix:@"/"]) {
        baseURL = [baseURL substringToIndex:baseURL.length - 1];
    }
    
    if (relativeURL.length && baseURL.length && ![relativeURL hasPrefix:@"/"]) {
        relativeURL = [@"/" stringByAppendingString:relativeURL];
    }
    
    NSString *requestURL = [baseURL stringByAppendingString:relativeURL];
    
    NSDictionary *params = request.requestParams;
    MMRequestMethod method = request.requestMethod;
    
    __weak typeof(self) weakSelf = self;
    MMRequestManagerSuccessBlock success = ^(NSURLSessionDataTask *task, NSURLResponse *response, id responseObject) {
        [weakSelf requestSuccess:task response:response responseObject:responseObject withRequest:request];
    };
    
    MMRequestManagerFailBlock fail = ^(NSURLSessionDataTask *task, NSURLResponse *response, id responseObject, NSError  *error) {
        [weakSelf requestFailed:task response:response responseObject:responseObject error:error withRequest:request];
    };
    
    NSString *methodString = @"";
    switch (method) {
        case MMRequestMethodGet:
            methodString = @"GET";
            break;
        case MMRequestMethodPost:
            methodString = @"POST";
            break;
        case MMRequestMethodHead:
        {
            methodString = @"HEAD";
        }
            break;
        case MMRequestMethodPut:
            methodString = @"PUT";
            break;
        case MMRequestMethodDelete:
            methodString = @"DELETE";
            break;
        case MMRequestMethodPatch:
            methodString = @"PATCH";
            break;
            
        default:
            break;
    }
    
    NSError *serializationError = nil;
    NSMutableURLRequest *requestObj = [self.manager.requestSerializer requestWithMethod:methodString
                                                                              URLString:requestURL
                                                                             parameters:params
                                                                                  error:&serializationError];
    if (serializationError || !requestObj) {
        fail(nil, nil, nil, MM_REQUEST_ERROR);
        return;
    }
    
    NSURLRequest *finalRequest = requestObj;
    
    if ([request respondsToSelector:@selector(modifyRequest:)]) {
        finalRequest = [request modifyRequest:requestObj];
    }
    
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [self.manager dataTaskWithRequest:finalRequest
                               completionHandler:
                ^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                    if (error) {
                        
                        if ([MMRequestConfiguration configuration].errorPreProcess) {
                            [MMRequestConfiguration configuration].errorPreProcess(response, responseObject, error);
                        }
                        
                        fail(dataTask, response, responseObject, error);
                    } else {
                        success(dataTask, response, responseObject);
                    }
                }];
    
    [dataTask resume];
    
    request.task = dataTask;
}

- (void)requestSuccess:(NSURLSessionDataTask *)task
              response:(NSURLResponse *)response
        responseObject:(id)responseObject
           withRequest:(MMBaseRequest *)request
{
    id convertedResponseObject = nil;
    
    @try {
        request.task = nil;
        
        if (!request.onFinish) {
            return;
        }
        
        Class responseClass = request.responseClass;
        
        if (!responseClass) {
            request.onFinish(request, responseObject);
            return;
        }
        
        convertedResponseObject = [responseClass yy_modelWithDictionary:responseObject];
    } @catch (NSException *exception) {
        [self requestFailed:task
                   response:response
             responseObject:responseObject
                      error:MM_REQUEST_ERROR
                withRequest:request];
        return;
    }
    
    request.onFinish(request, convertedResponseObject);
}

- (void)requestFailed:(NSURLSessionDataTask *)task
             response:(NSURLResponse *)response
       responseObject:(id)responseObject
                error:(NSError *)error
          withRequest:(MMBaseRequest *)request
{
    request.task = nil;
    
    if (error.code == NSURLErrorCancelled) {
        return;
    }
    
    if (request.onError) {
        request.onError(request, error);
    }
    
    if (request.onErrorHandle) {
        request.onErrorHandle(request, response, responseObject, error);
    }
}

- (void)cancelAllRequests
{
    for (NSURLSessionTask *task in self.manager.tasks) {
        [task cancel];
    }
}

#pragma mark - Action

- (void)globalSerializersDidChanged
{
    if (self.shouldReceiveGlobalSerializers) {
        self.manager.requestSerializer =
        [[MMRequestConfiguration configuration].requestSerializer copy];
        self.manager.responseSerializer =
        [[MMRequestConfiguration configuration].responseSerializer copy];
    }
}

#pragma mark - Utils

- (BOOL)requestIsValid:(MMBaseRequest *)request
{
    if (!request) {
        return NO;
    }
    
    if (!request.requestURL.length) {
        return NO;
    }
    
    if (request.requestMethod < MMRequestMethodGet ||
        request.requestMethod > MMRequestMethodPatch) {
        return NO;
    }
    
    return request.isValid;
}

@end
