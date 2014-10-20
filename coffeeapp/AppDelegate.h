//
//  AppDelegate.h
//  coffeeapp
//
//  Created by Omar Guzmán on 10/17/14.
//  Copyright (c) 2014 crowdint. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserObject.h"

@class LoginViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) UINavigationController * navigationController;
@property (nonatomic, strong) LoginViewController * viewController;
@property (nonatomic, strong) UserObject *userObject;

@end
