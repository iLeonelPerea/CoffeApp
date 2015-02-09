//
//  LoginViewController.h
//  coffeeapp
//
//  Created by Omar Guzmán on 10/17/14.
//  Copyright (c) 2014 crowdint. All rights reserved.
//

/** @name LoginViewController
 
    In this controller, the user do SignIn with G+ Auth proccess.
 */

#import <UIKit/UIKit.h>
#import <GooglePlus/GooglePlus.h>
#import <JGProgressHUD.h>
#import "UserProfileController.h"
#import "UserObject.h"
#import "AppDelegate.h"
#import "MenuViewController_iPhone.h"
#import <LMAlertView.h>

#define ApplicationOpenGoogleAuthNotification @"ApplicationOpenGoogleAuthNotification"

@class GPPSignInButton;

@interface LoginViewController : UIViewController <GPPSignInDelegate, UIWebViewDelegate>

@property (nonatomic, strong) UIWebView * gWebView;

/** Outlet for a custom button from the G+ SDK. */
@property (retain, nonatomic) IBOutlet GPPSignInButton *signInButton;

/** Outlet for an UIImageView to set the splash screen. */
@property (strong, nonatomic) IBOutlet UIImageView * imgSplashScreen;

/** UserObject object to store the credentials of the users received from G+ and Spree. */
@property (nonatomic, strong) UserObject *userObject;

/** Outlet for HUD component to display loading messages. */
@property (nonatomic, strong) JGProgressHUD *prgLoading;

/** Method to evaluate the result of the auth proccess with G+.
 
    @param auth It's not used.
    @param error Information about error in the auth proccess.
 
    It's a method from the G+ SDK. 
    - Check for error in the auth proccess.
    - If there's no errors. A UserObject object it's created with the credentials of G+.
    - The UserObject object is stored in the AppDelegate.
 */
-(void)finishedWithAuth:(GTMOAuth2Authentication *)auth error:(NSError *)error;

/** Check for the status of the SignIn proccess.
 */
-(void)refreshInterfaceBasedOnSignIn;

/** Push the view controller to do the SignIn proccess in G+.
 
    @param viewController View controller to be displayed for the login with G+.
 */
-(void)presentSignInViewController:(UIViewController*)viewController;

/** Set the data of UserObject in the AppDelegate after the SignIn proccess. If it is was succeded, posts a local notification to display the menu view controller.
 */
-(IBAction)doSetUserObject;

@end
