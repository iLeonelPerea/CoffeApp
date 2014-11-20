//
//  OrdersHistoryViewController.h
//  coffeeapp
//
//  Created by Crowd on 10/24/14.
//  Copyright (c) 2014 crowdint. All rights reserved.
//

/** @name OrdersHistoryViewController */

/** 
    This controller display all the orders from the user.
    
    There's to tabs:
        - Pending orders: All the orders placed or that are being attending.
        - Past orders: All the served orders.
    
    The information is from the ORDERSLOG table of local database.
 */

#import <UIKit/UIKit.h>
#import "DBManager.h"
#import <Parse/Parse.h>
#import "RESTManager.h"
#import "AppDelegate.h"
#import <JGProgressHUD.h>
#import <LMAlertView.h>

@interface OrdersHistoryViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

/** Outlet to display the title's background  */
@property (nonatomic, strong) IBOutlet UIImageView * imgPatron;

/** Outlet to set screen's title. Which is "Pending orders" or "Past orders" */
@property (nonatomic, strong) IBOutlet UILabel * lblTitle;

/** Outlet for TableView component where the orders's information is displayed */
@property (nonatomic, strong) IBOutlet UITableView * tblOrders;

/** Outlet for UIButton component. Which launch the action to display the orders in confirm or attending status  */
@property (nonatomic, strong) IBOutlet UIButton * btnIncomingOrders;

/** Outlet for UIButton component. Which launch the action to display the past _(complete)_ orders */
@property (nonatomic, strong) IBOutlet UIButton * btnPastOrders;

/** Array to store the orders to display on screen. It's content depends on which tab is selected */
@property (nonatomic, strong) NSMutableArray * arrOrders;

/** Boolean flat to indicate is the Pending Orders tab is active. 
    Also is used to set the param for the method that extracts the info from the local database when the app receives a push notification to update the user's order status */
@property (nonatomic, assign) BOOL isPendingOrdersSelected;

/** Outlet for the HUD component to display a _"loading"_ when some process is active */
@property (nonatomic, strong) JGProgressHUD * prgLoading;

/** Get and display all the orders in status "confirm" or "attendig".
    
    - Calls the method getOrdersHistory of the DBManager. When this method is called,
        the only param -withPastOrders- that it's required, is setted to NO.
    - Once the information is ready and stored in arrOrders, the table view is reloaded to display the data. 
    - The corresponding button is setted active.
    - The screen title is setted to "Pending Orders".
    - The flag isPendingOrdersSelected is setted in YES.
 
    @param (id)sender In this case this param is unused.
 */
-(IBAction)doShowPendingOrders:(id)sender;

/** Get and display all the orders in status "complete".
 
    - Calls the method getOrdersHistory of the DBManager. In this case, the required param -withPastOrders- is setted in YES.
    - Once the information is ready and stored in arrOrders, the table view is reloaded to display the data.
    - The corresponding button is setted active.
    - The screen title is setted to "Past Orders".
    - The flag isPendingOrdersSelected is setted in No.
 
    @param (id)sender In this case this param is unused.
 */
-(IBAction)doShowPastOrders:(id)sender;

@end
