//
//  ImageObject.h
//  GastronautBase
//
//  Created by Leonel Roberto Perea Trejo on 9/5/14.
//  Copyright (c) 2014 CrowdInt. All rights reserved.
//

/** @name ImageObject
 
    Object to store the data of the images of the products.
 */

#import <Foundation/Foundation.h>

@interface ImageObject : NSObject

/** Name of the file. */
@property (nonatomic, strong) NSString * attachment_file_name;

/** Id of the image. */
@property (nonatomic, assign) int image_id;

/** URL for the image of the product. */
@property (nonatomic, strong) NSString * product_url;

/** Create a custom init to code the object.
 
 @param coder NSCoder variable.
 */
-(id)initWithCoder:(NSCoder*)coder;

/** Create a custom init to decode the object properties.
 
 @param coder NSCoder variable.
 */
-(void)encodeWithCoder:(NSCoder*)coder;


@end
