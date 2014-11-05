//
//  OrdersHistoryViewController.m
//  coffeeapp
//
//  Created by Crowd on 10/24/14.
//  Copyright (c) 2014 crowdint. All rights reserved.
//

#import "OrdersHistoryViewController.h"

@interface OrdersHistoryViewController ()

@end

@implementation OrdersHistoryViewController
@synthesize imgPatron, lblTitle, tblOrders, btnIncomingOrders, btnPastOrders, arrOrders, arrOrdersDetail;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [tblOrders setDelegate:self];
    [tblOrders setDataSource:self];
    
    UILabel * lblControllerTitle = [[UILabel alloc] init];
    [lblControllerTitle setFrame:CGRectMake(0, 0, 140, 50)];
    [lblControllerTitle setText:@"The Crowd's Chef"];
    [lblControllerTitle setFont:[UIFont fontWithName:@"HelveticaNeue" size:20]];
    [lblControllerTitle setTextColor:[UIColor whiteColor]];
    [[self navigationItem] setTitleView:lblControllerTitle];
    
    //Get orders information, init with new orders
    [lblTitle setText:@"PENDING ORDERS"];
    arrOrders = [DBManager getOrdersHistory:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    arrOrdersDetail = [[arrOrders objectAtIndex:section] objectForKey:@"ORDER_DETAIL"];
    return [arrOrdersDetail count];
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
    [lblSectionTitle setFrame:CGRectMake(20, 15, 280, 30)];
    [lblSectionTitle setText:[dictOrderHeader objectForKey:@"ORDER_DATE"]];
    [lblSectionTitle setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18]];
    [lblSectionTitle setTextColor:[UIColor colorWithRed:84.0f/255.0f green:84.0f/255.0f blue:84.0f/255.0f alpha:1.0f]];
    [headerView addSubview:lblSectionTitle];
    
    if ([[dictOrderHeader objectForKey:@"ORDER_STATUS"] isEqual:@"attending"]) {
        UIImageView * imgLabel = [[UIImageView alloc] initWithFrame:CGRectMake(250, 0, 70, 70)];
        [imgLabel setImage:[UIImage imageNamed:@"label.png"]];
        [headerView addSubview:imgLabel];
    }
    
    /*
    UILabel * lblProductsNumber = [[UILabel alloc] init];
    [lblProductsNumber setFrame:CGRectMake(200, 0, 100, 50)];
    [lblProductsNumber setText:([[arrProductObjects objectAtIndex:section] count] > 1)?[NSString stringWithFormat:@"%d Products",(int)[[arrProductObjects objectAtIndex:section] count]]:@"1 Product"];
    [lblProductsNumber setTextAlignment:NSTextAlignmentRight];
    [lblProductsNumber setTextColor:[UIColor colorWithRed:146.0f/255.0f green:142.0f/255.0f blue:140.0f/255.0f alpha:1.0f]];
    [lblProductsNumber setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:15]];
    [headerView addSubview:lblProductsNumber];
    */
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
    UILabel *lblName = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 280, 23)];
    [lblName setText:[[arrOrdersDetail objectAtIndex:[indexPath row]] objectForKey:@"PRODUCT_NAME"]];
    [lblName setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:15]];
    [lblName setTextColor:[UIColor colorWithRed:84.0f/255.0f green:84.0f/255.0f blue:84.0f/255.0f alpha:1.0f]];
    [lblName setTextAlignment:NSTextAlignmentLeft];
    [cell addSubview:lblName];
    
    return cell;
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
}

@end
