//
//  ImageObject.m
//  GastronautBase
//
//  Created by Leonel Roberto Perea Trejo on 9/5/14.
//  Copyright (c) 2014 CrowdInt. All rights reserved.
//

#import "ImageObject.h"

@implementation ImageObject

@synthesize attachment_file_name, image_id, large_url, mini_url, product_url, small_url;


- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if(self != nil)
    {
        self.attachment_file_name = [coder decodeObjectForKey:@"attachment_file_name"];
        self.image_id = [coder decodeIntForKey:@"image_id"];
        self.large_url = [coder decodeObjectForKey:@"large_url"];
        self.mini_url = [coder decodeObjectForKey:@"mini_url"];
        self.product_url = [coder decodeObjectForKey:@"product_url"];
        self.small_url = [coder decodeObjectForKey:@"small_url"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:attachment_file_name forKey:@"attachment_file_name"];
    [coder encodeInt:image_id forKey:@"image_id"];
    [coder encodeObject:large_url forKey:@"large_url"];
    [coder encodeObject:mini_url forKey:@"mini_url"];
    [coder encodeObject:product_url forKey:@"product_url"];
    [coder encodeObject:small_url forKey:@"small_url"];
}

@end
