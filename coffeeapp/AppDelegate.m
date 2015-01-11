//
//  AppDelegate.m
//  coffeeapp
//
//  Created by Omar Guzmán on 10/17/14.
//  Copyright (c) 2014 crowdint. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import <GooglePlus/GooglePlus.h>
#import <JASidePanelController.h>
#import "LeftMenuViewController.h"
#import "RESTManager.h"
#import <LMAlertView.h>


@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize userObject, orderObject, isTestingEnv, dictOrderNotification, currentOrderNumber, isMenuViewController;

/// Google App client ID. Created specifically for CoffeeApp
static NSString * const kClientID = @"1079376875634-shj8qu3kuh4i9n432ns8kspkl5rikcvv.apps.googleusercontent.com";

/// Set flag and other settings when the app finished launching.
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    /// Parse credentials and settings.
    [Parse setApplicationId:@"M9XmhjQ8B2iqs3CdNLASwl6hypCXnI8rRJLqFy0x" clientKey:@"6tCRkL9VyM3HQaUQIsduISATRURhHqLQ42ii9QJ4"];
    [PFUser enableAutomaticUser];
    PFACL * defaultACL = [PFACL ACL];
    [defaultACL setPublicReadAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    /// Set YES to identify when requests are done to a testing enviroment.
    isTestingEnv = NO;
    /// Set dafault value of NO to the flag to identify when MenuViewController_iPhone is active.
    isMenuViewController = NO;
    
    /// Set app's client ID for GPPSignIn and GPPShare.
    [[GPPSignIn sharedInstance] setClientID:kClientID];
    /// Initialize an empty UserObject instance.
    userObject = [[UserObject alloc] init];
    orderObject = [[OrderObject alloc] init];
    
    /// Extract the userObject data from user defaults.
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSData * data = [defaults objectForKey:@"userObject"];
    UserObject * tmpUserObject = [[UserObject alloc] init];
    tmpUserObject = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    /// If exist userObject data from user defaults, is assigned into AppDelegate's userObject.
    if (tmpUserObject != nil) {
        userObject = tmpUserObject;
        orderObject.userObject = userObject;
    }
    
    [self setWindow:[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]]];
    /// Set the mainViewController property.
    [self setMainViewController:[[LoginViewController alloc] init]];
    /// Set the left panel.
    /// Override point for customization after application launch.
    [self setViewController: [[JASidePanelController alloc] init]];
    [[self viewController] setLeftPanel:[[LeftMenuViewController alloc] init]];
    [[self viewController] setLeftPanel:[[self viewController] leftPanel]];
    [[self viewController] setLeftFixedWidth:270];
    [[self viewController] setCenterPanel:[[UINavigationController alloc] initWithRootViewController:[[MenuViewController_iPhone alloc] init]]];

    /// Navigation bar customization.
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:4.0f/255.0f green:130.0f/255.0f blue:118.0f/255.0f alpha:1.0f]];

    /// Set navigation buttom color, set back button color, set back button arrow color.
    [[UINavigationBar appearanceWhenContainedIn:[UINavigationController class], nil] setTintColor:[UIColor whiteColor]];
    
    /// Check if the user is logged to set the root view controller. If is true, show the menu with the left side panel, in other case, show Login view controller.
    if ([[userObject userSpreeToken] isEqual:@""]) {
        [[self window] setRootViewController:[self mainViewController]];
    }else{
        [[self window] setRootViewController:[self viewController]];
    }
    [self.window makeKeyAndVisible];
    
    if (application.applicationState != UIApplicationStateBackground) {
        /// Track an app open here if we launch with a push, unless
        /// "content_available" was used to trigger a background push (introduced in iOS 7).
        /// In that case, we skip tracking here to avoid double counting the app-open.
        BOOL preBackgroundPush = ![application respondsToSelector:@selector(backgroundRefreshStatus)];
        BOOL oldPushHandlerOnly = ![self respondsToSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)];
        BOOL noPushPayload = ![launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (preBackgroundPush || oldPushHandlerOnly || noPushPayload) {
            [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
        }
    }
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    } else
#endif
    {
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert |UIRemoteNotificationTypeSound)];
    }
    
    //Add the notifications for menu's options
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidRequestMenu:) name:@"userDidRequestMenu" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidRequestOrders:) name:@"userDidRequestOrders" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidRequestSignOut:) name:@"userDidRequestSignOut" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidRequestSignIn:) name:@"userDidRequestSignIn" object:nil];
    
    [DBManager checkOrCreateDataBase];
    
    return YES;
}


#pragma mark -- Menu options methods
-(void)userDidRequestMenu:(NSNotification*)notification
{
    /// Menu view controoler
    [[self viewController] setCenterPanel:[[UINavigationController alloc] initWithRootViewController:[[MenuViewController_iPhone alloc] init]]];
}

-(void)userDidRequestOrders:(NSNotification*)notification
{
    /// Orders history view controller
    [[self viewController] setCenterPanel:[[UINavigationController alloc] initWithRootViewController:[[OrdersHistoryViewController alloc] init]]];
}

-(void)userDidRequestSignOut:(NSNotification*)notification
{
    /// Login view controller
    [[self window] setRootViewController:[self mainViewController]];
}

-(void)userDidRequestSignIn:(NSNotification*)notification
{
    /// Left panel with menu view controller
    [[self viewController] setCenterPanel:[[UINavigationController alloc] initWithRootViewController:[[MenuViewController_iPhone alloc] init]]];
    [[self window] setRootViewController:[self viewController]];
}

/// Register the app for remote notifications -Parse-.
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken {
    [PFPush storeDeviceToken:newDeviceToken];
}

/// Informs when the aplicattion could'nt be registered for remote notitications.
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    if (error.code == 3010) {
        NSLog(@"Push notifications are not supported in the iOS Simulator.");
    } else {
        /// show some alert or otherwise handle the failure to register.
        NSLog(@"application:didFailToRegisterForRemoteNotificationsWithError: %@", error);
    }
}

/// Handles the received notifications.
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    /// Check if the notification was received while the apps was in background.
    if (application.applicationState == UIApplicationStateInactive) {
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
        /// Check for the content of the notification to identify the operation to make.
        if ([[userInfo objectForKey:@"state"] isEqual:@"attending"] || [[userInfo objectForKey:@"state"] isEqual:@"complete"] || [[userInfo objectForKey:@"state"] isEqual:@"completeWithOutOfStock"]){
            /// Store the user info to update the order status when the app become active
            NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:userInfo] forKey:@"userInfo"];
            [defaults synchronize];
        }
        if([[userInfo objectForKey:@"msg"] isEqual:@"complete notification"]){
            ///Extract the data of order products
            NSArray * arrProducts = [[NSArray alloc] initWithArray:[userInfo objectForKey:@"data"]];
            NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:arrProducts] forKey:@"dataCompleteNotification"];
            [defaults setObject:@"complete notification" forKey:@"msg"];
            [defaults synchronize];
        }
    }
    
    /// Check for the content of the notification to identify the operation to make.
    if ([[userInfo objectForKey:@"state"] isEqual:@"attending"] || [[userInfo objectForKey:@"state"] isEqual:@"complete"] || [[userInfo objectForKey:@"state"] isEqual:@"completeWithOutOfStock"]) {
        
        /// Create a custom alert view to display the info about the notification received.
        LMAlertView * alertView = [[LMAlertView alloc] initWithTitle:@"" message:nil delegate:self cancelButtonTitle:@"Ok, Thanks" otherButtonTitles:nil];
        [alertView setSize:CGSizeMake(200.0f, 320.0f)];
        
        /// Create and add the content of the aler view.
        UIView *contentView = alertView.contentView;
        [contentView setBackgroundColor:[UIColor clearColor]];
        [alertView setBackgroundColor:[UIColor clearColor]];        
        UIImageView * imgV = [[UIImageView alloc] initWithFrame:CGRectMake(35.5f, 10.0f, 129.0f, 200.0f)];
        [imgV setImage:([[userInfo objectForKey:@"state"] isEqual:@"attending"])?[UIImage imageNamed:@"illustration_01"]:([[userInfo objectForKey:@"state"] isEqual:@"complete"])?[UIImage imageNamed:@"illustration_02"]:[UIImage imageNamed:@"illustration_00"]];
        [contentView addSubview:imgV];
        UILabel * lblStatus = [[UILabel alloc] initWithFrame:CGRectMake(10, 170, 180, 120)];
        lblStatus.numberOfLines = 3;
        [lblStatus setFont:[UIFont fontWithName:@"Lato-Regular" size:16]];
        [lblStatus setTextAlignment:NSTextAlignmentCenter];
        lblStatus.text = ([[userInfo objectForKey:@"state"] isEqual:@"completeWithOutOfStock"])?[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]:[NSString stringWithFormat:@"%@ Your order is %@", userObject.firstName, [userInfo objectForKey:@"state"]];
        [contentView addSubview:lblStatus];
        [alertView show];
        
        /// Update the state of the order in the ORDERSLOG table of the local database.
        [DBManager updateStateOrderLog:[userInfo objectForKey:@"orderId"] withState:([[userInfo objectForKey:@"state"] isEqual:@"completeWithOutOfStock"])?@"complete":[userInfo objectForKey:@"state"]];
        /// Post a local notification to trigger the doRefreshOrdersHistory method.
        [[NSNotificationCenter defaultCenter] postNotificationName:@"doRefreshOrdersHistory" object:nil];
    }
    if([[userInfo objectForKey:@"msg"] isEqual:@"complete notification"] && isMenuViewController){
        /// Extract the data of order products.
        NSArray * arrProducts = [[NSArray alloc] initWithArray:[userInfo objectForKey:@"data"]];
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:arrProducts] forKey:@"dataCompleteNotification"];
        [defaults setObject:@"complete notification" forKey:@"msg"];
        [defaults synchronize];
        /// Post a local notification to update products stock after an order is served.
        [[NSNotificationCenter defaultCenter] postNotificationName:@"doUpdateProductsStockAfterNotification" object:nil];
    }
    if ([[userInfo objectForKey:@"categoryMessage"] isEqual:@"YES"] && isMenuViewController){
        /// Post a local notification to update the menu without loading menu view controller.
        [[NSNotificationCenter defaultCenter] postNotificationName:@"doUpdateMenu" object:nil];
    }

    if ([[userInfo objectForKey:@"categoryMessage"] isEqual:@"DELETE"] && isMenuViewController){
        /// Clean the array arrProductsInQueue in the user defaults.
        NSUserDefaults *defaults =  [NSUserDefaults standardUserDefaults];
        [defaults setObject:nil forKey:@"arrProductsInQueue"];
        [defaults synchronize];
        /// Post a local notification to update the menu without loading menu view controller.
        [[NSNotificationCenter defaultCenter] postNotificationName:@"doUpdateMenu" object:nil];
    }
    if ([userInfo objectForKey:@"productMessage"] && isMenuViewController){
        /// Extract the data from user defaults to store it in arrProductsInQueue.
        NSUserDefaults *defaults =  [NSUserDefaults standardUserDefaults];
        NSData *data = [defaults objectForKey:@"arrProductsInQueue"];
        NSMutableArray *arrOrderSelectedProducts = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        /// Check is there's prodcuts selected by user.
        NSMutableArray *newArrOrderSelectedProducts = [[NSMutableArray alloc] init];
        for (ProductObject *orderSelectedProduct in arrOrderSelectedProducts) {
            if (orderSelectedProduct.product_id != [[userInfo objectForKey:@"productMessage"]integerValue] ) {
                [newArrOrderSelectedProducts addObject:orderSelectedProduct];
            }
        }
        [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:newArrOrderSelectedProducts] forKey:@"arrProductsInQueue"];
        [defaults synchronize];
        /// Post a local notification to update the menu without loading menu view controller.
        [[NSNotificationCenter defaultCenter] postNotificationName:@"doUpdateMenu" object:nil];
    }
    if ([[userInfo objectForKey:@"state"] isEqual:@"in-progress"]) {
        
        /// Create a custom alert view to display the info about the notification received.
        LMAlertView * alertView = [[LMAlertView alloc] initWithTitle:@"" message:nil delegate:self cancelButtonTitle:@"Wait a second..." otherButtonTitles:nil];
        [alertView setSize:CGSizeMake(200.0f, 320.0f)];
        
        /// Create and add the content of the aler view.
        UIView *contentView = alertView.contentView;
        [contentView setBackgroundColor:[UIColor clearColor]];
        [alertView setBackgroundColor:[UIColor clearColor]];
        UIImageView * imgV = [[UIImageView alloc] initWithFrame:CGRectMake(35.5f, 10.0f, 129.0f, 200.0f)];
        [imgV setImage:[UIImage imageNamed:@"illustration_06"]];
        [contentView addSubview:imgV];
        UILabel * lblStatus = [[UILabel alloc] initWithFrame:CGRectMake(10, 170, 180, 120)];
        lblStatus.numberOfLines = 3;
        [lblStatus setFont:[UIFont fontWithName:@"Lato-Regular" size:16]];
        [lblStatus setTextAlignment:NSTextAlignmentCenter];
        NSMutableDictionary * alert = [userInfo objectForKey:@"aps"];
        lblStatus.text = [alert objectForKey:@"alert"];
        [contentView addSubview:lblStatus];
        [alertView show];
    }
}

///////////////////////////////////////////////////////////
// Uncomment this method if you want to use Push Notifications with Background App Refresh
///////////////////////////////////////////////////////////
/*
 - (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
 if (application.applicationState == UIApplicationStateInactive) {
 [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
 }
 }
 */

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state.
     This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message)
     or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates.
     Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state
     information to restore your application to its current state in case it is terminated later.
     If your application supports background execution,
     this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    /// Post a notification to update the information in the menu.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"doUpdateMenu" object:nil];
}

/// Look for the push notifications that were received while the application was in backgroud.
/// Update order state and update products stock are the notification to look up.
- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    /// Create a variable for user defaults.
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSData * data = [defaults objectForKey:@"userInfo"];
    NSMutableDictionary * dictUserInfo = [[NSMutableDictionary alloc] init];
    dictUserInfo = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    /// Check for the content of the values on user defaults to identify which notification was received when the app was in backgroud.
    if ([[dictUserInfo objectForKey:@"state"] isEqual:@"attending"] || [[dictUserInfo objectForKey:@"state"] isEqual:@"complete"] || [[dictUserInfo objectForKey:@"state"] isEqual:@"completeWithOutOfStock"]){
        /// Update the order status in ORDERSLOG table of the local database.
        [DBManager updateStateOrderLog:[dictUserInfo objectForKey:@"orderId"] withState:([[dictUserInfo objectForKey:@"state"] isEqual:@"completeWithOutOfStock"])?@"complete":[dictUserInfo objectForKey:@"state"]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"doRefreshOrdersHistory" object:nil];
        /// Set to nil the value of the dictionary userInfo in user defaults.
        [defaults setObject:nil forKey:@"userInfo"];
    }
    
    /// Check if the order is complete to update products stock.
    if ([[defaults objectForKey:@"msg"] isEqual:@"complete notification"]) {
        /// Post a local notification to update the stock of the products of the current menu.
        [[NSNotificationCenter defaultCenter] postNotificationName:@"doUpdateProductsStockAfterNotification" object:nil];
    }
    [defaults synchronize];
    dictUserInfo = nil;
}

/// Operations to be done before the application is terminate. It's no used for this app.
- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

#pragma mark - ()
- (void)subscribeFinished:(NSNumber *)result error:(NSError *)error {
    if ([result boolValue]) {
        NSLog(@"ParseStarterProject successfully subscribed to push notifications on the broadcast channel.");
    } else {
        NSLog(@"ParseStarterProject failed to subscribe to push notifications on the broadcast channel.");
    }
}

#pragma mark -- GPPSigIn delegate
- (BOOL)application: (UIApplication *)application openURL: (NSURL *)url sourceApplication: (NSString *)sourceApplication annotation: (id)annotation
{
    return [GPPURLHandler handleURL:url sourceApplication:sourceApplication annotation:annotation];
}

@end
