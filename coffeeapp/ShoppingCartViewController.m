//
//  ShoppingCartViewController.m
//  GastronautBase
//
//  Created by Leonel Roberto Perea Trejo on 9/3/14.
//  Copyright (c) 2014 CrowdInt. All rights reserved.
//

#import "ShoppingCartViewController.h"

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

@interface ShoppingCartViewController ()

@end

@implementation ShoppingCartViewController

@synthesize btnCheckOut, btnEmptyShoppingCart, lblDate, tblProducts, arrProductsShoppingCart, HUDJMProgress;

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
    // Do any additional setup after loading the view from its nib.
    
    // create order details
    [self setTitle:@"Place Order"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE, LLLL d, yyyy"];
    [lblDate setText: [dateFormatter stringFromDate:[NSDate date]]];
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:@"arrProductsInQueue"];
    arrProductsShoppingCart = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    [tblProducts setDelegate:self];
    [tblProducts setDataSource:self];
    HUDJMProgress = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    HUDJMProgress.textLabel.text = @"Sending Request...";
}

-(void)viewDidAppear:(BOOL)animated
{
    [self doSetObjectsFrameFitToScreen];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- Set objects frame for fit to screen
-(void)doSetObjectsFrameFitToScreen
{
    //Set frame for screen objects between 3.5 and 4 inches
    [tblProducts setFrame:(IS_IPHONE_5)?CGRectMake(0, 183, 320, 287):CGRectMake(0, 183, 320, 210)];
    [btnEmptyShoppingCart setFrame:(IS_IPHONE_5)?CGRectMake(20, 520, 148, 30):CGRectMake(20, 440, 148, 30)];
    [btnCheckOut setFrame:(IS_IPHONE_5)?CGRectMake(234, 520, 66, 30):CGRectMake(234, 440, 66, 30)];
}

-(IBAction)doPlaceOrder:(id)sender{
    AppDelegate *myAppDelegate = [[UIApplication sharedApplication] delegate];
    NSMutableArray * arrOrderItems = [NSMutableArray new];
    for (ProductObject * productInQueue in arrProductsShoppingCart)
    {
        NSMutableDictionary * dictItemDetail = [NSMutableDictionary new];
        [dictItemDetail setObject:[NSString stringWithFormat:@"%d", productInQueue.masterObject.masterObject_id] forKey:@"variant_id"];
        [dictItemDetail setObject:[NSString stringWithFormat:@"%d", productInQueue.quantity] forKey:@"quantity"];
        [dictItemDetail setObject:[NSString stringWithFormat:@"%d", productInQueue.delivery_type] forKey:@"delivery_type"];
        [dictItemDetail setObject:productInQueue.delivery_date forKey:@"delivery_time"];
        [arrOrderItems addObject:dictItemDetail];
    }
    myAppDelegate.orderObject.arrLineItems = arrOrderItems; // Save the array in the orderObject
    [HUDJMProgress showInView:self.view];
    [RESTManager sendData:myAppDelegate.orderObject.getOrderPetition toService:@"checkouts" withMethod:@"POST" isTesting:NO
          withAccessToken:nil toCallback:^(id result) {
              [HUDJMProgress dismissAnimated:YES];
              NSLog(@"Order done with result %@", result);
              
              NSDictionary * dictResult = result;
              if ([dictResult objectForKey:@"number"] != nil && [[dictResult objectForKey:@"state"] isEqual:@"complete"]) {
                  UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Atention" message:@"Order Placed!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                  [alert show];
                  
                  //Register the order log
                  NSString * orderId = [dictResult objectForKey:@"number"];
                  NSString * orderState = [dictResult objectForKey:@"state"];
                  NSDateFormatter * dateFormat = [[NSDateFormatter alloc] init];
                  [dateFormat setDateFormat:@"dd-MM-yyyy HH:mm"];
                  NSString * orderDate = [dateFormat stringFromDate:[NSDate dateWithTimeIntervalSince1970:[[NSDate date] timeIntervalSince1970]]];
                  for (ProductObject * tmpProductObject in arrProductsShoppingCart) {
                      NSMutableDictionary * dictOrderLog = [[NSMutableDictionary alloc] init];
                      [dictOrderLog setObject:orderId forKey:@"orderId"];
                      [dictOrderLog setObject:orderState forKey:@"orderStatus"];
                      [dictOrderLog setObject:orderDate forKey:@"orderDate"];
                      [dictOrderLog setObject:[NSString stringWithFormat:@"%d",[[tmpProductObject masterObject] masterObject_id]] forKey:@"productId"];
                      [dictOrderLog setObject:[[tmpProductObject masterObject] name] forKey:@"productName"];
                      [dictOrderLog setObject:[NSString stringWithFormat:@"%d",[tmpProductObject quantity]] forKey:@"productQuantityOrdered"];
                      [DBManager insertOrdersLog:dictOrderLog];
                  }
                  
              }else{
                  UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Atention" message:@"Your order couldn't be proceeded" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                  [alert show];
              }
              NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
              [defaults setObject:nil forKey:@"arrProductsInQueue"];
              [defaults synchronize];
              [[NSNotificationCenter defaultCenter] postNotificationName:@"doSynchronizeDefaults" object:nil];
              [self.parentViewController bdb_dismissPopupViewControllerWithAnimation:BDBPopupViewHideAnimationDefault completion:nil];
          }];
    // Call the next view
}

-(IBAction)doCancel:(id)sender{
    [self.parentViewController bdb_dismissPopupViewControllerWithAnimation:BDBPopupViewHideAnimationDefault completion:nil];
}

#pragma mark -- UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (NSInteger)[arrProductsShoppingCart count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 130;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * strReusableIdentifier = @"CellProductInShoppingCart";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:strReusableIdentifier];
    cell = nil;
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strReusableIdentifier];
    }
    ProductObject * productObject = [arrProductsShoppingCart objectAtIndex:indexPath.row];
    if(productObject.masterObject.imageObject.attachment_file_name != nil){
        NSString *documentDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *filePathAndDirectory = [documentDirectoryPath stringByAppendingString:@"/images/thumbs"];
        [[NSFileManager defaultManager] createDirectoryAtPath:filePathAndDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        NSString *fileName = [NSString stringWithFormat:@"%@", productObject.masterObject.imageObject.attachment_file_name];
        NSString *fullPath = [NSString stringWithFormat:@"%@/%@",filePathAndDirectory, fileName];
        [cell.imageView setImage:[UIImage imageWithContentsOfFile:fullPath]];
    }else{
        [cell.imageView setImage:[UIImage imageNamed:@"noAvail.png"]];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@", productObject.name];
    return cell;
}

@end
