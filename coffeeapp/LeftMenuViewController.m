//
//  LeftMenuViewController.m
//  coffeeapp
//
//  Created by Omar Guzmán on 10/22/14.
//  Copyright (c) 2014 crowdint. All rights reserved.
//

#import "LeftMenuViewController.h"
#import <Parse/Parse.h>

@interface LeftMenuViewController ()

@end

@implementation LeftMenuViewController
@synthesize tblMenu, arrMenu, isUserLogged, btnSignOut, lblUser, imgUserProfile, HUD;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    AppDelegate * appDelegate = [[UIApplication sharedApplication] delegate];
    if(appDelegate.canOrderBeCancelled)
        arrMenu = [[NSMutableArray alloc] initWithObjects:@"Menu", @"My Orders", @"Cancel Order", nil];
    else
        arrMenu = [[NSMutableArray alloc] initWithObjects:@"Menu", @"My Orders", nil];
    [tblMenu setDelegate:self];
    [tblMenu setDataSource:self];
    [tblMenu reloadData];
    //Set the current user name from userObject located at AppDelegate
    UserObject * userObject = [[UserObject alloc] init];
    userObject = [appDelegate userObject];
    [lblUser setText:[userObject userName]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userCanCancelCurrentOrder:) name:@"userCanCancelCurrentOrder" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userCanNotCancelCurrentOrder:) name:@"userCanNotCancelCurrentOrder" object:nil];
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

-(void)userCanCancelCurrentOrder:(NSNotification*)notification
{
    arrMenu = [[NSMutableArray alloc] initWithObjects:@"Menu", @"My Orders", @"Cancel Order", nil];
    [tblMenu reloadData];
}

-(void)userCanNotCancelCurrentOrder:(NSNotification*)notification
{
    arrMenu = [[NSMutableArray alloc] initWithObjects:@"Menu", @"My Orders", nil];
    [tblMenu reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (NSInteger)[arrMenu count];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ([indexPath row]) {
        case 0:
            [[NSNotificationCenter defaultCenter] postNotificationName:@"userDidRequestMenu" object:nil];
            break;
        case 1:
            [[NSNotificationCenter defaultCenter] postNotificationName:@"userDidRequestOrders" object:nil];
            break;
        case 2:
            //todo: call cancel order
            NSLog(@"cancel order...");
            [self doCancelOrder];
            break;
        default:
            break;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identifier = @"CellMenu";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    [[cell textLabel] setText:[arrMenu objectAtIndex:[indexPath row]]];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    return cell;
}

#pragma mark -- SigOut delegate
-(IBAction)doSignOut:(id)sender
{
    //SignOut
    [[GPPSignIn sharedInstance] signOut];
    //Revoke token
    [[GPPSignIn sharedInstance] disconnect];
    //Clean the AppDelegate's userObject
    AppDelegate * appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate setUserObject:nil];
    //Clean userObject data stored in user defaults
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nil forKey:@"userObject"];
    [defaults setObject:nil forKey:@"arrProductsInQueue"];
    [defaults synchronize];
    //Calls to set the main view controller to display
    [[NSNotificationCenter defaultCenter] postNotificationName:@"userDidRequestSignOut" object:nil];
    //Delete content of local DB tables
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
        appDelegate.canOrderBeCancelled = NO;
        if(!succeeded)
        {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Error in Push Notification" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }

    }];
}
@end
