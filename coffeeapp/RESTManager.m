//
//  RESTManager.m
//  coffeeapp
//
//  Created by Crowd on 10/19/14.
//  Copyright (c) 2014 crowdint. All rights reserved.
//

#import "RESTManager.h"
#import <AsyncImageDownloader.h>
#import <UIKit/UIKit.h>
#import "AppDelegate.h"

/// Macro that store the URL for the testing server.
#define TESTING_URL @"https://stage-spree-demo-store-three.herokuapp.com/api"
#define API_URL @"https://stage-spree-demo-store-twoﬁ.herokuapp.com/api"

@implementation RESTManager

+(void)sendData:(NSMutableDictionary *)data toService:(NSString *)service withMethod:(NSString *)method isTesting:(BOOL)testing withAccessToken:(NSString *)accessToken isAccessTokenInHeader:(BOOL) isInHeader toCallback:(void (^)(id))callback
{
    /// Create an URL variable.
    NSURL *url = nil;
    /// Create a Request variable.
    NSMutableURLRequest *request;
    /// Check for the type of the method to make the request.
    if(![method isEqual: @"GET"])
    {
        /// Check if the request will be send to the testing server.
        if(testing)
        {
            url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",TESTING_URL, service]];
        }
        else
            url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", API_URL, service]];
    }
    else
    {
        /// Check if the request will be send to the testing server.
        if(testing)
            url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@.json", TESTING_URL, service]];
        else
        {
            url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@.json",API_URL, service]];
        }
    }
    
    /// Set the request variable.
    request = [NSMutableURLRequest requestWithURL:url];
    /// Check if the request require the accessToken -a.k.a. spree_api_key-.
    if(accessToken)
    {
        /// Check if the accessToken will be send in the header or in the body.
        if (isInHeader) {
            [request setValue:accessToken forHTTPHeaderField:@"X-Spree-Token"];
        }else{
            [data setObject:accessToken forKey:@"access_token"];
        }
    }
    /// Check if the request will send data.
    if(data)
    {
        /// Create a JSON data variable.
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:kNilOptions error:nil];
        
        /// Serialize the data.
        //NSString *JSONString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
        //NSLog(@"json string: %@", JSONString);
        [request setValue:[NSString stringWithFormat:@"%ld", [jsonData length]] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:jsonData];
    }
    
    /// Set the request.
    [request setHTTPMethod:method];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"json" forHTTPHeaderField:@"Data-Type"];
    /// Send the request.
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
       /// Check for the status of the response.
        if(httpResponse.statusCode == 204)
        {
            callback(@{@"success": @YES});
        }
        else if(!error && response != nil)
        {
            /// Create a dictionary based on the JSON of the response.
            NSDictionary *responseJson = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            callback(responseJson);
        }
        else
        {
            /// Check for the message error.
            if(error)
            {
                /// Set the dictionary with the values of the error message.
                NSMutableDictionary * dictErrorDetails = [NSMutableDictionary new];
                [dictErrorDetails setObject:@NO forKey:@"success"];
                NSString * strErr;
                if([error.userInfo objectForKey:@"NSLocalizedDescription"])
                {
                    //NSLog(@"%@",[error.userInfo objectForKey:@"NSLocalizedDescription"]);
                    strErr = [error.userInfo objectForKey:@"NSLocalizedDescription"];
                }
                else
                {
                    strErr = @"No Info Available!";
                }
                [dictErrorDetails setObject:strErr forKey:@"message"];
                callback(dictErrorDetails);
            }
            else
            {
                callback(nil);
            }
        }
    }];
}

+ (void)updateProducts:(NSString *)userAccessToken toCallback:(void (^)(id))callback{
    AppDelegate * appDelegate = [[UIApplication sharedApplication] delegate];
    /// Send a request to the Spree store. Calls the service "products" throuch "GET" method.
    [RESTManager sendData:nil toService:@"products" withMethod:@"GET" isTesting:appDelegate.isTestingEnv withAccessToken:userAccessToken  isAccessTokenInHeader:NO toCallback:^(id result){
        /// Check for the status of the response.
        if([[result objectForKey:@"success"] isEqual:@NO])
        {
            /// Create a custom alert view to inform about the error.
            LMAlertView * alertView = [[LMAlertView alloc] initWithTitle:@"" message:nil delegate:self cancelButtonTitle:@"Service Error!" otherButtonTitles:nil];
            [alertView setSize:CGSizeMake(200.0f, 320.0f)];
            
            // Add your subviews here to customise
            UIView *contentView = alertView.contentView;
            [contentView setBackgroundColor:[UIColor clearColor]];
            [alertView setBackgroundColor:[UIColor clearColor]];
            UIImageView * imgV = [[UIImageView alloc] initWithFrame:CGRectMake(35.5f, 10.0f, 129.0f, 200.0f)];
            [imgV setImage:[UIImage imageNamed:@"illustration_05"]];
            [contentView addSubview:imgV];
            UILabel * lblStatus = [[UILabel alloc] initWithFrame:CGRectMake(10, 170, 180, 120)];
            lblStatus.numberOfLines = 3;
            [lblStatus setFont:[UIFont fontWithName:@"Lato-Regular" size:16]];
            [lblStatus setTextAlignment:NSTextAlignmentCenter];
            lblStatus.text = [result objectForKey:@"message"];
            [contentView addSubview:lblStatus];
            [alertView show];
            return;
        }
        /// Delete the content of the PRODUCTS table of the local database.
        [DBManager deleteProducts];
        ProductObject *productObject;
        /// first time loading fix
        /// define __block var, to be used inside async block, in this case AsyncImageDownloader method.
        __block int totalImages = [[result objectForKey:@"total_count"] intValue];
        /// This is to control callback dispatch, once all images have been downloaded.
        /// Get all keys from result (since keys are dates).
        NSArray * arrKeys = [result allKeys];
        /// Get the categories from the result.
        NSArray * arrCategories = [result objectForKey:@"categories"];
        /// Delete the content of the tables.
        [DBManager deleteTableContent:@[@"PRODUCT_CATEGORIES", @"PRODUCTS"]];
        /// Insert the categories in the local database.
        for(NSDictionary * dictCategory in arrCategories)
        {
            [DBManager insertCategory:dictCategory];
        }
        /// Loop to look in the array that contains the info of the products.
        for(NSString * strKey in arrKeys)
        {
            /// Create a date formatter.
            NSDateFormatter * dtFormat = [[NSDateFormatter alloc] init];
            [dtFormat setDateFormat:@"yyyy-MM-dd"];
            
            /// Check if it is an exception to break the block and return callback(@NO).
            if([strKey isEqual:@"exception"]) {
                callback(@NO);
                break;
            }/// in result there is a key named total_count to retrieve how many images we are going to download
            else if(![strKey isEqual:@"total_count"] && ![strKey isEqual:@"menu_id"] && ![strKey isEqual:@"categories"])
            {
                /// Create and set the array for the Menu.
                NSArray * arrMenu = [result objectForKey:strKey];
                /// know how many images do we have in our products array
                totalImages = (int)[arrMenu count];
                /// Get the categories from the local database.
                NSMutableArray * arrCategories = [DBManager getCategories];
                for(NSDictionary * dictFinalProduct in arrMenu){
                    NSMutableDictionary * dictProduct = [dictFinalProduct mutableCopy];
                    productObject = [[ProductObject alloc] init];
                    productObject = [productObject assignProductObject:dictProduct];
                    if (productObject.categoryObject.category_id == 0) {
                        totalImages --;
                    }
                }
                /// Loop to look in each element of the array arrMenu.
                for(NSDictionary * dictFinalProduct in arrMenu)
                {
                    /// Create a mutable NSDictionary to set our key (date) as filter on 'available_on'
                    NSMutableDictionary * dictProduct = [dictFinalProduct mutableCopy];
                    [dictProduct setObject:strKey forKey:@"available_on"];
                    productObject = [[ProductObject alloc] init];
                    productObject = [productObject assignProductObject:dictProduct];
                    /// Loop foe each category element in the array arrCategories.
                    for (CategoryObject *categoryObject in arrCategories) {
                        /// Check for the category id of the product and the id of the category object.
                        if (productObject.categoryObject.category_id == categoryObject.category_id) {
                            
                            /// Set the values for the category in the product object.
                            productObject.categoryObject.category_id = categoryObject.category_id;
                            productObject.categoryObject.category_name = categoryObject.category_name;
                            
                            /// Download the images to the local storage.
                            NSString *documentDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                            NSString *filePathAndDirectory = [documentDirectoryPath stringByAppendingString:@"/images/thumbs"];
                            [[NSFileManager defaultManager] createDirectoryAtPath:filePathAndDirectory withIntermediateDirectories:YES attributes:nil error:nil];
                            NSString *fileName = [NSString stringWithFormat:@"%@", productObject.masterObject.imageObject.attachment_file_name];
                            NSString *fullPath = [NSString stringWithFormat:@"%@/%@",filePathAndDirectory, fileName];
                            NSArray * arrUrl = [productObject.masterObject.imageObject.product_url componentsSeparatedByString:@"?"];
                            NSString * url;
                            if([arrUrl count] > 1)
                            {
                                url = [arrUrl objectAtIndex:0];
                            }
                            else
                            {
                                url = productObject.masterObject.imageObject.product_url;
                            }
                            if(url != nil)
                            {
                                [[[AsyncImageDownloader alloc] initWithFileURL:url successBlock:^(NSData *data) {
                                    NSData * dataPic = [NSData dataWithData:UIImageJPEGRepresentation([UIImage imageWithData:data], 1.0f)];
                                    [dataPic writeToFile:fullPath atomically:YES];
                                    totalImages --;
                                    if(totalImages == 0)
                                        callback(@YES);
                                } failBlock:^(NSError *errro) {
                                    //NSLog(@"Failed to download the image to local storage");
                                    totalImages --;
                                    if(totalImages == 0)
                                        callback(@YES);
                                }] startDownload];
                            }
                            [DBManager insertProduct:productObject];
                        }
                    }
                }
            }
        }
    }];
}

@end
