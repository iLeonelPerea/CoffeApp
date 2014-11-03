//
//  ShoppingCartViewController.h
//  GastronautBase
//
//  Created by Leonel Roberto Perea Trejo on 9/3/14.
//  Copyright (c) 2014 CrowdInt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BDBPopupViewController/UIViewController+BDBPopupViewController.h>
#import <JGProgressHUD.h>
#import "MenuViewController_iPhone.h"
#import "RESTManager.h"
#import "ProductObject.h"
#import "RESTManager.h"
#import "AppDelegate.h"

@interface ShoppingCartViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) IBOutlet UIButton *btnCheckOut;
@property (nonatomic, strong) IBOutlet UIButton *btnEmptyShoppingCart;
@property (nonatomic, strong) IBOutlet UILabel *lblDate;
@property (nonatomic, strong) IBOutlet UITableView *tblProducts;
@property (nonatomic, strong) NSMutableArray *arrProductsShoppingCart;
@property (nonatomic, strong) JGProgressHUD * HUDJMProgress;
@property (nonatomic, strong) NSTimer *tmrOrder;

-(IBAction)doPlaceOrder:(id)sender;
-(IBAction)doCancel:(id)sender;
-(void)doSetObjectsFrameFitToScreen;

@end
