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

/// Macros to identify the screen size.
#define IS_IPHONE_5 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)568) < DBL_EPSILON)
#define IS_IPHONE_6 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)667) < DBL_EPSILON)
#define IS_IPHONE_6_PLUS (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)736) < DBL_EPSILON)

@interface LoginViewController ()

@end

@implementation LoginViewController
@synthesize signInButton, userObject, prgLoading, imgSplashScreen, gWebView;

/// Google App client ID. Created specifically for CoffeeApp.
static NSString * const kClientID = @"1079376875634-shj8qu3kuh4i9n432ns8kspkl5rikcvv.apps.googleusercontent.com";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /// Set the SignIn component for G+.
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    [signIn setShouldFetchGooglePlusUser:YES];
    [signIn setShouldFetchGoogleUserEmail:YES];
    /// Set the ClientID for the app.
    [signIn setClientID: kClientID];
    /// Set the scope.
    [signIn setScopes:@[@"profile"]];
    /// Set the SignIn delegate.
    [signIn setDelegate:self];
    /// Add an observer to set up the userObject in AppDelegate.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doSetUserObject) name:@"initUserFinishedLoading" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tryToLogin:) name:ApplicationOpenGoogleAuthNotification object:nil];
    /// Set the progress loading indicator.
    prgLoading = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    [[prgLoading textLabel] setText:@"Sign In..."];
}

-(void)tryToLogin:(NSNotification*)notification
{
    NSString * strURL = [NSString stringWithFormat:@"%@", [notification object]];
    NSLog(@"try to login on: %@", strURL);
    CGRect webRect = CGRectMake(10, self.view.frame.origin.y + 40, self.view.frame.size.width - 20, self.view.frame.size.height - 50);
    gWebView = [[UIWebView alloc]initWithFrame:webRect];//self.view.frame];
    NSURLRequest *nsrequest=[NSURLRequest requestWithURL:[NSURL URLWithString:strURL]];
    [gWebView setDelegate:self];
    [gWebView loadRequest:nsrequest];
    [self.view addSubview:gWebView];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"url: %@", [request URL]);
    if ([[[request URL] absoluteString] hasPrefix:@"com.crowdint.coffeeapp:/oauth2callback"]) {
        [prgLoading showInView:[self view]];
        [signInButton setEnabled:NO];
        [GPPURLHandler handleURL:[request URL] sourceApplication:@"com.apple.mobilesafari" annotation:nil];
        [gWebView removeFromSuperview];
        // Looks like we did log in (onhand of the url), we are logged in, the Google APi handles the rest
        //[self.navigationController popViewControllerAnimated:YES];
        return NO;
    }
    return YES;
}

/// System method.
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    /// Set the elements to fit the size of the screen.
    [signInButton setFrame:CGRectMake((self.view.bounds.size.width - 280) / 2, self.view.bounds.size.height - 65, 280, 50)];
    //[signInButton setFrame:(IS_IPHONE_6)?CGRectMake(47, 600, 280, 50):(IS_IPHONE_5)?CGRectMake(20, 508, 280, 50):CGRectMake(20, 420, 280, 50)];
    [imgSplashScreen setFrame:CGRectMake((self.view.bounds.size.width - 206) / 2, (self.view.bounds.size.height - 351) / 2, 206, 351)];
    //[imgSplashScreen setFrame:(IS_IPHONE_6)?CGRectMake(84, 100, 206, 351):(IS_IPHONE_5)?CGRectMake(57, 78, 206, 351):CGRectMake(57, 48, 206, 351)];
    /// Set the images for the SignIn button.
    [signInButton setImage:[UIImage imageNamed:@"login_btn_up@2x"] forState:UIControlStateNormal];
    [signInButton setImage:[UIImage imageNamed:@"login_btn_down@2x"] forState:UIControlStateHighlighted];
    [signInButton setImage:[UIImage imageNamed:@"login_btn_up@2x"] forState:UIControlStateDisabled];
}

#pragma mark -- GPPSignIn delegate
-(void)finishedWithAuth:(GTMOAuth2Authentication *)auth error:(NSError *)error
{
    //[prgLoading showInView:[self view]];
    //[signInButton setEnabled:NO];
    /** This is the content of auth dictionary, which is the response of the SingIn from G+
     {accessToken="", 
     refreshToken="", 
     code="", 
     expirationDate=""}
    */
    /// This is the email which the user used to did log in
    /// //NSLog(@"%@",[[GPPSignIn sharedInstance] userEmail]);
    /// This is the object with the user data
    GTLPlusPerson * person = [[GPPSignIn sharedInstance] googlePlusUser];
    /// //NSLog(@"%@", person);
    /// //NSLog(@"Received error %@ and auth object %@",error, auth);
    if (error) {
        /// Do some error handling here.
    } else {
        //check email domain
        BOOL isTestingMain = NO;
        NSString * strEmail = [[GPPSignIn sharedInstance] userEmail];
        if([strEmail isEqual:@"chefcrowd@gmail.com"])
            isTestingMain = YES;
        NSArray * arrEmail = [strEmail componentsSeparatedByString:@"@"];
        if(![[arrEmail objectAtIndex:1] isEqual:@"crowdint.com"] && !isTestingMain)
        {
            [prgLoading dismiss];
            NSLog(@"user does not belong to company and can do nothing here...");
            /// SignOut
            [[GPPSignIn sharedInstance] signOut];
            /// Revoke token
            [[GPPSignIn sharedInstance] disconnect];
            LMAlertView * alertView = [[LMAlertView alloc] initWithTitle:nil message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView setSize:CGSizeMake(200.0f, 320.0f)];
            /// Create and add the content of the aler view.
            UIView *contentView = alertView.contentView;
            [contentView setBackgroundColor:[UIColor clearColor]];
            [alertView setBackgroundColor:[UIColor clearColor]];
            UIImageView * imgV = [[UIImageView alloc] initWithFrame:CGRectMake(35.5f, 5.0f, 129.0f, 200.0f)];
            [imgV setImage:[UIImage imageNamed:@"ChefNo"]];
            [contentView addSubview:imgV];
            UILabel * lblStatus = [[UILabel alloc] initWithFrame:CGRectMake(10, 170, 180, 120)];
            lblStatus.numberOfLines = 3;
            [lblStatus setFont:[UIFont fontWithName:@"Lato-Regular" size:14]];
            [lblStatus setTextAlignment:NSTextAlignmentCenter];
            lblStatus.text = @"Sorry, you don't have permissions to enjoy our delicious application!";
            [contentView addSubview:lblStatus];
            [alertView show];
            return;
        }
        /// Show the loading message.
        [self refreshInterfaceBasedOnSignIn];
        AppDelegate *myAppDelegate = [[UIApplication sharedApplication] delegate];
        GTLPlusPersonName * nameData = [person name];
        /// //NSLog(@"name: %@, lastname: %@", [nameData givenName], [nameData familyName]);
        /// Create an instance of UserObject with the credentials from G+.
        userObject = [[UserObject alloc] initUser:[person displayName] withId:[person.JSON objectForKey:@"id"] andFirstName:[nameData givenName] andLastName:[nameData familyName] withEmail:[[GPPSignIn sharedInstance] userEmail]  password:[person ETag] urlProfileImage:[[person image] url] ];
        /// Store the userObject in the AppDelegate.
        myAppDelegate.orderObject.userObject = self.userObject;
    }
}

-(void)refreshInterfaceBasedOnSignIn {
    /// Check for the status of the SignIn proccess.
    if ([[GPPSignIn sharedInstance] authentication]) {
        /// Authentication was successfully
    } else {
        /// Create an alert view to inform about an error on SignIn.
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Attention" message:@"There's an unexpected action with your Sign In" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
}

/// Push the view controller to do the SignIn proccess in G+.
-(void)presentSignInViewController:(UIViewController*)viewController
{
    [[self navigationController] pushViewController:viewController animated:YES];
}

#pragma mark -- Set userObject delegate
-(void)doSetUserObject
{
    /// Set up the userObject in AppDelegate with the userObject values from LogIn
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate setUserObject:userObject];
    /// Store the userObject data in user defaults
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:userObject] forKey:@"userObject"];
    [defaults synchronize];
    [prgLoading dismiss];
    /// Post a local notification to trigger "userDidRequestSignIn".
    [[NSNotificationCenter defaultCenter] postNotificationName:@"userDidRequestSignIn" object:nil];
}

@end
