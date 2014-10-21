//
//  UserProfileController.h
//  coffeeapp
//
//  Created by Leonel Roberto Perea Trejo on 10/20/14.
//  Copyright (c) 2014 crowdint. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NZCircularImageView.h>
#import "AppDelegate.h"
#import "UserObject.h"

@interface UserProfileController : UIViewController

@property (nonatomic, strong) UserObject *userObject;
@property (nonatomic, strong) IBOutlet NZCircularImageView * imgUserProfile;
@property (nonatomic, strong) IBOutlet UILabel *lblUserName;
@property (nonatomic, strong) IBOutlet UILabel *lblUserEmail;

@end
