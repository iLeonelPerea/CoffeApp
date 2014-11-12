//
//  MenuViewController_iPhone.h
//  coffeeapp
//
//  Created by Omar Guzmán on 8/21/14.
//  Copyright (c) 2014 CrowdInt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AsyncImageDownloader/AsyncImageDownloader.h>
#import <BDBPopupViewController/UIViewController+BDBPopupViewController.h>
#import <JGProgressHUD.h>
#import "ProductCellTableViewCell.h"
#import "ShoppingCartViewController.h"
#import "ProductObject.h"
#import <JGProgressHUD.h>
#import "AppDelegate.h"
#import "CustomButton.h"
#import "RESTManager.h"
#import <LMAlertView.h>
#import <MapKit/MapKit.h>

@class LoginViewController;

@interface MenuViewController_iPhone : UIViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, MKMapViewDelegate, CLLocationManagerDelegate>
@property (strong, nonatomic) IBOutlet MKMapView *mapKitView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableArray *arrProductObjects;
@property (nonatomic, strong) NSMutableArray *arrProductCategoriesObjects;
@property (nonatomic, assign) BOOL isViewPlaceOrderActive;
@property (nonatomic, strong) IBOutlet UITableView * tblProducts;
@property (nonatomic, strong) IBOutlet UILabel * lblCurrentDay;
@property (nonatomic, strong) IBOutlet UIView *viewPlaceOrder;
@property (nonatomic, strong) IBOutlet UILabel *lblProductsCount;
@property (nonatomic, strong) IBOutlet UIButton *btnPlaceOrder;
@property (nonatomic, strong) NSArray * arrWeekDays;
@property (nonatomic, strong) JGProgressHUD *HUDJMProgress;
@property (nonatomic, strong) ProductObject *productObject;
@property (nonatomic, assign) int currentDayOfWeek;
@property (nonatomic, assign) BOOL areMealsAvailable;
@property (nonatomic, assign) int currentSection;
-(void)synchronizeDefaults;
-(NSMutableArray*)setQuantitySelectedProducts:(NSMutableArray*)arrMenuProducts;
-(void)doShowPlaceOrderBottomBar:(int)productsCount;
-(IBAction)doPlaceOrder:(id)sender;

@end
