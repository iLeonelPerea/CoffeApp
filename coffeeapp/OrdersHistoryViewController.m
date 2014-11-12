//
//  OrdersHistoryViewController.m
//  coffeeapp
//
//  Created by Crowd on 10/24/14.
//  Copyright (c) 2014 crowdint. All rights reserved.
//

#import "OrdersHistoryViewController.h"

//Macros to identify size screen
#define IS_IPHONE_5 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)568) < DBL_EPSILON)
#define IS_IPHONE_6 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)667) < DBL_EPSILON)
#define IS_IPHONE_6_PLUS (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)736) < DBL_EPSILON)

@interface OrdersHistoryViewController ()

@end

@implementation OrdersHistoryViewController
@synthesize imgPatron, lblTitle, tblOrders, btnIncomingOrders, btnPastOrders, arrOrders, isPendingOrdersSelected;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [tblOrders setDelegate:self];
    [tblOrders setDataSource:self];
    
    UILabel * lblControllerTitle = [[UILabel alloc] init];
    [lblControllerTitle setFrame:CGRectMake(0, 0, 140, 50)];
    [lblControllerTitle setText:@"The Crowd's Chef"];
    [lblControllerTitle setFont:[UIFont fontWithName:@"Lato-Light" size:20]];
    [lblControllerTitle setTextColor:[UIColor whiteColor]];
    [[self navigationItem] setTitleView:lblControllerTitle];
    
    //Get orders information, init with new orders
    [lblTitle setText:@"PENDING ORDERS"];
    [lblTitle setFont:[UIFont fontWithName:@"Lato-Light" size:20]];
    arrOrders = [DBManager getOrdersHistory:NO];
    isPendingOrdersSelected = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doRefreshOrdersHistory:) name:@"doRefreshOrdersHistory" object:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    //Fit to screen size
    [imgPatron setFrame:(IS_IPHONE_6)?CGRectMake(0, 64, 375, 50):CGRectMake(0, 64, 320, 50)];
    [lblTitle setFrame:(IS_IPHONE_6)?CGRectMake(20, 64, 375, 50):CGRectMake(20, 64, 320, 50)];
    [btnIncomingOrders setFrame:(IS_IPHONE_6)?CGRectMake(0, 611, 188, 56):(IS_IPHONE_5)?CGRectMake(0, 520, 160, 48):CGRectMake(0, 432, 160, 48)];
    [btnPastOrders setFrame:(IS_IPHONE_6)?CGRectMake(189, 611, 188, 56):(IS_IPHONE_5)?CGRectMake(161, 520, 159, 48):CGRectMake(161, 432, 159, 48)];
    [tblOrders setFrame:(IS_IPHONE_6)?CGRectMake(0, 110, 375, 501):(IS_IPHONE_5)?CGRectMake(0, 110, 320, 410):CGRectMake(0, 110, 320, 362)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- Refresh orders history after push notification
-(void)doRefreshOrdersHistory:(id)sender
{
    if (isPendingOrdersSelected) {
        arrOrders = [DBManager getOrdersHistory:NO];
    }else{
        arrOrders = [DBManager getOrdersHistory:YES];
    }
    [tblOrders reloadData];
}

#pragma mark -- Table view delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 23;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [arrOrders count]; // Save the count of sections
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[[arrOrders objectAtIndex:section] objectForKey:@"ORDER_DETAIL"] count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    //to-do:refactor this for other screen size
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,  tableView.bounds.size.width, 50)];
    [headerView setBackgroundColor:[UIColor whiteColor]];
    NSMutableDictionary * dictOrderHeader = [arrOrders objectAtIndex:section];
    
    UILabel * lblSectionTitle = [[UILabel alloc] init];
    [lblSectionTitle setFrame:(IS_IPHONE_6)?CGRectMake(20, 15, 335, 30):CGRectMake(20, 15, 280, 30)];
    [lblSectionTitle setNumberOfLines:2];
    [lblSectionTitle setText:[dictOrderHeader objectForKey:@"ORDER_DATE"]];
    [lblSectionTitle setFont:[UIFont fontWithName:@"Lato-Light" size:(IS_IPHONE_6)?17:15]];
    [lblSectionTitle setTextColor:[UIColor colorWithRed:84.0f/255.0f green:84.0f/255.0f blue:84.0f/255.0f alpha:1.0f]];
    [headerView addSubview:lblSectionTitle];
    
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

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellProduct";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = nil;
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    //--------- Product name
    UILabel *lblName = [[UILabel alloc] initWithFrame:(IS_IPHONE_6)?CGRectMake(20, 0, 335, 23):CGRectMake(20, 0, 280, 23)];
    [[[[arrOrders objectAtIndex:[indexPath section]] objectForKey:@"ORDER_DETAIL"] objectAtIndex:[indexPath row]] objectForKey:@"PRODUCT_QUANTITY_ORDERED"];
    [lblName setText:[NSString stringWithFormat:@"%@ %@",[[[[arrOrders objectAtIndex:[indexPath section]] objectForKey:@"ORDER_DETAIL"] objectAtIndex:[indexPath row]] objectForKey:@"PRODUCT_QUANTITY_ORDERED"],[[[[arrOrders objectAtIndex:[indexPath section]] objectForKey:@"ORDER_DETAIL"] objectAtIndex:[indexPath row]] objectForKey:@"PRODUCT_NAME"]]];
    [lblName setFont:[UIFont fontWithName:@"Lato-Regular" size:15]];
    [lblName setTextColor:[UIColor colorWithRed:84.0f/255.0f green:84.0f/255.0f blue:84.0f/255.0f alpha:1.0f]];
    [lblName setTextAlignment:NSTextAlignmentLeft];
    [cell addSubview:lblName];
    
    return cell;
}

#pragma mark -- Cancel order action
-(void)doCancelOrder:(id)sender
{
    //Extract the information from the arrOrders
    UIButton * senderButton = (UIButton *)sender;
    NSMutableDictionary * dictOrder = [arrOrders objectAtIndex:[senderButton tag]];

    AppDelegate * appDelegate = [[UIApplication sharedApplication] delegate];
    //Call spree to cancel the order
    [RESTManager sendData:nil toService:[NSString stringWithFormat:@"orders/%@/cancel",[dictOrder objectForKey:@"ORDER_ID"]] withMethod:@"PUT" isTesting:[appDelegate isTestingEnv]
          withAccessToken:[[appDelegate userObject] userSpreeToken] isAccessTokenInHeader:YES toCallback:^(id result) {
              NSLog(@"%@",result);
              //Check if the result retrieve state cancel... actually is result answer right
              if ([[result objectForKey:@"state"] isEqual:@"canceled"]) {
                  //Send the a push notification to CoffeeBoy App
                  NSDictionary *data = @{
                                         @"sound": @"default",
                                         @"action": @"cancelOrder"
                                         };
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
                  //Delete the order from local DB
                  [DBManager deleteOrderLog:[dictOrder objectForKey:@"ORDER_ID"]];
                  //Post a local notification to refresh the OrderViewController if the user is in that controller
                  [[NSNotificationCenter defaultCenter] postNotificationName:@"doRefreshOrdersHistory" object:nil];
              }
        }];
}

#pragma mark -- Buttons actions
-(void)doShowPastOrders:(id)sender
{
    //Get the past orders
    arrOrders = [DBManager getOrdersHistory:YES];
    //Set the titles and buttons
    [tblOrders reloadData];
    [lblTitle setText:@"PAST ORDERS"];
    [btnIncomingOrders setImage:[UIImage imageNamed:@"neworders_btn_up.png"] forState:UIControlStateNormal];
    [btnPastOrders setImage:[UIImage imageNamed:@"history_btn_selected.png"] forState:UIControlStateNormal];
    isPendingOrdersSelected = NO;
}

-(void)doShowPendingOrders:(id)sender
{
    //Get the pending orders
    arrOrders = [DBManager getOrdersHistory:NO];
    //Set the titles and buttons
    [tblOrders reloadData];
    [lblTitle setText:@"PENDING ORDERS"];
    [btnIncomingOrders setImage:[UIImage imageNamed:@"neworders_btn_selected.png"] forState:UIControlStateNormal];
    [btnPastOrders setImage:[UIImage imageNamed:@"history_btn_up.png"] forState:UIControlStateNormal];
    isPendingOrdersSelected = YES;
}

@end
