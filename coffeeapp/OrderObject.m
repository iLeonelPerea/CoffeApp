//
//  OrderObject.m
//  coffeeapp
//
//  Created by Crowd on 10/21/14.
//  Copyright (c) 2014 crowdint. All rights reserved.
//

#import "OrderObject.h"

@implementation OrderObject
@synthesize itemTotal, total, shipTotal, state, adjustmentTotal, email, channel, currency, totalQuantity, displayTotal, displayShipTotal, arrLineItems, orderNumber, userObject;

//Set defaults values when init an instance object
-(id)init
{
    self = [super init];
    if (self) {
        //Main properties
        [self setItemTotal:@"0"];
        [self setTotal:@"0"];
        [self setShipTotal:@"0"];
        [self setState:@"cart"];
        [self setAdjustmentTotal:@"0.00"];
        userObject = [[UserObject alloc] init];
        [self setEmail:[userObject userEmail]];
        [self setChannel:@"spree"];
        [self setCurrency:@"USD"];
        [self setTotalQuantity:@"0"];
        [self setDisplayTotal:@"0"];
        [self setDisplayShipTotal:@""];
        [self setOrderNumber:@""];
    }
    return self;
}

//Code and encode methos to store object into user defaults
- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if(self != nil)
    {
        [self setItemTotal:[coder decodeObjectForKey:@"itemTotal"]];
        [self setTotal:[coder decodeObjectForKey:@"total"]];
        [self setShipTotal:[coder decodeObjectForKey:@"shipTotal"]];
        [self setState:[coder decodeObjectForKey:@"state"]];
        [self setAdjustmentTotal:[coder decodeObjectForKey:@"adjustmentTotal"]];
        [self setEmail:[coder decodeObjectForKey:@"email"]];
        [self setChannel:[coder decodeObjectForKey:@"channel"]];
        [self setCurrency:[coder decodeObjectForKey:@"currency"]];
        [self setTotalQuantity:[coder decodeObjectForKey:@"totalQuantity"]];
        [self setDisplayTotal:[coder decodeObjectForKey:@"displayTotal"]];
        [self setDisplayShipTotal:[coder decodeObjectForKey:@"displayShipTotal"]];
        [self setOrderNumber:[coder decodeObjectForKey:@"orderNumber"]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:itemTotal forKey:@"itemTotal"];
    [coder encodeObject:total forKey:@"total"];
    [coder encodeObject:shipTotal forKey:@"shipTotal"];
    [coder encodeObject:state forKey:@"state"];
    [coder encodeObject:adjustmentTotal forKey:@"adjustmentTotal"];
    [coder encodeObject:email forKey:@"email"];
    [coder encodeObject:channel forKey:@"channel"];
    [coder encodeObject:currency forKey:@"currency"];
    [coder encodeObject:totalQuantity forKey:@"totalQuantity"];
    [coder encodeObject:displayTotal forKey:@"displayTotal"];
    [coder encodeObject:displayShipTotal forKey:@"displayShipTotal"];
    [coder encodeObject:orderNumber forKey:@"orderNumber"];
}

#pragma mark -- Get order petition method
-(NSMutableDictionary *)getOrderPetition
{
    //This method set all the data into the structure required to make a Spree order
    //Iniatilaze the master dictionary to store petition order data
    NSMutableDictionary * dictMaster = [[NSMutableDictionary alloc] init];
    
    //Set the main values required
    [dictMaster setObject:[NSString stringWithFormat:@"%d",userObject.userId] forKey:@"user_id"];
    NSMutableDictionary * dictFullOrder = [[NSMutableDictionary alloc] init];
    [dictFullOrder setObject:itemTotal forKey:@"item_total"];
    [dictFullOrder setObject:total forKey:@"total"];
    [dictFullOrder setObject:shipTotal forKey:@"ship_total"];
    [dictFullOrder setObject:state forKey:@"state"];
    [dictFullOrder setObject:adjustmentTotal forKey:@"adjustment_total"];
    [dictFullOrder setObject:[userObject userEmail] forKey:@"email"];
    [dictFullOrder setObject:channel forKey:@"channel"];
    [dictFullOrder setObject:currency forKey:@"currency"];
    [dictFullOrder setObject:totalQuantity forKey:@"total_quantity"];
    [dictFullOrder setObject:displayTotal forKey:@"display_total"];
    [dictFullOrder setObject:displayShipTotal forKey:@"display_ship_total"];
    
    //Checkout steps
    [dictFullOrder setObject:@[@"address", @"delivery", @"complete"] forKey:@"checkout_steps"];
    
    //Permissions
    NSMutableDictionary * dictPermissions = [[NSMutableDictionary alloc] init];
    [dictPermissions setObject:@"true" forKey:@"can_update"];
    [dictFullOrder setObject:dictPermissions forKey:@"permissions"];
    
    //Billing address
    NSMutableDictionary * dictBillingAddressAttributes = [[NSMutableDictionary alloc] init];
    /*[dictBillingAddressAttributes setObject:@"Crowd" forKey:@"firstname"];
    [dictBillingAddressAttributes setObject:@"Interactive" forKey:@"lastname"];*/
    [dictBillingAddressAttributes setObject:userObject.firstName forKey:@"firstname"];
    [dictBillingAddressAttributes setObject:userObject.lastName forKey:@"lastname"];
    [dictBillingAddressAttributes setObject:@"Constitución 2035" forKey:@"address1"];
    [dictBillingAddressAttributes setObject:@"Colima" forKey:@"city"];
    [dictBillingAddressAttributes setObject:@"312123456789" forKey:@"phone"];
    [dictBillingAddressAttributes setObject:@"28017" forKey:@"zipcode"];
    [dictBillingAddressAttributes setObject:@"49" forKey:@"state_id"];
    [dictBillingAddressAttributes setObject:@"49" forKey:@"country_id"];
    [dictFullOrder setObject:dictBillingAddressAttributes forKey:@"bill_address_attributes"];
    
    //Shipping address
    NSMutableDictionary * dictAddressAttributes = [[NSMutableDictionary alloc] init];
    /*[dictAddressAttributes setObject:@"Crowd" forKey:@"firstname"];
    [dictAddressAttributes setObject:@"Interactive" forKey:@"lastname"];*/
    [dictAddressAttributes setObject:userObject.firstName forKey:@"firstname"];
    [dictAddressAttributes setObject:userObject.lastName forKey:@"lastname"];
    [dictAddressAttributes setObject:@"Constitucion 2035" forKey:@"address1"];
    [dictAddressAttributes setObject:@"Colima" forKey:@"city"];
    [dictAddressAttributes setObject:@"312123456789" forKey:@"phone"];
    [dictAddressAttributes setObject:@"28017" forKey:@"zipcode"];
    [dictAddressAttributes setObject:@"49" forKey:@"state_id"];
    [dictAddressAttributes setObject:@"49" forKey:@"country_id"];
    [dictFullOrder setObject:dictAddressAttributes forKey:@"ship_address_attributes"];
    
    //Selected products
    [dictFullOrder setObject:arrLineItems forKey:@"line_items"];
    
    //Payment method
    NSMutableArray * arrPaymentsAttributes = [[NSMutableArray alloc] init];
    NSMutableDictionary * dictPaymentMethod = [[NSMutableDictionary alloc] init];
    [dictPaymentMethod setObject:@"6" forKey:@"payment_method_id"];
    [arrPaymentsAttributes addObject:dictPaymentMethod];
    [dictFullOrder setObject:arrPaymentsAttributes forKey:@"payments_attributes"];
    
    //Shipments
    NSMutableArray * arrShipments = [[NSMutableArray alloc] init];
    NSMutableDictionary * dictShipping = [[NSMutableDictionary alloc] init];
    [dictShipping setObject:@"1" forKey:@"selected_shipping_rate_id"];
    [dictShipping setObject:@"1" forKey:@"id"];
    [arrShipments addObject:dictShipping];
    [dictFullOrder setObject:arrShipments forKey:@"shipments"];
    
    //Credit card info
    NSMutableDictionary * dictPaymentSource = [[NSMutableDictionary alloc] init];
    NSMutableDictionary * dictPaymentSourceInfo = [[NSMutableDictionary alloc] init];
    [dictPaymentSourceInfo setObject:@"5454545454545454" forKey:@"number"];
    [dictPaymentSourceInfo setObject:@"312" forKey:@"verification_value"];
    [dictPaymentSourceInfo setObject:@"01/30" forKey:@"expiry"];
    [dictPaymentSourceInfo setObject:@"Visa" forKey:@"cc_type"];
    [dictPaymentSourceInfo setObject:@"Credit" forKey:@"cc_kind"];
    //[dictPaymentSourceInfo setObject:@"Crowd Interactive" forKey:@"name"];
    [dictPaymentSource setObject:dictPaymentSourceInfo forKey:@"1"];
    
    //Inser into master dictionay all data
    [dictMaster setObject:dictPaymentSource forKey:@"payment_source"];
    [dictMaster setObject:dictFullOrder forKey:@"order"];
    [dictMaster setObject:orderNumber forKey:@"orderNumber"];
    
    return dictMaster;
}


@end
