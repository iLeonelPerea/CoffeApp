//
//  LeftMenuViewController.h
//  coffeeapp
//
//  Created by Omar Guzmán on 10/22/14.
//  Copyright (c) 2014 crowdint. All rights reserved.
//

/** @name LeftMenuViewController
 
    Display the options menu of the app:
    - Menu
    - My Orders
 
    And the button for Sign Out.
 */
#import <UIKit/UIKit.h>
#import <GooglePlus/GooglePlus.h>
#import <GoogleOpenSource/GoogleOpenSource.h>
#import <NZCircularImageView.h>
#import "AppDelegate.h"

@interface LeftMenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

/** Outlet for an UITableView to display the options menu. */
@property (nonatomic, strong) IBOutlet UITableView * tblMenu;

/** Array to store the options of the menu. */
@property (nonatomic, strong) NSMutableArray * arrMenu;

/** Boolean flag to determine if the user is logged. */
@property (nonatomic, assign) BOOL isUserLogged;

/** Outlet for an UILabel to display the name of the user. */
@property (nonatomic, strong) IBOutlet UILabel * lblUser;

/** Outlet for an UIButton to do the Sign Out of the app. */
@property (nonatomic, strong) IBOutlet UIButton * btnSignOut;

/** Outlet for a circular image view container to display the image of the user. */
@property (nonatomic, strong) IBOutlet NZCircularImageView * imgUserProfile;

/** Outlet for an UILabel to display the title of the menu. */
@property (nonatomic, strong) IBOutlet UILabel * lblOptions;

/** Outlet for a HUD component to display loading messages. */
@property (nonatomic, strong) JGProgressHUD * HUD;

/** Do the Sign Out of the application.
 
    @param (id)sender It's not used.
 
    - SignOut from G+.
    - Revoke token.
    - Clean userObject data stored in user defaults.
    - Calls to set the main view controller to display.
    - Delete content of local DB tables.
 */
-(IBAction)doSignOut:(id)sender;
@end
