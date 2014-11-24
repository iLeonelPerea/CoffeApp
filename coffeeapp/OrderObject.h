//
//  OrderObject.h
//  coffeeapp
//
//  Created by Crowd on 10/21/14.
//  Copyright (c) 2014 crowdint. All rights reserved.
//

/** @name OrderObject
 
    Object to contain all data required to make a Spree order.
    It has a method to set the dictionary required to send the order to the Spree store.
 */

#import <Foundation/Foundation.h>
#import "UserObject.h"

@interface OrderObject : NSObject

/** Total number of items on the order. */
@property (nonatomic, strong) NSString * itemTotal;

/** Total amount of the order. */
@property (nonatomic, strong) NSString * total;

/** Total amount of the ship of the order. */
@property (nonatomic, strong) NSString * shipTotal;

/** State of the order. Could be "cart", "confirm" or "complete". */
@property (nonatomic, strong) NSString * state;

/** Total of the adjustment of the order. */
@property (nonatomic, strong) NSString * adjustmentTotal;

/** Email of the user that is sending the order. */
@property (nonatomic, strong) NSString * email;

/** Channel of the user to listen push notifications. */
@property (nonatomic, strong) NSString * channel;

/** Currency used in the order. */
@property (nonatomic, strong) NSString * currency;

/** Total quantity of products of the order. */
@property (nonatomic, strong) NSString * totalQuantity;

/** Total displayed of the order. */
@property (nonatomic, strong) NSString * displayTotal;

/** Total displayed of the shipment of the order. */
@property (nonatomic, strong) NSString * displayShipTotal;

/** Array to store the prodcuts of the order. */
@property (nonatomic, strong) NSMutableArray * arrLineItems;

/** Order number of the order. */
@property (nonatomic, strong) NSString * orderNumber;

/** Object of UserObject to store data of the user. */
@property (nonatomic, strong) UserObject * userObject;


/** Set defaults values when init an instance object. */
-(id)init;

/** Create a custom init to code the object.
 
 @param coder NSCoder variable.
 */
-(id)initWithCoder:(NSCoder*)coder;

/** Create a custom init to decode the object properties.
 
 @param coder NSCoder variable.
 */
-(void)encodeWithCoder:(NSCoder*)coder;

/** Method that returns the dictionary required to make the order.
 
    Set the next things of the order.
    - Checkout steps.
    - Permissions.
    - Billing address.
    - Shipping address.
    - Selected products.
    - Payment method.
    - Shipments.
    - Credit card info.
 */
-(NSMutableDictionary *)getOrderPetition;

@end
