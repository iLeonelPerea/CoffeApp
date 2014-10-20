//
//  LoginViewController.h
//  coffeeapp
//
//  Created by Omar Guzmán on 10/17/14.
//  Copyright (c) 2014 crowdint. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GooglePlus/GooglePlus.h>
#import "UserProfileController.h"
#import "UserObject.h"
#import "AppDelegate.h"

@class GPPSignInButton;

@interface LoginViewController : UIViewController <GPPSignInDelegate>

@property (retain, nonatomic) IBOutlet GPPSignInButton *signInButton;
@property (nonatomic, strong) IBOutlet UIButton *btnSignOut;
@property (nonatomic, strong) UserObject *userObject;

-(IBAction)doSignOut:(id)sender;

@end
