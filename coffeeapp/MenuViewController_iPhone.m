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
@synthesize arrProductObjects, arrProductCategoriesObjects, pageControl, isPageControlInUse, tblProducts, lblCurrentDay, arrWeekDays, HUDJMProgress, productObject, currentDayOfWeek, viewPlaceOrder, lblProductsCount, btnPlaceOrder;

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
    viewPlaceOrder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 600)];
    [tblProducts bringSubviewToFront:viewPlaceOrder];
}

-(void)viewDidAppear:(BOOL)animated{
    //assign labels data days
    lblCurrentDay.text = [arrWeekDays objectAtIndex:currentDayOfWeek - 2];
    
    //Set objects to fit screen between 3.5 and 4 inches
    [tblProducts setFrame:(IS_IPHONE_5)?CGRectMake(0, 90, 320, 440):CGRectMake(0, 90, 320, 333)];
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
    [lblProductsCount setText:[NSString stringWithFormat:@"%d Products",productsCount]];
    NSLog(@"viewPlaceOrder.frame.origin.x: %f",viewPlaceOrder.frame.origin.x);
    NSLog(@"viewPlaceOrder.frame.origin.y: %f",viewPlaceOrder.frame.origin.y);
    NSLog(@"viewPlaceOrder.frame.origin.y - viewPlaceOrder.frame.size.height: %f",viewPlaceOrder.frame.origin.y - viewPlaceOrder.frame.size.height);
    NSLog(@"viewPlaceOrder.frame.size.height: %f",viewPlaceOrder.frame.size.height);
    NSLog(@"viewPlaceOrder.frame.size.width: %f",viewPlaceOrder.frame.size.width);
    [viewPlaceOrder setFrame:CGRectMake(viewPlaceOrder.frame.origin.x, viewPlaceOrder.frame.origin.y - viewPlaceOrder.frame.size.height, viewPlaceOrder.frame.size.height, viewPlaceOrder.frame.size.width)];
    NSLog(@"-- after --");
    NSLog(@"viewPlaceOrder.frame.origin.x: %f",viewPlaceOrder.frame.origin.x);
    NSLog(@"viewPlaceOrder.frame.origin.y: %f",viewPlaceOrder.frame.origin.y);
    NSLog(@"viewPlaceOrder.frame.origin.y - viewPlaceOrder.frame.size.height: %f",viewPlaceOrder.frame.origin.y - viewPlaceOrder.frame.size.height);
    NSLog(@"viewPlaceOrder.frame.size.height: %f",viewPlaceOrder.frame.size.height);
    NSLog(@"viewPlaceOrder.frame.size.width: %f",viewPlaceOrder.frame.size.width);
    [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:arrProductsInQueue] forKey:@"arrProductsInQueue"];
    [defaults synchronize];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark --scrollView delegate

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    isPageControlInUse = NO;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    isPageControlInUse = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    isPageControlInUse = NO;
}

-(void)doReloadData
{
    [tblProducts reloadData];
}

#pragma mark -- Table view data delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (IS_IPHONE_5)?440.0f:340.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSUserDefaults *defaults =  [NSUserDefaults standardUserDefaults];
    return [[defaults objectForKey:@"count_sections"] intValue]; // Save the count of sections
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[arrProductObjects objectAtIndex:section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [(CategoryObject *)[arrProductCategoriesObjects objectAtIndex:section] category_name];
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
    
    UILabel *lblName = [[UILabel alloc] initWithFrame:(IS_IPHONE_5)?CGRectMake(20, 20, 280, 21):CGRectMake(20, 10, 280, 21)];
    [lblName setText: [productObject name]];
    [lblName setTextAlignment:NSTextAlignmentCenter];
    [cell addSubview:lblName];
    
    UIImageView *imgProduct = [[UIImageView alloc] initWithFrame:(IS_IPHONE_5)?CGRectMake(20, 53, 280, 192):CGRectMake(50, 43, 224, 154)];
    if(productObject.masterObject.imageObject.attachment_file_name != nil){
        NSString *documentDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *filePathAndDirectory = [documentDirectoryPath stringByAppendingString:@"/images/thumbs"];
        [[NSFileManager defaultManager] createDirectoryAtPath:filePathAndDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        NSString *fileName = [NSString stringWithFormat:@"%@", productObject.masterObject.imageObject.attachment_file_name];
        NSString *fullPath = [NSString stringWithFormat:@"%@/%@",filePathAndDirectory, fileName];
        [imgProduct setImage:[UIImage imageWithContentsOfFile:fullPath]];
    }else{
        [imgProduct setImage:[UIImage imageNamed:@"noAvail.png"]];
    }
    [cell addSubview:imgProduct];
     
    UILabel *lblDescription = [[UILabel alloc] initWithFrame:(IS_IPHONE_5)?CGRectMake(20, 253, 199, 73):CGRectMake(20, 200, 199, 73)];
    [lblDescription setNumberOfLines:4];
    [lblDescription setText:[productObject description]];
    [cell addSubview:lblDescription];
    
    UILabel *lblPrice = [[UILabel alloc] initWithFrame:(IS_IPHONE_5)?CGRectMake(227, 254, 73, 21):CGRectMake(227, 201, 73, 21)];
    [lblPrice setTextAlignment:NSTextAlignmentRight];
    [lblPrice setText:[NSString stringWithFormat:@"$ %@",[productObject price]]];
    [cell addSubview:lblPrice];
    
    UILabel *lblQuantity = [[UILabel alloc] initWithFrame:(IS_IPHONE_5)?CGRectMake(81, 338, 158, 21):CGRectMake(81, 280, 158, 21)];
    [lblQuantity setText:[NSString stringWithFormat:@"Request: %d Units", productObject.quantity]];
    [lblQuantity setTextAlignment:NSTextAlignmentCenter];
    [cell addSubview:lblQuantity];
    
    CustomButton *btnAdd = [CustomButton buttonWithType:UIButtonTypeSystem];
    [btnAdd setFrame:(IS_IPHONE_5)?CGRectMake(20, 334, 53, 30):CGRectMake(20, 280, 53, 20)];
    [btnAdd.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [btnAdd setTitle:@"+" forState:UIControlStateNormal];
    [btnAdd setIndex:(int)indexPath.row];
    [btnAdd setSection:(int)indexPath.section];
    int productDayAvailable = ([[dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:productObject.date_available]] intValue] == 1)? 8: [[dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:productObject.date_available]] intValue];
    [btnAdd setEnabled:( productDayAvailable < currentDayOfWeek)? NO:YES]; // Disable if the ProductAvailable is lower than currentDay
    if (!productObject.total_on_hand > productObject.quantity && [btnAdd isEnabled]) {
        [btnAdd setEnabled:NO];
        [btnAdd setHidden:YES];
        [lblQuantity setText:@"Without Stock"];
    }
    [btnAdd addTarget:self action:@selector(didSelectProduct:) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:btnAdd];
    
    CustomButton *btnMinus = [CustomButton buttonWithType:UIButtonTypeSystem];
    [btnMinus setFrame:(IS_IPHONE_5)?CGRectMake(247, 334, 53, 30):CGRectMake(247, 280, 53, 20)];
    [btnMinus.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [btnMinus setTitle:@"-" forState:UIControlStateNormal];
    [btnMinus setIndex:(int)indexPath.row];
    [btnMinus setSection:(int)indexPath.section];    [btnMinus setHidden:(productObject.quantity > 0)?NO:YES];
    [btnMinus addTarget:self action:@selector(didDeselectProduct:) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:btnMinus];
    return cell;
}

#pragma mark -- action for + button in cell

-(void)didSelectProduct:(id)sender
{
    ProductObject * selectedProduct = [ProductObject new];
    CustomButton * senderButton = (CustomButton*)sender;
    selectedProduct = [[arrProductObjects objectAtIndex:senderButton.section] objectAtIndex:senderButton.index];
    selectedProduct.quantity ++;
    [self doReloadData];
    [self synchronizeDefaults];
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
    
}

@end
