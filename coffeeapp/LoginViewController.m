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
@synthesize signInButton, userObject, prgLoaging;

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
    //Add an observer to set up the userObject in AppDelegate
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doSetUserObject) name:@"initUserFinishedLoading" object:nil];
    //Set the progress loading indicator
    prgLoaging = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    [[prgLoaging textLabel] setText:@"Sign In..."];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    [signInButton setImage:[UIImage imageNamed:@"login_btn_up"] forState:UIControlStateNormal];
    [signInButton setImage:[UIImage imageNamed:@"login_btn_down"] forState:UIControlStateHighlighted];
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
        [prgLoaging showInView:[self view]];
        [self refreshInterfaceBasedOnSignIn];
        AppDelegate *myAppDelegate = [[UIApplication sharedApplication] delegate];
        GTLPlusPersonName * nameData = [person name];
        //NSLog(@"name: %@, lastname: %@", [nameData givenName], [nameData familyName]);
        userObject = [[UserObject alloc] initUser:[person displayName] withId:[person.JSON objectForKey:@"id"] andFirstName:[nameData givenName] andLastName:[nameData familyName] withEmail:[[GPPSignIn sharedInstance] userEmail]  password:[person ETag] urlProfileImage:[[person image] url] ];
        myAppDelegate.orderObject.userObject = self.userObject;
    }
}

-(void)refreshInterfaceBasedOnSignIn {
    if ([[GPPSignIn sharedInstance] authentication]) {
        //Authentication was successfully
    } else {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Attention" message:@"There's an unexpected action with your Sign In" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
}

-(void)presentSignInViewController:(UIViewController*)viewController
{
    [[self navigationController] pushViewController:viewController animated:YES];
}

#pragma mark -- Set userObject delegate
-(void)doSetUserObject
{
    //Set up the userObject in AppDelegate with the userObject values from LogIn
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate setUserObject:userObject];
    //Sotre the userObject data in user defaults
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:userObject] forKey:@"userObject"];
    [defaults synchronize];
    [prgLoaging dismiss];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"userDidRequestSignIn" object:nil];
}

@end
