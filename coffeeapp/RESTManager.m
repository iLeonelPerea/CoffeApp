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


#define TESTING_URL @"http://36b9d303.ngrok.com/api"

@implementation RESTManager

+(void)sendData:(NSMutableDictionary *)data toService:(NSString *)service withMethod:(NSString *)method isTesting:(BOOL)testing withAccessToken:(NSString *)accessToken isAccessTokenInHeader:(BOOL) isInHeader toCallback:(void (^)(id))callback
{
    NSURL *url = nil;
    NSMutableURLRequest *request;
    if(![method isEqual: @"GET"])
    {
        if(testing)
        {
            url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",TESTING_URL, service]];
        }
        else
            url = [NSURL URLWithString:[NSString stringWithFormat:@"https://stage-spree-demo-store-two.herokuapp.com/api/%@", service]];
    }
    else
    {
        if(testing)
            url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@.json", TESTING_URL, service]];
        else
        {
            url = [NSURL URLWithString:[NSString stringWithFormat:@"https://stage-spree-demo-store-two.herokuapp.com/api/%@.json", service]];
        }
    }
    
    
    request = [NSMutableURLRequest requestWithURL:url];
    if(accessToken)
    {
        if (isInHeader) {
            [request setValue:accessToken forHTTPHeaderField:@"X-Spree-Token"];
        }else{
            [data setObject:accessToken forKey:@"access_token"];
        }
    }
    if(data)
    {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:kNilOptions error:nil];
        
        NSString *JSONString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
        NSLog(@"json string: %@", JSONString);
        [request setValue:[NSString stringWithFormat:@"%ld", [jsonData length]] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:jsonData];
    }
    [request setHTTPMethod:method];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"json" forHTTPHeaderField:@"Data-Type"];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if(httpResponse.statusCode == 204)
        {
            callback(@{@"success": @YES});
        }
        else if(!error && response != nil)
        {
            NSDictionary *responseJson = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            callback(responseJson);
        }
        else
        {
            callback(nil);
        }
    }];
}

+ (void)updateProducts:(NSString *)userAccessToken toCallback:(void (^)(id))callback{
    AppDelegate * appDelegate = [[UIApplication sharedApplication] delegate];
    [RESTManager sendData:nil toService:@"products" withMethod:@"GET" isTesting:appDelegate.isTestingEnv withAccessToken:userAccessToken  isAccessTokenInHeader:NO toCallback:^(id result){
        //int showDays = 0;
        [DBManager deleteProducts];
        ProductObject *productObject;
        //first time loading fix
        __block int totalImages = [[result objectForKey:@"total_count"] intValue]; // define __block var, to be used inside async block, in this case AsyncImageDownloader method
        // this is to control callback dispatch, once all images have been downloaded.
        NSArray * arrKeys = [result allKeys]; //get all keys from result (since keys are dates)
        NSArray * arrCategories = [result objectForKey:@"categories"];
        [DBManager deleteTableContent:@[@"PRODUCT_CATEGORIES", @"PRODUCTS"]];
        for(NSDictionary * dictCategory in arrCategories)
        {
            [DBManager insertCategory:dictCategory];
        }
        for(NSString * strKey in arrKeys)
        {
            NSDateFormatter * dtFormat = [[NSDateFormatter alloc] init];
            [dtFormat setDateFormat:@"yyyy-MM-dd"];
            //NSString * strCurrentDate = [dtFormat stringFromDate:[NSDate date]];
            
            if([strKey isEqual:@"exception"]) {
                callback(@NO);
                break;
            }else if(![strKey isEqual:@"total_count"] && ![strKey isEqual:@"menu_id"] && ![strKey isEqual:@"categories"]) // in result there is a key named total_count to retrieve how many images we are going to download
            //else if([strKey isEqual:[dtFormat stringFromDate:[NSDate date]]])
            {
                NSArray * arrMenu = [result objectForKey:strKey];
                totalImages = (int)[arrMenu count]; // know how many images do we have in our products array
                NSMutableArray * arrCategories = [DBManager getCategories];
                for(NSDictionary * dictFinalProduct in arrMenu){
                    NSMutableDictionary * dictProduct = [dictFinalProduct mutableCopy];
                    productObject = [[ProductObject alloc] init];
                    productObject = [productObject assignProductObject:dictProduct];
                    if (productObject.categoryObject.category_id != 0) {
                        totalImages --;
                    }
                }
                for(NSDictionary * dictFinalProduct in arrMenu)
                {
                    NSMutableDictionary * dictProduct = [dictFinalProduct mutableCopy]; //create a mutable NSDictionary to set our key (date) as filter on 'available_on'
                    [dictProduct setObject:strKey forKey:@"available_on"];
                    productObject = [[ProductObject alloc] init];
                    productObject = [productObject assignProductObject:dictProduct];
                    
                    for (CategoryObject *categoryObject in arrCategories) {
                        if (productObject.categoryObject.category_id == categoryObject.category_id) {
                            
                            productObject.categoryObject.category_id = categoryObject.category_id;
                            productObject.categoryObject.category_name = categoryObject.category_name;
                            
                            // Image download to local storage.
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
                                } failBlock:^(NSError *errro) {
                                    NSLog(@"Failed to download the image to local storage");
                                    totalImages --;
                                }] startDownload];
                            }
                            [DBManager insertProduct:productObject];
                        }
                    }
                }
                callback(@YES);
            }
        }
    }];
}

@end
