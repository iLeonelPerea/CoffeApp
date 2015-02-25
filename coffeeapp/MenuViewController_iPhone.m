//
//  MenuViewController_iPhone.m
//  GastronautBase
//
//  Created by Omar Guzmán on 8/21/14.
//  Copyright (c) 2014 CrowdInt. All rights reserved.
//
// ViewDidDisappear was removed. synchronizeDefaults was modified to -really- synchronize the values of user defaults
// An method called doShowPlaceOrderBottomBar was created to detemine if the bottom bar has to be displayed or not. Because the code
// that used to do that, was putted in the synchronizeDefaults. That was the cause of some behavior issues in the menu view controller.
// Also were removed a lot of calls to synchronizeDefaults, which were unnecessary. The method doSynchronizeDefaults
// was modified to optimize the code, now is called doUpdateMenu .
// -- Francisco Flores --

#import "MenuViewController_iPhone.h"
#import "DBManager.h"
#import "RESTManager.h"
#import "AppDelegate.h"

/// Macros to identify size screen
#define IS_IPHONE_5 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)568) < DBL_EPSILON) 
#define IS_IPHONE_6 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)667) < DBL_EPSILON) 
#define IS_IPHONE_6_PLUS (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)736) < DBL_EPSILON)

@interface MenuViewController_iPhone ()

@end

@implementation MenuViewController_iPhone
@synthesize viewPicker, viewCategories, viewScrollCategories, pickerOptions, mapKitView, locationManager, arrProductObjects, arrProductCategoriesObjects, isViewPlaceOrderActive, tblProducts, HUDJMProgress, productObject, currentDayOfWeek, viewPlaceOrder, lblProductsCount, btnPlaceOrder, currentSection, areLocationServicesAvailable, pickerFilterActiveOption, isPickerFilterActive, tblProductsHeight, separatorView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    /// Set isMenuViewController flag to YES in the AppDelegate.
    AppDelegate * initialAppDelegate = [[UIApplication sharedApplication] delegate];
    [initialAppDelegate setIsMenuViewController:YES];

    /// Set the default value to flag for location services.
    areLocationServicesAvailable = YES;
    
    /// Set the constraints for the elements on the view.
    [[self view] setFrame:(IS_IPHONE_6_PLUS)?CGRectMake(0, 0, 414, 736):(IS_IPHONE_6)?CGRectMake(0, 0, 375, 667):(IS_IPHONE_5)?CGRectMake(0, 0, 320, 568):CGRectMake(0, 0, 320, 480)];
    [viewPlaceOrder setFrame:CGRectMake(0, self.view.frame.size.height+60, self.view.frame.size.width, 60)];
    [viewPlaceOrder setBackgroundColor:[UIColor colorWithRed:255.0f/255.0f green:127.0f/255.0f blue:0.0f/255.0f alpha:1.0f]];
    [lblProductsCount setFrame:CGRectMake(19, 0, 90, 60)];
    [lblProductsCount setTextAlignment:NSTextAlignmentLeft];
    [lblProductsCount setFont:[UIFont fontWithName:@"Lato-light" size:16]];
    [btnPlaceOrder setFrame:CGRectMake(self.view.bounds.size.width - 201, 0, 182, 60)];
    //[btnPlaceOrder setFrame:(IS_IPHONE_6)?CGRectMake(174, 0, 182, 60):CGRectMake(119, 0, 182, 60)];
    [[btnPlaceOrder titleLabel] setTextColor:[UIColor whiteColor]];
    [[btnPlaceOrder titleLabel] setFont:[UIFont fontWithName:@"Lato-Regular" size:22]];
    [[btnPlaceOrder titleLabel] setTextAlignment:NSTextAlignmentLeft];
    UIImageView * imgCheckMark = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 39, 22, 20, 15)];
    //UIImageView * imgCheckMark = [[UIImageView alloc] initWithFrame:(IS_IPHONE_6)?CGRectMake(336, 22, 20, 15):CGRectMake(281, 22, 20, 15)];
    [imgCheckMark setImage:[UIImage imageNamed:@"Checkmark_White"]];
    [viewPlaceOrder addSubview:imgCheckMark];
    
    /// Set the default value to the flag for bottom bar.
    isViewPlaceOrderActive = NO;
    
    /// Setting up tableview delegates and datasources
    [tblProducts setDelegate:self];
    [tblProducts setDataSource:self];
    HUDJMProgress = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    
    ///Iniliatize the arrays to store the products.
    arrProductObjects = [NSMutableArray new];
    
    /// Set the HUD for loading message
    [[HUDJMProgress textLabel] setText:@"Loading products"];
    [HUDJMProgress showInView:[self view]];
    AppDelegate * appDelegate =  [[UIApplication sharedApplication] delegate];
    /// Make a request to spree to get all the elements of the menu.
    [RESTManager updateProducts:[[appDelegate userObject] userSpreeToken] toCallback:^(id resultSignUp) {
        if ([resultSignUp isEqual:@YES]) {
            /// Set the array prodcuts - If the there's products selected by users, they will be set here.
            arrProductCategoriesObjects = [DBManager getCategories];
            arrProductObjects = [[self setQuantitySelectedProducts:[DBManager getProducts]] mutableCopy];
            [tblProducts reloadData];
            [self updateCategoryBar];
        }else{
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Atention!" message:@"There's no Menu available" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        [HUDJMProgress dismiss];
    }];
    
    /// Get the current day of the week.
    NSDate *now = [NSDate date];
    NSDateFormatter *weekday = [[NSDateFormatter alloc] init];
    [weekday setDateFormat: @"e"];
    currentDayOfWeek = ([[weekday stringFromDate:now] intValue] == 1)? 8:[[weekday stringFromDate:now] intValue];
    
    /// Create a notification that reload data.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doUpdateMenu:) name:@"doUpdateMenu" object:nil];

    UILabel * lblControllerTitle = [[UILabel alloc] init];
    [lblControllerTitle setFrame:CGRectMake(0, 0, 140, 55)];
    [lblControllerTitle setText:@"The Crowd's Chef"];
    [lblControllerTitle setFont:[UIFont fontWithName:@"Lato-Regular" size:20]];
    [lblControllerTitle setTextColor:[UIColor whiteColor]];
    [[self navigationItem] setTitleView:lblControllerTitle];
    
    UIImage *faceImage = [UIImage imageNamed:@"PlateCover"];
    UIButton *face = [UIButton buttonWithType:UIButtonTypeCustom];
    face.bounds = CGRectMake( 0, 0, faceImage.size.width/2, faceImage.size.height/2 );//set bound as per you want
    [face addTarget:self action:@selector(doHideShowCategoryFilter:) forControlEvents:UIControlEventTouchUpInside];
    [face setImage:faceImage forState:UIControlStateNormal];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:face];
    [self navigationItem].rightBarButtonItem = backButton;
    
    /// Create observer to update products stock without call the spree service
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doUpdateProductsStockAfterNotification:) name:@"doUpdateProductsStockAfterNotification" object:nil];
    
    /// Create a location manager
    locationManager = [[CLLocationManager alloc] init];
    // Set a delegate to receive location callbacks
    locationManager.delegate = self;
    /// Start the location manager
    [locationManager startUpdatingLocation];
    
    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [locationManager requestWhenInUseAuthorization];
    }
    [locationManager startUpdatingLocation];
    
    /// Initialice mapkit
    mapKitView.delegate = self;
    [mapKitView setShowsUserLocation:YES];
    
    tblProductsHeight = self.view.frame.size.height;
}

-(void)viewDidAppear:(BOOL)animated{
    
    /// Check if the bottom bar is active, to set the size of tblProducts.
    int newTblProductsHeight =  tblProductsHeight - 125;
    if (isViewPlaceOrderActive) {
        [tblProducts setFrame:CGRectMake(0, 123, self.view.frame.size.width, newTblProductsHeight)];
    }else{
        [tblProducts setFrame:CGRectMake(0, 125, self.view.frame.size.width, newTblProductsHeight)];
    }
    [viewCategories setFrame:CGRectMake(0, 65, self.view.frame.size.width, 57)];
    [viewScrollCategories setFrame:CGRectMake(0, 0, self.view.frame.size.width, 57)];
    separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 124, self.view.frame.size.width, 0.3f)];
    [separatorView setBackgroundColor:[UIColor colorWithRed:165.0f/255.0f green:150.0f/255.0f blue:143.0f/255.0f alpha:1.0f]];
    separatorView.layer.opacity = 0.5f;
    [self.view addSubview:separatorView];
    [self.view bringSubviewToFront:separatorView];
}

-(void)viewWillDisappear:(BOOL)animated
{
    //Set isMenuViewController to No in the AppDelegate
    AppDelegate * appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate setIsMenuViewController:NO];
}

#pragma mark -- setQuantitySelectedProducts delegate
-(NSMutableArray*)setQuantitySelectedProducts:(NSMutableArray *)arrMenuProducts
{
    /// Extract from user defaults arrProductsInQueue, which contains the selected products by user.
    NSUserDefaults *defaults =  [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:@"arrProductsInQueue"];
    NSMutableArray *arrOrderSelectedProducts = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    /// Check is there's prodcuts selected by user.
    if ([arrOrderSelectedProducts count] > 0) {
        for (int arrayDimention=0; arrayDimention<arrMenuProducts.count; arrayDimention++) {
            for(ProductObject *prodObject in [arrMenuProducts objectAtIndex:arrayDimention]){
                MasterObject *masterObject = [prodObject masterObject];
                /// Loop for the array that contains the selected products by user.
                for (ProductObject *orderSelectedProduct in arrOrderSelectedProducts) {
                    MasterObject *orderMasterProduct = [orderSelectedProduct masterObject];
                    /// If the id from selected product is equal to id from menu product, aasign the quantity to display.
                    if ([orderMasterProduct masterObject_id] == [masterObject masterObject_id]) {
                        [prodObject setQuantity:[orderSelectedProduct quantity]];
                        prodObject.comment = orderSelectedProduct.comment;
                        continue;
                    }
                }
            }
        }
    }
    
    /// Extract the products that are in orders with status in "confirm" o "attending".Then, they are stored in arrProductsOrdered.
    NSArray * arrProductsOrdered = [[NSArray alloc] initWithArray:[DBManager getProductsInConfirm]];
    /// Check if arrProductsOrdered has elements to check with arrMenuProducts
    if ([arrProductsOrdered count] > 0) {
        for (NSArray * arrTmpProducts in arrMenuProducts) {
            for (ProductObject *tmpProductObject in arrTmpProducts) {
                /// Loop for set the temporally stock to products
                for (NSDictionary * dictTmpProduct in arrProductsOrdered) {
                    if ([tmpProductObject.masterObject masterObject_id] == [[dictTmpProduct objectForKey:@"PRODUCT_ID"] intValue]) {
                        /// Check the stock and the quantity ordered
                        /// Sustract the ordered quantity to total on hand. If more than 0, update the stock to a new temporally stock, in other way, the stock is set to 0
                        int productStock = [tmpProductObject total_on_hand] - [[dictTmpProduct objectForKey:@"TOTAL"] intValue];
                        (productStock > 0)?[tmpProductObject setTotal_on_hand:productStock]:[tmpProductObject setTotal_on_hand:0];
                        continue;
                    }
                }
            }
        }
    }
    
    /// Loop to check all the elements of the menu stored in arrProductsObjects.
    int productsCount = 0;
    for (ProductObject * tmpProductObject in arrOrderSelectedProducts) {
        /// Check if the product has been selected.
        if ([tmpProductObject quantity] != 0) {
            productsCount += [tmpProductObject quantity];
        }
    }
    //Call the method that determines if the bottom bar is displayed or not
    [self doShowPlaceOrderBottomBar:productsCount];
    return arrMenuProducts;
}

-(void)doUpdateProductsStockAfterNotification:(NSNotification *)notification
{
    /// Extract the data from user defaults.
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSData * data = [defaults objectForKey:@"dataCompleteNotification"];
    NSMutableArray * arrProductsStock = [NSKeyedUnarchiver unarchiveObjectWithData:data];

    /// Update the stock in local DB
    for (NSMutableDictionary * dictProduct in arrProductsStock) {
        [DBManager updateProductStock:[[dictProduct objectForKey:@"master_id"] intValue] withStock:[[dictProduct objectForKey:@"total_on_hand"]intValue]];
    }

    /// Set again the products array
    arrProductObjects = [[self setQuantitySelectedProducts:[DBManager getProducts]] mutableCopy];
    [tblProducts reloadData];
    
    /// Reset the values in user defaults
    [defaults setObject:nil forKey:@"dataCompleteNotification"];
    [defaults setObject:nil forKey:@"msg"];
    [defaults synchronize];
}

-(void)doUpdateMenu:(NSNotification*)notification
{
    /// Update the array temporally to clean it from selected products and display clean the menu.
    arrProductObjects = [[self setQuantitySelectedProducts:[DBManager getProducts]] mutableCopy];
    [tblProducts reloadData];

    /// Set and display de HUD for loading message.
    [[HUDJMProgress textLabel] setText:@"Loading products"];
    if (HUDJMProgress.visible != YES) {
        [HUDJMProgress showInView:[self view]];
    }
    AppDelegate * appDelegate =  [[UIApplication sharedApplication] delegate];
    /// Request to spree for the products of the current menu.
    [RESTManager updateProducts:[[appDelegate userObject] userSpreeToken] toCallback:^(id resultSignUp) {
        if ([resultSignUp isEqual:@YES]) {
            /// Set the array prodcuts - If the there's products selected by users, they will be set here.
            arrProductCategoriesObjects = [DBManager getCategories];
            arrProductObjects = [[self setQuantitySelectedProducts:[DBManager getProducts]] mutableCopy];
            /// Reload the table view to display de changes.
            [tblProducts reloadData];
            [self updateCategoryBar];
        }else{
            /// Create an alert view to inform that there's no menu available.
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Atention!" message:@"There's no Menu available" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        [HUDJMProgress dismiss];
    }];
}

#pragma mark -- Synchronize defaults
-(void)synchronizeDefaults
{
    /// Create an instance of user defaults.
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    /// Create a mutable array to store the selected products by user.
    NSMutableArray * arrProductsInQueue = [NSMutableArray new];
    
    /// Loop to check all the elements of the menu stored in arrProductsObjects.
    int productsCount = 0;
    for (int arrayDimention=0; arrayDimention<arrProductObjects.count; arrayDimention++) {
        for(ProductObject * tmpObject in [arrProductObjects objectAtIndex:arrayDimention])
        {
            /// Check if the product has been selected.
            if (tmpObject.quantity != 0) {
                productsCount += tmpObject.quantity;
                tmpObject.comment = @"";
                [arrProductsInQueue addObject:tmpObject];
            }
        }
    }
    /// Archive the array arrProductsInQueue with the selected products by user.
    [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:arrProductsInQueue] forKey:@"arrProductsInQueue"];
    [defaults synchronize];
    
    /// Call the method to determine if the bottom bar is displayed.
    [self doShowPlaceOrderBottomBar:productsCount];
}

#pragma mark -- Show place order bottom bar
-(void)doShowPlaceOrderBottomBar:(int)productsCount
{
    /// Initialize the height of the table checking if the viewCategories is hidden or not.
    int newTblProductsHeight = ([viewCategories isHidden])?tblProductsHeight-65:tblProductsHeight-125;
    int tblProductsYPosition = ([viewCategories isHidden])?65:125;
    /// Check for the quantity of selected products && if place order is not active.
    if (productsCount>0 && !isViewPlaceOrderActive) {
        /// Set flag in YES.
        isViewPlaceOrderActive = YES;
        /// Decrease the value of the table height
        newTblProductsHeight = newTblProductsHeight - 60;
        /// Make an animation to hide the place order bottom bar.
        [UIView animateWithDuration:0.4f animations:^{
            // Decrease
            [viewPlaceOrder setFrame:CGRectMake(0, self.view.frame.size.height-60, viewPlaceOrder.frame.size.width, 60)];
        } completion:^(BOOL finished) {
            [tblProducts setFrame:CGRectMake(0, tblProductsYPosition, self.view.frame.size.width, newTblProductsHeight)];
        }];
        
    }else if(productsCount==0 && isViewPlaceOrderActive){
        /// Set flag in NO.
        isViewPlaceOrderActive = NO;
        /// Increase the value of the table height
        [tblProducts setFrame:CGRectMake(0, tblProductsYPosition, self.view.frame.size.width, newTblProductsHeight)];
        /// Create an animation to shoe the place order bottom bar.
        [UIView animateWithDuration:0.4f animations:^{
            // Increase
            [viewPlaceOrder setFrame:CGRectMake(0, self.view.frame.size.height+60, viewPlaceOrder.frame.size.width, 60)];
        }];
    }
    /// Set the label which display the number of selected products by user.
    [lblProductsCount setText:(productsCount == 1)?[NSString stringWithFormat:@"%d Product",productsCount]:[NSString stringWithFormat:@"%d Products",productsCount]];
}

/// System method.
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/// Reload tblProducts table view.
-(void)doReloadData
{
    [tblProducts reloadData];
}

#pragma mark -- Table view data delegate
/// Define the height for a each row, based on which device is -iPhone 6 or another-.
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (IS_IPHONE_6_PLUS)?257:(IS_IPHONE_6)?234.0f:200.0f;
}

/// Return the number of sections based on the element that contains array arrProductObjects. If the filter is active return 1.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return (isPickerFilterActive) ? 1 : [arrProductObjects count]; // Save the count of sections
}

/// Return the number of rows for each section. Is determined by the number of elements in each sub-array stored in the main array arrProducObjects. If the filter is active return the section selected.
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return (isPickerFilterActive) ? [[arrProductObjects objectAtIndex:pickerFilterActiveOption] count] : [[arrProductObjects objectAtIndex:section] count];
}

/// Define the height for the header section.
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44;
}

/// Draw the content of each section of the table view.
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    // If the filter is active set the category selected.
    long filteredSection = (isPickerFilterActive) ? pickerFilterActiveOption : section;
    
    /// Create a view that will contain all the elements of the section.
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,  tableView.bounds.size.width, 44)];
    [headerView setBackgroundColor:[UIColor whiteColor]];
    
    /// Create and set a label to display the title of the sections.
    UILabel * lblSectionTitle = [[UILabel alloc] init];
    [lblSectionTitle setFrame:CGRectMake(19, 0, 200, 44)];
    NSString * sectionTitleUpperCase = [(CategoryObject *)[arrProductCategoriesObjects objectAtIndex:filteredSection] category_name ];
    [lblSectionTitle setText:[sectionTitleUpperCase uppercaseString]];
    [lblSectionTitle setFont:[UIFont fontWithName:@"Lato-Bold" size:18]];
    [lblSectionTitle setTextColor:[UIColor colorWithRed:74.0f/255.0f green:67.0f/255.0f blue:63.0f/255.0f alpha:255]];
    [headerView addSubview:lblSectionTitle];
    
    /// Create and set a label to display the number of elements in the section.
    UILabel * lblProductsNumber = [[UILabel alloc] init];
    [lblProductsNumber setFrame:CGRectMake(tblProducts.bounds.size.width -119, 0, 100, 44)];
    [lblProductsNumber setText:([[arrProductObjects objectAtIndex:filteredSection] count] > 1)?[NSString stringWithFormat:@"%d Products",(int)[[arrProductObjects objectAtIndex:filteredSection] count]]:[NSString stringWithFormat:@"%d Product",(int)[[arrProductObjects objectAtIndex:filteredSection] count]]];
    [lblProductsNumber setTextAlignment:NSTextAlignmentRight];
    [lblProductsNumber setTextColor:[UIColor colorWithRed:74.0f/255.0f green:67.0f/255.0f blue:63.0f/255.0f alpha:255]];
    [lblProductsNumber setFont:[UIFont fontWithName:@"Lato-Light" size:16]];
    [headerView addSubview:lblProductsNumber];
    
    return headerView;
}

///Draw the content of each row of the table view.
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    // If the filter is active set the category selected.
    long filteredSection = (isPickerFilterActive) ? pickerFilterActiveOption : indexPath.section;
    
    static NSString *CellIdentifier = @"CellProduct";
    
    /// Create the cell will contain all the elements.
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = nil;
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    /// Create a product object and
    productObject = [[ProductObject alloc] init];
    productObject = [[arrProductObjects objectAtIndex:filteredSection] objectAtIndex:(NSInteger)indexPath.row];
    
    /// --------- Product image
    UIImageView *imgProduct = [[UIImageView alloc] initWithFrame:(IS_IPHONE_6_PLUS)?CGRectMake(0, 0, 414,257):(IS_IPHONE_6)?CGRectMake(0, 0, 375, 234):CGRectMake(0, 0, 320, 200)];
    if(productObject.masterObject.imageObject.attachment_file_name != nil){
        NSString *documentDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *filePathAndDirectory = [documentDirectoryPath stringByAppendingString:@"/images/thumbs"];
        [[NSFileManager defaultManager] createDirectoryAtPath:filePathAndDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        NSString *fileName = [NSString stringWithFormat:@"%@", productObject.masterObject.imageObject.attachment_file_name];
        NSString *fullPath = [NSString stringWithFormat:@"%@/%@",filePathAndDirectory, fileName];
        [imgProduct setImage:[UIImage imageWithContentsOfFile:fullPath]];
    }else{
        [imgProduct setImage:[UIImage imageNamed:@"noAvail"]];
    }
    [cell addSubview:imgProduct];
    
    /// --------- Gradiant background
    UIImageView * imgGradiant = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Gradiant"]];
    [imgGradiant setFrame:[imgProduct bounds]];
    [cell addSubview:imgGradiant];
    
    /// --------- Product name
    UILabel *lblName = [[UILabel alloc] initWithFrame:(IS_IPHONE_6 || IS_IPHONE_6_PLUS)?CGRectMake(19, 187.5f, 222, 187.5f):CGRectMake(19, 100, 190, 100)];
    [lblName setText: [(NSString*)[productObject name] capitalizedString]];
    [lblName setFont:[UIFont fontWithName:@"Lato-Bold" size:19]];
    [lblName setTextAlignment:NSTextAlignmentLeft];
    [lblName setNumberOfLines:0];
    [lblName sizeToFit];
    [lblName setTextColor:[UIColor colorWithRed:255.0f green:255.0f blue:255.0f alpha:1.0f]];
    [lblName setFrame:CGRectMake(19, (imgProduct.frame.size.height - 9) - lblName.frame.size.height, lblName.frame.size.width, lblName.frame.size.height)];
    [cell addSubview:lblName];

    /// --------- Add button
    CustomButton *btnAdd = [CustomButton buttonWithType:UIButtonTypeCustom];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    /// Create a date formatter
    NSDateFormatter * dtFormatter = [[NSDateFormatter alloc] init];
    [dtFormatter setLocale:locale];
    [dtFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [dtFormatter setDateFormat:@"HH:mm"];
    NSString * currentEndHour = [NSString stringWithFormat:@"%@", productObject.endHour];
     NSDate * initialAvailableTime = [dtFormatter dateFromString:productObject.startHour];
     NSDate * finalAvailableTime = [dtFormatter dateFromString:currentEndHour];
     /// Get the current time from the server
     AppDelegate * appDelegate = [[UIApplication sharedApplication] delegate];
     NSDateFormatter * dtFormatterFullTimeFormat = [[NSDateFormatter alloc] init];
    [dtFormatterFullTimeFormat setLocale:locale];
    [dtFormatterFullTimeFormat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [dtFormatterFullTimeFormat setDateFormat:@"HH:mm:ss"];
     NSDate * currentTime = [dtFormatterFullTimeFormat dateFromString:[appDelegate strCurrentHour]];
     BOOL bIsAvail = (([currentTime compare:initialAvailableTime] == NSOrderedDescending) &&  ([currentTime compare:finalAvailableTime] == NSOrderedAscending));
    if(!bIsAvail || (![productObject total_on_hand] > [productObject quantity] || productObject.total_on_hand < 0))
    {
        //Button outstock
        UIView * viewOutOfStock = [[UIView alloc] initWithFrame:CGRectMake( (tblProducts.bounds.size.width - 148) / 2, ( ((IS_IPHONE_6_PLUS)?257:(IS_IPHONE_6)?234.0f:200.0f) -27) / 2, 148, 27)];
        //UIView * viewOutOfStock = [[UIView alloc] initWithFrame:(IS_IPHONE_6)?CGRectMake(113.5f, 101, 148, 27):CGRectMake(86, 86, 148, 27)];
        [viewOutOfStock setBackgroundColor:[UIColor colorWithRed:255.0f/255.0f green:127.0f/255.0f blue:0.0f/255.0f alpha:1.0f]];
        [viewOutOfStock.layer setCornerRadius:5.0f];
        [viewOutOfStock.layer setMasksToBounds:YES];
        UILabel * lblOutOfStock = [[UILabel alloc] initWithFrame:CGRectMake(6.5f, 0.0f, 118.0f, 27.0f)];
        [lblOutOfStock setText:@"OUT OF STOCK"];
        [lblOutOfStock setTextAlignment:NSTextAlignmentLeft];
        [lblOutOfStock setTextColor:[UIColor whiteColor]];
        [lblOutOfStock setFont:[UIFont fontWithName:@"Lato-Bold" size:16]];
        [viewOutOfStock addSubview:lblOutOfStock];
        UIImageView * imgOutOfStock = [[UIImageView alloc] initWithFrame:CGRectMake(124.5f, 4.5f, 18.0f, 18.0f)];
        [imgOutOfStock setImage:[UIImage imageNamed:@"SadFace"]];
        [viewOutOfStock addSubview:imgOutOfStock];
        [cell addSubview:viewOutOfStock];
    }
    else
    {
        /// Check if the quantity is equal to total on hand, if it is, then set enabled property in NO.
        [btnAdd setEnabled:([productObject total_on_hand] == [productObject quantity])?NO:YES];
        
        /// Check if the quantity -selected product- is more than zero to modify the aspect of the add button.
        [btnAdd setFrame:CGRectMake(tblProducts.bounds.size.width -59, ((IS_IPHONE_6_PLUS)?257:(IS_IPHONE_6)?234.0f:200.0) - 51 , 40, 40)];
        //[btnAdd setFrame:(IS_IPHONE_6)?CGRectMake(316, 183, 40, 40):CGRectMake(261, 149, 40, 40)];
        [btnAdd setImage:[UIImage imageNamed:@"AddButton"] forState:UIControlStateNormal];
        [btnAdd setImage:[UIImage imageNamed:@"AddButton_Pressed"] forState:UIControlStateHighlighted];

        [btnAdd setIndex:(int)indexPath.row];
        [btnAdd setSection:(int)indexPath.section];

        [btnAdd addTarget:self action:@selector(didSelectProduct:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:btnAdd];
        
        /// -------- Minus button
        CustomButton *btnMinus = [CustomButton buttonWithType:UIButtonTypeCustom];
        if ([productObject quantity] > 0)
        {
            [btnMinus setFrame:CGRectMake(tblProducts.bounds.size.width - 109, ((IS_IPHONE_6_PLUS)?257:(IS_IPHONE_6)?234.0f:200.0) -51, 40, 40)];
            //[btnMinus setFrame:(IS_IPHONE_6)?CGRectMake(266, 183, 40, 40):CGRectMake(211, 149, 40, 40)];
            [btnMinus setImage:[UIImage imageNamed:@"SubstractButton"] forState:UIControlStateNormal];
            [btnMinus setImage:[UIImage imageNamed:@"SubstractButton-Pressed"] forState:UIControlStateHighlighted];
        }
        [btnMinus setTitle:@"-" forState:UIControlStateNormal];
        [btnMinus setIndex:(int)indexPath.row];
        [btnMinus setSection:(int)indexPath.section];
        [btnMinus setHidden:(productObject.quantity > 0)?NO:YES];
        [btnMinus addTarget:self action:@selector(didDeselectProduct:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:btnMinus];
        
        /// -------- Quantity selected
        UIImageView * imgBadge = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Circle_Count"]];
        [imgBadge setFrame:CGRectMake(tblProducts.bounds.size.width - 32, ((IS_IPHONE_6_PLUS)?257:(IS_IPHONE_6)?234.0f:200.0)-63, 25, 25)];
        //[imgBadge setFrame:(IS_IPHONE_6)?CGRectMake(343, 171, 25, 25):CGRectMake(288, 137, 25, 25)];
        [imgBadge setHidden:(productObject.quantity > 0)?NO:YES];
        [cell addSubview:imgBadge];
        
        UILabel *lblQuantity = [[UILabel alloc] initWithFrame:CGRectMake(tblProducts.bounds.size.width - 32, ((IS_IPHONE_6_PLUS)?257:(IS_IPHONE_6)?234.0f:200.0)-63, 25, 25)];
        [lblQuantity setText:[NSString stringWithFormat:@"%d", productObject.quantity]];
        [lblQuantity setTextAlignment:NSTextAlignmentCenter];
        [lblQuantity setTextColor:[UIColor whiteColor]];
        [lblQuantity setNumberOfLines:0];
        [lblQuantity setFont:[UIFont fontWithName:@"Lato-Bold" size:12]];
        [lblQuantity setHidden:(productObject.quantity > 0)?NO:YES];
        [cell addSubview:lblQuantity];
        /// --------------------------
        
        /// Check for the stock of the product to enable/disable the add button
        [btnAdd setEnabled:([productObject total_on_hand] <= [productObject quantity])? NO:YES];
    }
    
    return cell;
}

#pragma mark -- action for + button in cell
-(void)didSelectProduct:(id)sender
{
    /// Extract the content of the sender param and create a custom button
    CustomButton * senderButton = (CustomButton*)sender;
    
    // If the filter is active set the category selected.
    long filteredSection = (isPickerFilterActive) ? pickerFilterActiveOption : senderButton.section;
    
    /// Check if the product quantity is equal to one, then display an alert view to ask the user if he wants to add more items to his selection.
    if (((ProductObject *)[[arrProductObjects objectAtIndex:filteredSection] objectAtIndex:((CustomButton *)sender).index]).quantity==1) {
        senderButton.selected = YES;
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Please check!" message:[NSString stringWithFormat:@"Are you sure you want to add two items to your order?"] delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        currentSection = (int)filteredSection;
        [alert setTag:((CustomButton*)sender).index];
        [alert show];
    }else{
        /// Add one more to product quantity
        ProductObject * selectedProduct = [ProductObject new];
        selectedProduct = [[arrProductObjects objectAtIndex:filteredSection] objectAtIndex:senderButton.index];
        selectedProduct.quantity ++;
        [self doReloadData];
        [self synchronizeDefaults];
    }
}

-(void)didDeselectProduct:(id)sender
{
    /// Create a product object variable.
    ProductObject * selectedProduct = [ProductObject new];
    /// Extract the content of sender param.
    CustomButton * senderButton = (CustomButton*)sender;
    
    // If the filter is active set the category selected.
    long filteredSection = (isPickerFilterActive) ? pickerFilterActiveOption : senderButton.section;
    
    /// Set product object with the reference of the selected product stored in arrProductObjects.
    selectedProduct = [[arrProductObjects objectAtIndex:filteredSection] objectAtIndex:senderButton.index];
    selectedProduct.quantity --;
    [self doReloadData];
    [self synchronizeDefaults];
}

#pragma mark -- button place Order
- (IBAction)doPlaceOrder:(id)sender{
    AppDelegate * appDelegate = [[UIApplication sharedApplication] delegate];
    /// Check if the location service are available and if the user`s location is under 1,000 meters.
    /// In case of false, a custom alert view is displayed to inform the user about.
    //if ([self updateDistanceToAnnotation]>1000 && areLocationServicesAvailable) {
    if (([self updateDistanceToAnnotation] > 1000) && areLocationServicesAvailable) {
        /// Create the custom alert.
        LMAlertView * alertView = [[LMAlertView alloc] initWithTitle:@"" message:nil delegate:self cancelButtonTitle:@"Ooh, Something happens!" otherButtonTitles:nil];
        [alertView setSize:CGSizeMake(250.0f, 320.0f)];
        
        /// Create an UIView that will contain all the elements of the alert.
        UIView *contentView = alertView.contentView;
        [contentView setBackgroundColor:[UIColor clearColor]];
        [alertView setBackgroundColor:[UIColor clearColor]];
        
        /// Create an UIImageView and set the proper illustration for the case.
        UIImageView * imgV = [[UIImageView alloc] initWithFrame:CGRectMake(60.0f, 10.0f, 129.0f, 200.0f)];
        [imgV setImage:[UIImage imageNamed:@"illustration_04"]];
        [contentView addSubview:imgV];
        /// Create a UILaberl to display the message.
        UILabel * lblStatus = [[UILabel alloc] initWithFrame:CGRectMake(10, 175, 230, 120)];
        [lblStatus setTextAlignment:NSTextAlignmentCenter];
        lblStatus.numberOfLines = 3;
        lblStatus.text = [NSString stringWithFormat:@"%@ you are out of range to request an order!", appDelegate.userObject.firstName];
        [contentView addSubview:lblStatus];
        [alertView show];
    }else{
        /// Create an instance of user defaults.
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        /// Create an array to store the array of products in queue from user defaults.
        NSMutableArray * arrProductsInQueue = [NSMutableArray new];
        
        /// Set flag isPlaceOrder in YES.
        BOOL isPlaceOrder = YES;
        /// Set variable productsCount in zero.
        int productsCount = 0;
        /// Look for the products in the arrProductObjects.
        for (int arrayDimention=0; arrayDimention<arrProductObjects.count; arrayDimention++) {
            for(ProductObject * tmpObject in [arrProductObjects objectAtIndex:arrayDimention])
            {
                /// Check if the quantity selected is more than zero
                if (tmpObject.quantity != 0) {
                    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
                    /// Create a date formatter
                    NSDateFormatter * dtFormatter = [[NSDateFormatter alloc] init];
                    [dtFormatter setLocale:locale];
                    [dtFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
                    [dtFormatter setDateFormat:@"HH:mm"];
                    NSString * currentEndHour = [NSString stringWithFormat:@"%@", productObject.endHour];
                    NSDate * initialAvailableTime = [dtFormatter dateFromString:productObject.startHour];
                    NSDate * finalAvailableTime = [dtFormatter dateFromString:currentEndHour];
                    /// Get the current time from the server
                    AppDelegate * appDelegate = [[UIApplication sharedApplication] delegate];
                    NSDateFormatter * dtFormatterFullTimeFormat = [[NSDateFormatter alloc] init];
                    [dtFormatterFullTimeFormat setLocale:locale];
                    [dtFormatterFullTimeFormat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
                    [dtFormatterFullTimeFormat setDateFormat:@"HH:mm:ss"];
                    NSDate * currentTime = [dtFormatterFullTimeFormat dateFromString:[appDelegate strCurrentHour]];
                    BOOL bIsAvail = (([currentTime compare:initialAvailableTime] == NSOrderedDescending) &&  ([currentTime compare:finalAvailableTime] == NSOrderedAscending));
                    NSLog(@"bIsAvailInDoPlaceOrder: %d", bIsAvail);
                    
                    if(!bIsAvail)//todo:check here product availability
                    {
                        /// Set the quantity of the product in zero.
                        tmpObject.quantity = 0;
                        /// Create a custom alert view.
                        LMAlertView * alertView = [[LMAlertView alloc] initWithTitle:@"" message:nil delegate:self cancelButtonTitle:@"Ok, Something happened." otherButtonTitles:nil];
                        [alertView setSize:CGSizeMake(250.0f, 320.0f)];
                        
                        /// Create an UIView to store all the elements of the custom alert view.
                        UIView *contentView = alertView.contentView;
                        [contentView setBackgroundColor:[UIColor clearColor]];
                        [alertView setBackgroundColor:[UIColor clearColor]];
                        
                        /// Create an UIImageView to set the proper illustration.
                        UIImageView * imgV = [[UIImageView alloc] initWithFrame:CGRectMake(60.0f, 10.0f, 129.0f, 200.0f)];
                        [imgV setImage:[UIImage imageNamed:@"illustration_03"]];
                        [contentView addSubview:imgV];
                        /// Create an UILabel to set the message of the alert view.
                        UILabel * lblStatus = [[UILabel alloc] initWithFrame:CGRectMake(10, 175, 230, 120)];
                        [lblStatus setTextAlignment:NSTextAlignmentCenter];
                        lblStatus.numberOfLines = 3;
                        lblStatus.text = [NSString stringWithFormat:@"%@ The period to make an order it's over.", appDelegate.userObject.firstName];
                        [contentView addSubview:lblStatus];
                        [alertView show];
                        [self synchronizeDefaults];
                        isPlaceOrder = NO;
                        [tblProducts reloadData];
                        break;
                    }else{
                        /// Add the productsCount variable.
                        productsCount += tmpObject.quantity;
                        [arrProductsInQueue addObject:tmpObject];
                    }
                }
            }
        }
        
        /// Check the flag isPlaceOrder.
        if (isPlaceOrder) {
            /// Archive the arrProductsInQueue array in user defaults.
            [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:arrProductsInQueue] forKey:@"arrProductsInQueue"];
            [defaults synchronize];
            
            /// Set isMenuViewController flag to No in the AppDelegate
            [appDelegate setIsMenuViewController:NO];
            
            [self.navigationController dismissViewControllerAnimated:NO completion:nil];
            /// Create an instance of ShoppingCartViewController.
            ShoppingCartViewController *shoppingCartViewController = [[ShoppingCartViewController alloc] init];
            [self bdb_presentPopupViewController:shoppingCartViewController
                                   withAnimation:BDBPopupViewShowAnimationDefault
                                  completion:nil];
        }
    }
}

#pragma mark -- UIAlertViewDelegate
/// Alert view delegate. Add the quantity to a specific product when the user select more than one.
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    /// Check is the title of the alert view is "Please check!"
    if([alertView.title isEqual:@"Please check!"])
    {
        /// If the button index is one, create an ProductObject object and is setted with the one from arrProductsObjects.
        if (buttonIndex == 1) {
            ProductObject * selectedProduct = [ProductObject new];
            selectedProduct = [[arrProductObjects objectAtIndex:currentSection] objectAtIndex:alertView.tag];
            currentSection = 0;
            selectedProduct.quantity ++;
            [self doReloadData];
            [self synchronizeDefaults];
        }
    }
}

#pragma mark -- CropImage
/// Crop a image sended to the method.
- (UIImage*) getSubImageFrom: (UIImage*) img WithRect: (CGRect) rect {
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    // translated rectangle for drawing sub image
    //CGRect drawRect = CGRectMake(-rect.origin.x, -rect.origin.y, img.size.width, img.size.height);
    CGRect drawRect = CGRectMake(0, 0, img.size.width, img.size.height);
    // clip to the bounds of the image context
    // not strictly necessary as it will get clipped anyway?
    CGContextClipToRect(context, CGRectMake(0, 0, rect.size.width, rect.size.height));
    // draw image
    [img drawInRect:drawRect];
    // grab image
    UIImage* subImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return subImage;
}

#pragma mark -- MapKit Delegates
/// Update the distance between the user position and the destination point.
-(double)updateDistanceToAnnotation{
    /// Set the location of the destiny point.
    CLLocation *pinLocation = [[CLLocation alloc]
                               initWithLatitude:+19.26506377
                               longitude:-103.71073774];
    /// Set the current location of the user.
    CLLocation *userLocation = [[CLLocation alloc]
                                initWithLatitude:mapKitView.userLocation.coordinate.latitude
                                longitude:mapKitView.userLocation.coordinate.longitude];
    /// Calculate the distance between the points.
    CLLocationDistance distance = [pinLocation distanceFromLocation:userLocation];
    
    return distance;
}

/// Set the flag areLocationServicesAvailable in NO when the location services are off.
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    areLocationServicesAvailable = NO;
}

/// Set the flag areLocationServicesAvailable in YES when the location services are on.
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    areLocationServicesAvailable = YES;
}

/// Refresh the map after the user location was updated.
-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    /// Draw the user position.
    MKCoordinateRegion mapRegion;
    mapRegion.center = mapView.userLocation.coordinate;
    mapRegion.span.latitudeDelta = 0.002;
    mapRegion.span.longitudeDelta = 0.002;
    
    [mapKitView setRegion:mapRegion animated: YES];
}

#pragma mark -- updateCategory
/// Set values of each category in the top bar
-(void)updateCategoryBar{
    //Remove subviews from viewScroll
    for (UIView * view in viewScrollCategories.subviews){
        [view removeFromSuperview];
    }
    
    int indexArrayProductCategories = -1; // set index of category
    float xPositionCategory = 3.0, widthLastCategory = 0.0; //position of each category
    
    UIButton * btnCategoryAll = [[UIButton alloc] initWithFrame:CGRectMake(xPositionCategory, 0, 5*12, 57)];
    [btnCategoryAll setTitle:@"ALL" forState:UIControlStateNormal];
    [btnCategoryAll addTarget:self action:@selector(setFilter:) forControlEvents:UIControlEventTouchUpInside];
    [btnCategoryAll setTitleColor:[UIColor colorWithRed:146.0f/255.0f green:132.0f/255.0f blue:125.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    [btnCategoryAll.titleLabel setFont:[UIFont fontWithName:@"Lato-Bold" size:12]];
    [btnCategoryAll.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [btnCategoryAll setTag:indexArrayProductCategories];
    [viewScrollCategories addSubview:btnCategoryAll];
    if (!isPickerFilterActive) { //If filter is active
        UILabel *lblActiveCategory = [[UILabel alloc] init];
        [lblActiveCategory setFrame:CGRectMake(xPositionCategory-11+(5*12/2), 25, 25, 25)];
        lblActiveCategory.textAlignment = NSTextAlignmentCenter;
        [lblActiveCategory setText:@"·"];
        [lblActiveCategory setFont:[UIFont fontWithName:@"Lato-Light" size:80]];
        [lblActiveCategory setTextColor:[UIColor colorWithRed:255.0f/255.0f green:127.0f/255.0f blue:0.0f/255.0f alpha:1.0f]];
        [viewScrollCategories addSubview:lblActiveCategory];
    }
    indexArrayProductCategories ++;
    xPositionCategory += 50;
    for (CategoryObject *category in arrProductCategoriesObjects) {
        //Create label of category
        UIButton * btnCategory = [[UIButton alloc] initWithFrame:CGRectMake(xPositionCategory, 0, [category.category_name length]*12, 57)];
        [btnCategory setTitle:[category.category_name uppercaseString] forState:UIControlStateNormal];
        [btnCategory addTarget:self action:@selector(setFilter:) forControlEvents:UIControlEventTouchUpInside];
        [btnCategory setTitleColor:[UIColor colorWithRed:146.0f/255.0f green:132.0f/255.0f blue:125.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
        [btnCategory.titleLabel setFont:[UIFont fontWithName:@"Lato-Bold" size:12]];
        [btnCategoryAll.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [btnCategory setTag:indexArrayProductCategories];
        [viewScrollCategories addSubview:btnCategory];
        if (isPickerFilterActive && indexArrayProductCategories == pickerFilterActiveOption) { //If filter is active
            UILabel *lblActiveCategory = [[UILabel alloc] init];
            [lblActiveCategory setFrame:CGRectMake(xPositionCategory-11+([category.category_name length]*12/2), 25, 25, 25)];
            lblActiveCategory.textAlignment = NSTextAlignmentCenter;
            [lblActiveCategory setText:@"·"];
            [lblActiveCategory setFont:[UIFont fontWithName:@"Lato-Light" size:80]];
            [lblActiveCategory setTextColor:[UIColor colorWithRed:255.0f/255.0f green:127.0f/255.0f blue:0.0f/255.0f alpha:1.0f]];
            [viewScrollCategories addSubview:lblActiveCategory];
        }
        xPositionCategory += [category.category_name length]*12;
        indexArrayProductCategories ++;
        widthLastCategory = [category.category_name length]*12;
    }
    viewScrollCategories.contentSize = CGSizeMake(xPositionCategory, 57); //Assign content size
}

-(void)doHideShowCategoryFilter:(id)sender
{
    [viewCategories setHidden:![viewCategories isHidden]];
    if(![viewCategories isHidden])
    {
        [viewCategories setAlpha:0.0f];
    }
    int newTblProductsHeight = ([viewCategories isHidden])?tblProductsHeight-65:tblProductsHeight-125;
    newTblProductsHeight = (isViewPlaceOrderActive)?newTblProductsHeight-60:newTblProductsHeight;
    [UIView animateWithDuration:0.2f animations:^{
        [tblProducts setFrame:CGRectMake(0, ([viewCategories isHidden])?65:125, tblProducts.frame.size.width, newTblProductsHeight)];
        [separatorView setFrame:CGRectMake(0, ([viewCategories isHidden])?64:124, self.view.frame.size.width, 1)];
    } completion:^(BOOL finished) {
        [viewCategories setAlpha:1.0f];
    }];
}

// Asign new filter and refresh
-(void)setFilter:(id)sender{
    //UILabel *selection = (UILabel *)tapGesture.view;
    isPickerFilterActive = ([sender tag] + 1==0) ? NO : YES;
    pickerFilterActiveOption = [sender tag];
    [self doReloadData];
    [self synchronizeDefaults];
    [self updateCategoryBar];
}

@end
