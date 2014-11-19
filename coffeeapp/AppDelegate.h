//
//  AppDelegate.h
//  coffeeapp
//
//  Created by Omar Guzmán on 10/17/14.
//  Copyright (c) 2014 crowdint. All rights reserved.
//

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
@property (nonatomic, strong) UINavigationController * navigationController;
@property (nonatomic, strong) LoginViewController * mainViewController;
@property (nonatomic, strong) JASidePanelController * viewController;
@property (nonatomic, strong) UserObject *userObject;
@property (nonatomic, strong) OrderObject *orderObject;
@property (nonatomic, assign) BOOL isTestingEnv;
@property (nonatomic, strong) NSMutableDictionary * dictOrderNotification;
@property (nonatomic, strong) NSString * currentOrderNumber;
@property (nonatomic, assign) BOOL isMenuViewController;

@end
