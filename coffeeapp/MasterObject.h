//
//  MasterObject.h
//  GastronautBase
//
//  Created by Leonel Roberto Perea Trejo on 9/5/14.
//  Copyright (c) 2014 CrowdInt. All rights reserved.
//

/** @name MasterObject
 
    Class for the master data of the product.
 */

#import <Foundation/Foundation.h>
#import "ImageObject.h"

@interface MasterObject : NSObject

/** Price cost of the product. */
@property (nonatomic, strong) NSString * cost_price;

/** Description of the product. */
@property (nonatomic, strong) NSString * description;

/** Price to display of the product. */
@property (nonatomic, strong) NSString * display_price;

/** Master Id of the product in the Spree store. */
@property (nonatomic, assign) int masterObject_id;

/** Integer flag to know if the product is in stock in the Spree store. */
@property (nonatomic, assign) int in_stock;

/** Name of the product. */
@property (nonatomic, strong) NSString * name;

/** Price of the product. */
@property (nonatomic, strong) NSString * price;

/** Sku of the product. */
@property (nonatomic, strong) NSString * sku;

/** Object image to store all the images of the product. */
@property (nonatomic, strong) ImageObject * imageObject;

/** Create a custom init to code the object.
 
 @param coder NSCoder variable.
 */
-(id)initWithCoder:(NSCoder*)coder;

/** Create a custom init to decode the object properties.
 
 @param coder NSCoder variable.
 */
-(void)encodeWithCoder:(NSCoder*)coder;

@end
