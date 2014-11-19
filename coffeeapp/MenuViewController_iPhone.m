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
// -- Franciso Flores --

#import "MenuViewController_iPhone.h"
#import "DBManager.h"
#import "RESTManager.h"

//Macros to identify size screen
#define IS_IPHONE_5 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)568) < DBL_EPSILON) 
#define IS_IPHONE_6 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)667) < DBL_EPSILON) 
#define IS_IPHONE_6_PLUS (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)736) < DBL_EPSILON)

@interface MenuViewController_iPhone ()

@end

@implementation MenuViewController_iPhone
@synthesize mapKitView, locationManager, arrProductObjects, arrProductCategoriesObjects, isViewPlaceOrderActive, tblProducts, lblCurrentDay, arrWeekDays, HUDJMProgress, productObject, currentDayOfWeek, viewPlaceOrder, lblProductsCount, btnPlaceOrder, areMealsAvailable, currentSection, areLocationServicesAvailable;

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
    //Arrays data init
    arrWeekDays = [[NSArray alloc] initWithObjects:@"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", @"Sunday", nil];
    areLocationServicesAvailable = YES;
    //Set the elementos on the placeHolder view
    [[self view] setFrame:(IS_IPHONE_6)?CGRectMake(0, 0, 375, 667):(IS_IPHONE_5)?CGRectMake(0, 0, 320, 568):CGRectMake(0, 0, 320, 480)];
    [viewPlaceOrder setFrame:CGRectMake(0, self.view.frame.size.height+60, self.view.frame.size.width, 60)];
    [viewPlaceOrder setBackgroundColor:[UIColor colorWithRed:217.0f/255.0f green:109.0f/255.0f blue:0.0f/255.0f alpha:1.0f]];
    [lblProductsCount setFrame:CGRectMake(20, 0, 100, 60)];
    [lblProductsCount setTextAlignment:NSTextAlignmentLeft];
    [btnPlaceOrder setFrame:(IS_IPHONE_6)?CGRectMake(230, 0, 120, 60):CGRectMake(175, 0, 120, 60)];
    [[btnPlaceOrder titleLabel] setFont:[UIFont fontWithName:@"Lato-Bold" size:18]];
    [[btnPlaceOrder titleLabel] setTextAlignment:NSTextAlignmentRight];
    
    isViewPlaceOrderActive = NO;
    // check if meals are available based on server time
    [RESTManager sendData:nil toService:@"v1/current_time" withMethod:@"GET" isTesting:NO withAccessToken:nil isAccessTokenInHeader:NO toCallback:^(id result) {
        if([[result objectForKey:@"success"] isEqual:@NO])
        {
            if (HUDJMProgress) {
                [HUDJMProgress dismissAnimated:YES];
            }
            return;
        }
        NSString * strHr = [[result objectForKey:@"current_time"] substringToIndex:2];
        if([strHr intValue] > 7 && [strHr intValue] < 11)
        {
            areMealsAvailable = YES;
        }
        else
        {
            areMealsAvailable = NO;
        }
    }];
   
    //Setting up tableview delegates and datasources
    [tblProducts setDelegate:self];
    [tblProducts setDataSource:self];
    HUDJMProgress = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    arrProductObjects = [NSMutableArray new];
    
    //Update prodcuts
    [[HUDJMProgress textLabel] setText:@"Loading products"];
    [HUDJMProgress showInView:[self view]];
    AppDelegate * appDelegate =  [[UIApplication sharedApplication] delegate];
    [RESTManager updateProducts:[[appDelegate userObject] userSpreeToken] toCallback:^(id resultSignUp) {
        if ([resultSignUp isEqual:@YES]) {
            //Set the array prodcuts - If the there's products selected by users, they will be set here.
            arrProductCategoriesObjects = [DBManager getCategories];
            arrProductObjects = [[self setQuantitySelectedProducts:[DBManager getProducts]] mutableCopy];
            [tblProducts reloadData];
        }else{
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Atention!" message:@"There's no Menu available" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        [HUDJMProgress dismiss];
    }];
    
    NSDate *now = [NSDate date];
    NSDateFormatter *weekday = [[NSDateFormatter alloc] init];
    [weekday setDateFormat: @"e"];
    currentDayOfWeek = ([[weekday stringFromDate:now] intValue] == 1)? 8:[[weekday stringFromDate:now] intValue]; // Get the current date
    
    //Create a notification that reload data
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doUpdateMenu:) name:@"doUpdateMenu" object:nil];
    UILabel * lblControllerTitle = [[UILabel alloc] init];
    [lblControllerTitle setFrame:CGRectMake(0, 0, 140, 50)];
    [lblControllerTitle setText:@"The Crowd's Chef"];
    [lblControllerTitle setFont:[UIFont fontWithName:@"Lato-Light" size:20]];
    [lblControllerTitle setTextColor:[UIColor whiteColor]];
    [[self navigationItem] setTitleView:lblControllerTitle];
    
    //Create observer to update products stock without call the spree service
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doUpdateProductsStockAfterNotification:) name:@"doUpdateProductsStockAfterNotification" object:nil];
    
    // Create a location manager
    locationManager = [[CLLocationManager alloc] init];
    // Set a delegate to receive location callbacks
    locationManager.delegate = self;
    // Start the location manager
    [locationManager startUpdatingLocation];
    
    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [locationManager requestWhenInUseAuthorization];
    }
    [locationManager startUpdatingLocation];
    
    // initialice mapkit
    mapKitView.delegate = self;
    [mapKitView setShowsUserLocation:YES];
}

-(void)viewDidAppear:(BOOL)animated{
    //Set objects to fit screen
    if (isViewPlaceOrderActive) {
        [tblProducts setFrame: (IS_IPHONE_6)?CGRectMake(0, 64, 375, 545):(IS_IPHONE_5)?CGRectMake(0, 64, 320, 446):CGRectMake(0, 64, 320, 358)];
    }else{
        [tblProducts setFrame:(IS_IPHONE_6)?CGRectMake(0, 64, 375, 603):(IS_IPHONE_5)?CGRectMake(0, 64, 320, 504):CGRectMake(0, 64, 320, 416)];
    }
}

#pragma mark -- setQuantitySelectedProducts delegate
-(NSMutableArray*)setQuantitySelectedProducts:(NSMutableArray *)arrMenuProducts
{
    NSUserDefaults *defaults =  [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:@"arrProductsInQueue"];
    NSMutableArray *arrOrderSelectedProducts = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    //Check is there's prodcuts selected by user.
    if ([arrOrderSelectedProducts count] > 0) {
        for (int arrayDimention=0; arrayDimention<arrMenuProducts.count; arrayDimention++) {
            for(ProductObject *prodObject in [arrMenuProducts objectAtIndex:arrayDimention]){
                MasterObject *masterObject = [prodObject masterObject];
                //Loop for the array that contains the selected products by user
                for (ProductObject *orderSelectedProduct in arrOrderSelectedProducts) {
                    MasterObject *orderMasterProduct = [orderSelectedProduct masterObject];
                    //if the id from selected product is equal to id from menu product, aasign the quantity to display.
                    if ([orderMasterProduct masterObject_id] == [masterObject masterObject_id]) {
                        [prodObject setQuantity:[orderSelectedProduct quantity]];
                        continue;
                    }
                }
            }
        }
    }
    
    NSArray * arrProductsOrdered = [[NSArray alloc] initWithArray:[DBManager getProductsInConfirm]];
    if ([arrProductsOrdered count] > 0) {
        for (NSArray * arrTmpProducts in arrMenuProducts) {
            for (ProductObject *tmpProductObject in arrTmpProducts) {
                //Loop for set the temporally stock to products
                for (NSDictionary * dictTmpProduct in arrProductsOrdered) {
                    if ([tmpProductObject.masterObject masterObject_id] == [[dictTmpProduct objectForKey:@"PRODUCT_ID"] intValue]) {
                        //Check the stock and the quantity ordered
                        //Sustract the ordered quantity to total on hand. If more than 0, update the stock to a new temporally stock, in other way, the stock is set to 0
                        int productStock = [tmpProductObject total_on_hand] - [[dictTmpProduct objectForKey:@"TOTAL"] intValue];
                        (productStock > 0)?[tmpProductObject setTotal_on_hand:productStock]:[tmpProductObject setTotal_on_hand:0];
                        NSLog(@"%d", [tmpProductObject total_on_hand]);
                        continue;
                    }
                }
            }
        }
    }
        //Call the method that determines if the bottom bar is displayed or not
    [self doShowPlaceOrderBottomBar:(int)[arrOrderSelectedProducts count]];
    return arrMenuProducts;
}

-(void)doUpdateProductsStockAfterNotification:(NSNotification *)notification
{
    //Extract the data from user defaults
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSData * data = [defaults objectForKey:@"dataCompleteNotification"];
    NSMutableArray * arrProductsStock = [NSKeyedUnarchiver unarchiveObjectWithData:data];

    //Update the stock in local DB
    for (NSMutableDictionary * dictProduct in arrProductsStock) {
        [DBManager updateProductStock:[[dictProduct objectForKey:@"master_id"] intValue] withStock:[[dictProduct objectForKey:@"total_on_hand"]intValue]];
    }

    //Set again the products array
    arrProductObjects = [[self setQuantitySelectedProducts:[DBManager getProducts]] mutableCopy];
    [tblProducts reloadData];
    
    //Reset the values in user defaults
    [defaults setObject:nil forKey:@"dataCompleteNotification"];
    [defaults setObject:nil forKey:@"msg"];
    [defaults synchronize];
}

-(void)doUpdateMenu:(NSNotification*)notification
{
    //Update prodcuts
    [[HUDJMProgress textLabel] setText:@"Loading products"];
    [HUDJMProgress showInView:[self view]];
    AppDelegate * appDelegate =  [[UIApplication sharedApplication] delegate];
    [RESTManager updateProducts:[[appDelegate userObject] userSpreeToken] toCallback:^(id resultSignUp) {
        if ([resultSignUp isEqual:@YES]) {
            //Set the array prodcuts - If the there's products selected by users, they will be set here.
            arrProductCategoriesObjects = [DBManager getCategories];
            arrProductObjects = [[self setQuantitySelectedProducts:[DBManager getProducts]] mutableCopy];
            [tblProducts reloadData];
        }else{
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Atention!" message:@"There's no Menu available" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        [HUDJMProgress dismiss];
    }];
}

#pragma mark -- Synchronize defaults
-(void)synchronizeDefaults
{
    //Update the information of selected products in user defaults
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray * arrProductsInQueue = [NSMutableArray new];
    
    int productsCount = 0;
    for (int arrayDimention=0; arrayDimention<arrProductObjects.count; arrayDimention++) {
        for(ProductObject * tmpObject in [arrProductObjects objectAtIndex:arrayDimention])
        {
            if (tmpObject.quantity != 0) {
                productsCount += tmpObject.quantity;
                [arrProductsInQueue addObject:tmpObject];
            }
        }
    }
    [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:arrProductsInQueue] forKey:@"arrProductsInQueue"];
    [defaults synchronize];
    
    //Call the method to determine if the bottom bar is displayed
    [self doShowPlaceOrderBottomBar:productsCount];
}

#pragma mark -- Show place order bottom bar
-(void)doShowPlaceOrderBottomBar:(int)productsCount
{
    // If found products in shoppingCart && is not visible the viewPlaceOrder
    if (productsCount>0 && !isViewPlaceOrderActive) {
        isViewPlaceOrderActive = YES;
        [UIView animateWithDuration:0.4f animations:^{
            // Decrease
            [viewPlaceOrder setFrame:CGRectMake(0, self.view.frame.size.height-60, viewPlaceOrder.frame.size.width, 60)];
        } completion:^(BOOL finished) {
            [tblProducts setFrame: (IS_IPHONE_6)?CGRectMake(0, 64, 375, 545):(IS_IPHONE_5)?CGRectMake(0, 64, 320, 446):CGRectMake(0, 64, 320, 358)];
        }];
        
    }else if(productsCount==0 && isViewPlaceOrderActive){
        isViewPlaceOrderActive = NO;
        [tblProducts setFrame:(IS_IPHONE_6)?CGRectMake(0, 64, 375, 603):(IS_IPHONE_5)?CGRectMake(0, 64, 320, 504):CGRectMake(0, 64, 320, 416)];
        [UIView animateWithDuration:0.4f animations:^{
            // Increase
            [viewPlaceOrder setFrame:CGRectMake(0, self.view.frame.size.height+60, viewPlaceOrder.frame.size.width, 60)];
        }];
    }
    [lblProductsCount setText:(productsCount == 1)?[NSString stringWithFormat:@"%d Product",productsCount]:[NSString stringWithFormat:@"%d Products",productsCount]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)doReloadData
{
    [tblProducts reloadData];
}

#pragma mark -- Table view data delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (IS_IPHONE_6)?280.0f:240.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [arrProductObjects count]; // Save the count of sections
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[arrProductObjects objectAtIndex:section] count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    //to-do:refactor this for other screen size
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,  tableView.bounds.size.width, 50)];
    
    UIImageView * imgBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,  tableView.bounds.size.width, 50)];
    [imgBackground setImage:[UIImage imageNamed:@"patron_01"]];
    [headerView addSubview:imgBackground];
    
    UILabel * lblSectionTitle = [[UILabel alloc] init];
    [lblSectionTitle setFrame:CGRectMake(20, 0, 200, 50)];
    [lblSectionTitle setText:[(CategoryObject *)[arrProductCategoriesObjects objectAtIndex:section] category_name ]];
    [lblSectionTitle setFont:[UIFont fontWithName:@"Lato-Light" size:20]];
    [lblSectionTitle setTextColor:[UIColor colorWithRed:255 green:255 blue:255 alpha:255]];
    [headerView addSubview:lblSectionTitle];
    
    UILabel * lblProductsNumber = [[UILabel alloc] init];
    [lblProductsNumber setFrame:(IS_IPHONE_6)?CGRectMake(250, 0, 100, 50):CGRectMake(200, 0, 100, 50)];
    [lblProductsNumber setText:([[arrProductObjects objectAtIndex:section] count] > 1)?[NSString stringWithFormat:@"%d Products",(int)[[arrProductObjects objectAtIndex:section] count]]:[NSString stringWithFormat:@"%d Product",(int)[[arrProductObjects objectAtIndex:section] count]]];
    [lblProductsNumber setTextAlignment:NSTextAlignmentRight];
    [lblProductsNumber setTextColor:[UIColor colorWithRed:146.0f/255.0f green:142.0f/255.0f blue:140.0f/255.0f alpha:1.0f]];
    [lblProductsNumber setFont:[UIFont fontWithName:@"Lato-Light" size:15]];
    [headerView addSubview:lblProductsNumber];
    
    return headerView;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"CellProduct";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = nil;
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    productObject = [[ProductObject alloc] init];
    productObject = [[arrProductObjects objectAtIndex:indexPath.section] objectAtIndex:(NSInteger)indexPath.row];
    
    //--------- Product image
    UIImageView *imgProduct = [[UIImageView alloc] initWithFrame:(IS_IPHONE_6)?CGRectMake(0, 0, 375, 280):CGRectMake(0, 0, 320, 240)];
    if(productObject.masterObject.imageObject.attachment_file_name != nil){
        NSString *documentDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *filePathAndDirectory = [documentDirectoryPath stringByAppendingString:@"/images/thumbs"];
        [[NSFileManager defaultManager] createDirectoryAtPath:filePathAndDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        NSString *fileName = [NSString stringWithFormat:@"%@", productObject.masterObject.imageObject.attachment_file_name];
        NSString *fullPath = [NSString stringWithFormat:@"%@/%@",filePathAndDirectory, fileName];
        [imgProduct setImage:[UIImage imageWithContentsOfFile:fullPath]];
        
        //[imgProduct setImage:[self getSubImageFrom:[UIImage imageWithContentsOfFile:fullPath] WithRect:(IS_IPHONE_6)?CGRectMake(0, 0, 375, 280):CGRectMake(0, 0, 320, 240)]];
    }else{
        [imgProduct setImage:[UIImage imageNamed:@"noAvail"]];
    }
    [cell addSubview:imgProduct];
    
    UIImageView * imgTransparent = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"item_transparency"]];
    [imgTransparent setFrame:(IS_IPHONE_6)?CGRectMake(47, 159, 280, 88):CGRectMake(20, 136, 280, 88)];
    [cell addSubview:imgTransparent];
    
    //--------- Product name
    UILabel *lblName = [[UILabel alloc] initWithFrame:(IS_IPHONE_6)?CGRectMake(47, 159, 280, 36):CGRectMake(20, 136, 280, 36)];
    [lblName setText: [productObject name]];
    [lblName setFont:[UIFont fontWithName:@"Lato-Bold" size:15]];
    [lblName setTextAlignment:NSTextAlignmentCenter];
    [lblName setNumberOfLines:2];
    [lblName setTextColor:[UIColor colorWithRed:84.0f/255.0f green:84.0f/255.0f blue:84.0f/255.0f alpha:1.0f]];
    [lblName setTextAlignment:NSTextAlignmentCenter];
    [cell addSubview:lblName];
    
    //Creat add button
    CustomButton *btnAdd = [CustomButton buttonWithType:UIButtonTypeCustom];
    
    if (!areMealsAvailable && [[(CategoryObject *)[arrProductCategoriesObjects objectAtIndex:indexPath.section] category_name ] isEqualToString:@"Desayuno"]) {
        //Button outstock
        [btnAdd setFrame:(IS_IPHONE_6)?CGRectMake(52, 197, 270, 45):CGRectMake(25, 174, 270, 45)];
        [btnAdd setImage:[UIImage imageNamed:@"outstock_btn_up"] forState:UIControlStateNormal];
        [btnAdd setImage:[UIImage imageNamed:@"outstock_btn_down"] forState:UIControlStateHighlighted];
        [cell addSubview:btnAdd];
    }
    else
    {
        // Disable button if quantity more than stock
        [btnAdd setEnabled:([productObject total_on_hand] == [productObject quantity])?NO:YES];
        
        if ([productObject quantity] > 0) {
            [btnAdd setFrame:(IS_IPHONE_6)?CGRectMake(122, 197, 200, 45):CGRectMake(95, 174, 200, 45)];
            [btnAdd setImage:[UIImage imageNamed:@"add02_btn_up"] forState:UIControlStateNormal];
            [btnAdd setImage:[UIImage imageNamed:@"add02_btn_down"] forState:UIControlStateHighlighted];
        }else{
            [btnAdd setFrame:(IS_IPHONE_6)?CGRectMake(52, 197, 270, 45):CGRectMake(25, 174, 270, 45)];
            [btnAdd setImage:[UIImage imageNamed:@"add_btn_up"] forState:UIControlStateNormal];
            [btnAdd  setImage:[UIImage imageNamed:@"add_btn_down"] forState:UIControlStateHighlighted];
        }
        [btnAdd setIndex:(int)indexPath.row];
        [btnAdd setSection:(int)indexPath.section];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat: @"e"];
        int productDayAvailable = ([[dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:productObject.date_available]] intValue] == 1)? 8: [[dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:productObject.date_available]] intValue];
        
        //When a product is outstock
        //if ((!productObject.total_on_hand > productObject.quantity || produc )&& [btnAdd isEnabled]) {
        if (![productObject total_on_hand] > [productObject quantity] || productObject.total_on_hand < 0 || (productDayAvailable < currentDayOfWeek) ) {
            [btnAdd setFrame:(IS_IPHONE_6)?CGRectMake(52, 197, 270, 45):CGRectMake(25, 174, 270, 45)];
            [btnAdd setImage:[UIImage imageNamed:@"outstock_btn_up"] forState:UIControlStateNormal];
            [btnAdd setImage:[UIImage imageNamed:@"outstock_btn_down"] forState:UIControlStateHighlighted];
            [btnAdd setEnabled:NO];
        }
        [btnAdd addTarget:self action:@selector(didSelectProduct:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:btnAdd];
        
        //-------- Minus button
        CustomButton *btnMinus = [CustomButton buttonWithType:UIButtonTypeCustom];
        if ([productObject quantity] > 0)
        {
            [btnMinus setFrame:(IS_IPHONE_6)?CGRectMake(52, 197, 60, 45):CGRectMake(25, 174, 60, 45)];
            [btnMinus setImage:[UIImage imageNamed:@"subtract_btn_up"] forState:UIControlStateNormal];
            [btnMinus setImage:[UIImage imageNamed:@"subtract_btn_down"] forState:UIControlStateHighlighted];
        }
        [btnMinus setTitle:@"-" forState:UIControlStateNormal];
        [btnMinus setIndex:(int)indexPath.row];
        [btnMinus setSection:(int)indexPath.section];
        [btnMinus setHidden:(productObject.quantity > 0)?NO:YES];
        [btnMinus addTarget:self action:@selector(didDeselectProduct:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:btnMinus];
        
        //-------- Quantity selected
        UIImageView * imgBadge = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"badge_ima"]];
        [imgBadge setFrame:(IS_IPHONE_6)?CGRectMake(247, 20, 80, 80):CGRectMake(220, 10, 80, 80)];
        [imgBadge setHidden:(productObject.quantity > 0)?NO:YES];
        [cell addSubview:imgBadge];
        
        UILabel *lblQuantity = [[UILabel alloc] initWithFrame:(IS_IPHONE_6)?CGRectMake(250, 20, 70, 70):CGRectMake(223, 10, 70, 70)];
        [lblQuantity setText:[NSString stringWithFormat:@"%d Selected", productObject.quantity]];
        [lblQuantity setTextAlignment:NSTextAlignmentCenter];
        [lblQuantity setTextColor:[UIColor whiteColor]];
        [lblQuantity setNumberOfLines:2];
        [lblQuantity setFont:[UIFont fontWithName:@"Lato-Regular" size:15]];
        [lblQuantity setHidden:(productObject.quantity > 0)?NO:YES];
        [cell addSubview:lblQuantity];
        //--------------------------
        
        //Check for the stock of the product to enable/disable the add button
        [btnAdd setEnabled:(productDayAvailable < currentDayOfWeek || [productObject total_on_hand] <= [productObject quantity])? NO:YES]; // Disable if the ProductAvailable is lower than currentDay
    }
    
    return cell;
}

#pragma mark -- action for + button in cell
-(void)didSelectProduct:(id)sender
{
    CustomButton * senderButton = (CustomButton*)sender;
    if (((ProductObject *)[[arrProductObjects objectAtIndex:((CustomButton *)sender).section] objectAtIndex:((CustomButton *)sender).index]).quantity==1) {
        senderButton.selected = YES;
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Please check!" message:[NSString stringWithFormat:@"Are you sure you want to add two items to your order?"] delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        currentSection = ((CustomButton*)sender).section;
        [alert setTag:((CustomButton*)sender).index];
        [alert show];
        //to-do: check the way how find the object to assign the quantity
    }else{
        ProductObject * selectedProduct = [ProductObject new];
        selectedProduct = [[arrProductObjects objectAtIndex:senderButton.section] objectAtIndex:senderButton.index];
        selectedProduct.quantity ++;
        [self doReloadData];
        [self synchronizeDefaults];
    }
}

-(void)didDeselectProduct:(id)sender
{
    ProductObject * selectedProduct = [ProductObject new];
    CustomButton * senderButton = (CustomButton*)sender;
    selectedProduct = [[arrProductObjects objectAtIndex:senderButton.section] objectAtIndex:senderButton.index];
    selectedProduct.quantity --;
    [self doReloadData];
    [self synchronizeDefaults];
}

#pragma mark -- button place Order
- (IBAction)doPlaceOrder:(id)sender{
    AppDelegate * appDelegate = [[UIApplication sharedApplication] delegate];
    if ([self updateDistanceToAnnotation]>1000 && areLocationServicesAvailable) {
        LMAlertView * alertView = [[LMAlertView alloc] initWithTitle:@"" message:nil delegate:self cancelButtonTitle:@"Ooh, Something happens!" otherButtonTitles:nil];
        [alertView setSize:CGSizeMake(250.0f, 320.0f)];
        
        // Add your subviews here to customise
        UIView *contentView = alertView.contentView;
        [contentView setBackgroundColor:[UIColor clearColor]];
        [alertView setBackgroundColor:[UIColor clearColor]];
        
        UIImageView * imgV = [[UIImageView alloc] initWithFrame:CGRectMake(60.0f, 10.0f, 129.0f, 200.0f)];
        [imgV setImage:[UIImage imageNamed:@"illustration_04"]];
        [contentView addSubview:imgV];
        UILabel * lblStatus = [[UILabel alloc] initWithFrame:CGRectMake(10, 175, 230, 120)];
        [lblStatus setTextAlignment:NSTextAlignmentCenter];
        lblStatus.numberOfLines = 3;
        lblStatus.text = [NSString stringWithFormat:@"%@ you are out of range to request an order!", appDelegate.userObject.firstName];
        [contentView addSubview:lblStatus];
        [alertView show];
    }else{
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        NSMutableArray * arrProductsInQueue = [NSMutableArray new];
        
        BOOL isPlaceOrder = YES;
        int productsCount = 0;
        for (int arrayDimention=0; arrayDimention<arrProductObjects.count; arrayDimention++) {
            for(ProductObject * tmpObject in [arrProductObjects objectAtIndex:arrayDimention])
            {
                if (tmpObject.quantity != 0) {
                    if (!areMealsAvailable && [tmpObject.categoryObject.category_name isEqualToString:@"Desayuno"]) {
                        tmpObject.quantity = 0;
                        LMAlertView * alertView = [[LMAlertView alloc] initWithTitle:@"" message:nil delegate:self cancelButtonTitle:@"Ok, Algo ha pasado" otherButtonTitles:nil];
                        [alertView setSize:CGSizeMake(250.0f, 320.0f)];
                        
                        // Add your subviews here to customise
                        UIView *contentView = alertView.contentView;
                        [contentView setBackgroundColor:[UIColor clearColor]];
                        [alertView setBackgroundColor:[UIColor clearColor]];
                        
                        UIImageView * imgV = [[UIImageView alloc] initWithFrame:CGRectMake(60.0f, 10.0f, 129.0f, 200.0f)];
                        [imgV setImage:[UIImage imageNamed:@"illustration_03"]];
                        [contentView addSubview:imgV];
                        UILabel * lblStatus = [[UILabel alloc] initWithFrame:CGRectMake(10, 175, 230, 120)];
                        [lblStatus setTextAlignment:NSTextAlignmentCenter];
                        lblStatus.numberOfLines = 3;
                        lblStatus.text = [NSString stringWithFormat:@"%@ Ha Terminado El Periodo Para Pedir Desayuno", appDelegate.userObject.firstName];
                        [contentView addSubview:lblStatus];
                        [alertView show];
                        [self synchronizeDefaults];
                        isPlaceOrder = NO;
                        [tblProducts reloadData];
                        break;
                    }else{
                        productsCount += tmpObject.quantity;
                        [arrProductsInQueue addObject:tmpObject];
                    }
                }
            }
        }
        
        if (isPlaceOrder) {
            [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:arrProductsInQueue] forKey:@"arrProductsInQueue"];
            [defaults synchronize];
            
            [self.navigationController dismissViewControllerAnimated:NO completion:nil];
            ShoppingCartViewController *shoppingCartViewController = [[ShoppingCartViewController alloc] init];
            [self bdb_presentPopupViewController:shoppingCartViewController
                                   withAnimation:BDBPopupViewShowAnimationDefault
                                  completion:nil];
        }
    }
}

#pragma mark -- UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([alertView.title isEqual:@"Please check!"])
    {
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
-(double)updateDistanceToAnnotation{
    // Location to Reference
    CLLocation *pinLocation = [[CLLocation alloc]
                               initWithLatitude:+19.26506377
                               longitude:-103.71073774];
    
    CLLocation *userLocation = [[CLLocation alloc]
                                initWithLatitude:mapKitView.userLocation.coordinate.latitude
                                longitude:mapKitView.userLocation.coordinate.longitude];
    
    CLLocationDistance distance = [pinLocation distanceFromLocation:userLocation];
    
    NSLog(@"Distance to point %4.0f m.", distance);
    return distance;
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    areLocationServicesAvailable = NO;
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    areLocationServicesAvailable = YES;
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    MKCoordinateRegion mapRegion;
    mapRegion.center = mapView.userLocation.coordinate;
    mapRegion.span.latitudeDelta = 0.002;
    mapRegion.span.longitudeDelta = 0.002;
    
    [mapKitView setRegion:mapRegion animated: YES];
}

@end
