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

/** Master Id of the product in the Spree store. */
@property (nonatomic, assign) int masterObject_id;

/** Integer flag to know if the product is in stock in the Spree store. */
@property (nonatomic, assign) int in_stock;

/** Name of the product. */
@property (nonatomic, strong) NSString * name;


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
