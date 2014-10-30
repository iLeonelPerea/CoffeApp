//
//  LeftMenuViewController.m
//  coffeeapp
//
//  Created by Omar Guzmán on 10/22/14.
//  Copyright (c) 2014 crowdint. All rights reserved.
//

#import "LeftMenuViewController.h"

@interface LeftMenuViewController ()

@end

@implementation LeftMenuViewController
@synthesize tblMenu, arrMenu, isUserLogged, btnSignOut, lblUser, imgUserProfile, HUD;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    arrMenu = [[NSMutableArray alloc] initWithObjects:@"Menu", @"My Orders", nil];
    [tblMenu setDelegate:self];
    [tblMenu setDataSource:self];
    [tblMenu reloadData];
    //Set the current user name from userObject located at AppDelegate
    AppDelegate * appDelegate = [[UIApplication sharedApplication] delegate];
    UserObject * userObject = [[UserObject alloc] init];
    userObject = [appDelegate userObject];
    [lblUser setText:[userObject userName]];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- UITableViewDelegate
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
    [defaults synchronize];
    //Calls to set the main view controller to display
    [[NSNotificationCenter defaultCenter] postNotificationName:@"userDidRequestSignOut" object:nil];
}
@end
