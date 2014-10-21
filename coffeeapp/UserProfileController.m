//
//  UserProfileController.m
//  coffeeapp
//
//  Created by Leonel Roberto Perea Trejo on 10/20/14.
//  Copyright (c) 2014 crowdint. All rights reserved.
//

#import "UserProfileController.h"
#import <Parse/Parse.h>

@interface UserProfileController ()

@end

@implementation UserProfileController

@synthesize userObject, imgUserProfile, lblUserName, lblUserEmail, HUD;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Load User From AppDelegate
    AppDelegate *myAppDelegate = [[UIApplication sharedApplication] delegate];
    userObject = myAppDelegate.userObject;
    if([(NSString*) userObject.userUrlProfileImage rangeOfString:@"?"].location != NSNotFound)
    {
        NSArray * arrStrPic = [[NSArray alloc] init];
        arrStrPic = [(NSString*)userObject.userUrlProfileImage componentsSeparatedByString:@"?"];
        //NSLog(@"final usr pic url: %@", [arrStrPic objectAtIndex:0]);
        //NZCircularImageView does not support images with ? chars.
        userObject.userUrlProfileImage = [arrStrPic objectAtIndex:0];
        [imgUserProfile setImageWithResizeURL:[arrStrPic objectAtIndex:0] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    else
    {
        [imgUserProfile setImageWithResizeURL:userObject.userUrlProfileImage usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    [lblUserName setText:userObject.userName];
    [lblUserEmail setText:userObject.userEmail];
    NSString * userChannel = [NSString stringWithFormat:@"User_%@",userObject.userSpreeToken];
    //[userObject setUserChannel:userChannel];
    [PFPush subscribeToChannelInBackground:userChannel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)doRequestAmericano:(id)sender
{
    //add hud
    HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    HUD.textLabel.text = @"Sending request...";
    [HUD showInView:self.view];
    // Send a notification to all devices subscribed to the "requests" channel, in this case coffee boy app.
    
    NSString * strMessage = [NSString stringWithFormat:@"Please prepare me an Americano - %@", userObject.userName];
    
    NSDictionary *data = @{
                           @"alert": strMessage,
                           @"userPic": userObject.userUrlProfileImage, // Photo's object id
                           @"product": @"Americano" // hardcoded kind of coffee
                           };
    PFPush *push = [[PFPush alloc] init];
    [push setChannel:@"requests"];
    [push setData:data];
    [push sendPushInBackground];
    
    
    /*
    PFPush *push = [[PFPush alloc] init];
    [push setChannel:@"requests"];
    [push setMessage:strMessage];
     */
    [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [HUD dismissAnimated:YES];
        if(!succeeded)
        {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Error in Push Notification" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }
        [(UIButton*)sender setHidden:YES];
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
