//
//  RESTManager.h
//  coffeeapp
//
//  Created by Crowd on 10/19/14.
//  Copyright (c) 2014 crowdint. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RESTManager : NSObject

+(void)sendData:(NSMutableDictionary *)data toService:(NSString *)service withMethod:(NSString *)method isTesting:(BOOL)testing withAccessToken:(NSString *)accessToken toCallback:(void (^)(id))callback;

@end