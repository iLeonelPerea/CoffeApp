//
//  OrdersHistoryViewController.m
//  coffeeapp
//
//  Created by Crowd on 10/24/14.
//  Copyright (c) 2014 crowdint. All rights reserved.
//

#import "OrdersHistoryViewController.h"

/// Macros to identify size screen
#define IS_IPHONE_5 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)568) < DBL_EPSILON)
#define IS_IPHONE_6 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)667) < DBL_EPSILON)
#define IS_IPHONE_6_PLUS (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)736) < DBL_EPSILON)

@interface OrdersHistoryViewController ()

@end

@implementation OrdersHistoryViewController
@synthesize imgPatron, lblTitle, tblOrders, btnIncomingOrders, btnPastOrders, arrOrders, isPendingOrdersSelected, prgLoading;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    /// Clean Orderslog table from local DB, delete orders in confirm or attending status from days before the current date
    [DBManager deleteUnattendedOrders];
    
    /** Set the loading HUD */
    prgLoading = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    [[prgLoading textLabel] setText:@"Cancelling..."];
    
    /** Set delegate and datasource for Table view controller */
    [tblOrders setDelegate:self];
    [tblOrders setDataSource:self];
    
    /** Create and set the title label for the navigation bar */
    UILabel * lblControllerTitle = [[UILabel alloc] init];
    [lblControllerTitle setFrame:CGRectMake(0, 0, 140, 50)];
    [lblControllerTitle setText:@"The Crowd's Chef"];
    [lblControllerTitle setFont:[UIFont fontWithName:@"Lato-Light" size:20]];
    [lblControllerTitle setTextColor:[UIColor whiteColor]];
    [[self navigationItem] setTitleView:lblControllerTitle];
    
    /** Set screen's title label to "Pending orders" */
    [lblTitle setText:@"PENDING ORDERS"];
    [lblTitle setFont:[UIFont fontWithName:@"Lato-Bold" size:18]];
    [lblTitle setTextColor:[UIColor colorWithRed:84.0f/255.0f green:84.0f/255.0f blue:84.0f/255.0f alpha:1.0f]];
    
    /** Get the orders information, init with the orders in status "confirm" or "attending" */
    arrOrders = [DBManager getOrdersHistory:NO];
    
    /** Flag is setted in YES */
    isPendingOrdersSelected = YES;
    
    /** Create an observer to trigger a refresh of the screen when is active and one of the orders is attended or served */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doRefreshOrdersHistory:) name:@"doRefreshOrdersHistory" object:nil];
}

/** Set the components to fit in iPhone's differents screen sizes */
-(void)viewDidAppear:(BOOL)animated
{
    /** The components are setted to fit the screen size according their proportions. Fits to iPhone 4/4S/5/5S/6, 6 plus is not supported yet */
    [imgPatron setFrame:(IS_IPHONE_6)?CGRectMake(0, 64, 375, 50):CGRectMake(0, 64, 320, 50)];
    [lblTitle setFrame:(IS_IPHONE_6)?CGRectMake(20, 64, 375, 50):CGRectMake(20, 64, 320, 50)];
    [btnIncomingOrders setFrame:(IS_IPHONE_6)?CGRectMake(0, 611, 188, 56):(IS_IPHONE_5)?CGRectMake(0, 520, 160, 48):CGRectMake(0, 432, 160, 48)];
    [btnPastOrders setFrame:(IS_IPHONE_6)?CGRectMake(189, 611, 188, 56):(IS_IPHONE_5)?CGRectMake(161, 520, 159, 48):CGRectMake(161, 432, 159, 48)];
    [tblOrders setFrame:(IS_IPHONE_6)?CGRectMake(0, 110, 375, 501):(IS_IPHONE_5)?CGRectMake(0, 110, 320, 410):CGRectMake(0, 110, 320, 362)];
}

/** System method */
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- Refresh orders history after push notification
-(void)doRefreshOrdersHistory:(id)sender
{
    /** Check flag isPendingOrdersSelected to determine the value of the param required for DBManager's getOrdersHistory method 
        When is YES, get the past orders, in other case get the orders in status "confirm" or "attending".
     */
    if (isPendingOrdersSelected) {
        arrOrders = [DBManager getOrdersHistory:NO];
    }else{
        arrOrders = [DBManager getOrdersHistory:YES];
    }
    /** Reload table view to display info */
    [tblOrders reloadData];
}

#pragma mark -- Table view delegate
/// Return the height for the rows
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 23;
}

/// Return the numbers of section on the table from the number of elements in arrOrders
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [arrOrders count]; // Save the count of sections
}

/// Return the numbers of rows based on the elements in each sub-array "ORDER_DETAIL" in the main array arrOrders
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[[arrOrders objectAtIndex:section] objectForKey:@"ORDER_DETAIL"] count];
}

/// Return the height of the header section
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}

/// Draw the header's content with order's date and label when the order is being attended
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    /// Create a UIView component to store all the header's content
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,  tableView.bounds.size.width, 50)];
    [headerView setBackgroundColor:[UIColor whiteColor]];
    NSMutableDictionary * dictOrderHeader = [arrOrders objectAtIndex:section];
    
    /// Create and set a UILabel to display the order's date
    UILabel * lblSectionTitle = [[UILabel alloc] init];
    [lblSectionTitle setFrame:(IS_IPHONE_6)?CGRectMake(20, 15, 335, 30):CGRectMake(20, 15, 280, 30)];
    [lblSectionTitle setNumberOfLines:2];
    [lblSectionTitle setText:[dictOrderHeader objectForKey:@"ORDER_DATE"]];
    [lblSectionTitle setFont:[UIFont fontWithName:@"Lato-Light" size:(IS_IPHONE_6)?17:15]];
    [lblSectionTitle setTextColor:[UIColor colorWithRed:84.0f/255.0f green:84.0f/255.0f blue:84.0f/255.0f alpha:1.0f]];
    [headerView addSubview:lblSectionTitle];
    
    /// Check the status of the order to add a delete icon when the order is in "confirm" or a label when is in "attendind"
    if ([[dictOrderHeader objectForKey:@"ORDER_STATUS"] isEqual:@"attending"]) {
        UIImageView * imgLabel = [[UIImageView alloc] initWithFrame:(IS_IPHONE_6)?CGRectMake(305, 0, 70, 70):CGRectMake(250, 0, 70, 70)];
        [imgLabel setImage:[UIImage imageNamed:@"label.png"]];
        [headerView addSubview:imgLabel];
    }else if ([[dictOrderHeader objectForKey:@"ORDER_STATUS"] isEqual:@"confirm"]) {
        UIButton * btnCancel = [[UIButton alloc] initWithFrame:(IS_IPHONE_6)?CGRectMake(330, 9, 40, 40):CGRectMake(275, 9, 40, 40)];
        [btnCancel setImage:[UIImage imageNamed:@"delete_order_btn_up"] forState:UIControlStateNormal];
        [btnCancel setImage:[UIImage imageNamed:@"delete_order_btn_down"] forState:UIControlStateHighlighted];
        [headerView addSubview:btnCancel];
        
        [btnCancel addTarget:self action:@selector(doCancelOrder:) forControlEvents:UIControlEventTouchUpInside];
        [btnCancel setTag:section];
    }

    return headerView;
}

/// Draw the cell with the elements of each order and the quantity of each of them.
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /// Create and define de style of the cell
    static NSString *CellIdentifier = @"CellProduct";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = nil;
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    /// --------- Product name
    UILabel *lblName = [[UILabel alloc] initWithFrame:(IS_IPHONE_6)?CGRectMake(20, 0, 335, 23):CGRectMake(20, 0, 280, 23)];
    [[[[arrOrders objectAtIndex:[indexPath section]] objectForKey:@"ORDER_DETAIL"] objectAtIndex:[indexPath row]] objectForKey:@"PRODUCT_QUANTITY_ORDERED"];
    [lblName setText:[NSString stringWithFormat:@"%@ %@",[[[[arrOrders objectAtIndex:[indexPath section]] objectForKey:@"ORDER_DETAIL"] objectAtIndex:[indexPath row]] objectForKey:@"PRODUCT_QUANTITY_ORDERED"],[(NSString*)[[[[arrOrders objectAtIndex:[indexPath section]] objectForKey:@"ORDER_DETAIL"] objectAtIndex:[indexPath row]] objectForKey:@"PRODUCT_NAME"] capitalizedString]]];
    [lblName setFont:[UIFont fontWithName:@"Lato-Regular" size:15]];
    [lblName setTextColor:[UIColor colorWithRed:84.0f/255.0f green:84.0f/255.0f blue:84.0f/255.0f alpha:1.0f]];
    [lblName setTextAlignment:NSTextAlignmentLeft];
    [cell addSubview:lblName];
    
    return cell;
}

#pragma mark -- Cancel order action
-(void)doCancelOrder:(id)sender
{
    /// Show an HUD
    dispatch_async(dispatch_get_main_queue(),^{
        [(UIButton*)sender setEnabled:NO];
        [prgLoading showInView:[self view]];
    });
    
    /// Extract the information from the arrOrders
    UIButton * senderButton = (UIButton *)sender;
    NSMutableDictionary * dictOrder = [arrOrders objectAtIndex:[senderButton tag]];

    /// Create a variable of AppDelegate
    AppDelegate * appDelegate = [[UIApplication sharedApplication] delegate];
    /// Call spree to cancel the order
    [RESTManager sendData:nil toService:[NSString stringWithFormat:@"orders/%@/cancel",[dictOrder objectForKey:@"ORDER_ID"]] withMethod:@"PUT" isTesting:[appDelegate isTestingEnv]
          withAccessToken:[[appDelegate userObject] userSpreeToken] isAccessTokenInHeader:YES toCallback:^(id result) {
              
              /// Check for the final state of the request. If it is negative display a custom alert to inform the user and escape from the code block
              if([[result objectForKey:@"success"] isEqual:@NO])
              {
                  /// Create an instance of a custom alert
                  LMAlertView * alertView = [[LMAlertView alloc] initWithTitle:@"" message:nil delegate:self cancelButtonTitle:@"Service Error!" otherButtonTitles:nil];
                  [alertView setSize:CGSizeMake(200.0f, 320.0f)];
                  
                  /// Create a UIView to store all the components of the alert
                  UIView *contentView = alertView.contentView;
                  [contentView setBackgroundColor:[UIColor clearColor]];
                  [alertView setBackgroundColor:[UIColor clearColor]];
                  /// Create an set the image for the alert
                  UIImageView * imgV = [[UIImageView alloc] initWithFrame:CGRectMake(35.5f, 10.0f, 129.0f, 200.0f)];
                  [imgV setImage:[UIImage imageNamed:@"illustration_05"]];
                  [contentView addSubview:imgV];
                  ///Create and set the label of the alert's message
                  UILabel * lblStatus = [[UILabel alloc] initWithFrame:CGRectMake(10, 170, 180, 120)];
                  lblStatus.numberOfLines = 3;
                  [lblStatus setFont:[UIFont fontWithName:@"Lato-Regular" size:16]];
                  [lblStatus setTextAlignment:NSTextAlignmentCenter];
                  lblStatus.text = [result objectForKey:@"message"];
                  [contentView addSubview:lblStatus];
                  /// Display the alert
                  [alertView show];
                  
                  /// If the HUD is still active, is dimissed
                  if(prgLoading)
                     [prgLoading dismissAnimated:YES];
                  return;
              }

              /// Check if the result retrieve state cancel... actually is result answer right
              if ([[result objectForKey:@"state"] isEqual:@"canceled"]) {
                  /// Send the a push notification to CoffeeBoy App
                  NSDictionary *data = @{
                                         @"sound": @"default",
                                         @"action": @"cancelOrder"
                                         };
                  /// Create and set the push notification to send it to the CoffeeBoy App
                  PFPush *push = [[PFPush alloc] init];
                  [push setChannel:@"requests"];
                  [push setData:data];
                  [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                      if(!succeeded)
                      {
                          UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Error in Push Notification" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                          [alert show];
                      }
                  }];
                  /// Delete the order from local DB
                  [DBManager deleteOrderLog:[dictOrder objectForKey:@"ORDER_ID"]];
                  /// Post a local notification to refresh the OrderViewController if the user is in that controller
                  [prgLoading dismiss];
                  [[NSNotificationCenter defaultCenter] postNotificationName:@"doRefreshOrdersHistory" object:nil];
              }
        }];
}

#pragma mark -- Buttons actions
-(void)doShowPastOrders:(id)sender
{
    /// Get the past orders
    arrOrders = [DBManager getOrdersHistory:YES];
    /// Set the title and buttons's images
    [tblOrders reloadData];
    [lblTitle setText:@"PAST ORDERS"];
    [btnIncomingOrders setImage:[UIImage imageNamed:@"neworders_btn_up.png"] forState:UIControlStateNormal];
    [btnPastOrders setImage:[UIImage imageNamed:@"history_btn_selected.png"] forState:UIControlStateNormal];
    /// Set flag in NO
    isPendingOrdersSelected = NO;
}

-(void)doShowPendingOrders:(id)sender
{
    /// Get the pending orders
    arrOrders = [DBManager getOrdersHistory:NO];
    /// Set the titles and buttons
    [tblOrders reloadData];
    [lblTitle setText:@"PENDING ORDERS"];
    [btnIncomingOrders setImage:[UIImage imageNamed:@"neworders_btn_selected.png"] forState:UIControlStateNormal];
    [btnPastOrders setImage:[UIImage imageNamed:@"history_btn_up.png"] forState:UIControlStateNormal];
    /// Set flag in YES
    isPendingOrdersSelected = YES;
}

@end
