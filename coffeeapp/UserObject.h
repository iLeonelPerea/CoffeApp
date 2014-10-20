//
//  UserObject.h
//  coffeeapp
//
//  Created by Crowd on 10/19/14.
//  Copyright (c) 2014 crowdint. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RESTManager.h"

@interface UserObject : NSObject

@property (nonatomic, assign) int userId;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *userEmail;
@property (nonatomic, strong) NSString *userPassword;
@property (nonatomic, strong) NSString *userUrlProfileImage;
@property (nonatomic, strong) NSString *userSpreeToken;

-(id)initUser:(NSString*)user withEmail:(NSString*)email password:(NSString*)password urlProfileImage:(NSString *)urlProfileImage;

@end
