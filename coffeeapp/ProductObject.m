//
//  ProductObject.m
//  GastronautBase
//
//  Created by Leonel Roberto Perea Trejo on 9/5/14.
//  Copyright (c) 2014 CrowdInt. All rights reserved.
//

#import "ProductObject.h"

@implementation ProductObject

@synthesize description, display_price, product_id, masterObject, categoryObject, name, price, slug, total_on_hand, quantity, delivery_type, delivery_date, showDays, date_available;


//create coder and decoder to be able to save on standar user defaults.
- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if(self != nil)
    {
        self.description = [coder decodeObjectForKey:@"description"];
        self.display_price = [coder decodeObjectForKey:@"display_price"];
        self.product_id = [coder decodeIntForKey:@"product_id"];
        self.masterObject = [coder decodeObjectForKey:@"masterObject"];
        self.name = [coder decodeObjectForKey:@"name"];
        self.price = [coder decodeObjectForKey:@"price"];
        self.slug = [coder decodeObjectForKey:@"slug"];
        self.delivery_date = [coder decodeObjectForKey:@"delivery_date"];
        self.total_on_hand = [coder decodeIntForKey:@"total_on_hand"];
        self.quantity = [coder decodeIntForKey:@"quantity"];
        self.showDays = [coder decodeIntForKey:@"showDays"];
        self.delivery_type = [coder decodeIntForKey:@"delivery_type"];
        self.date_available = [coder decodeFloatForKey:@"date_available"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:description forKey:@"description"];
    [coder encodeObject:display_price forKey:@"display_price"];
    [coder encodeInteger:product_id forKey:@"product_id"];
    [coder encodeObject:masterObject forKey:@"masterObject"];
    [coder encodeObject:name forKey:@"name"];
    [coder encodeObject:price forKey:@"price"];
    [coder encodeObject:slug forKey:@"slug"];
    [coder encodeObject:delivery_date forKey:@"delivery_date"];
    [coder encodeInteger:total_on_hand forKey:@"total_on_hand"];
    [coder encodeInteger:quantity forKey:@"quantity"];
    [coder encodeInteger:showDays forKey:@"showDays"];
    [coder encodeInteger:delivery_type forKey:@"delivery_type"];
    [coder encodeFloat:date_available forKey:@"date_available"];
}


-(ProductObject*)assignProductObject:(NSDictionary*)dictProduct{
    ProductObject *newProductObject = [ProductObject new];
    masterObject = [MasterObject new];
    [newProductObject setDescription:([dictProduct objectForKey:@"description"]!= [NSNull null])? [dictProduct objectForKey:@"description"]:@""];
    [newProductObject setDisplay_price:([dictProduct objectForKey:@"display_price"]!= [NSNull null])? [dictProduct objectForKey:@"description"]:@""];
    [newProductObject setProduct_id:([dictProduct objectForKey:@"id"]!= [NSNull null])? [[dictProduct objectForKey:@"id"] intValue]:0];
    NSDictionary * dictMaster = [dictProduct objectForKey:@"master"];
    [masterObject setDisplay_price:([dictMaster objectForKey:@"display_price"]!= [NSNull null])? [dictProduct objectForKey:@"display_price"]:@""];
    [masterObject setDescription:([dictMaster objectForKey:@"description"] != [NSNull null])? [dictMaster objectForKey:@"description"]:@"No description"];
    [masterObject setCost_price:([dictMaster objectForKey:@"cost_price"]!= [NSNull null])? [dictMaster objectForKey:@"cost_price"]:@""];
    [masterObject setSku:([dictMaster objectForKey:@"sku"]!= [NSNull null])? [dictMaster objectForKey:@"sku"]:@""];
    [masterObject setMasterObject_id:([dictMaster objectForKey:@"id"]!= [NSNull null])? [[dictMaster objectForKey:@"id"] intValue]:0];
    ImageObject *imageObject = [ImageObject new];
    NSMutableArray *arrImages = [dictMaster objectForKey:@"images"];
    NSMutableDictionary * dictImages = [arrImages objectAtIndex:0];
    [imageObject setAttachment_file_name:([dictImages objectForKey:@"attachment_file_name"]!= [NSNull null])? [dictImages objectForKey:@"attachment_file_name"]:@""];
    [imageObject setImage_id:[[dictImages objectForKey:@"id"] intValue]];
    [imageObject setLarge_url:([dictImages objectForKey:@"large_url"]!= [NSNull null])? [dictImages objectForKey:@"large_url"]:@""];
    [imageObject setMini_url:([dictImages objectForKey:@"mini_url"]!= [NSNull null])? [dictImages objectForKey:@"mini_url"]:@""];
    [imageObject setProduct_url:([dictImages objectForKey:@"product_url"]!= [NSNull null])? [dictImages objectForKey:@"product_url"]:@""];
    [imageObject setSmall_url:([dictImages objectForKey:@"small_url"]!= [NSNull null])? [dictImages objectForKey:@"small_url"]:@""];
    [masterObject setImageObject:imageObject];
    [masterObject setIn_stock:([dictMaster objectForKey:@"in_stock"]!= [NSNull null])? [[dictMaster objectForKey:@"in_stock"] intValue]:0];
    [masterObject setName:([dictMaster objectForKey:@"name"]!= [NSNull null])? [dictMaster objectForKey:@"name"]:@""];
    [masterObject setPrice:([dictMaster objectForKey:@"price"]!= [NSNull null])? [dictMaster objectForKey:@"price"]:@""];
    [masterObject setSku:([dictMaster objectForKey:@"sku"]!= [NSNull null])? [dictMaster objectForKey:@"sku"]:@""];
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
    [newProductObject setPrice:([dictProduct objectForKey:@"price"] != [NSNull null])?[dictProduct objectForKey:@"price"]:@"N/A"];
    [newProductObject setSlug:([dictProduct objectForKey:@"slug"]!= [NSNull null])? [dictProduct objectForKey:@"slug"]:@""];
    [newProductObject setTotal_on_hand:([dictProduct objectForKey:@"total_on_hand"]!= [NSNull null])? [[dictProduct objectForKey:@"total_on_hand"] intValue]:0];
    NSString * strGivenDate = [[dictProduct objectForKey:@"available_on"] substringToIndex:10];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *dateFromString = [[NSDate alloc] init];
    dateFromString = [dateFormatter dateFromString:strGivenDate];
    float dateFloat = [dateFromString timeIntervalSince1970];
    [newProductObject setDate_available:dateFloat];
    return newProductObject;
}

-(ProductObject*)assignProductObjectDB:(NSDictionary*)dictProduct{
    ProductObject *newProductObject = [[ProductObject alloc]init];
    masterObject = [[MasterObject alloc] init];
    [newProductObject setDescription:([dictProduct objectForKey:@"description"]!= [NSNull null])? [dictProduct objectForKey:@"description"]:@""];
    [newProductObject setDisplay_price:([dictProduct objectForKey:@"display_price"]!= [NSNull null])? [dictProduct objectForKey:@"description"]:@""];
    [newProductObject setProduct_id:([dictProduct objectForKey:@"product_id"]!= [NSNull null])? [[dictProduct objectForKey:@"product_id"] intValue]:0];
    [masterObject setCost_price:([dictProduct objectForKey:@"cost_price"]!= [NSNull null])? [dictProduct objectForKey:@"cost_price"]:@""];
    [masterObject setDescription:([dictProduct objectForKey:@"description"] != [NSNull null])? [dictProduct objectForKey:@"description"]:@"No description"];
    [masterObject setDisplay_price:([dictProduct objectForKey:@"display_price"]!= [NSNull null])? [dictProduct objectForKey:@"display_price"]:@""];
    [masterObject setSku:([dictProduct objectForKey:@"sku"]!= [NSNull null])? [dictProduct objectForKey:@"sku"]:@""];
    [masterObject setMasterObject_id:([dictProduct objectForKey:@"masterObject_id"]!= [NSNull null])? [[dictProduct objectForKey:@"masterObject_id"] intValue]:0];
    ImageObject *imageObject = [[ImageObject alloc] init];
    [imageObject setAttachment_file_name:([dictProduct objectForKey:@"attachment_file_name"]!= [NSNull null])? [dictProduct objectForKey:@"attachment_file_name"]:@""];
    [imageObject setImage_id:[[dictProduct objectForKey:@"image_id"] intValue]];
    [imageObject setLarge_url:([dictProduct objectForKey:@"large_url"]!= [NSNull null])? [dictProduct objectForKey:@"large_url"]:@""];
    [imageObject setMini_url:([dictProduct objectForKey:@"mini_url"]!= [NSNull null])? [dictProduct objectForKey:@"mini_url"]:@""];
    [imageObject setProduct_url:([dictProduct objectForKey:@"product_url"]!= [NSNull null])? [dictProduct objectForKey:@"product_url"]:@""];
    [imageObject setSmall_url:([dictProduct objectForKey:@"small_url"]!= [NSNull null])? [dictProduct objectForKey:@"small_url"]:@""];
    [masterObject setImageObject:imageObject];
    [masterObject setIn_stock:([dictProduct objectForKey:@"in_stock"]!= [NSNull null])? [[dictProduct objectForKey:@"in_stock"] intValue]:0];
    [masterObject setName:([dictProduct objectForKey:@"name"]!= [NSNull null])? [dictProduct objectForKey:@"name"]:@""];
    [masterObject setPrice:([dictProduct objectForKey:@"price"]!= [NSNull null])? [dictProduct objectForKey:@"price"]:@""];
    [newProductObject setMasterObject:masterObject];
    CategoryObject * newCategoryObject = [[CategoryObject alloc] init];
    [newCategoryObject setCategory_id:([dictProduct objectForKey:@"category_id"]!= [NSNull null])? [[dictProduct objectForKey:@"category_id"] intValue]:0];
    [newCategoryObject setCategory_name:([dictProduct objectForKey:@"category_name"] != [NSNull null])?[dictProduct objectForKey:@"category_name"]:@"N/A"];
    [newProductObject setCategoryObject:newCategoryObject];
    [newProductObject setName:([dictProduct objectForKey:@"name"] != [NSNull null])?[dictProduct objectForKey:@"name"]:@"N/A"];
    [newProductObject setPrice:([dictProduct objectForKey:@"price"] != [NSNull null])?[dictProduct objectForKey:@"price"]:@"N/A"];
    [newProductObject setSlug:([dictProduct objectForKey:@"slug"]!= [NSNull null])? [dictProduct objectForKey:@"slug"]:@""];
    [newProductObject setTotal_on_hand:([dictProduct objectForKey:@"total_on_hand"]!= [NSNull null])? [[dictProduct objectForKey:@"total_on_hand"] intValue]:0];
    [newProductObject setShowDays:([dictProduct objectForKey:@"showDays"]!= [NSNull null])? [[dictProduct objectForKey:@"showDays"] intValue]:0];
    [newProductObject setDate_available:([[dictProduct objectForKey:@"date_available"] floatValue] != 0.0f)?[[dictProduct objectForKey:@"date_available"] floatValue]:0.0f];
    [newProductObject setDelivery_type:0];
    [newProductObject setDelivery_date:@"01-01-2000 00:00"];
    return newProductObject;
}

@end
