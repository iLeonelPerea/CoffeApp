//
//  ShoppingCartViewController.h
//  GastronautBase
//
//  Copyright (c) 2014 CrowdInt. All rights reserved.
//

/** @name ShoppingCartViewController.

    In this controller the user can make the order -checkout proccess- or cancel -return to the menu-.
 */

#import <UIKit/UIKit.h>
#import <BDBPopupViewController/UIViewController+BDBPopupViewController.h>
#import <JGProgressHUD.h>
#import "MenuViewController_iPhone.h"
#import "RESTManager.h"
#import "ProductObject.h"
#import "RESTManager.h"
#import "AppDelegate.h"
#import <LMAlertView.h>

@interface ShoppingCartViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

/** Outlet to set the screen's title. */
@property (nonatomic, strong) IBOutlet UIImageView * imgTitle;

/** Outlet to set the background of the botton bar of the screen. */
@property (nonatomic, strong) IBOutlet UIImageView * imgBottomBar;

/** Outlet for an UIButton to make the order. */
@property (nonatomic, strong) IBOutlet UIButton *btnCheckOut;

/** Outlet for an UIButton to cancel -return to the menu-. */
@property (nonatomic, strong) IBOutlet UIButton *btnEmptyShoppingCart;

/** Outlet for an UILabel to display the current date. */
@property (nonatomic, strong) IBOutlet UILabel *lblDate;

/** Outlet for an UILabel to display a disclaimer message. */
@property (nonatomic, strong) IBOutlet UILabel *lblDisclaimer;

/** Outlet for a tebla view component, which display the items selected by user.  */
@property (nonatomic, strong) IBOutlet UITableView *tblProducts;

/** Mutable array to store the items selected for the order. */
@property (nonatomic, strong) NSMutableArray *arrProductsShoppingCart;

/** Outlet for a HUD to display laoding messages. */
@property (nonatomic, strong) JGProgressHUD * HUDJMProgress;

/** Timer to trigger the cancel method after 20 minutes of inactivity. */
@property (nonatomic, strong) NSTimer *tmrOrder;

/** Dismiss the current view controller. 
 
    @param (id)sender It's no used.
 */
-(IBAction)doDismissShoppingCart:(id)sender;

/** Place order.
    
    @param (id)sender It's not used.
    
    - Extract the selected products and create a dictionary for each one, which is added to an array. It will be setted to the OrderObject in AppDelegate to prepare the order petition.
    - Requeste to spree to make the order, based on the data of getOrder from the UserObject in AppDelegate.
    - Check for the result of the request.
    - Insert in the local database the log if the request was succeded.
    - Post a notification to CoffeeBoy app, to informa about a new order maded.
    - Dismiss the current view controller to return to the menu.
 */
-(IBAction)doPlaceOrder:(id)sender;

/** Post a notification to CoffeBoy App.
 
    @param orderNumber The ORDER_ID of the order maded.
    @param andOrderToken Token generated by spree for the order maded.
 
    Send a notification for the CoffeeBoy app to inform about a new order maded.
    - Set the data to be sended.
    - Send the notification via "Requests" channel.
 */
-(void)doPostPushNotificationWithOrderNumber:(NSString*)orderNumber andOrderToken:(NSString*)orderToken;

/** Dismiss the ShoppingCartViewController and cancell the checkout proccess.
 
    @param (id)sender It's not used.
 */
-(IBAction)doCancel:(id)sender;
@end
