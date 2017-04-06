//
//  MMBaseResponse.h
//  Test
//
//  Created by Shadow on 16/8/31.
//  Copyright © 2016年 Shadow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYModel/YYModel.h>

@protocol MMResponseCustomProtocol <YYModel>

@optional
+ (NSDictionary *)modelCustomPropertyMapper;
+ (NSDictionary *)modelContainerPropertyGenericClass;

+ (NSArray *)modelPropertyBlacklist;
+ (NSArray *)modelPropertyWhitelist;

@end

@interface MMBaseResponse : NSObject <MMResponseCustomProtocol>

@end
