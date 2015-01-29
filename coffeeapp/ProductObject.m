//
//  ProductObject.m
//  GastronautBase
//
//  Created by Leonel Roberto Perea Trejo on 9/5/14.
//  Copyright (c) 2014 CrowdInt. All rights reserved.
//

#import "ProductObject.h"
#import "AppDelegate.h"

@implementation ProductObject

@synthesize product_id, masterObject, categoryObject, name, total_on_hand, quantity, delivery_type, delivery_date, date_available, comment, isEditingComments, isAvailable;


//create coder and decoder to be able to save on standar user defaults.
- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if(self != nil)
    {
        self.product_id = [coder decodeIntForKey:@"product_id"];
        self.masterObject = [coder decodeObjectForKey:@"masterObject"];
        self.name = [coder decodeObjectForKey:@"name"];
        self.delivery_date = [coder decodeObjectForKey:@"delivery_date"];
        self.total_on_hand = [coder decodeIntForKey:@"total_on_hand"];
        self.quantity = [coder decodeIntForKey:@"quantity"];
        self.delivery_type = [coder decodeIntForKey:@"delivery_type"];
        self.date_available = [coder decodeFloatForKey:@"date_available"];
        self.comment = [coder decodeObjectForKey:@"comment"];
        self.isEditingComments = [coder decodeBoolForKey:@"isEditingComments"];
        self.isAvailable = [coder decodeBoolForKey:@"isAvailable"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeInteger:product_id forKey:@"product_id"];
    [coder encodeObject:masterObject forKey:@"masterObject"];
    [coder encodeObject:name forKey:@"name"];
    [coder encodeObject:delivery_date forKey:@"delivery_date"];
    [coder encodeInteger:total_on_hand forKey:@"total_on_hand"];
    [coder encodeInteger:quantity forKey:@"quantity"];
    [coder encodeInteger:delivery_type forKey:@"delivery_type"];
    [coder encodeFloat:date_available forKey:@"date_available"];
    [coder encodeObject:comment forKey:@"comment"];
    [coder encodeBool:isEditingComments forKey:@"isEditingComments"];
    [coder encodeBool:isAvailable forKey:@"isAvailable"];
}

/// Assign the properties of the product object based on a dictionary.
-(ProductObject*)assignProductObject:(NSDictionary*)dictProduct{
    ProductObject *newProductObject = [ProductObject new];
    masterObject = [MasterObject new];
    [newProductObject setProduct_id:([dictProduct objectForKey:@"id"]!= [NSNull null])? [[dictProduct objectForKey:@"id"] intValue]:0];
    NSDictionary * dictMaster = [dictProduct objectForKey:@"master"];    [masterObject setMasterObject_id:([dictMaster objectForKey:@"id"]!= [NSNull null])? [[dictMaster objectForKey:@"id"] intValue]:0];
    ImageObject *imageObject = [ImageObject new];
    NSMutableArray *arrImages = [dictMaster objectForKey:@"images"];
    NSMutableDictionary * dictImages = [arrImages objectAtIndex:0];
    [imageObject setAttachment_file_name:([dictImages objectForKey:@"attachment_file_name"]!= [NSNull null])? [dictImages objectForKey:@"attachment_file_name"]:@""];
    [imageObject setImage_id:[[dictImages objectForKey:@"id"] intValue]];    [imageObject setProduct_url:([dictImages objectForKey:@"product_url"]!= [NSNull null])? [dictImages objectForKey:@"product_url"]:@""];
    [masterObject setImageObject:imageObject];
    [masterObject setIn_stock:([dictMaster objectForKey:@"in_stock"]!= [NSNull null])? [[dictMaster objectForKey:@"in_stock"] intValue]:0];
    [newProductObject setMasterObject:masterObject];
    CategoryObject * newCategoryObject = [[CategoryObject alloc] init];
    NSMutableArray * arrCategory = [dictProduct objectForKey:@"categories"];
    if ([arrCategory count]!=0) {
        NSMutableDictionary * dictCategory = [arrCategory objectAtIndex:0];
        [newCategoryObject setCategory_id:([dictCategory objectForKey:@"id"] != [NSNull null])?[[dictCategory objectForKey:@"id"] intValue]:0];
        [newCategoryObject setCategory_name:([dictCategory objectForKey:@"name"] != [NSNull null])?[dictCategory objectForKey:@"name"]:@"N/A"];
    }else{
        [newCategoryObject setCategory_id:0];
        [newCategoryObject setCategory_name:@"N/A"];
    }
    [newProductObject setCategoryObject:newCategoryObject];
    [newProductObject setName:([dictProduct objectForKey:@"name"] != [NSNull null])?[dictProduct objectForKey:@"name"]:@"N/A"];
    [newProductObject setTotal_on_hand:([dictProduct objectForKey:@"total_on_hand"]!= [NSNull null])? [[dictProduct objectForKey:@"total_on_hand"] intValue]:0];
    NSString * strGivenDate = [[dictProduct objectForKey:@"available_on"] substringToIndex:10];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *dateFromString = [[NSDate alloc] init];
    dateFromString = [dateFormatter dateFromString:strGivenDate];
    float dateFloat = [dateFromString timeIntervalSince1970];
    [newProductObject setDate_available:dateFloat];
    newProductObject.isEditingComments = NO;
    
    NSDateFormatter * dtFormatter = [[NSDateFormatter alloc] init];
    [dtFormatter setDateFormat:@"HH:mm"];
    NSDate * initialAvailableTime = [dtFormatter dateFromString:[dictProduct objectForKey:@"available_from"]];
    NSDate * finalAvailableTime = [dtFormatter dateFromString:[dictProduct objectForKey:@"available_to"]];
    
    /// Get the current time from the server
    AppDelegate * appDelegate = [[UIApplication sharedApplication] delegate];
    NSDateFormatter * dtFormatterFullTimeFormat = [[NSDateFormatter alloc] init];
    [dtFormatterFullTimeFormat setDateFormat:@"HH:mm:SS"];
    NSDate * currentTime = [dtFormatterFullTimeFormat dateFromString:[appDelegate strCurrentHour]];
    
    [newProductObject setIsAvailable:(([currentTime compare:initialAvailableTime] == NSOrderedDescending) &&  ([currentTime compare:finalAvailableTime] == NSOrderedAscending))];
    NSLog(@"product.isAvailable: %d", newProductObject.isAvailable);
    return newProductObject;
}

/// Assign the product object properties based on a dictionary with data from the local DB.
-(ProductObject*)assignProductObjectDB:(NSDictionary*)dictProduct{
    ProductObject *newProductObject = [[ProductObject alloc]init];
    masterObject = [[MasterObject alloc] init];
    [newProductObject setProduct_id:([dictProduct objectForKey:@"product_id"]!= [NSNull null])? [[dictProduct objectForKey:@"product_id"] intValue]:0];
    [masterObject setMasterObject_id:([dictProduct objectForKey:@"masterObject_id"]!= [NSNull null])? [[dictProduct objectForKey:@"masterObject_id"] intValue]:0];
    ImageObject *imageObject = [[ImageObject alloc] init];
    [imageObject setAttachment_file_name:([dictProduct objectForKey:@"attachment_file_name"]!= [NSNull null])? [dictProduct objectForKey:@"attachment_file_name"]:@""];
    [imageObject setImage_id:[[dictProduct objectForKey:@"image_id"] intValue]];
    [imageObject setProduct_url:([dictProduct objectForKey:@"product_url"]!= [NSNull null])? [dictProduct objectForKey:@"product_url"]:@""];
    [masterObject setImageObject:imageObject];
    [masterObject setIn_stock:([dictProduct objectForKey:@"in_stock"]!= [NSNull null])? [[dictProduct objectForKey:@"in_stock"] intValue]:0];
    [newProductObject setMasterObject:masterObject];
    CategoryObject * newCategoryObject = [[CategoryObject alloc] init];
    [newCategoryObject setCategory_id:([dictProduct objectForKey:@"category_id"]!= [NSNull null])? [[dictProduct objectForKey:@"category_id"] intValue]:0];
    [newCategoryObject setCategory_name:([dictProduct objectForKey:@"category_name"] != [NSNull null])?[dictProduct objectForKey:@"category_name"]:@"N/A"];
    [newProductObject setCategoryObject:newCategoryObject];
    [newProductObject setName:([dictProduct objectForKey:@"name"] != [NSNull null])?[dictProduct objectForKey:@"name"]:@"N/A"];
    [newProductObject setTotal_on_hand:([dictProduct objectForKey:@"total_on_hand"]!= [NSNull null])? [[dictProduct objectForKey:@"total_on_hand"] intValue]:0];
    [newProductObject setDate_available:([[dictProduct objectForKey:@"date_available"] floatValue] != 0.0f)?[[dictProduct objectForKey:@"date_available"] floatValue]:0.0f];
    [newProductObject setDelivery_type:0];
    [newProductObject setDelivery_date:@"01-01-2000 00:00"];
    return newProductObject;
}

@end
