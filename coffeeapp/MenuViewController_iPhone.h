//
//  MenuViewController_iPhone.h
//  coffeeapp
//
//  Created by Omar Guzmán on 8/21/14.
//  Copyright (c) 2014 CrowdInt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AsyncImageDownloader/AsyncImageDownloader.h>
#import "ProductCellTableViewCell.h"
#import "ProductObject.h"
#import <JGProgressHUD.h>
#import "AppDelegate.h"

@class LoginViewController;

@interface MenuViewController_iPhone : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray *arrProductObjects;
@property (nonatomic, strong) IBOutlet UIPageControl *pageControl;
@property (nonatomic, assign) BOOL isPageControlInUse;
@property (nonatomic, strong) IBOutlet UITableView * tblProducts;
@property (nonatomic, strong) IBOutlet UILabel * lblCurrentDay;
@property (nonatomic, strong) NSMutableArray *arrDataMonday;
@property (nonatomic, strong) NSMutableArray *arrDataTuesday;
@property (nonatomic, strong) NSMutableArray *arrDataWednesday;
@property (nonatomic, strong) NSMutableArray *arrDataThursday;
@property (nonatomic, strong) NSMutableArray *arrDataFriday;
@property (nonatomic, strong) NSMutableArray *arrDataSaturday;
@property (nonatomic, strong) NSMutableArray *arrDataSunday;
@property (nonatomic, strong) NSArray * arrWeekDays;
@property (nonatomic, strong) JGProgressHUD *HUDJMProgress;
@property (nonatomic, strong) ProductObject *productObject;
@property (nonatomic, assign) int directionChangePageControl; //0:Left 1:Rigth
@property (nonatomic, assign) int currentDayOfWeek;
- (IBAction)changePage;
- (void)synchronizeDefaults;
- (NSMutableArray*)setQuantitySelectedProducts:(NSMutableArray*)arrMenuProducts;
@end
