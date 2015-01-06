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

/// Macros to identify size screen
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
    
    /// Set the screen elements to fit on the screen depending on the device.
    [lblDate setFrame:(IS_IPHONE_6)?CGRectMake(0, 20, 375, 50):CGRectMake(0, 20, 320, 50)];
    [imgTitle setFrame:(IS_IPHONE_6)?CGRectMake(0, 20, 375, 50):CGRectMake(0, 20, 430, 50)];
    [tblProducts setFrame:(IS_IPHONE_6)?CGRectMake(0, 70, 375, 430):(IS_IPHONE_5)?CGRectMake(0, 70, 320, 320):CGRectMake(0, 70, 320, 270)];
    [lblDisclaimer setFrame:(IS_IPHONE_6)?CGRectMake(0, 500, 375, 90):(IS_IPHONE_5)?CGRectMake(0, 400, 320, 90):CGRectMake(0, 330, 320, 90)];
    [imgBottomBar setFrame:(IS_IPHONE_6)?CGRectMake(0, 607, 375, 60):(IS_IPHONE_5)?CGRectMake(0, 508, 320, 60):CGRectMake(0, 420, 320, 60)];
    [btnEmptyShoppingCart setFrame:(IS_IPHONE_6)?CGRectMake(20, 620, 48, 30):(IS_IPHONE_5)?CGRectMake(20, 525, 48, 30):CGRectMake(20, 437, 48, 30)];
    [btnCheckOut setFrame:(IS_IPHONE_6)?CGRectMake(230, 620, 130, 30):(IS_IPHONE_5)?CGRectMake(170, 525, 130, 30):CGRectMake(170, 437, 130, 30)];
    
    /// Set title text.
    [self setTitle:@"Place Order"];
    /// Set the current date text.
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE, LLLL d, yyyy"];
    [lblDate setFont:[UIFont fontWithName:@"Lato-Light" size:20]];
    [lblDate setText: [dateFormatter stringFromDate:[NSDate date]]];
    /// Set the style of the disclaimer message.
    [lblDisclaimer setFont:[UIFont fontWithName:@"Lato-Light" size:20]];
    
    /// Extract the data of the array arrProductsInQueue from user defaults.
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:@"arrProductsInQueue"];
    arrProductsShoppingCart = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    /// Set the datasource and delegate for the table view tblProducts.
    [tblProducts setDelegate:self];
    [tblProducts setDataSource:self];
    /// Set the style for the HUD component.
    HUDJMProgress = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    HUDJMProgress.textLabel.text = @"Sending Request...";
    
    /// Set the timer to trigger the order cancelation after 20 minutes of inactivity.
    tmrOrder = [NSTimer scheduledTimerWithTimeInterval:1200.0f target:self selector:@selector(doDismissShoppingCart:) userInfo:nil repeats:NO];
    
    /// Set requested products
    int productsCount = 0;
    for(ProductObject * tmpObject in arrProductsShoppingCart)
    {
        if (tmpObject.quantity != 0) {
            productsCount += tmpObject.quantity;
        }
    }
}

/// Operations to be done when the view appear.
-(void)viewDidAppear:(BOOL)animated
{
    /// Set image to Place order button
    [btnCheckOut setImage:[UIImage imageNamed:@"plceorder_btn_up"] forState:UIControlStateNormal];
    [imgBottomBar setBackgroundColor:[UIColor colorWithRed:217.0f/255.0f green:109.0f/255.0f blue:0.0f alpha:1.0f]];
}

/// System method.
-(void)viewWillDisappear:(BOOL)animated
{
    /// Set isMenuViewController flag to YES in AppDelegate.
    AppDelegate * appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate setIsMenuViewController:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- Dismiss shopping cart after timer fired
-(void)doDismissShoppingCart:(id)sender{
    /// Dismiss the ShoppingCartViewController.
    [self.parentViewController bdb_dismissPopupViewControllerWithAnimation:BDBPopupViewHideAnimationDefault completion:nil];
}

#pragma mark -- Place order
-(IBAction)doPlaceOrder:(id)sender{
    AppDelegate *myAppDelegate = [[UIApplication sharedApplication] delegate];
    /// Create a mutable array.
    NSMutableArray * arrOrderItems = [NSMutableArray new];
    /// Loop to create a dictionary to be stored in arrOrderItems, based on data of arrProductsShoppingCart.
    for (ProductObject * productInQueue in arrProductsShoppingCart)
    {
        /// Create a dictionary to store the variant_id, quantity, delivery_type and delivery_time of the product.
        NSMutableDictionary * dictItemDetail = [NSMutableDictionary new];
        [dictItemDetail setObject:[NSString stringWithFormat:@"%d", productInQueue.masterObject.masterObject_id] forKey:@"variant_id"];
        [dictItemDetail setObject:[NSString stringWithFormat:@"%d", productInQueue.quantity] forKey:@"quantity"];
        [dictItemDetail setObject:[NSString stringWithFormat:@"%d", productInQueue.delivery_type] forKey:@"delivery_type"];
        //new parameter added here
        //todo: check with backend
        if(productInQueue.comment.length != 0)
        {
            [dictItemDetail setObject:productInQueue.comment forKey:@"comment"];
        }
        else
        {
            [dictItemDetail setObject:@"" forKey:@"comment"];
        }
        [dictItemDetail setObject:productInQueue.delivery_date forKey:@"delivery_time"];
        [arrOrderItems addObject:dictItemDetail];
    }
    /// Save the array in the orderObject
    myAppDelegate.orderObject.arrLineItems = arrOrderItems;
    /// Show the HUD for loading message.
    [HUDJMProgress showInView:self.view];
    /// Request to spree to do the checkout proccess.
    /// The petition is done to "checkouts", with data from myAppDelegate.orderObject.getOrderPetition
    [RESTManager sendData:myAppDelegate.orderObject.getOrderPetition toService:@"checkouts" withMethod:@"POST" isTesting:myAppDelegate.isTestingEnv
          withAccessToken:myAppDelegate.userObject.userSpreeToken isAccessTokenInHeader:YES toCallback:^(id result) {
              /// Dismiss the HUD
              [HUDJMProgress dismissAnimated:YES];
              /// Check for the status of the request.
              if([[result objectForKey:@"success"] isEqual:@NO])
              {
                  /// Create a custom alert view.
                  LMAlertView * alertView = [[LMAlertView alloc] initWithTitle:@"" message:nil delegate:self cancelButtonTitle:@"Service Error!" otherButtonTitles:nil];
                  [alertView setSize:CGSizeMake(200.0f, 320.0f)];
                  
                  /// Create an UIView to contain all the elements for the alert view.
                  UIView *contentView = alertView.contentView;
                  [contentView setBackgroundColor:[UIColor clearColor]];
                  [alertView setBackgroundColor:[UIColor clearColor]];
                  /// Create an UIImageView and set the proper illustration.
                  UIImageView * imgV = [[UIImageView alloc] initWithFrame:CGRectMake(35.5f, 10.0f, 129.0f, 200.0f)];
                  [imgV setImage:[UIImage imageNamed:@"illustration_05"]];
                  [contentView addSubview:imgV];
                  /// Create an UILabel and set the alert view message.
                  UILabel * lblStatus = [[UILabel alloc] initWithFrame:CGRectMake(10, 170, 180, 120)];
                  lblStatus.numberOfLines = 3;
                  [lblStatus setFont:[UIFont fontWithName:@"Lato-Regular" size:16]];
                  [lblStatus setTextAlignment:NSTextAlignmentCenter];
                  lblStatus.text = [result objectForKey:@"message"];
                  [contentView addSubview:lblStatus];
                  [alertView show];
                  return;
              }
              NSLog(@"order Number: %@ and order Token: %@", [result objectForKey:@"number"], [result objectForKey:@"token"]);
              /// Post a local notification to be sended to CoffeeBoy App to inform about an new order maded.
              [self doPostPushNotificationWithOrderNumber:[result objectForKey:@"number"] andOrderToken:[result objectForKey:@"token"]];
              //NSLog(@"Order done with result %@", result);
              /// Create a dictionary based on the result object from the request.
              NSDictionary * dictResult = result;
              /// Check for the number -of the order- and the state -of the order- in the dictionary.
              if ([dictResult objectForKey:@"number"] != nil && [[dictResult objectForKey:@"state"] isEqual:@"confirm"]) {
                  /// Create an alert view to inform that the order is placed.
                  UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Atention" message:@"Order Placed!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                  [alert show];
                  myAppDelegate.currentOrderNumber = [result objectForKey:@"number"];
                  /// Create a dictionary, will contain the data to be registered as log in the local database.
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
                  /// Create an alert view to inform about and error on making the order.
                  UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Atention" message:@"Your order couldn't be proceeded" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                  [alert show];
              }
              /// Set array arrProductsInQueue to nil in user defaults.
              NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
              [defaults setObject:nil forKey:@"arrProductsInQueue"];
              [defaults synchronize];
              /// Post a notification to update the information in the menu after the order is placed
              [[NSNotificationCenter defaultCenter] postNotificationName:@"doUpdateMenu" object:nil];
              [self.parentViewController bdb_dismissPopupViewControllerWithAnimation:BDBPopupViewHideAnimationDefault completion:nil];

          }];
    // Call the next view
}

/// Post notification to coffee boy app
-(void)doPostPushNotificationWithOrderNumber:(NSString*)orderNumber andOrderToken:(NSString*)orderToken
{
    /// Send a notification to all devices subscribed to the "requests" channel, in this case coffee boy app.
    AppDelegate * appDelegate = [[UIApplication sharedApplication] delegate];
    /// Set the notification message.
    NSString * strMessage = [NSString stringWithFormat:@"Nuevo pedido de: %@", appDelegate.userObject.userName];
    /// Create and set the data dictionary to be sended as notification.
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
    /// Check for an error after pushing the notification.
    [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(!succeeded)
        {
            /// Create an alert view to inform about the error of pushing the notification.
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Error in Push Notification" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
}

-(IBAction)doCancel:(id)sender{
    //Post a local notification to update the menu
    [[NSNotificationCenter defaultCenter] postNotificationName:@"doUpdateMenu" object:nil];
    /// Dismiss the ShoppingCartViewController and cancelling the checkout proccess.
    [self.parentViewController bdb_dismissPopupViewControllerWithAnimation:BDBPopupViewHideAnimationDefault completion:nil];
}

#pragma mark -- UITableViewDelegate
/// Define the number of rows for the table view tblProducts based on the number of elements of arrProductsShoppingCart.
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (NSInteger)[arrProductsShoppingCart count];
}

/// Define the height fot the row based on the device screen size.
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProductObject * selectedProduct = [arrProductsShoppingCart objectAtIndex:indexPath.row];
    if(selectedProduct.isEditingComments)
    {
        return 180;
    }
    return (IS_IPHONE_6)?94:80;
}

/// Draw the contect of the cell for the table row. Display the quantity and name of the product with the image as background.
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /// Create and set the cell
    static NSString * strReusableIdentifier = @"CellProductInShoppingCart";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:strReusableIdentifier];
    cell = nil;
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strReusableIdentifier];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    
    /// Create an ProductObject object and setted to the reference of a product stored in the array arrProductsShoppingCart.
    ProductObject * productObject = [arrProductsShoppingCart objectAtIndex:[indexPath row]];
    
    /// -------- Image product
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
    
    /// ------- Transparency image
    UIImageView * imgTransparency = [[UIImageView alloc] init];
    [imgTransparency setFrame:(IS_IPHONE_6)?CGRectMake(0, 0, 375, 94):CGRectMake(0, 0, 320, 80)];
    [imgTransparency setImage:[UIImage imageNamed:@"item_transparency_03"]];
    [cell addSubview:imgTransparency];
    
    /// -------- Product name
    UILabel * lblProductName = [[UILabel alloc] init];
    //[lblProductName setFrame:(IS_IPHONE_6)?CGRectMake(0, 0, 375, 94):CGRectMake(0, 0, 320, 80)];
    [lblProductName setFrame:CGRectMake(0, 0, self.view.frame.size.width-50, 80)];
    [lblProductName setText:[NSString stringWithFormat:@"%d %@",[productObject quantity],[productObject name]]];
    [lblProductName setNumberOfLines:2];
    [lblProductName setFont:[UIFont fontWithName:@"Lato-Bold" size:18]];
    [lblProductName setTextColor:[UIColor colorWithRed:84.0f/255.0f green:84.0f/255.0f blue:84.0f/255.0f alpha:1.0f]];
    [lblProductName setTextAlignment:NSTextAlignmentCenter];
    [cell addSubview:lblProductName];
    //---------------------------------------------------
    
    //--------------------- Notes Section ---------------
    if(productObject.isEditingComments)
    {
        UITextField * txtComment = [[UITextField alloc] initWithFrame:CGRectMake(20, 70, self.view.frame.size.width-40, 80)];
        txtComment.placeholder = @"Make a note for this item";
        //check if prev. comment has been added.
        if(![productObject.comment isEqual:@""])
            txtComment.text = productObject.comment;
        [txtComment setDelegate:self];
        [txtComment setTag:indexPath.row];
        [cell addSubview:txtComment];
        
        UIButton * btnClose = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-40, 27, 28, 27)];
        [btnClose setImage:[UIImage imageNamed:@"close_note"] forState:UIControlStateNormal];
        [btnClose setTag:indexPath.row];
        [btnClose addTarget:self action:@selector(doCancelNoteToProduct:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:btnClose];
        
        UIButton * btnDone = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-80, 140, 80, 40)];
        [btnDone setImage:[UIImage imageNamed:@"done_btn_up"] forState:UIControlStateNormal];
        [btnDone setImage:[UIImage imageNamed:@"done_btn_down"] forState:UIControlStateHighlighted];
        [btnDone setTag:indexPath.row];
        [btnDone addTarget:self action:@selector(doDoneNoteToProduct:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:btnDone];
    }
    else
    {
        UIButton * btnNotes = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-40, 27, 28, 27)];
        [btnNotes setImage:[UIImage imageNamed:@"notes_ico"] forState:UIControlStateNormal];
        [btnNotes setTag:indexPath.row];
        [btnNotes addTarget:self action:@selector(doAddNoteToProduct:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:btnNotes];
    }
    return cell;
}

/// Done note selector
-(void)doDoneNoteToProduct:(id)sender
{
    UIButton * btn = (UIButton*)sender;
    ProductObject * selectedProduct = [arrProductsShoppingCart objectAtIndex:btn.tag];
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:tblProducts];
    NSIndexPath *indexPath = [tblProducts indexPathForRowAtPoint:buttonPosition];
    UITableViewCell * cell = [tblProducts cellForRowAtIndexPath:indexPath];
    for (UIView * view in cell.subviews)
    {
        if([view isKindOfClass:[UITextField class]])
        {
            UITextField * txtNote = (UITextField*)view;
            selectedProduct.comment = txtNote.text;
            selectedProduct.isEditingComments = NO;
            [tblProducts reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:indexPath.row inSection:0]] withRowAnimation:UITableViewRowAnimationMiddle];
            break;
        }
    }
    [self doSynchronizeDefaults];
}

/// cancel note selector
-(void)doCancelNoteToProduct:(id)sender
{
    UIButton * btn = (UIButton*)sender;
    ProductObject * selectedProduct = [arrProductsShoppingCart objectAtIndex:btn.tag];
    selectedProduct.isEditingComments = NO;
    [tblProducts reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:btn.tag inSection:0]] withRowAnimation:UITableViewRowAnimationMiddle];
}

/// add note selector
-(void)doAddNoteToProduct:(id)sender
{
    UIButton * btn = (UIButton*)sender;
    ProductObject * selectedProduct = [arrProductsShoppingCart objectAtIndex:btn.tag];
    selectedProduct.isEditingComments = YES;
    [tblProducts setContentOffset:CGPointMake(0, btn.frame.origin.y+(btn.tag*50))];
    [tblProducts reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:btn.tag inSection:0]] withRowAnimation:UITableViewRowAnimationMiddle];
}

/// Crop the image sended as param.
- (UIImage*) getSubImageFrom: (UIImage*) img WithRect: (CGRect) rect {
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    /// Translated rectangle for drawing sub image
    /// CGRect drawRect = CGRectMake(-rect.origin.x, -rect.origin.y, img.size.width, img.size.height);
    CGRect drawRect = CGRectMake(0, 0, img.size.width, img.size.height);
    /// Clip to the bounds of the image context
    /// Not strictly necessary as it will get clipped anyway?
    CGContextClipToRect(context, CGRectMake(0, 0, rect.size.width, rect.size.height));
    /// Draw image
    [img drawInRect:drawRect];
    /// Grab image
    UIImage* subImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return subImage;
}

/// Synchronize values into user defaults.
-(void)doSynchronizeDefaults
{
     /// Set the array arrProductsInQueue with the values of the array arrProductsShoppingCart
     NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
     [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:arrProductsShoppingCart] forKey:@"arrProductsInQueue"];
     [defaults synchronize];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [tblProducts setContentSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height+(textField.tag*100))];
    [tblProducts setContentOffset:CGPointMake(0, textField.frame.origin.y+(textField.tag*55)) animated:YES];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    static const NSUInteger limit = 50; // we limit to 50 characters
    NSUInteger allowedLength = limit - [textField.text length] + range.length;
    if (string.length > allowedLength) {
        if (string.length > 1) {
            // get at least the part of the new string that fits
            NSString *limitedString = [string substringToIndex:allowedLength];
            NSMutableString *newString = [textField.text mutableCopy];
            [newString replaceCharactersInRange:range withString:limitedString];
            textField.text = newString;
        }
        return NO;
    } else {
        return YES;
    }
}

@end
