//
//  LoginViewController.m
//  coffeeapp
//
//  Created by Omar Guzmán on 10/17/14.
//  Copyright (c) 2014 crowdint. All rights reserved.
//

#import "LoginViewController.h"
#import <GooglePlus/GooglePlus.h>
#import <GoogleOpenSource/GoogleOpenSource.h>

@interface LoginViewController ()

@end

@implementation LoginViewController
@synthesize signInButton, btnSignOut, userObject;

//Google App client ID. Created specifically for CoffeeApp
static NSString * const kClientID = @"1079376875634-shj8qu3kuh4i9n432ns8kspkl5rikcvv.apps.googleusercontent.com";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Set the SignIn
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    [signIn setShouldFetchGooglePlusUser:YES];
    [signIn setShouldFetchGoogleUserEmail:YES];
    //Set the ClientID for the app
    [signIn setClientID: kClientID];
    //Set the scope
    [signIn setScopes:@[@"profile"]];
    //Set the SignIn delegate
    [signIn setDelegate:self];
    //Hide the SignOut button
    [[self btnSignOut] setHidden:YES];
    //Add an observer to set up the userObject in AppDelegate
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doSetUserObject) name:@"initUserFinishedLoading" object:nil];
    //If user has been sign in before, automatically trigger de sign in method
    [signIn trySilentAuthentication];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- GPPSignIn delegate
-(void)finishedWithAuth:(GTMOAuth2Authentication *)auth error:(NSError *)error
{
    /*This is the content of auth dictionary, which is the response of the SingIn from G+
     {accessToken="", 
     refreshToken="", 
     code="", 
     expirationDate=""}
    */
    //This is the email which the user used to did log in
    //NSLog(@"%@",[[GPPSignIn sharedInstance] userEmail]);
    //This is the object with the user data
    GTLPlusPerson * person = [[GPPSignIn sharedInstance] googlePlusUser];
    //NSLog(@"%@", person);
    //NSLog(@"Received error %@ and auth object %@",error, auth);
    if (error) {
        // Do some error handling here.
    } else {
        [self refreshInterfaceBasedOnSignIn];
        userObject = [[UserObject alloc] initUser:[person displayName] withEmail:[[GPPSignIn sharedInstance] userEmail]  password:[person ETag] urlProfileImage:[[person image] url] ];
    }
}

-(void)refreshInterfaceBasedOnSignIn {
    if ([[GPPSignIn sharedInstance] authentication]) {
        // The user is signed in.
        [[self signInButton] setHidden:YES];
        [[self btnSignOut] setHidden:NO];
    } else {
        [[self signInButton] setHidden:NO];
        [[self btnSignOut] setHidden:YES];
    }
}

-(void)presentSignInViewController:(UIViewController*)viewController
{
    [[self navigationController] pushViewController:viewController animated:YES];
}

#pragma mark -- SigOut delegate
-(IBAction)doSignOut:(id)sender
{
    //SignOut
    [[GPPSignIn sharedInstance] signOut];
    //Revoke token
    [[GPPSignIn sharedInstance] disconnect];
    //Display the SignIn button
    [[self signInButton] setHidden:NO];
    //Hide the SignOut button
    [[self btnSignOut] setHidden:YES];
}

#pragma mark -- Set userObject delegate
-(void)doSetUserObject
{
    //Set up the userObject in AppDelegate with the userObject values from LogIn
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate setUserObject:userObject];
    UserProfileController * userProfileController = [[UserProfileController alloc] initWithNibName:@"UserProfileController" bundle:nil];
    [self.navigationController pushViewController:userProfileController animated:YES];
}

@end
