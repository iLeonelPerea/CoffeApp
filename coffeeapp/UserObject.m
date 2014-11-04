//
//  UserObject.m
//  coffeeapp
//
//  Created by Crowd on 10/19/14.
//  Copyright (c) 2014 crowdint. All rights reserved.
//

#import "UserObject.h"
#import <Parse/Parse.h>

@implementation UserObject
@synthesize userId, firstName, lastName, userName, userEmail, userPassword, userUrlProfileImage, userSpreeToken, userChannel;

//Init method set default properties values
-(id)init
{
    self = [super init];
    if (self) {
        [self setUserId:0];
        [self setFirstName:@""];
        [self setLastName:@""];
        [self setUserName:@""];
        [self setUserEmail:@""];
        [self setUserPassword:@""];
        [self setUserSpreeToken:@""];
        [self setUserChannel:@""];
    }
    return self;
}

//Create a custom init method which do Log In in Spree store. If the user is not registered, will be and retrieved the necesary data
-(id)initUser:(NSString*)user withFirstName:(NSString*)strFirstName andLastName:(NSString*)strLastName withEmail:(NSString*)email password:(NSString*)password urlProfileImage:(NSString *)urlProfileImage
{
    self = [super init];
    if (self) {
        [self setUserName:user];
        [self setFirstName:strFirstName];
        [self setLastName:strLastName];
        [self setUserEmail:email];
        [self setUserPassword:password];
        [self setUserUrlProfileImage:[urlProfileImage stringByReplacingOccurrencesOfString:@"?sz=50"
                                                                    withString:@"?sz=90"]];
        
        //With userEmail and userPassword do Log In in spree store to retrieve
        //Set the dictionary with the credentials to spree store
        NSMutableDictionary *jsonDict = [NSMutableDictionary dictionaryWithDictionary:@{@"spree_user":@{@"email": [self userEmail], @"password": [self userPassword]}}];
        //Make the call to do Log In
        [RESTManager sendData:jsonDict toService:@"v1/authorizations" withMethod:@"POST" isTesting:YES withAccessToken:nil isAccessTokenInHeader:NO toCallback:^(id result) {
            if ([result objectForKey:@"error"] && ![[result objectForKey:@"error"] isEqualToString:@""]) {
                 NSLog(@"%@",[result objectForKey:@"error"]);
                
                    //Attempt to register the user in spree store
                    if ([[result objectForKey:@"error"] isEqualToString:@"Record not found"]) {
                        
                        NSMutableDictionary *jsonDictRegister = [NSMutableDictionary dictionaryWithDictionary:@{@"user":@{@"email": [self userEmail], @"password": [self userPassword], @"password_confirmation": [self userPassword]}}];
                        [RESTManager sendData:jsonDictRegister toService:@"users" withMethod:@"POST" isTesting:YES withAccessToken:nil isAccessTokenInHeader:NO toCallback:^(id result) {
                            
                            if ([result objectForKey:@"error"] && ![[result objectForKey:@"error"] isEqualToString:@""]) {
                                NSLog(@"%@",[result objectForKey:@"error"]);
                                return;
                            }
                            [self setUserId:[[result objectForKey:@"id"] intValue]];
                            [self setUserSpreeToken:[result objectForKey:@"spree_api_key"]];
                            NSLog(@"I'm here");
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"initUserFinishedLoading" object:nil];
                        }];
                    }
                return;
                }
            [self setUserId:[[[result objectForKey:@"user"] objectForKey:@"id"] intValue]];
            [self setUserSpreeToken:[[result objectForKey:@"user"] objectForKey:@"spree_api_key"]];
            NSString * customUserChannel = [NSString stringWithFormat:@"User_%@",self.userSpreeToken];
            [self setUserChannel:customUserChannel];
            [PFPush subscribeToChannelInBackground:customUserChannel];
            
            //NSLog(@"I'm here now");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"initUserFinishedLoading" object:nil];
        }];
    }
    return self;
}

//Create coder and decoder to be able to save on standar user defaults.
-(id)initWithCoder:(NSCoder*)coder
{
    self = [super init];
    if (self) {
        [self setUserId:[coder decodeIntForKey:@"userId"]];
        [self setUserName:[coder decodeObjectForKey:@"userName"]];
        [self setFirstName:[coder decodeObjectForKey:@"firstName"]];
        [self setLastName:[coder decodeObjectForKey:@"lastName"]];
        [self setUserEmail:[coder decodeObjectForKey:@"userEmail"]];
        [self setUserPassword:[coder decodeObjectForKey:@"userPassword"]];
        [self setUserUrlProfileImage:[coder decodeObjectForKey:@"userUrlProfileImage"]];
        [self setUserSpreeToken:[coder decodeObjectForKey:@"userSpreeToken"]];
        [self setUserChannel:[coder decodeObjectForKey:@"userChannel"]];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder*)coder
{
    [coder encodeInt:userId forKey:@"userId"];
    [coder encodeObject:userName forKey:@"userName"];
    [coder encodeObject:firstName forKey:@"firstName"];
    [coder encodeObject:lastName forKey:@"lastName"];
    [coder encodeObject:userEmail forKey:@"userEmail"];
    [coder encodeObject:userPassword forKey:@"userPassword"];
    [coder encodeObject:userUrlProfileImage forKey:@"userUrlProfileImage"];
    [coder encodeObject:userSpreeToken forKey:@"userSpreeToken"];
    [coder encodeObject:userChannel forKey:@"userChannel"];
}

@end