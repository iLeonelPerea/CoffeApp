//
//  CategoryObject.h
//  coffeeapp
//
//  Copyright (c) 2014 crowdint. All rights reserved.
//

/** @name CategoryObject
 
    Class to define the structure of a category of products.
 */

#import <Foundation/Foundation.h>

@interface CategoryObject : NSObject

/** Id for the category in the Spree store. */
@property (nonatomic, assign) int category_id;

/** Name of the category. */
@property (nonatomic, strong) NSString * category_name;

/** Create a custom init to code the object.
 
 @param coder NSCoder variable.
 */
-(id)initWithCoder:(NSCoder*)coder;

/** Create a custom init to decode the object properties.
 
 @param coder NSCoder variable.
 */
-(void)encodeWithCoder:(NSCoder*)coder;

@end
