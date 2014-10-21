//
//  OrderObject.h
//  coffeeapp
//
//  Created by Crowd on 10/21/14.
//  Copyright (c) 2014 crowdint. All rights reserved.
//
//---------------------------------------------------
// Object to contain all data required to make a Spree order.
// In this case, most of the values are hard coded.

#import <Foundation/Foundation.h>
#import "UserObject.h"

@interface OrderObject : NSObject

//Main object properties
@property (nonatomic, strong) NSString * itemTotal;
@property (nonatomic, strong) NSString * total;
@property (nonatomic, strong) NSString * shipTotal;
@property (nonatomic, strong) NSString * state;
@property (nonatomic, strong) NSString * adjustmentTotal;
@property (nonatomic, strong) NSString * email;
@property (nonatomic, strong) NSString * channel;
@property (nonatomic, strong) NSString * currency;
@property (nonatomic, strong) NSString * totalQuantity;
@property (nonatomic, strong) NSString * displayTotal;
@property (nonatomic, strong) NSString * displayShipTotal;
@property (nonatomic, strong) NSMutableArray * arrLineItems;
@property (nonatomic, strong) NSString * orderNumber;
@property (nonatomic, strong) UserObject * userObject;

-(NSMutableDictionary *)getOrderPetition;

@end
