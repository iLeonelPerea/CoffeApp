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
+(NSString*)getDBPath;
+(NSMutableArray*)getProducts;
+(void)deleteProducts;

@end
