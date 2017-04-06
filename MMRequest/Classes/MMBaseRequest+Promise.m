//
//  MMBaseRequest+Promise.m
//  Test
//
//  Created by Shadow on 2017/4/6.
//  Copyright © 2017年 Shadow. All rights reserved.
//

#import "MMBaseRequest+Promise.h"

@implementation MMBaseRequest (Promise)

- (PMKPromise *)promise
{
    return [PMKPromise new:^(PMKFulfiller fulfill, PMKRejecter reject) {
        [self onFinish:^(MMBaseRequest *request, id response) {
            fulfill(PMKManifold(response));
        } onError:^(MMBaseRequest *request, NSError *error) {
            reject(error);
        }];
        
        [self request];
    }];
}

@end
