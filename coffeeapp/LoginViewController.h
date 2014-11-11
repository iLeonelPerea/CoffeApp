//
//  LoginViewController.h
//  coffeeapp
//
//  Created by Omar Guzmán on 10/17/14.
//  Copyright (c) 2014 crowdint. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GooglePlus/GooglePlus.h>
#import <JGProgressHUD.h>
#import "UserProfileController.h"
#import "UserObject.h"
#import "AppDelegate.h"
#import "MenuViewController_iPhone.h"

@class GPPSignInButton;

@interface LoginViewController : UIViewController <GPPSignInDelegate>

@property (retain, nonatomic) IBOutlet GPPSignInButton *signInButton;
@property (strong, nonatomic) IBOutlet UIImageView * imgSplashScreen;
@property (nonatomic, strong) UserObject *userObject;
@property (nonatomic, strong) JGProgressHUD *prgLoaging;

@end
