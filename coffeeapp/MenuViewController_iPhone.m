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
@synthesize arrProductObjects, tblProducts, pageControl, arrDataMonday, arrDataTuesday, arrDataWednesday, arrDataThursday, arrDataFriday, arrDataSaturday, arrDataSunday, isPageControlInUse, lblCurrentDay, HUDJMProgress, directionChangePageControl, currentDayOfWeek;
@synthesize arrWeekDays;

@synthesize productObject;

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
    arrDataMonday = [NSMutableArray new];
    arrDataTuesday = [NSMutableArray new];
    arrDataWednesday = [NSMutableArray new];
    arrDataThursday = [NSMutableArray new];
    arrDataFriday = [NSMutableArray new];
    arrDataSaturday = [NSMutableArray new];
    arrDataSunday = [NSMutableArray new];
   
    //Setting up tableview delegates and datasources
    [tblProducts setDelegate:self];
    [tblProducts setDataSource:self];
    HUDJMProgress = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    arrProductObjects = [NSMutableArray new];
    //Set the array prodcuts - If the there's products selected by users, they will be set here.
    arrProductObjects = [[self setQuantitySelectedProducts:[DBManager getProducts]] mutableCopy];
    
    /*
    UISwipeGestureRecognizer *gestureL = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFromL:)];
    gestureL.numberOfTouchesRequired = 1;
    [gestureL setDirection:UISwipeGestureRecognizerDirectionRight];
    UISwipeGestureRecognizer *gestureR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFromR:)];
    gestureR.numberOfTouchesRequired = 1;
    [gestureR setDirection:UISwipeGestureRecognizerDirectionLeft];
    [tblProducts addGestureRecognizer:gestureL];
    [tblProducts addGestureRecognizer:gestureR];
    */
    
    NSDate *now = [NSDate date];
    NSDateFormatter *weekday = [[NSDateFormatter alloc] init];
    [weekday setDateFormat: @"e"];
    currentDayOfWeek = ([[weekday stringFromDate:now] intValue] == 1)? 8:[[weekday stringFromDate:now] intValue]; // Get the current date
    pageControl.currentPage = currentDayOfWeek - 2; // Change to the current date
    
    directionChangePageControl = pageControl.currentPage;
    [self loadDataDays];
}

-(void)viewDidAppear:(BOOL)animated{
    //assign labels data days
    lblCurrentDay.text = [arrWeekDays objectAtIndex:currentDayOfWeek - 2];
    
    //Set objects to fit screen between 3.5 and 4 inches
    [tblProducts setFrame:(IS_IPHONE_5)?CGRectMake(0, 90, 320, 440):CGRectMake(0, 90, 320, 333)];
    [pageControl setFrame:(IS_IPHONE_5)?CGRectMake(0, 531, 320, 37):CGRectMake(0, 443, 320, 37)];
}

#pragma mark -- SwipeGestureRecognizer delegate
- (void)handleSwipeFromR:(UISwipeGestureRecognizer *)recognizer {
    if(pageControl.currentPage < 6)
    {
        pageControl.currentPage ++;
        [tblProducts reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationLeft];
        [lblCurrentDay setAlpha:0];
        [UIView animateWithDuration:.7 animations:^{
            lblCurrentDay.text = [arrWeekDays objectAtIndex:pageControl.currentPage];
            [lblCurrentDay setAlpha:1];
        }];
        directionChangePageControl = 1;
    }
    else
    {
        pageControl.currentPage = pageControl.currentPage;
    }
}

- (void)handleSwipeFromL:(UISwipeGestureRecognizer *)recognizer {
    if(pageControl.currentPage > 0)
    {
        pageControl.currentPage --;
        [tblProducts reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationRight];
        [lblCurrentDay setAlpha:0];
        [UIView animateWithDuration:.7 animations:^{
            lblCurrentDay.text = [arrWeekDays objectAtIndex:pageControl.currentPage];
            [lblCurrentDay setAlpha:1];
        }];
        directionChangePageControl = 0;
    }
    else
    {
        pageControl.currentPage = pageControl.currentPage;
    }
}


#pragma mark -- setQuantitySelectedProducts delegate
-(NSMutableArray*)setQuantitySelectedProducts:(NSMutableArray *)arrMenuProducts
{
    NSMutableArray *arrToReturn = [[NSMutableArray alloc] init];
    NSUserDefaults *defaults =  [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:@"arrProductsInQueue"];
    NSMutableArray *arrOrderSelectedProducts = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    //Check is there's prodcuts selected by user.
    if ([arrOrderSelectedProducts count] > 0) {
        for (ProductObject *prodObject in arrMenuProducts) {
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
            [arrToReturn addObject:prodObject];
        }
        return arrToReturn;
    }else{
        //If there's no selected products, returns the original array
        arrToReturn = arrMenuProducts;
        return arrToReturn;
    }
}

#pragma mark -- Synchronize defaults
-(void)synchronizeDefaults
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray * arrProductsInQueue = [NSMutableArray new];
    
    for(ProductObject * tmpObject in arrDataMonday)
    {
        if (tmpObject.quantity != 0) {
            [arrProductsInQueue addObject:tmpObject];
        }
    }
    for(ProductObject * tmpObject in arrDataTuesday)
    {
        if (tmpObject.quantity != 0) {
            [arrProductsInQueue addObject:tmpObject];
        }
    }
    for(ProductObject * tmpObject in arrDataWednesday)
    {
        if (tmpObject.quantity != 0) {
            [arrProductsInQueue addObject:tmpObject];
        }
    }
    for(ProductObject * tmpObject in arrDataThursday)
    {
        if (tmpObject.quantity != 0) {
            [arrProductsInQueue addObject:tmpObject];
        }
    }
    for(ProductObject * tmpObject in arrDataFriday)
    {
        if (tmpObject.quantity != 0) {
            [arrProductsInQueue addObject:tmpObject];
        }
    }
    for(ProductObject * tmpObject in arrDataSaturday)
    {
        if (tmpObject.quantity != 0) {
            [arrProductsInQueue addObject:tmpObject];
        }
    }
    for(ProductObject * tmpObject in arrDataSunday)
    {
        if (tmpObject.quantity != 0) {
            [arrProductsInQueue addObject:tmpObject];
        }
    }
    [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:arrProductsInQueue] forKey:@"arrProductsInQueue"];
    [defaults synchronize];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark --scrollView delegate
- (IBAction)changePage{
    if (directionChangePageControl > pageControl.currentPage) {
        [tblProducts reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationRight];
        [lblCurrentDay setAlpha:0];
        [UIView animateWithDuration:.7 animations:^{
            lblCurrentDay.text = [arrWeekDays objectAtIndex:pageControl.currentPage];
            [lblCurrentDay setAlpha:1];
        }];
    }else{
        [tblProducts reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationLeft];
        [lblCurrentDay setAlpha:0];
        [UIView animateWithDuration:.7 animations:^{
            lblCurrentDay.text = [arrWeekDays objectAtIndex:pageControl.currentPage];
            [lblCurrentDay setAlpha:1];
        }];
    }
    directionChangePageControl = pageControl.currentPage;
    isPageControlInUse = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
	if (!isPageControlInUse) {
		// Switch the indicator when more than 50% of the previous/next page is visible
        lblCurrentDay.text = [arrWeekDays objectAtIndex:currentDayOfWeek - 2];
//        [self doReloadData];
	}
}

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

#pragma mark -- Data days load
-(void)loadDataDays
{
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"date_available" ascending:YES];
    NSArray *descriptors = [NSArray arrayWithObject:descriptor];
    NSArray * arrSortedProducts = [arrProductObjects sortedArrayUsingDescriptors:descriptors];
    
    ProductObject * firstProduct = [arrSortedProducts objectAtIndex:0];
    float currentDate = firstProduct.date_available;
    
    NSArray * arrDays = [[NSMutableArray alloc] initWithObjects:arrDataMonday, arrDataTuesday, arrDataWednesday, arrDataThursday, arrDataFriday, arrDataSaturday, arrDataSunday, nil];
    int currentArray = 0;
    for(ProductObject * product in arrSortedProducts)
    {
        //NSLog(@"currentArray: %d, currentDate: %f, product.date_avail: %f", currentArray, currentDate, product.date_available);
        if(product.date_available == currentDate)
        {
            [[arrDays objectAtIndex:currentArray] addObject:product];
            currentDate = product.date_available;
        }
        else
        {
            currentArray ++;
            [[arrDays objectAtIndex:currentArray] addObject:product];
            currentDate = product.date_available;
        }
    }
    [self changePage];
}

#pragma mark -- Table view data delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (IS_IPHONE_5)?440.0f:340.0f;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger toRet;
    switch (currentDayOfWeek -2) {
        case 0:
            toRet = [arrDataMonday count];
            break;
        case 1:
            toRet = [arrDataTuesday count];
            break;
        case 2:
            toRet = [arrDataWednesday count];
            break;
        case 3:
            toRet = [arrDataThursday count];
            break;
        case 4:
            toRet = [arrDataFriday count];
            break;
        case 5:
            toRet = [arrDataSaturday count];
            break;
        case 6:
            toRet = [arrDataSunday count];
            break;
        default:
            toRet = 0;
    }
    return toRet;
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
    switch (currentDayOfWeek - 2) {
        case 0:
            productObject = [arrDataMonday objectAtIndex:(NSUInteger)indexPath.row];
            break;
        case 1:
            productObject = [arrDataTuesday objectAtIndex:(NSUInteger)indexPath.row];
            break;
        case 2:
            productObject = [arrDataWednesday objectAtIndex:(NSUInteger)indexPath.row];
            break;
        case 3:
            productObject = [arrDataThursday objectAtIndex:(NSUInteger)indexPath.row];
            break;
        case 4:
            productObject = [arrDataFriday objectAtIndex:(NSUInteger)indexPath.row];
            break;
        case 5:
            productObject = [arrDataSaturday objectAtIndex:(NSUInteger)indexPath.row];
            break;
        case 6:
            productObject = [arrDataSunday objectAtIndex:(NSUInteger)indexPath.row];
            break;
        default:
            break;
    }
    
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
    
    UIButton *btnAdd = [UIButton buttonWithType:UIButtonTypeSystem];
    [btnAdd setFrame:(IS_IPHONE_5)?CGRectMake(20, 334, 53, 30):CGRectMake(20, 280, 53, 20)];
    [btnAdd.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [btnAdd setTitle:@"+" forState:UIControlStateNormal];
    [btnAdd setTag:indexPath.row];
    int productDayAvailable = ([[dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:productObject.date_available]] intValue] == 1)? 8: [[dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:productObject.date_available]] intValue];
    [btnAdd setEnabled:( productDayAvailable < currentDayOfWeek)? NO:YES]; // Disable if the ProductAvailable is lower than currentDay
    if (!productObject.total_on_hand > productObject.quantity && [btnAdd isEnabled]) {
        [btnAdd setEnabled:NO];
        [btnAdd setHidden:YES];
        [lblQuantity setText:@"Without Stock"];
    }
    [btnAdd addTarget:self action:@selector(didSelectProduct:) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:btnAdd];
    
    UIButton *btnMinus = [UIButton buttonWithType:UIButtonTypeSystem];
    [btnMinus setFrame:(IS_IPHONE_5)?CGRectMake(247, 334, 53, 30):CGRectMake(247, 280, 53, 20)];
    [btnMinus.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [btnMinus setTitle:@"-" forState:UIControlStateNormal];
    [btnMinus setTag:indexPath.row];
    [btnMinus setHidden:(productObject.quantity > 0)?NO:YES];
    [btnMinus addTarget:self action:@selector(didDeselectProduct:) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:btnMinus];
    return cell;
}

#pragma mark -- action for + button in cell

-(void)didSelectProduct:(id)sender
{
    ProductObject * selectedProduct = [ProductObject new];
    UIButton * senderButton = (UIButton*)sender;
    switch (currentDayOfWeek - 2) {
        case 0:
        {
            selectedProduct = [arrDataMonday objectAtIndex:senderButton.tag];
        }
            break;
        case 1:
        {
            selectedProduct = [arrDataTuesday objectAtIndex:senderButton.tag];
        }
            break;
        case 2:
        {
            selectedProduct = [arrDataWednesday objectAtIndex:senderButton.tag];
        }
            break;
        case 3:
        {
            selectedProduct = [arrDataThursday objectAtIndex:senderButton.tag];
        }
            break;
        case 4:
        {
            selectedProduct = [arrDataFriday objectAtIndex:senderButton.tag];
        }
            break;
        case 5:
        {
            selectedProduct = [arrDataSaturday objectAtIndex:senderButton.tag];
        }
            break;
        case 6:
        {
            selectedProduct = [arrDataSunday objectAtIndex:senderButton.tag];
        }
            break;
        default:
            break;
    }
    selectedProduct.quantity ++;
    [self doReloadData];
    [self synchronizeDefaults];
}

-(void)didDeselectProduct:(id)sender
{
    ProductObject * selectedProduct = [ProductObject new];
    UIButton * senderButton = (UIButton*)sender;
    switch (currentDayOfWeek - 2) {
        case 0:
        {
            selectedProduct = [arrDataMonday objectAtIndex:senderButton.tag];
        }
            break;
        case 1:
        {
            selectedProduct = [arrDataTuesday objectAtIndex:senderButton.tag];
        }
            break;
        case 2:
        {
            selectedProduct = [arrDataWednesday objectAtIndex:senderButton.tag];
        }
            break;
        case 3:
        {
            selectedProduct = [arrDataThursday objectAtIndex:senderButton.tag];
        }
            break;
        case 4:
        {
            selectedProduct = [arrDataFriday objectAtIndex:senderButton.tag];
        }
            break;
        case 5:
        {
            selectedProduct = [arrDataSaturday objectAtIndex:senderButton.tag];
        }
            break;
        case 6:
        {
            selectedProduct = [arrDataSunday objectAtIndex:senderButton.tag];
        }
            break;
        default:
            break;
    }
    selectedProduct.quantity --;
    [self doReloadData];
    [self synchronizeDefaults];
}

@end
