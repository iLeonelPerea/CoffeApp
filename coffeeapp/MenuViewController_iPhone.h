//
//  MenuViewController_iPhone.h
//  coffeeapp
//
//  Created by Omar Guzmán on 8/21/14.
//  Copyright (c) 2014 CrowdInt. All rights reserved.
//

/** MenuViewController_iPhone */

/**
    This controller display the current menu
 
    The user can do:
    - Browse the menu.
    - Select items -add/remove- for his order.
 */

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

/** Outlet to enable the use of geolocalization through MapKit. */
@property (strong, nonatomic) IBOutlet MKMapView *mapKitView;

/** Use to set and calculate the distance between the client -iPhone App- and the administrator -iPad App-.  */
@property (strong, nonatomic) CLLocationManager *locationManager;

/** Array to store all the elements of the menu -Categories and Products-. */
@property (nonatomic, strong) NSMutableArray *arrProductObjects;

/** Array to store only the categories. */
@property (nonatomic, strong) NSMutableArray *arrProductCategoriesObjects;

/** Boolean flag to determine if the bottom bar for place the order is active. */
@property (nonatomic, assign) BOOL isViewPlaceOrderActive;

/** Outlet for the table view element, where the menu is displayed. */
@property (nonatomic, strong) IBOutlet UITableView * tblProducts;

/** Outlet for the view used as bottom bar to place the order. */
@property (nonatomic, strong) IBOutlet UIView *viewPlaceOrder;

/** Outlet for the label that display the total amount of selected products by user. */
@property (nonatomic, strong) IBOutlet UILabel *lblProductsCount;

/** Outlet for the button to place order -display the shopping cart controller-. */
@property (nonatomic, strong) IBOutlet UIButton *btnPlaceOrder;

/** Outlet for the HUD used to display loading while some proccess is active */
@property (nonatomic, strong) JGProgressHUD *HUDJMProgress;

/** A variable of ProductObject kind.  */
@property (nonatomic, strong) ProductObject *productObject;

/** Variable to store the current day of the week in integer value, which can be between 0 and 6.  */
@property (nonatomic, assign) int currentDayOfWeek;

/** Boolean flag to determine if the category meals is available according to a time schedule. */
@property (nonatomic, assign) BOOL areMealsAvailable;

/** Variable to store the number of the current -displayed on screen- section. */
@property (nonatomic, assign) int currentSection;

/** Boolean flag to determine is the location service are available on the device. If they're not, the geolocalization limitant is disable. */
@property (nonatomic, assign) BOOL areLocationServicesAvailable;


-(NSMutableArray*)setQuantitySelectedProducts:(NSMutableArray*)arrMenuProducts;
-(void)synchronizeDefaults;
-(void)doShowPlaceOrderBottomBar:(int)productsCount;
-(IBAction)doPlaceOrder:(id)sender;

@end
