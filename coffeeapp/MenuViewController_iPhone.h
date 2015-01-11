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

@interface MenuViewController_iPhone : UIViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, MKMapViewDelegate, CLLocationManagerDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

/** Outlet to enable the filter categories throught UIPicker. */
@property (nonatomic, strong) IBOutlet UIView * viewPicker;

/** Outlet to enable the filter categories throught UIScroll. */
@property (nonatomic, strong) IBOutlet UIView * viewCategories;

/** Outlet to enable the filter categories throught UILabel. */
@property (nonatomic, strong) IBOutlet UIScrollView * viewScrollCategories;

/** Outlet to hide the picker and buttons. */
@property (nonatomic, strong) IBOutlet UIPickerView *pickerOptions;

/** Use to save the category selected. */
@property (nonatomic, assign) long pickerFilterActiveOption;

/** Boolean flag to determine if the filter is active. */
@property (nonatomic, assign) BOOL isPickerFilterActive;

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

/** Set the quantity for selected products and update the total on hand of the products.
 
    @param arrMenuProducts A mutable array, which depending where the message is sended is the origin of the content of the array. It must have the categories and the products of the current menu.
 
    - First check if there's selected products by user. If there's, then look for those products to update their quantity value.
    - Create and set an mutable array called arrProductsOrdered with the products that are in orders with status "confirm" or "attending". To get the information a method from DBManager is used -getProductsInConfirm-. After, look for those products to update the total on hand value.
    - Return the array received via arrMenuProducts.
 
 */
-(NSMutableArray*)setQuantitySelectedProducts:(NSMutableArray*)arrMenuProducts;

/** Local notification to update the stock after a push notification is received.
 
    @param notification A NSNotification param, in this case it's not used.
 
    The app can receive a push notification which informas that an order has been served. When this occurs the method do:
    - Extract the data from user defaults stored in dataCompleteNotification, an array with the products that will be updated..
    - Update the stock in local DB. Call the DBManager's method updateProductStock, sendind the master_id and total_on_hand as params.
    - Set again the products array calling local method setQuantitySelectedProducts.
    - Reload table view tblProducts.
    - Reset the values in user defaults, setting dataCompleteNotification in nil.
 */
-(void)doUpdateProductsStockAfterNotification:(NSNotification *)notification;

/** Local notification to update the categories and products of the current menu.
 
    @param notification A NSNotification param, in this case it's not used.
 
    Request to spree the current menu, update the local DB and set again the array arrProductObjects. This method is called in the next cases:
    - After an order is maded by the user.
    - A category is added/removed/updated from the current menu.
    - A product is added/removed/updated from the current menu.
    - The app returns from the background.
 */
-(void)doUpdateMenu:(NSNotification*)notification;

/** Synchronize the array arrProductsInQueue in the user defaults. */
-(void)synchronizeDefaults;

/** Show or hide the bottom bar with the button to place the order and the select items count.
 
    @param productsCount Integer variable with the total quantity of selected items.
 */
-(void)doShowPlaceOrderBottomBar:(int)productsCount;

/** Add the quantity of the selected product.
 
    @param (id)sender Contains the reference of the add button of the current selected product.
 
    - Create a product object variable.
    - Extract the content of sender param.
    - Set product object with the reference of the selected product stored in arrProductObjects.
    - Update the quantity of the product.
    - Reload the table view tblProducts.
 */
-(void)didSelectProduct:(id)sender;

/** Sustract the quantity of the selected product.
 
    @param (id)sender Contains the reference of the minus button of the current selected product.
 
    - Create a product object variable.
    - Extract the content of sender param.
    - Set product object with the reference of the selected product stored in arrProductObjects.
    - Update the quantity of the product.
    - Reload the table view tblProducts.
 */
-(void)didDeselectProduct:(id)sender;

/** Display the ShoppingCartViewController.
 
    @param (id)sender In this case it's not used.
 
    To display de shopping cart, it is neccesary:
    - Check if the location service are available and if the user`s location is under 1,000 meters. In case of false, a custom alert view is displayed to inform the user about.
    - Check if the category of the product is equal to "Desayuno" and if the meals category is available.
 */
-(IBAction)doPlaceOrder:(id)sender;
-(IBAction)doPickerOk:(id)sender;
-(IBAction)doPickerCancel:(id)sender;

@end
