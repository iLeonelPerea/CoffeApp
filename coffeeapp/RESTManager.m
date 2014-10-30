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

#define TESTING_URL @"http://539aac34.ngrok.com/api"

@implementation RESTManager

+(void)sendData:(NSMutableDictionary *)data toService:(NSString *)service withMethod:(NSString *)method isTesting:(BOOL)testing withAccessToken:(NSString *)accessToken toCallback:(void (^)(id))callback
{
    NSURL *url = nil;
    NSMutableURLRequest *request;
    if(![method isEqual: @"GET"])
    {
        if(testing)
            url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",TESTING_URL, service]];
        else
            url = [NSURL URLWithString:[NSString stringWithFormat:@"http://stage-spree-demo-store-two.herokuapp.com/api/%@", service]];
    }
    else
    {
        if(testing)
            url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@.json", TESTING_URL, service]];
        else
        {
            url = [NSURL URLWithString:[NSString stringWithFormat:@"http://stage-spree-demo-store-two.herokuapp.com/api/%@.json", service]];
        }
    }
    
    
    request = [NSMutableURLRequest requestWithURL:url];
    if(accessToken && data)
    {
        [data setObject:accessToken forKey:@"access_token"];
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
    [RESTManager sendData:nil toService:@"products" withMethod:@"GET" isTesting:NO withAccessToken:userAccessToken toCallback:^(id result){
        //int showDays = 0;
        [DBManager deleteProducts];
        ProductObject *productObject;
        //first time loading fix
        __block int totalImages = [[result objectForKey:@"total_count"] intValue]; // define __block var, to be used inside async block, in this case AsyncImageDownloader method
        NSUserDefaults *defaults =  [NSUserDefaults standardUserDefaults]; // Save the count of sections
        [defaults setObject:[result objectForKey:@"total_count"] forKey:@"count_sections"];
        [defaults synchronize];
        // this is to control callback dispatch, once all images have been downloaded.
        NSArray * arrKeys = [result allKeys]; //get all keys from result (since keys are dates)
        for(NSString * strKey in arrKeys)
        {
            if(![strKey isEqual:@"total_count"] && ![strKey isEqual:@"menu_id"] && ![strKey isEqual:@"categories"]) // in result there is a key named total_count to retrieve how many images we are going to download
            {
                NSArray * arrMenu = [result objectForKey:strKey];
                for(NSDictionary * dictFinalProduct in arrMenu)
                {
                    NSMutableDictionary * dictProduct = [dictFinalProduct mutableCopy]; //create a mutable NSDictionary to set our key (date) as filter on 'available_on'
                    [dictProduct setObject:strKey forKey:@"available_on"];
                    productObject = [[ProductObject alloc] init];
                    productObject = [productObject assignProductObject:dictProduct];
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
                            if(totalImages == 0)
                            {
                                callback(@YES);
                            }
                        } failBlock:^(NSError *errro) {
                            NSLog(@"Failed to download the image to local storage");
                            totalImages --;
                            if(totalImages == 0)
                                callback(@YES);
                        }] startDownload];
                    }
                    [DBManager insertProduct:productObject];
                    [DBManager insertProductCategory:productObject];
                }
            }
        }
    }];
}

@end
