//
//  UserObject.h
//  coffeeapp
//
//  Created by Crowd on 10/19/14.
//  Copyright (c) 2014 crowdint. All rights reserved.
//

/** @name UserObject
    
    Class to define the structure of the user object. It contains a method to initialize a new object with data to retrieve the credentials of the user from Spree.
 */

#import <Foundation/Foundation.h>
#import "RESTManager.h"
#import <LMAlertView.h>

@interface UserObject : NSObject

/** The Id of the user in the Spree store. */
@property (nonatomic, assign) int userId;

/** First name of the user. */
@property (nonatomic, strong) NSString *firstName;

/** Last name of the user. */
@property (nonatomic, strong) NSString *lastName;

/** Full name of the user. */
@property (nonatomic, strong) NSString *userName;

/** Email of the user. */
@property (nonatomic, strong) NSString *userEmail;

/** Password of the user, taken from a G+ unique tag. */
@property (nonatomic, strong) NSString *userPassword;

/** URL of the profile image of the user in G+. */
@property (nonatomic, strong) NSString *userUrlProfileImage;

/** The Spree token of the user -a.k.a spree_api_key-. */
@property (nonatomic, strong) NSString *userSpreeToken;

/** Value for the channel of the user to listen push notifications using Parse service. */
@property (nonatomic, strong) NSString *userChannel;

/** Init method set default properties values */
-(id)init;

/** Initialize a user object with specific data.
 
    Create a custom init method which do Log In in Spree store. If the user is not registered, will be and retrieved the necesary data.
    - Set the properties values with the param values received.
    - With userEmail and userPassword do Log In in spree store. Set the dictionary with the credentials to spree store.
    - Make the call to do Log In.
    - Check for the error message to identify if the user doesn't exists in the Spree store. In this case, the user will be registered in the Spree store.
        - Attempt to register the user in spree store.
        - Sent the request to register the user in the Spree store. Use the service "users", sending a hash with email, password, password confirmation, image_url and channel values of the user.
        - Check for an error in the register proccess of the user in the Spree store.
    - If the proccess of register or Log In is successful, then:
        - Set the value of the user Id of the Spree store and the value for the spree_api_key into the UserObject properties.
        - Suscribe the user in the Parse service for listen push notifications.
        - Post a local notification to trigger the action for ending the Log In proccess.
 
    @param user Full name of the user.
    @param strUserId Id of the user in G+. Used to create the user channel for listen push notifications.
    @param firstName First name of the user.
    @param lastName Last name of the user.
    @param email Email of the user.
    @param password Tag value of the user in G+. Used to create the password fot user account in Spree store.
    @param urlProfileImage URL of the profile image of the user in G+.

 */
-(id)initUser:(NSString*)user withId:(NSString*)strUserId andFirstName:(NSString*)strFirstName andLastName:(NSString*)strLastName withEmail:(NSString*)email password:(NSString*)password urlProfileImage:(NSString *)urlProfileImage;

/** Create a custom init to code the object.

    @param coder NSCoder variable.
 */
-(id)initWithCoder:(NSCoder*)coder;

/** Create a custom init to decode the object properties.

    @param coder NSCoder variable.
 */
-(void)encodeWithCoder:(NSCoder*)coder;

@end
