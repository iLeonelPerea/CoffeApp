//
//  ImageObject.m
//  GastronautBase
//
//  Created by Leonel Roberto Perea Trejo on 9/5/14.
//  Copyright (c) 2014 CrowdInt. All rights reserved.
//

#import "ImageObject.h"

@implementation ImageObject

@synthesize attachment_file_name, image_id, product_url;

/// Create a custom init to code the object properties.
- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if(self != nil)
    {
        self.attachment_file_name = [coder decodeObjectForKey:@"attachment_file_name"];
        self.image_id = [coder decodeIntForKey:@"image_id"];
        self.product_url = [coder decodeObjectForKey:@"product_url"];    }
    return self;
}

/// Create a custom init to decode the object properties.
- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:attachment_file_name forKey:@"attachment_file_name"];
    [coder encodeInt:image_id forKey:@"image_id"];
    [coder encodeObject:product_url forKey:@"product_url"];
}

@end
