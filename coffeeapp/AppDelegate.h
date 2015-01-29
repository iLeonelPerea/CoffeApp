//
//  AppDelegate.h
//  coffeeapp
//
//  Created by Omar Guzmán on 10/17/14.
//  Copyright (c) 2014 crowdint. All rights reserved.
//

/** @name AppDelegate
 */

#import <UIKit/UIKit.h>
#import <GooglePlus/GooglePlus.h>
#import "UserObject.h"
#import "LoginViewController.h"
#import "MenuViewController_iPhone.h"
#import "OrdersHistoryViewController.h"
#import "DBManager.h"
#import "OrderObject.h"

@class LoginViewController, JASidePanelController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

/** Navigation controller. */
@property (nonatomic, strong) UINavigationController * navigationController;

/** Login view controller. */
@property (nonatomic, strong) LoginViewController * mainViewController;

/** Lateral menu -view controller-. */
@property (nonatomic, strong) JASidePanelController * viewController;

/** User object, to store the data of the user logged in the app. */
@property (nonatomic, strong) UserObject *userObject;

/** Order object. */
@property (nonatomic, strong) OrderObject *orderObject;

/** Boolean flag to know is the requests will be sended to testing or production server. */
@property (nonatomic, assign) BOOL isTestingEnv;

/** Dictionary to store the data of the push notifications. */
@property (nonatomic, strong) NSMutableDictionary * dictOrderNotification;

/** Current order number. */
@property (nonatomic, strong) NSString * currentOrderNumber;

/** Boolean flag to know if the MenuViewController_iPhone is active. */
@property (nonatomic, assign) BOOL isMenuViewController;

/** Current menu active. */
@property (nonatomic, assign) int activeMenu;

@property (nonatomic, strong) NSString strCurrentHour;

/** Handle the receveid push notifications.
 
    Listen for push notifications in active or inactive state of the application.
    The list of notification can be received are.
    - Update order state. Modify the status of the order in ORDERSLOG table from the local database. And to inform the user the state of his order.
    - Update products stock. When a order is served in the CoffeeBoy app, the stock of the products from the current menu must be updated.
    - Category message. When a category is added/removed from the current menu.
    - Product message. When a product is added/removed from the current menu.
 
    @param userInfo Dictionary that contains the information of the notification. The content may vary according to the notification.
 */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;

/** Set the MenuViewController_iPhone as the view controller for the center panel -main screen-.
    
    @param notification It's not used.
 */
-(void)userDidRequestMenu:(NSNotification*)notification;

/** Set the OrdersHistoryViewController as the view controller for the center panel -main screen-.
 
    @param notification It's not used.
 */
-(void)userDidRequestOrders:(NSNotification*)notification;

/** Set mainViewController as the root view controller of the app.
 
    @param notification It's not used.
 */
-(void)userDidRequestSignOut:(NSNotification*)notification;

/** Set the view controller to display the left menu and the main screen controller after the user Logged In on the application.
 
    @param notification It's not used.
 */
-(void)userDidRequestSignIn:(NSNotification*)notification;

@end
