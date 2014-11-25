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


@end
