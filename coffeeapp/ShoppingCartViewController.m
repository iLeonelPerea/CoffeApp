//
//  ShoppingCartViewController.m
//  GastronautBase
//
//  Created by Leonel Roberto Perea Trejo on 9/3/14.
//  Copyright (c) 2014 CrowdInt. All rights reserved.
//

#import "ShoppingCartViewController.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"
#import "UserObject.h"

//Macros to identify size screen
#define IS_IPHONE_5 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)568) < DBL_EPSILON)
#define IS_IPHONE_6 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)667) < DBL_EPSILON)
#define IS_IPHONE_6_PLUS (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)736) < DBL_EPSILON)

@interface ShoppingCartViewController ()

@end

@implementation ShoppingCartViewController

@synthesize btnCheckOut, btnEmptyShoppingCart, lblDate, tblProducts, arrProductsShoppingCart, HUDJMProgress, tmrOrder, imgBottomBar, imgTitle, lblDisclaimer;

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
    
    // set isShoppingCart to stop entry push notifications
    AppDelegate * appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate setIsShoppingCart:YES];
    
    //Fit to screen values
    [lblDate setFrame:(IS_IPHONE_6)?CGRectMake(0, 20, 375, 50):CGRectMake(0, 20, 320, 50)];
    [imgTitle setFrame:(IS_IPHONE_6)?CGRectMake(0, 20, 375, 50):CGRectMake(0, 20, 430, 50)];
    [tblProducts setFrame:(IS_IPHONE_6)?CGRectMake(0, 70, 375, 430):(IS_IPHONE_5)?CGRectMake(0, 70, 320, 320):CGRectMake(0, 70, 320, 270)];
    [lblDisclaimer setFrame:(IS_IPHONE_6)?CGRectMake(0, 500, 375, 90):(IS_IPHONE_5)?CGRectMake(0, 400, 320, 90):CGRectMake(0, 330, 320, 90)];
    [imgBottomBar setFrame:(IS_IPHONE_6)?CGRectMake(0, 607, 375, 60):(IS_IPHONE_5)?CGRectMake(0, 508, 320, 60):CGRectMake(0, 420, 320, 60)];
    [btnEmptyShoppingCart setFrame:(IS_IPHONE_6)?CGRectMake(20, 620, 48, 30):(IS_IPHONE_5)?CGRectMake(20, 525, 48, 30):CGRectMake(20, 437, 48, 30)];
    [btnCheckOut setFrame:(IS_IPHONE_6)?CGRectMake(230, 620, 130, 30):(IS_IPHONE_5)?CGRectMake(170, 525, 130, 30):CGRectMake(170, 437, 130, 30)];
    
    // create order details
    [self setTitle:@"Place Order"];
    //Set label date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE, LLLL d, yyyy"];
    [lblDate setFont:[UIFont fontWithName:@"Lato-Light" size:20]];
    [lblDate setText: [dateFormatter stringFromDate:[NSDate date]]];
    //Set the style for disclaimer message
    [lblDisclaimer setFont:[UIFont fontWithName:@"Lato-Light" size:20]];
    //Extract data from user defaults
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:@"arrProductsInQueue"];
    arrProductsShoppingCart = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    [tblProducts setDelegate:self];
    [tblProducts setDataSource:self];
    HUDJMProgress = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    HUDJMProgress.textLabel.text = @"Sending Request...";
    
    //Set the timer
    tmrOrder = [NSTimer scheduledTimerWithTimeInterval:1200.0f target:self selector:@selector(doDismissShoppingCart:) userInfo:nil repeats:NO];
    
    //Set requested products
    int productsCount = 0;
    for(ProductObject * tmpObject in arrProductsShoppingCart)
    {
        if (tmpObject.quantity != 0) {
            productsCount += tmpObject.quantity;
        }
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    // set isShoppingCart to reactive entry push notification
    AppDelegate * appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate setIsShoppingCart:NO];
}

-(void)viewDidAppear:(BOOL)animated
{
    //Set image to Place order button
    [btnCheckOut setImage:[UIImage imageNamed:@"plceorder_btn_up"] forState:UIControlStateNormal];
    [imgBottomBar setBackgroundColor:[UIColor colorWithRed:217.0f/255.0f green:109.0f/255.0f blue:0.0f alpha:1.0f]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- Dismiss shopping cart after timer fired
-(void)doDismissShoppingCart:(id)sender{
    [self.parentViewController bdb_dismissPopupViewControllerWithAnimation:BDBPopupViewHideAnimationDefault completion:nil];
}


#pragma mark -- Place order
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
    [RESTManager sendData:myAppDelegate.orderObject.getOrderPetition toService:@"checkouts" withMethod:@"POST" isTesting:myAppDelegate.isTestingEnv
          withAccessToken:myAppDelegate.userObject.userSpreeToken isAccessTokenInHeader:YES toCallback:^(id result) {
              [HUDJMProgress dismissAnimated:YES];
              NSLog(@"order Number: %@ and order Token: %@", [result objectForKey:@"number"], [result objectForKey:@"token"]);
              [self doPostPushNotificationWithOrderNumber:[result objectForKey:@"number"] andOrderToken:[result objectForKey:@"token"]];
              NSLog(@"Order done with result %@", result);
              NSDictionary * dictResult = result;
              if ([dictResult objectForKey:@"number"] != nil && [[dictResult objectForKey:@"state"] isEqual:@"confirm"]) {
                  UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Atention" message:@"Order Placed!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                  [alert show];
                  myAppDelegate.currentOrderNumber = [result objectForKey:@"number"];
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
              [[NSNotificationCenter defaultCenter] postNotificationName:@"doCleanMenuAfterOrderPlaced" object:nil];
              [self.parentViewController bdb_dismissPopupViewControllerWithAnimation:BDBPopupViewHideAnimationDefault completion:nil];

          }];
    // Call the next view
}

//post notification to coffee boy app
-(void)doPostPushNotificationWithOrderNumber:(NSString*)orderNumber andOrderToken:(NSString*)orderToken
{
    // Send a notification to all devices subscribed to the "requests" channel, in this case coffee boy app.
    AppDelegate * appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSString * strMessage = [NSString stringWithFormat:@"Nuevo pedido de: %@", appDelegate.userObject.userName];
    
    NSDictionary *data = @{
                           @"alert": strMessage,
                           @"userName": appDelegate.userObject.userName,
                           @"userChannel": appDelegate.userObject.userChannel,
                           @"orderNumber": orderNumber,
                           @"orderToken": orderToken,
                           @"userPic": appDelegate.userObject.userUrlProfileImage
                           };
    PFPush *push = [[PFPush alloc] init];
    [push setChannel:@"requests"];
    [push setData:data];
    [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(!succeeded)
        {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Error in Push Notification" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
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
    return (IS_IPHONE_6)?94:80;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * strReusableIdentifier = @"CellProductInShoppingCart";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:strReusableIdentifier];
    cell = nil;
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strReusableIdentifier];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    
    ProductObject * productObject = [arrProductsShoppingCart objectAtIndex:[indexPath row]];
    
    //-------- Image product
    UIImageView * imgProduct = [[UIImageView alloc] initWithFrame:(IS_IPHONE_6)?CGRectMake(0, 0, 375, 94):CGRectMake(0, 0, 320, 80)];
    if(productObject.masterObject.imageObject.attachment_file_name != nil){
        NSString *documentDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *filePathAndDirectory = [documentDirectoryPath stringByAppendingString:@"/images/thumbs"];
        [[NSFileManager defaultManager] createDirectoryAtPath:filePathAndDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        NSString *fileName = [NSString stringWithFormat:@"%@", productObject.masterObject.imageObject.attachment_file_name];
        NSString *fullPath = [NSString stringWithFormat:@"%@/%@",filePathAndDirectory, fileName];
        //[imgProduct setImage:[UIImage imageWithContentsOfFile:fullPath]];
        // testing crop
        UIImage *imageToCrop = [UIImage imageWithContentsOfFile:fullPath];
        CGRect cropRect = (IS_IPHONE_6)?CGRectMake(0, 0, 375, 94):CGRectMake(0, 0, 320, 80);
        UIImage *croppedImage = [self getSubImageFrom:imageToCrop WithRect:cropRect];
        [imgProduct setImage:croppedImage];
    }else{
        [imgProduct setImage:[UIImage imageNamed:@"noAvail"]];
    }
    [cell addSubview:imgProduct];
    
    //------- Transparency image
    UIImageView * imgTransparency = [[UIImageView alloc] init];
    [imgTransparency setFrame:(IS_IPHONE_6)?CGRectMake(0, 0, 375, 94):CGRectMake(0, 0, 320, 80)];
    [imgTransparency setImage:[UIImage imageNamed:@"item_transparency_03"]];
    [cell addSubview:imgTransparency];
    
    //-------- Product name
    UILabel * lblProductName = [[UILabel alloc] init];
    [lblProductName setFrame:(IS_IPHONE_6)?CGRectMake(0, 0, 375, 94):CGRectMake(0, 0, 320, 80)];
    [lblProductName setText:[NSString stringWithFormat:@"%d %@",[productObject quantity],[productObject name]]];
    [lblProductName setNumberOfLines:2];
    [lblProductName setFont:[UIFont fontWithName:@"Lato-Bold" size:18]];
    [lblProductName setTextColor:[UIColor colorWithRed:84.0f/255.0f green:84.0f/255.0f blue:84.0f/255.0f alpha:1.0f]];
    [lblProductName setTextAlignment:NSTextAlignmentCenter];
    [cell addSubview:lblProductName];
    //---------------------------------------------------
    
    return cell;
}


// crop image method
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
