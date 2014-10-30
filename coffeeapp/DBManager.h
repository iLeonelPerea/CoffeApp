//
//  DBManager.h
//  testTableView
//
//  Created by Leonel Roberto Perea Trejo on 9/1/14.
//  Copyright (c) 2014 Leonel Roberto Perea Trejo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProductObject.h"
#import <sqlite3.h>

@interface DBManager : NSObject

+(BOOL)checkOrCreateDataBase;
+(void)insertProduct:(ProductObject *)product;
+(void)insertProductCategory:(ProductObject *)product;
+(NSMutableArray *)getCategories;
+(NSMutableArray*)getProducts;
+(NSMutableArray *)getProductsCategory:(CategoryObject *)category;
+(NSString*)getDBPath;
+(void)deleteProducts;
+(void)insertOrdersLog:(NSDictionary*)dictDataOrder;
+(NSArray*)getOrdersHistory:(BOOL)withPastOrders;
+(NSArray*)getOrderHistorySummary:(BOOL)withPastOrders;

@end
