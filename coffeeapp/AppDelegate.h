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
//#import "LoginViewController.h"
#import "MenuViewController_iPhone.h"
#import "DBManager.h"
#import "RESTManager.h"

@class MenuViewController_iPhone;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) UINavigationController * navigationController;
//@property (nonatomic, strong) LoginViewController * viewController;
@property (nonatomic, strong) MenuViewController_iPhone *menuViewController;
@property (nonatomic, strong) UserObject *userObject;

@end
