//
//  MasterObject.h
//  GastronautBase
//
//  Created by Leonel Roberto Perea Trejo on 9/5/14.
//  Copyright (c) 2014 CrowdInt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageObject.h"

@interface MasterObject : NSObject

@property (nonatomic, strong) NSString * cost_price;
@property (nonatomic, strong) NSString * description;
@property (nonatomic, strong) NSString * display_price;
@property (nonatomic, assign) int masterObject_id;
@property (nonatomic, assign) int in_stock;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * price;
@property (nonatomic, strong) NSString * sku;
@property (nonatomic, strong) ImageObject * imageObject;

@end
