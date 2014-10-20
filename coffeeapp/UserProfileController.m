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

@synthesize userObject, imgUserURLProfile, lblUserName, lblUserEmail;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Load User From AppDelegate
    AppDelegate *myAppDelegate = [[UIApplication sharedApplication] delegate];
    userObject = myAppDelegate.userObject;
    
    NSURL * urlPic = [NSURL URLWithString:userObject.userUrlProfileImage];
    NSData * dataPic = [NSData dataWithContentsOfURL:urlPic];
    [self.imgUserURLProfile setImage:[UIImage imageWithData:dataPic]];
    [lblUserName setText:userObject.userName];
    [lblUserEmail setText:userObject.userEmail];
    NSString * userChannel = [NSString stringWithFormat:@"User_%@",userObject.userSpreeToken];
    [PFPush subscribeToChannelInBackground:userChannel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
