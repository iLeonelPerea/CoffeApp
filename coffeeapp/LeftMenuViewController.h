//
//  LeftMenuViewController.h
//  coffeeapp
//
//  Created by Omar Guzmán on 10/22/14.
//  Copyright (c) 2014 crowdint. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GooglePlus/GooglePlus.h>
#import <GoogleOpenSource/GoogleOpenSource.h>
#import <NZCircularImageView.h>
#import "AppDelegate.h"

@interface LeftMenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) IBOutlet UITableView * tblMenu;
@property (nonatomic, strong) NSMutableArray * arrMenu;
@property (nonatomic, assign) BOOL isUserLogged;
@property (nonatomic, strong) IBOutlet UILabel * lblUser;
@property (nonatomic, strong) IBOutlet UIButton * btnSignOut;
@property (nonatomic, strong) IBOutlet NZCircularImageView * imgUserProfile;
@property (nonatomic, strong) JGProgressHUD * HUD;
// methods
-(IBAction)doSignOut:(id)sender;
@end
