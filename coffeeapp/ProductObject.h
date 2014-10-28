//
//  ProductObject.h
//  GastronautBase
//
//  Created by Leonel Roberto Perea Trejo on 9/5/14.
//  Copyright (c) 2014 CrowdInt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MasterObject.h"
#import "ImageObject.h"
#import "CategoryObject.h"

@interface ProductObject : NSObject

@property (nonatomic, strong) NSString * description;
@property (nonatomic, strong) NSString * display_price;
@property (nonatomic, assign) int product_id;
@property (nonatomic, strong) MasterObject * masterObject;
@property (nonatomic, strong) CategoryObject * categoryObject;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * price;
@property (nonatomic, strong) NSString * slug;
@property (nonatomic, assign) int total_on_hand;
@property (nonatomic, assign) int quantity;
@property (nonatomic, assign) int showDays;
@property (nonatomic, assign) int delivery_type;
@property (nonatomic, strong) NSString * delivery_date;
@property (nonatomic, assign) float date_available;

-(ProductObject*)assignProductObject:(NSMutableDictionary*)dictProduct;
-(ProductObject*)assignProductObjectDB:(NSDictionary*)dictProduct;

@end
