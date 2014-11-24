//
//  RESTManager.h
//  coffeeapp
//
//  Created by Crowd on 10/19/14.
//  Copyright (c) 2014 crowdint. All rights reserved.
//

/** Class with the methods for request to the Spree store. */

#import <Foundation/Foundation.h>
#import "ProductObject.h"
#import "DBManager.h"
#import <LMAlertView.h>

@interface RESTManager : NSObject

/** Method to send a request to the Spree store.
 
    It is used to send a request to an endpoint of the Spree store.
 
    The process consits on:
    - Check for the type of the method to make the request.
        - Check if the request will be send to the testing server.
    - Check if the request require the accessToken -a.k.a. spree_api_key-.
        - Check if the accessToken will be send in the header or in the body.
    - Check if the request will send data.
        - Serialize the data.
    - Send the request.
        - Check for the status of the response.
            - Create a dictionary based on the JSON of the response.
            - Check for errors.
 
    @param data Dictionary with the data to be sended.
    @param service The name of the endpoint of the Spree store.
    @param method If the request is GET or POST.
    @param testing Flag to define is the request will be send to the testing server.
    @param accessToken The spree_api_key value.
    @param isInHeader Flag to define if the accessToken will be sended in the header or in the boy of the request.
    @param (id)callback The response of the request.
 */
+(void)sendData:(NSMutableDictionary *)data toService:(NSString *)service withMethod:(NSString *)method isTesting:(BOOL)testing withAccessToken:(NSString *)accessToken isAccessTokenInHeader:(BOOL) isInHeader toCallback:(void (^)(id))callback;

/** A special request to get the current menu from the Spree store.
 
    The process consists on:
    - Send a request to the Spree store. Calls the service "products" throuch "GET" method.
    - Check for the status of the response.
        - Check for errors in the response.
    - Delete the content of the PRODUCTS table of the local database.
    - Get all keys from result (since keys are dates).
    - Get the categories from the result.
    - Delete the content of the tables. Calls DBManager's method deleteTableContent, with an array with the values -names of tables- "PRODUCT_CATEGORIES" and "PRODUCTS".
    - Loop to look in the array that contains the info of the products.
        - Check if it is an exception to break the block and return callback(@NO).
        - Create and set the array for the Menu.
        - Get the categories from the local database.
        - Loop to look in each element of the array arrMenu.
        - Download the images to the local storage.
 
    @param userAccessToken The spree_api_key value.
    @param (id)callback The response of the request.
 */
+(void)updateProducts:(NSString *)userAccessToken toCallback:(void (^)(id))callback;

@end
