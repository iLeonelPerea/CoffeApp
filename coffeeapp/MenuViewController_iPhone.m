//
//  MenuViewController_iPhone.m
//  GastronautBase
//
//  Created by Omar Guzmán on 8/21/14.
//  Copyright (c) 2014 CrowdInt. All rights reserved.
//
// Todo: Try to load everything on a single UITableView, instead 7

#import "MenuViewController_iPhone.h"
#import "DBManager.h"
#import "RESTManager.h"

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

@interface MenuViewController_iPhone ()

@end

@implementation MenuViewController_iPhone
@synthesize arrProductObjects, arrProductCategoriesObjects, isViewPlaceOrderActive, tblProducts, lblCurrentDay, arrWeekDays, HUDJMProgress, productObject, currentDayOfWeek, viewPlaceOrder, lblProductsCount, btnPlaceOrder;

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
    
    isViewPlaceOrderActive = false;
   
    //Setting up tableview delegates and datasources
    [tblProducts setDelegate:self];
    [tblProducts setDataSource:self];
    HUDJMProgress = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    arrProductObjects = [NSMutableArray new];
    
    //Set the array prodcuts - If the there's products selected by users, they will be set here.
    arrProductCategoriesObjects = [DBManager getCategories];
    arrProductObjects = [[self setQuantitySelectedProducts:[DBManager getProducts]] mutableCopy];
    
    NSDate *now = [NSDate date];
    NSDateFormatter *weekday = [[NSDateFormatter alloc] init];
    [weekday setDateFormat: @"e"];
    currentDayOfWeek = ([[weekday stringFromDate:now] intValue] == 1)? 8:[[weekday stringFromDate:now] intValue]; // Get the current date
    
    //Create a notification that reload data
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doSynchronizeDefaults:) name:@"doSynchronizeDefaults" object:nil];
    UILabel * lblControllerTitle = [[UILabel alloc] init];
    [lblControllerTitle setFrame:CGRectMake(0, 0, 140, 50)];
    [lblControllerTitle setText:@"The Crowd's Chef"];
    [lblControllerTitle setFont:[UIFont fontWithName:@"HelveticaNeue" size:20]];
    [lblControllerTitle setTextColor:[UIColor whiteColor]];
    [[self navigationItem] setTitleView:lblControllerTitle];
    
    //Set the elementos on the placeHolder view
    [lblProductsCount setFrame:CGRectMake(20, 0, 100, 60)];
    [lblProductsCount setTextAlignment:NSTextAlignmentLeft];
    [btnPlaceOrder setFrame:CGRectMake(175, 0, 120, 60)];
    [[btnPlaceOrder titleLabel] setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:18]];
    [[btnPlaceOrder titleLabel] setTextAlignment:NSTextAlignmentRight];
    [viewPlaceOrder setBackgroundColor:[UIColor colorWithRed:217.0f/255.0f green:109.0f/255.0f blue:0.0f/255.0f alpha:1.0f]];
}

-(void)viewDidAppear:(BOOL)animated{
    //Set objects to fit screen between 3.5 and 4 inches
    [self synchronizeDefaults];
    if (isViewPlaceOrderActive) {
        [tblProducts setFrame:(IS_IPHONE_5)?CGRectMake(0, 0, 320, 510):CGRectMake(0, 90, 320, 333)];
    }else{
        [tblProducts setFrame:(IS_IPHONE_5)?CGRectMake(0, 0, 320, 568):CGRectMake(0, 90, 320, 333)];
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
    return arrMenuProducts;
}

#pragma mark -- NSNotificationCenter
-(void)doSynchronizeDefaults:(NSNotification *)notification{ //Called when ShoppingViewController was dissmised
    arrProductObjects = [[self setQuantitySelectedProducts:[DBManager getProducts]] mutableCopy];
    [tblProducts reloadData];
    isViewPlaceOrderActive = false;
    [UIView animateWithDuration:0.5f animations:^{
        [tblProducts setFrame:(IS_IPHONE_5)?CGRectMake(0, 0, 320, 568):CGRectMake(0, 90, 320, 333)];
        [UIView animateWithDuration:1.0f animations:^{
            // Increase the frame.origin.y
            [viewPlaceOrder setFrame:CGRectMake(0, viewPlaceOrder.frame.origin.y+viewPlaceOrder.frame.size.height, viewPlaceOrder.frame.size.width, viewPlaceOrder.frame.size.height)];
        }];
    } completion:^(BOOL finished) {
    }];
}


#pragma mark -- Synchronize defaults
-(void)synchronizeDefaults
{
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
    // If found products in shoppingCart && is not visible the viewPlaceOrder
    if (productsCount>0 && !isViewPlaceOrderActive) {
        isViewPlaceOrderActive = true;
        [UIView animateWithDuration:.5f animations:^{
            [tblProducts setFrame:(IS_IPHONE_5)?CGRectMake(0, 0, 320, 510):CGRectMake(0, 90, 320, 333)];
            [UIView animateWithDuration:1.0f animations:^{
                // Decrease the frame.origin.y
                [viewPlaceOrder setFrame:CGRectMake(0, viewPlaceOrder.frame.origin.y-60, viewPlaceOrder.frame.size.width, 60)];
            }];
        } completion:^(BOOL finished) {
        }];
    }else if(productsCount==0 && isViewPlaceOrderActive){
        isViewPlaceOrderActive = false;
        [UIView animateWithDuration:.5f animations:^{
            [tblProducts setFrame:(IS_IPHONE_5)?CGRectMake(0, 0, 320, 568):CGRectMake(0, 90, 320, 333)];
            [UIView animateWithDuration:1.0f animations:^{
                // Increase the frame.origin.y
                [viewPlaceOrder setFrame:CGRectMake(0, viewPlaceOrder.frame.origin.y+60, viewPlaceOrder.frame.size.width, 60)];
            }];
        } completion:^(BOOL finished) {
        }];
    }
    [lblProductsCount setText:(productsCount == 1)?[NSString stringWithFormat:@"%d Product",productsCount]:[NSString stringWithFormat:@"%d Products",productsCount]];
    [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:arrProductsInQueue] forKey:@"arrProductsInQueue"];
    [defaults synchronize];
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
    return (IS_IPHONE_5)?230.0f:340.0f;
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
    [lblSectionTitle setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:20]];
    [lblSectionTitle setTextColor:[UIColor colorWithRed:255 green:255 blue:255 alpha:255]];
    [headerView addSubview:lblSectionTitle];
    
    UILabel * lblProductsNumber = [[UILabel alloc] init];
    [lblProductsNumber setFrame:CGRectMake(200, 0, 100, 50)];
    [lblProductsNumber setText:([[arrProductObjects objectAtIndex:section] count] > 1)?[NSString stringWithFormat:@"%d Products",(int)[[arrProductObjects objectAtIndex:section] count]]:@"1 Product"];
    [lblProductsNumber setTextAlignment:NSTextAlignmentRight];
    [lblProductsNumber setTextColor:[UIColor colorWithRed:146.0f/255.0f green:142.0f/255.0f blue:140.0f/255.0f alpha:1.0f]];
    [lblProductsNumber setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:15]];
    [headerView addSubview:lblProductsNumber];
    
    return headerView;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"CellProduct";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"e"];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = nil;
    if (cell == nil) {
        //cell = [[NSBundle mainBundle] loadNibNamed:@"ProductCellTableViewCell" owner:self options:nil][0];
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    productObject = [[ProductObject alloc] init];
    productObject = [[arrProductObjects objectAtIndex:indexPath.section] objectAtIndex:(NSInteger)indexPath.row];
    
    //--------- Product image
    UIImageView *imgProduct = [[UIImageView alloc] initWithFrame:(IS_IPHONE_5)?CGRectMake(0, 0, 320, 230):CGRectMake(50, 43, 224, 154)];
    if(productObject.masterObject.imageObject.attachment_file_name != nil){
        NSString *documentDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *filePathAndDirectory = [documentDirectoryPath stringByAppendingString:@"/images/thumbs"];
        [[NSFileManager defaultManager] createDirectoryAtPath:filePathAndDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        NSString *fileName = [NSString stringWithFormat:@"%@", productObject.masterObject.imageObject.attachment_file_name];
        NSString *fullPath = [NSString stringWithFormat:@"%@/%@",filePathAndDirectory, fileName];
        //[imgProduct setImage:[UIImage imageWithContentsOfFile:fullPath]];
        // testing crop
        UIImage *imageToCrop = [UIImage imageWithContentsOfFile:fullPath];
        CGRect cropRect = CGRectMake(0, 0, 120, 100);
        UIImage *croppedImage = [self getSubImageFrom:imageToCrop WithRect:cropRect];
        [imgProduct setImage:croppedImage];
    }else{
        [imgProduct setImage:[UIImage imageNamed:@"noAvail"]];
    }
    [cell addSubview:imgProduct];
    
    UIImageView * imgTransparent = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"item_transparency"]];
    [imgTransparent setFrame:(IS_IPHONE_5)?CGRectMake(20, 140, 280, 80):CGRectMake(20, 280, 53, 20)];
    [cell addSubview:imgTransparent];
    
    //--------- Product name
    UILabel *lblName = [[UILabel alloc] initWithFrame:(IS_IPHONE_5)?CGRectMake(20, 145, 280, 21):CGRectMake(20, 10, 280, 21)];
    [lblName setText: [productObject name]];
    [lblName setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:15]];
    [lblName setTextColor:[UIColor colorWithRed:84.0f/255.0f green:84.0f/255.0f blue:84.0f/255.0f alpha:1.0f]];
    [lblName setTextAlignment:NSTextAlignmentCenter];
    [cell addSubview:lblName];
    
    //--------- Add button
    CustomButton *btnAdd = [CustomButton buttonWithType:UIButtonTypeCustom];
    //Check the quantity selected by user, if is more than 0, then change the size of the button on screen
    if ([productObject quantity] > 0) {
        [btnAdd setFrame:(IS_IPHONE_5)?CGRectMake(95, 170, 200, 45):CGRectMake(20, 280, 53, 20)];
        [btnAdd setImage:[UIImage imageNamed:@"add02_btn_up"] forState:UIControlStateNormal];
        [btnAdd setImage:[UIImage imageNamed:@"add02_btn_down"] forState:UIControlStateHighlighted];
    }else{
        [btnAdd setFrame:(IS_IPHONE_5)?CGRectMake(25, 170, 270, 45):CGRectMake(20, 280, 53, 20)];
        [btnAdd setImage:[UIImage imageNamed:@"add_btn_up"] forState:UIControlStateNormal];
        [btnAdd  setImage:[UIImage imageNamed:@"add_btn_down"] forState:UIControlStateHighlighted];
    }
    [btnAdd setIndex:(int)indexPath.row];
    [btnAdd setSection:(int)indexPath.section];
    int productDayAvailable = ([[dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:productObject.date_available]] intValue] == 1)? 8: [[dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:productObject.date_available]] intValue];
    [btnAdd setEnabled:( productDayAvailable < currentDayOfWeek)? NO:YES]; // Disable if the ProductAvailable is lower than currentDay

    //When a product is outstock
    //if (!productObject.total_on_hand > productObject.quantity && [btnAdd isEnabled]) {
    if (![productObject total_on_hand] > [productObject quantity] || (productDayAvailable < currentDayOfWeek) ) {
        [btnAdd setFrame:(IS_IPHONE_5)?CGRectMake(25, 170, 270, 45):CGRectMake(20, 280, 53, 20)];
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
        [btnMinus setFrame:(IS_IPHONE_5)?CGRectMake(25, 170, 60, 45):CGRectMake(247, 280, 53, 20)];
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
    UIImageView * imgBadge = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"badge_ima.png"]];
    [imgBadge setFrame:(IS_IPHONE_5)?CGRectMake(220, 10, 80, 80):CGRectMake(20, 280, 53, 20)];
    [imgBadge setHidden:(productObject.quantity > 0)?NO:YES];
    [cell addSubview:imgBadge];
    
    UILabel *lblQuantity = [[UILabel alloc] initWithFrame:(IS_IPHONE_5)?CGRectMake(223, 10, 70, 70):CGRectMake(81, 280, 158, 21)];
    [lblQuantity setText:[NSString stringWithFormat:@"%d Selected", productObject.quantity]];
    [lblQuantity setTextAlignment:NSTextAlignmentCenter];
    [lblQuantity setTextColor:[UIColor whiteColor]];
    [lblQuantity setNumberOfLines:2];
    [lblQuantity setFont:[UIFont fontWithName:@"Helvetica" size:15]];
    [lblQuantity setHidden:(productObject.quantity > 0)?NO:YES];
    [cell addSubview:lblQuantity];
    //--------------------------
    
    return cell;
}

#pragma mark -- action for + button in cell
-(void)didSelectProduct:(id)sender
{
    CustomButton * senderButton = (CustomButton*)sender;
    if (((ProductObject *)[[arrProductObjects objectAtIndex:((CustomButton *)sender).section] objectAtIndex:((CustomButton *)sender).index]).quantity==1) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Please check!" message:[NSString stringWithFormat:@"Are you sure you want to add two items to your order?"] delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        [alert show];
        senderButton.active = YES;
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
    [self.navigationController dismissViewControllerAnimated:NO completion:nil];
    ShoppingCartViewController *shoppingCartViewController = [[ShoppingCartViewController alloc] init];
    [self bdb_presentPopupViewController:shoppingCartViewController
                           withAnimation:BDBPopupViewShowAnimationDefault
                              completion:nil];
}

#pragma mark -- UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([alertView.title isEqual:@"Please check!"])
    {
        CustomButton * senderButton;
        for(UIView * cells in tblProducts.visibleCells) // Search into cells
            for(UIView * subView in cells.subviews) // Get subviews of each cell
                if([subView isKindOfClass:[CustomButton class]]) // be sure subView is UIButton Class
                    if (((CustomButton*)subView).active)
                        senderButton = (CustomButton*)subView; // Save the button active
        if (buttonIndex == 1) {
            ProductObject * selectedProduct = [ProductObject new];
            selectedProduct = [[arrProductObjects objectAtIndex:senderButton.section] objectAtIndex:senderButton.index];
            selectedProduct.quantity ++;
            [self doReloadData];
            [self synchronizeDefaults];
        }
        senderButton.active = NO;
    }
}

// crop image
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

@end
