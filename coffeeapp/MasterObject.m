//
//  MasterObject.m
//  GastronautBase
//
//  Created by Leonel Roberto Perea Trejo on 9/5/14.
//  Copyright (c) 2014 CrowdInt. All rights reserved.
//

#import "MasterObject.h"

@implementation MasterObject

@synthesize masterObject_id, in_stock, imageObject;


/// Create a custom init to code the object properties.
- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if(self != nil)
    {
        self.masterObject_id = [coder decodeIntForKey:@"masterObject_id"];
        self.in_stock = [coder decodeIntForKey:@"in_stock"];
        self.imageObject = [coder decodeObjectForKey:@"imageObject"];
    }
    return self;
}

/// Create a custom init to decode the object properties.
- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeInteger:masterObject_id forKey:@"masterObject_id"];
    [coder encodeInteger:in_stock forKey:@"in_stock"];
}

@end
