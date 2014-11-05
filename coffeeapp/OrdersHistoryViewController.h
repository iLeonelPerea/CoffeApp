//
//  OrdersHistoryViewController.h
//  coffeeapp
//
//  Created by Crowd on 10/24/14.
//  Copyright (c) 2014 crowdint. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBManager.h"

@interface OrdersHistoryViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UIImageView * imgPatron;
@property (nonatomic, strong) IBOutlet UILabel * lblTitle;
@property (nonatomic, strong) IBOutlet UITableView * tblOrders;
@property (nonatomic, strong) IBOutlet UIButton * btnIncomingOrders;
@property (nonatomic, strong) IBOutlet UIButton * btnPastOrders;
@property (nonatomic, strong) NSMutableArray * arrOrders;
@property (nonatomic, strong) NSMutableArray * arrOrdersDetail;
@property (nonatomic, assign) BOOL isPendingOrdersSelected;

-(IBAction)doShowPendingOrders:(id)sender;
-(IBAction)doShowPastOrders:(id)sender;

@end
