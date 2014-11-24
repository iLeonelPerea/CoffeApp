//
//  CategoryObject.m
//  coffeeapp
//
//  Copyright (c) 2014 crowdint. All rights reserved.
//

#import "CategoryObject.h"

@implementation CategoryObject

@synthesize category_id, category_name;

//create coder and decoder to be able to save on standar user defaults.
- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if(self != nil)
    {
        self.category_id = [coder decodeIntForKey:@"category_id"];
        self.category_name = [coder decodeObjectForKey:@"category_name"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeInteger:category_id forKey:@"category_id"];
    [coder encodeObject:category_name forKey:@"category_name"];
}
@end
