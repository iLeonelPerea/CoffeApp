//
//  MasterObject.m
//  GastronautBase
//
//  Created by Leonel Roberto Perea Trejo on 9/5/14.
//  Copyright (c) 2014 CrowdInt. All rights reserved.
//

#import "MasterObject.h"

@implementation MasterObject

@synthesize cost_price, description, display_price, masterObject_id, in_stock, name, price, sku, imageObject;

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if(self != nil)
    {
        self.cost_price = [coder decodeObjectForKey:@"cost_price"];
        self.description = [coder decodeObjectForKey:@"description"];
        self.display_price = [coder decodeObjectForKey:@"display_price"];
        self.masterObject_id = [coder decodeIntForKey:@"masterObject_id"];
        self.in_stock = [coder decodeIntForKey:@"in_stock"];
        self.name = [coder decodeObjectForKey:@"name"];
        self.price = [coder decodeObjectForKey:@"price"];
        self.sku = [coder decodeObjectForKey:@"sku"];
        self.imageObject = [coder decodeObjectForKey:@"imageObject"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:cost_price forKey:@"cost_price"];
    [coder encodeObject:description forKey:@"description"];
    [coder encodeObject:display_price forKey:@"display_price"];
    [coder encodeInteger:masterObject_id forKey:@"masterObject_id"];
    [coder encodeInteger:in_stock forKey:@"in_stock"];
    [coder encodeObject:name forKey:@"name"];
    [coder encodeObject:price forKey:@"price"];
    [coder encodeObject:sku forKey:@"sku"];
    [coder encodeObject:imageObject forKey:@"imageObject"];
}

@end
