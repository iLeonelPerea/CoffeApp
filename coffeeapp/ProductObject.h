//
//  ProductObject.h
//
//  Copyright (c) 2014 CrowdInt. All rights reserved.
//

/** @name ProductObject
 
    Class to define the structure of the products.
 
    It has two methods to assign the object properties.
 */

#import <Foundation/Foundation.h>
#import "MasterObject.h"
#import "ImageObject.h"
#import "CategoryObject.h"

@interface ProductObject : NSObject

/** Description of the product. */
@property (nonatomic, strong) NSString * description;

/** Price to display of the product. */
@property (nonatomic, strong) NSString * display_price;

/** Id of the product in the Spree store. */
@property (nonatomic, assign) int product_id;

/** Object for the master data of the product. */
@property (nonatomic, strong) MasterObject * masterObject;

/** Object for the category of the product. */
@property (nonatomic, strong) CategoryObject * categoryObject;

/** Name of the product. */
@property (nonatomic, strong) NSString * name;

/** Price of the product. */
@property (nonatomic, strong) NSString * price;

/** Slug of the product. */
@property (nonatomic, strong) NSString * slug;

/** Total on hand -stock- of the product in the Spree store. */
@property (nonatomic, assign) int total_on_hand;

/** Quantity selected of the product. */
@property (nonatomic, assign) int quantity;

/** Days that the product will be display. */
@property (nonatomic, assign) int showDays;

/** Delivery type of the product. */
@property (nonatomic, assign) int delivery_type;

/** Delivery date for the product. */
@property (nonatomic, strong) NSString * delivery_date;

/** Date of the availability of the product. */
@property (nonatomic, assign) float date_available;

/** Assign the properties of an product object based on the dictionary sended as param. Returns an instance with the data setted.
 
    @param dictProduct Dictionary with the data of the product.
 */
-(ProductObject*)assignProductObject:(NSMutableDictionary*)dictProduct;

/** Assign the properties of an product object based on the dictionary sended as param from the local database. Returns an instance with the data setted.
 
 @param dictProduct Dictionary with the data of the product.
 */
-(ProductObject*)assignProductObjectDB:(NSDictionary*)dictProduct;

@end
