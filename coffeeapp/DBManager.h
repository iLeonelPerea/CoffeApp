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
+(void)insertCategory:(NSDictionary *)category;
+(NSMutableArray *)getCategories;
+(NSMutableArray*)getProducts;
+(NSMutableArray *)getProductsCategory:(CategoryObject *)category;
+(NSString*)getDBPath;
+(void)deleteProducts;
+(void)insertOrdersLog:(NSDictionary*)dictDataOrder;
+(NSMutableArray*)getOrdersHistory:(BOOL)withPastOrders;
+(void)updateStateOrderLog:(NSString*)orderId withState:(NSString*)orderState;
+(void)deleteTableContent:(NSArray*)tables;
+(void)updateProductStock:(int)productId withStock:(int)stock;

@end
