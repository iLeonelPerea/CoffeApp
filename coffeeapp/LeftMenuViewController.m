//
//  LeftMenuViewController.m
//  coffeeapp
//
//  Created by Omar Guzmán on 10/22/14.
//  Copyright (c) 2014 crowdint. All rights reserved.
//

#import "LeftMenuViewController.h"
#import <Parse/Parse.h>

/// Macros to identify the size of the screen.
#define IS_IPHONE_5 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)568) < DBL_EPSILON)
#define IS_IPHONE_6 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)667) < DBL_EPSILON)
#define IS_IPHONE_6_PLUS (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)736) < DBL_EPSILON)

@interface LeftMenuViewController ()

@end

@implementation LeftMenuViewController
@synthesize tblMenu, arrMenu, isUserLogged, btnSignOut, lblUser, imgUserProfile, HUD, lblOptions;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    AppDelegate * appDelegate = [[UIApplication sharedApplication] delegate];
    /// Create an array to set the options of the left menu.
    arrMenu = [[NSMutableArray alloc] initWithObjects:@"Menu", @"My Orders", nil];
    /// Set the datasource and delegate of the table view tblMenu.
    [tblMenu setDelegate:self];
    [tblMenu setDataSource:self];
    [tblMenu reloadData];
    /// Set the current user name from userObject located at AppDelegate
    UserObject * userObject = [[UserObject alloc] init];
    userObject = [appDelegate userObject];
    /// Set the style for the user's label.
    [lblUser setFont:[UIFont fontWithName:@"Lato-Regular" size:20]];
    [lblUser setText:[userObject userName]];
    [lblUser setTextColor:[UIColor colorWithRed:84.0f/255.0f green:84.0f/255.0f blue:84.0f/255.0f alpha:1.0f]];
    [lblOptions setFont:[UIFont fontWithName:@"Lato-Light" size:20]];
    /// Check for the image of the user.
    if([(NSString*) userObject.userUrlProfileImage rangeOfString:@"?"].location != NSNotFound)
    {
        NSArray * arrStrPic = [[NSArray alloc] init];
        arrStrPic = [(NSString*)userObject.userUrlProfileImage componentsSeparatedByString:@"?"];
        userObject.userUrlProfileImage = [arrStrPic objectAtIndex:0];
        [imgUserProfile setImageWithResizeURL:[arrStrPic objectAtIndex:0] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    else
    {
        [imgUserProfile setImageWithResizeURL:userObject.userUrlProfileImage usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }

}

-(void)viewDidAppear:(BOOL)animated
{
    /// Set the elements to fit on the screen.
    [tblMenu setFrame:(IS_IPHONE_6 || IS_IPHONE_5)?CGRectMake(0, 70, 320, 160):CGRectMake(0, 70, 320, 100)];
    [imgUserProfile setFrame:(IS_IPHONE_6)?CGRectMake(20, 441, 90, 90):(IS_IPHONE_5)?CGRectMake(20, 341, 90, 90):CGRectMake(20, 250, 90, 90)];
    [lblUser setFrame:(IS_IPHONE_6)?CGRectMake(20, 539, 240, 60):(IS_IPHONE_5)?CGRectMake(20, 439, 240, 60):CGRectMake(20, 350, 240, 60)];
    [btnSignOut setFrame:(IS_IPHONE_6)?CGRectMake(20, 610, 200, 40):(IS_IPHONE_5)?CGRectMake(20, 507, 200, 40):CGRectMake(20, 420, 200, 40)];
}

/// System method.
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- UITableViewDelegate
/// Define the height for the table row based on the device.
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (IS_IPHONE_6 || IS_IPHONE_5)?80:50;
}

/// Define the numbers of rows based on the numbers of elements of the array arrMenu.
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (NSInteger)[arrMenu count];
}

/// Check for the selected row. Depending on which is the view controller displayed.
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tblMenu reloadData];
    /// Add image indicator to indicate the selected cell
    UIImageView *imgIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10,(IS_IPHONE_6 || IS_IPHONE_5)?80:50)];
    switch ([indexPath row]) {
        case 0:
            [[NSNotificationCenter defaultCenter] postNotificationName:@"userDidRequestMenu" object:nil];
            [imgIndicator setImage:[UIImage imageNamed:@"menu_selected"]];
            break;
        case 1:
            [[NSNotificationCenter defaultCenter] postNotificationName:@"userDidRequestOrders" object:nil];
            [imgIndicator setImage:[UIImage imageNamed:@"menu_selected"]];
            break;
        default:
            break;
    }
    [[tableView cellForRowAtIndexPath:indexPath] addSubview:imgIndicator];
}

/// Draw the content of each cell of the table.
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /// Create and set the cell for the row.
    static NSString * identifier = @"CellMenu";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    /// Set the label for the cell.
    [[cell textLabel] setTextColor:[UIColor colorWithRed:84.0f/255.0f green:84.0f/255.0f blue:84.0f/255.0f alpha:1.0f]];
    [[cell textLabel] setFont:[UIFont fontWithName:@"Lato-Light" size:24]];
    [[cell textLabel] setText:[arrMenu objectAtIndex:[indexPath row]]];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    /// Add image indicator to indicate the selected cell
    UIView *viewIndicator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10,(IS_IPHONE_6 || IS_IPHONE_5)?80:50)];
    [viewIndicator setBackgroundColor:[UIColor whiteColor]];
    [cell addSubview:viewIndicator];
    return cell;
}

#pragma mark -- SigOut delegate
-(IBAction)doSignOut:(id)sender
{
    /// SignOut
    [[GPPSignIn sharedInstance] signOut];
    /// Revoke token
    [[GPPSignIn sharedInstance] disconnect];
    /// Clean the AppDelegate's userObject
    AppDelegate * appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate setUserObject:nil];
    /// Clean userObject data stored in user defaults
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nil forKey:@"userObject"];
    [defaults setObject:nil forKey:@"arrProductsInQueue"];
    [defaults synchronize];
    /// Calls to set the main view controller to display
    [[NSNotificationCenter defaultCenter] postNotificationName:@"userDidRequestSignOut" object:nil];
    /// Delete content of local DB tables
    NSArray * arrTables = [[NSArray alloc] init];
    arrTables = @[@"PRODUCT_CATEGORIES", @"PRODUCTS",@"ORDERSLOG",@"SHOPPINGCART"];
    [DBManager deleteTableContent:arrTables];
}

-(void)doCancelOrder
{
    AppDelegate * appDelegate = [[UIApplication sharedApplication] delegate];
    NSDictionary *data = @{
                           @"sound": @"default",
                           @"orderNumber": appDelegate.currentOrderNumber,
                           @"action": @"cancelOrder"
                           };
    PFPush *push = [[PFPush alloc] init];
    [push setChannel:@"requests"];
    [push setData:data];
    [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        arrMenu = [[NSMutableArray alloc] initWithObjects:@"Menu", @"My Orders", nil];
        [tblMenu reloadData];
        //Delete the order from local DB
        [DBManager deleteOrderLog:appDelegate.currentOrderNumber];
        //Post a local notification to refresh the OrderViewController if the user is in that controller
        [[NSNotificationCenter defaultCenter] postNotificationName:@"doRefreshOrdersHistory" object:nil];
        //Reset values
        appDelegate.currentOrderNumber = nil;
        if(!succeeded)
        {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Error in Push Notification" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }

    }];
}
@end
