//
//  RESTManager.m
//  coffeeapp
//
//  Created by Crowd on 10/19/14.
//  Copyright (c) 2014 crowdint. All rights reserved.
//

#import "RESTManager.h"
#define TESTING_URL @"http://mobile-store.ngrok.com/api/"

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
            url = [NSURL URLWithString:[NSString stringWithFormat:@"http://spree-demo-store.herokuapp.com/api/%@", service]];
    }
    else
    {
        if(testing)
            url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@.json", TESTING_URL, service]];
        else
        {
            url = [NSURL URLWithString:[NSString stringWithFormat:@"http://spree-demo-store.herokuapp.com/api/%@.json", service]];
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

@end
