//
//  MMBaseRequest+Promise.h
//  Test
//
//  Created by Shadow on 2017/4/6.
//  Copyright © 2017年 Shadow. All rights reserved.
//

#import "MMBaseRequest.h"
#import <PromiseKit/PromiseKit.h>

@interface MMBaseRequest (Promise)

- (PMKPromise *)promise;

@end
