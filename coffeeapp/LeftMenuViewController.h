//
//  LeftMenuViewController.h
//  coffeeapp
//
//  Created by Omar Guzmán on 10/22/14.
//  Copyright (c) 2014 crowdint. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeftMenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) IBOutlet UITableView * tblMenu;
@property (nonatomic, strong) NSMutableArray * arrMenu;
@property (nonatomic, assign) BOOL isUserLogged;
@property (nonatomic, strong) IBOutlet UILabel * lblUser;
@property (nonatomic, strong) IBOutlet UIButton * btnLogout;
// methods
-(IBAction)doLogout:(id)sender;
@end
