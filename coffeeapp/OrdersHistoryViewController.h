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

    @param (id)sender In this case this param is unused.
 
    - Calls the method getOrdersHistory of the DBManager. When this method is called,
        the only param -withPastOrders- that it's required, is setted to NO.
    - Once the information is ready and stored in arrOrders, the table view is reloaded to display the data. 
    - The corresponding button is setted active.
    - The screen title is setted to "Pending Orders".
    - The flag isPendingOrdersSelected is setted in YES.
 */
-(IBAction)doShowPendingOrders:(id)sender;

/** Get and display all the orders in status "complete".
 
    @param (id)sender In this case this param is unused.
 
    - Calls the method getOrdersHistory of the DBManager. In this case, the required param -withPastOrders- is setted in YES.
    - Once the information is ready and stored in arrOrders, the table view is reloaded to display the data.
    - The corresponding button is setted active.
    - The screen title is setted to "Past Orders".
    - The flag isPendingOrdersSelected is setted in No.
*/
-(IBAction)doShowPastOrders:(id)sender;

/** Refresh the table view controller

    @param (id)sender In this case this param is unused.
 
    When a push notificationis received to infrom about and update on the order status. This method refresh the content of the table view.
    First check the value of the flag isPendingOrdersSelected to determine the param to call DBManager's getOrdersHistory.
    Once the information is ready, the tableview is refreshed to display the updated information.
 
*/
-(IBAction)doRefreshOrdersHistory:(id)sender;

/** Cancel order
 
    @param  (id)sender Receives a UIButton element.
 
    - Only orders with status in "confirm" can be canceled.
    - Whith the value received on sender, takes the tag value as a index for arrOrders.
    - Create a dictionary based on the array index.
    - Send a request via RESTManager to spree, Send thr ORDER_ID stored in the dictionary to service "/cancel"
    - When spree response. Check for error in the request. If it is an error create a custom alert to display and return to normal app flow.
    - In the case of non negative response, check for canceled state in result dictionary. Create a push notification to be sended to the CoffeeBoy,
        with action setted in "cancelOrder" and sound in "default".
    - Call to DBManager's method deleteOrderLog, sending as parameter the "ORDER_ID" value stored in dictOrder.
    - Dismiss the HUD element and return to the normal app flow.
 
 */
-(IBAction)doCancelOrder:(id)sender;

@end
