//
//  DBManager.m
//  testTableView
//
//  Created by Leonel Roberto Perea Trejo on 9/1/14.
//  Copyright (c) 2014 Leonel Roberto Perea Trejo. All rights reserved.
//

#import "DBManager.h"

@implementation DBManager

#pragma mark -- DB base methods
+(BOOL)checkOrCreateDataBase{
    BOOL isDbOk;
    sqlite3 *inventoryDB;
    NSFileManager *filemgr = [NSFileManager defaultManager];
    //const char *dbpath = [[DBManager getDBPath] UTF8String];
    NSLog(@"%@",[DBManager getDBPath]);
    if([filemgr fileExistsAtPath:[DBManager getDBPath]] == NO){
        const char *dbpath = [[DBManager getDBPath] UTF8String];
        if (sqlite3_open(dbpath, &inventoryDB) == SQLITE_OK) {
            char *errMsg;
            const char *sql_stmt = "CREATE TABLE IF NOT EXISTS SHOPPINGCART (ID INTEGER PRIMARY KEY AUTOINCREMENT, PRODUCT_DESCRIPTION TEXT, PRODUCT_DISPLAY_PRICE TEXT, PRODUCT_PRODUCT_ID INTEGER, PRODUCT_MASTER_COST_PRICE TEXT, PRODUCT_MASTER_DESCRIPTION TEXT, PRODUCT_MASTER_DISPLAY_PRICE TEXT, PRODUCT_MASTER_MASTEROBJECT_ID INTEGER, PRODUCT_MASTER_IN_STOCK INTEGER, PRODUCT_MASTER_NAME TEXT, PRODUCT_MASTER_PRICE TEXT, PRODUCT_MASTER_SKU TEXT, PRODUCT_MASTER_IMAGE_ATTACHMENT_FILE_NAME TEXT, PRODUCT_MASTER_IMAGE_IMAGE_ID INTEGER, PRODUCT_MASTER_IMAGE_LARGE_URL TEXT, PRODUCT_MASTER_IMAGE_MINI_URL TEXT, PRODUCT_MASTER_IMAGE_PRODUCT_URL TEXT, PRODUCT_MASTER_IMAGE_SMALL_URL TEXT, PRODUCT_NAME TEXT, PRODUCT_PRICE TEXT, PRODUCT_SLUG TEXT, PRODUCT_TOTAL_ON_HAND INTEGER, PRODUCT_QUANTITY INTEGER); CREATE TABLE IF NOT EXISTS PRODUCTS (ID INTEGER PRIMARY KEY AUTOINCREMENT, PRODUCT_DESCRIPTION TEXT, PRODUCT_DISPLAY_PRICE TEXT, PRODUCT_PRODUCT_ID INTEGER, PRODUCT_MASTER_COST_PRICE TEXT, PRODUCT_MASTER_DESCRIPTION TEXT, PRODUCT_MASTER_DISPLAY_PRICE TEXT, PRODUCT_MASTER_MASTEROBJECT_ID INTEGER, PRODUCT_MASTER_IN_STOCK INTEGER, PRODUCT_MASTER_NAME TEXT, PRODUCT_MASTER_PRICE TEXT, PRODUCT_MASTER_SKU TEXT, PRODUCT_MASTER_IMAGE_ATTACHMENT_FILE_NAME TEXT, PRODUCT_MASTER_IMAGE_IMAGE_ID INTEGER, PRODUCT_MASTER_IMAGE_LARGE_URL TEXT, PRODUCT_MASTER_IMAGE_MINI_URL TEXT, PRODUCT_MASTER_IMAGE_PRODUCT_URL TEXT, PRODUCT_MASTER_IMAGE_SMALL_URL TEXT, PRODUCT_CATEGORY_ID INTEGER, PRODUCT_NAME TEXT, PRODUCT_PRICE TEXT, PRODUCT_SLUG TEXT, PRODUCT_TOTAL_ON_HAND INTEGER, PRODUCT_SHOW_DAYS INTEGER, DATE_AVAILABLE INTEGER);  CREATE TABLE IF NOT EXISTS PRODUCT_CATEGORIES (ID INTEGER, CATEGORY_NAME TEXT, INTERNAL_ID INTEGER PRIMARY KEY AUTOINCREMENT); CREATE TABLE IF NOT EXISTS ORDERSLOG(ID INTEGER PRIMARY KEY AUTOINCREMENT, ORDER_ID TEXT, ORDER_STATUS TEXT, ORDER_DATE INTEGER, PRODUCT_ID INTEGER, PRODUCT_NAME TEXT, PRODUCT_QUANTITY_ORDERED INTEGER); CREATE TABLE IF NOT EXISTS USERADDRESS(ID INTEGER PRIMARY KEY AUTOINCREMENT, ID_USER INTEGER, ADDRESS_FIRSTNAME TEXT, ADDRESS_LASTNAME TEXT, ADDRESS_ADDRESS1 TEXT, ADDRESS_CITY TEXT, ADDRESS_PHONE TEXT, ADDRESS_ZIPCODE TEXT, ADDRESS_STATE_ID TEXT, ADDRESS_COUNTRY_ID TEXT, BILLING_ADDRESS_FIRSTNAME TEXT, BILLING_ADDRESS_LASTNAME TEXT, BILLING_ADDRESS_ADDRESS1 TEXT, BILLING_ADDRESS_CITY TEXT, BILLING_ADDRESS_PHONE TEXT, BILLING_ADDRESS_ZIPCODE TEXT, BILLING_ADDRESS_STATE_ID TEXT, BILLING_ADDRESS_COUNTRY_ID TEXT);";
            if (sqlite3_exec(inventoryDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK){
                isDbOk = NO;
                NSLog(@"table fail...");
            }else{
                isDbOk = YES;
            }
            [DBManager finalizeStatements:nil withDB:inventoryDB];
        }else{
            NSLog(@"db fail...");
            isDbOk = NO;
        }
    }else{
        isDbOk = YES; // DB already exists
    }
    return isDbOk;
}

+(NSString*)getDBPath
{
    NSString *docsDir;
    NSArray *dirPaths;
    NSString *databasePath;
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:@"CoffeDB.sqlite3"]];
    NSLog(@"docsDir: %@",docsDir);
    return databasePath;
}

+(void)finalizeStatements:(sqlite3_stmt*)stm withDB:(sqlite3*)DB
{
    sqlite3_finalize(stm);
    sqlite3_close(DB);
}

#pragma mark -- Product methods
+(void)insertProduct:(ProductObject *)product{
    sqlite3 *inventoryDB = nil;
    sqlite3_stmt *statement;
    const char *dbpath = [[DBManager getDBPath] UTF8String];
    if (sqlite3_open(dbpath, &inventoryDB) == SQLITE_OK) {
        NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO PRODUCTS (PRODUCT_DESCRIPTION, PRODUCT_DISPLAY_PRICE, PRODUCT_PRODUCT_ID, PRODUCT_MASTER_COST_PRICE, PRODUCT_MASTER_DESCRIPTION, PRODUCT_MASTER_DISPLAY_PRICE, PRODUCT_MASTER_MASTEROBJECT_ID, PRODUCT_MASTER_IN_STOCK, PRODUCT_MASTER_NAME, PRODUCT_MASTER_PRICE, PRODUCT_MASTER_SKU, PRODUCT_MASTER_IMAGE_ATTACHMENT_FILE_NAME, PRODUCT_MASTER_IMAGE_IMAGE_ID, PRODUCT_MASTER_IMAGE_LARGE_URL, PRODUCT_MASTER_IMAGE_MINI_URL, PRODUCT_MASTER_IMAGE_PRODUCT_URL, PRODUCT_MASTER_IMAGE_SMALL_URL, PRODUCT_CATEGORY_ID, PRODUCT_NAME, PRODUCT_PRICE, PRODUCT_SLUG, PRODUCT_TOTAL_ON_HAND, PRODUCT_SHOW_DAYS, DATE_AVAILABLE) VALUES (\"%@\", \"%@\", \"%d\", \"%@\", \"%@\", \"%@\", \"%d\", \"%d\", \"%@\", \"%@\", \"%@\", \"%@\", \"%d\",\"%@\",\"%@\",\"%@\",\"%@\",\"%d\",\"%@\",\"%@\",\"%@\",\"%d\",\"%d\",\"%2f\")", product.description, product.display_price, product.product_id, product.masterObject.cost_price, product.masterObject.description, product.masterObject.display_price, product.masterObject.masterObject_id, product.masterObject.in_stock, product.masterObject.name, product.masterObject.price, product.masterObject.sku, product.masterObject.imageObject.attachment_file_name, product.masterObject.imageObject.image_id, product.masterObject.imageObject.large_url, product.masterObject.imageObject.mini_url, product.masterObject.imageObject.product_url, product.masterObject.imageObject.small_url, product.categoryObject.category_id, product.name, product.price, product.slug, product.total_on_hand, product.showDays, product.date_available];
        const char *insert_stmt = [insertSQL UTF8String];
        
        sqlite3_prepare_v2(inventoryDB, insert_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) != SQLITE_DONE) {
            NSLog(@"fiel error... %s - %d", sqlite3_errmsg(inventoryDB),product.product_id);
        }
    }
    [DBManager finalizeStatements:statement withDB:inventoryDB];
}

+(NSMutableArray *)getProductsCategory:(CategoryObject *)category{
    sqlite3 * inventoryDB;
    sqlite3_stmt * statement;
    const char * dbpath = [[DBManager getDBPath] UTF8String];
    NSMutableDictionary * dictToReturn;
    NSMutableArray * arrToReturn = [NSMutableArray new];
    NSString * selectFoodSQL = [NSString stringWithFormat: @"SELECT * FROM PRODUCTS WHERE PRODUCT_CATEGORY_ID =%d",category.category_id];
    const char * select_stmt = [selectFoodSQL UTF8String];
    if (sqlite3_open(dbpath, &inventoryDB) == SQLITE_OK) {
        if(sqlite3_prepare_v2(inventoryDB, select_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                ProductObject *productObject = [[ProductObject alloc] init];
                dictToReturn = [NSMutableDictionary new];
                [dictToReturn setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)] forKey:@"description"];
                [dictToReturn setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)] forKey:@"display_price"];
                [dictToReturn setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)] forKey:@"product_id"];
                [dictToReturn setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)] forKey:@"cost_price"];
                [dictToReturn setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 5)] forKey:@"description"];
                [dictToReturn setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 6)] forKey:@"display_price"];
                [dictToReturn setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 7)] forKey:@"masterObject_id"];
                [dictToReturn setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 8)] forKey:@"in_stock"];
                [dictToReturn setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 9)] forKey:@"name"];
                [dictToReturn setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 10)] forKey:@"masterPrice"];
                [dictToReturn setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 11)] forKey:@"sku"];
                [dictToReturn setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 12)] forKey:@"attachment_file_name"];
                [dictToReturn setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 13)] forKey:@"image_id"];
                [dictToReturn setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 14)] forKey:@"large_url"];
                [dictToReturn setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 15)] forKey:@"mini_url"];
                [dictToReturn setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 16)] forKey:@"product_url"];
                [dictToReturn setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 17)] forKey:@"small_url"];
                [dictToReturn setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 18)] forKey:@"category_id"];
                [dictToReturn setObject:category.category_name forKey:@"category_name"];
                [dictToReturn setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 19)] forKey:@"name"];
                [dictToReturn setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 20)] forKey:@"price"];
                [dictToReturn setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 21)] forKey:@"slug"];
                [dictToReturn setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 22)] forKey:@"total_on_hand"];
                [dictToReturn setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 23)] forKey:@"showDays"];
                [dictToReturn setObject:[NSString stringWithFormat:@"%.2f", sqlite3_column_double(statement, 24)] forKey:@"date_available"];
                productObject = [productObject assignProductObjectDB:dictToReturn];
                [arrToReturn addObject:productObject];
            }
            [DBManager finalizeStatements:statement withDB:inventoryDB];
            return arrToReturn;
        }
        else
            return nil;
    }
    else
        return nil;
}

+(NSMutableArray *)getProducts{
    sqlite3 * inventoryDB;
    sqlite3_stmt * statement;
    const char * dbpath = [[DBManager getDBPath] UTF8String];
    NSMutableArray * arrToReturn = [NSMutableArray new];
    NSString * selectFoodSQL = [NSString stringWithFormat: @"SELECT * FROM PRODUCT_CATEGORIES"];
    const char * select_stmt = [selectFoodSQL UTF8String];
    if (sqlite3_open(dbpath, &inventoryDB) == SQLITE_OK) {
        if(sqlite3_prepare_v2(inventoryDB, select_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                CategoryObject *newProductCategoryObject = [[CategoryObject alloc] init];
                [newProductCategoryObject setCategory_id:sqlite3_column_int(statement, 0)];
                [newProductCategoryObject setCategory_name:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)]];
                [arrToReturn addObject:[self getProductsCategory:newProductCategoryObject]];
            }
            [DBManager finalizeStatements:statement withDB:inventoryDB];
            return arrToReturn;
        }
        else
            return nil;
    }
    else
        return nil;
}

+(void)deleteProducts{
    sqlite3 *inventoryDB = nil;
    sqlite3_stmt *statement;
    const char *dbpath = [[DBManager getDBPath] UTF8String];
    if (sqlite3_open(dbpath, &inventoryDB) == SQLITE_OK) {
        NSString *insertSQL = [NSString stringWithFormat:@"DELETE FROM PRODUCTS"];
        const char *insert_stmt = [insertSQL UTF8String];
        
        sqlite3_prepare_v2(inventoryDB, insert_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) != SQLITE_DONE) {
            NSLog(@"fiel error... %s", sqlite3_errmsg(inventoryDB));
        }
    }
    [DBManager finalizeStatements:statement withDB:inventoryDB];
}

#pragma mark -- Prducts Category methods
+(void)insertProductCategory:(ProductObject *)product{
    sqlite3 *inventoryDB = nil;
    sqlite3_stmt *statement;
    const char *dbpath = [[DBManager getDBPath] UTF8String];
    if (sqlite3_open(dbpath, &inventoryDB) == SQLITE_OK) {
        NSString *insertSQL = [NSString stringWithFormat:@"INSERT OR REPLACE INTO PRODUCT_CATEGORIES (ID, CATEGORY_NAME) VALUES (\"%d\", \"%@\")", product.categoryObject.category_id, product.categoryObject.category_name];
        const char *insert_stmt = [insertSQL UTF8String];
        
        sqlite3_prepare_v2(inventoryDB, insert_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) != SQLITE_DONE) {
            NSLog(@"fiel error... %s - %d", sqlite3_errmsg(inventoryDB),product.product_id);
        }
    }
    [DBManager finalizeStatements:statement withDB:inventoryDB];
}

+(void)insertCategory:(NSDictionary *)category
{
    sqlite3 *inventoryDB = nil;
    sqlite3_stmt *statement;
    const char *dbpath = [[DBManager getDBPath] UTF8String];
    if (sqlite3_open(dbpath, &inventoryDB) == SQLITE_OK) {
        NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO PRODUCT_CATEGORIES (ID, CATEGORY_NAME) VALUES (\"%d\", \"%@\")", [[category objectForKey:@"id"] intValue], [category objectForKey:@"name"]];
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(inventoryDB, insert_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) != SQLITE_DONE) {
            NSLog(@"fiel error... %s - %@", sqlite3_errmsg(inventoryDB),[category objectForKey:@"name"]);
        }
    }
    [DBManager finalizeStatements:statement withDB:inventoryDB];
}

+(NSMutableArray *)getCategories{
    sqlite3 * inventoryDB;
    sqlite3_stmt * statement;
    const char * dbpath = [[DBManager getDBPath] UTF8String];
    NSMutableArray * arrToReturn = [NSMutableArray new];
    NSString * selectFoodSQL = [NSString stringWithFormat: @"SELECT * FROM PRODUCT_CATEGORIES"];
    const char * select_stmt = [selectFoodSQL UTF8String];
    if (sqlite3_open(dbpath, &inventoryDB) == SQLITE_OK) {
        if(sqlite3_prepare_v2(inventoryDB, select_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                CategoryObject *newProductCategoryObject = [[CategoryObject alloc] init];
                [newProductCategoryObject setCategory_id:sqlite3_column_int(statement, 0)];
                [newProductCategoryObject setCategory_name:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)]];
                [arrToReturn addObject:newProductCategoryObject];
            }
            [DBManager finalizeStatements:statement withDB:inventoryDB];
            return arrToReturn;
        }
        else
            return nil;
    }
    else
        return nil;
}

#pragma mark -- Orders history methods
+(void)insertOrdersLog:(NSDictionary *)dictDataOrder
{
    sqlite3 * appDB;
    sqlite3_stmt * statement;
    const char * dbPath = [[DBManager getDBPath] UTF8String];
    NSDateFormatter * dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd-MM-yyyy HH:mm"];
    
    if (sqlite3_open(dbPath, &appDB) == SQLITE_OK) {
        NSString * sqlInsert = [NSString stringWithFormat:@"INSERT INTO ORDERSLOG (ORDER_ID, ORDER_STATUS, ORDER_DATE, PRODUCT_ID, PRODUCT_NAME, PRODUCT_QUANTITY_ORDERED) VALUES(\"%@\", \"%@\", \"%f\", \"%d\", \"%@\", \"%d\")", [dictDataOrder objectForKey:@"orderId"],[dictDataOrder objectForKey:@"orderStatus"],(double)[[dateFormat dateFromString:[dictDataOrder objectForKey:@"orderDate"]] timeIntervalSince1970],[[dictDataOrder objectForKey:@"productId"] intValue],[dictDataOrder objectForKey:@"productName"],[[dictDataOrder objectForKey:@"productQuantityOrdered"] intValue]];
        const char * insertSQL = [sqlInsert UTF8String];
        sqlite3_prepare_v2(appDB, insertSQL, -1, &statement, NULL);
        if (sqlite3_step(statement) != SQLITE_DONE) {
            NSLog(@"%s",sqlite3_errmsg(appDB));
        }
    }
    [DBManager finalizeStatements:statement withDB:appDB];
}

+(void)updateStateOrderLog:(NSString*)orderId withState:(NSString*)orderState;
{
    //Update the order state in the orders log table
    sqlite3 * appDB;
    sqlite3_stmt * statement;
    const char * dbPath = [[DBManager getDBPath] UTF8String];
    if (sqlite3_open(dbPath, &appDB) == SQLITE_OK) {
        NSString * sqlUpdate = [NSString stringWithFormat:@"UPDATE ORDERSLOG SET ORDER_STATUS = '%@' WHERE ORDER_ID = '%@' ",orderState, orderId];
        const char * updateSQL = [sqlUpdate UTF8String];
        sqlite3_prepare_v2(appDB, updateSQL, -1, &statement, NULL);
        if (sqlite3_step(statement) != SQLITE_DONE) {
            NSLog(@"%s", sqlite3_errmsg(appDB));
        }
    }
    [DBManager finalizeStatements:statement withDB:appDB];
}

+(NSMutableArray *)getOrdersHistory:(BOOL)withPastOrders
{
    sqlite3 * appDB;
    sqlite3_stmt * statement;
    const char * dbPath = [[DBManager getDBPath] UTF8String];
    NSMutableArray * arrToReturn = [[NSMutableArray alloc] init];
    NSMutableArray * arrTotalOrders = [[NSMutableArray alloc] init];
    NSString * sqlSelect = @"";

    //Get the distincts orders (incoming/past)
    if (sqlite3_open(dbPath, &appDB) ==  SQLITE_OK) {
        NSDateFormatter *dtFormat =[[NSDateFormatter alloc] init];
        [dtFormat setDateFormat:@"EEEE, LLLL d, yyyy, HH:mm"];
        //[dtFormat setDateFormat:@"dd-MM-yyyy HH:mm"];
        
        if (withPastOrders) {
            sqlSelect = [NSString stringWithFormat:@"SELECT DISTINCT ORDER_ID, ORDER_DATE, ORDER_STATUS FROM ORDERSLOG WHERE ORDER_STATUS = \"complete\"  ORDER BY ORDER_DATE DESC"];
            //sqlSelect = [NSString stringWithFormat:@"SELECT DISTINCT ORDER_ID, ORDER_DATE, ORDER_STATUS FROM ORDERSLOG WHERE ORDER_DATE < %f ORDER BY ORDER_DATE DESC", (double)[[NSDate date] timeIntervalSince1970]];
        }else{
            sqlSelect = [NSString stringWithFormat:@"SELECT DISTINCT ORDER_ID, ORDER_DATE, ORDER_STATUS FROM ORDERSLOG WHERE ORDER_STATUS = \"confirm\" OR ORDER_STATUS = \"attending\" ORDER BY ORDER_DATE DESC"];
            //sqlSelect = [NSString stringWithFormat:@"SELECT DISTINCT ORDER_ID, ORDER_DATE, ORDER_STATUS FROM ORDERSLOG WHERE ORDER_DATE >= %f ORDER BY ORDER_DATE DESC", (double)[[NSDate date] timeIntervalSince1970]];
        }
        const char *select_stmt = [sqlSelect UTF8String];
        sqlite3_prepare_v2(appDB, select_stmt, -1, &statement, nil);
        while (sqlite3_step(statement) != SQLITE_DONE) {
            NSMutableDictionary *dictOrderHistory = [[NSMutableDictionary alloc] init];
            [dictOrderHistory setObject:[NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 0)] forKey:@"ORDER_ID"];
            [dictOrderHistory setObject:[dtFormat stringFromDate:[NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(statement, 1)]] forKey:@"ORDER_DATE"];
            [dictOrderHistory setObject:[NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 2)] forKey:@"ORDER_STATUS"];
            [arrTotalOrders addObject:dictOrderHistory];
        }
    }
    [DBManager finalizeStatements:statement withDB:appDB];

    //Get the detail of each order previously selected
    for (NSMutableDictionary * dictDetailOrder in arrTotalOrders) {
        NSMutableArray * arrOrderDetail = [[NSMutableArray alloc] init];
        if (sqlite3_open(dbPath, &appDB) ==  SQLITE_OK) {
            NSDateFormatter *dtFormat =[[NSDateFormatter alloc] init];
            [dtFormat setDateFormat:@"dd-MM-yyyy HH:mm"];
            
            if (withPastOrders) {
                sqlSelect = [NSString stringWithFormat:@"SELECT PRODUCT_ID, PRODUCT_NAME, PRODUCT_QUANTITY_ORDERED FROM ORDERSLOG WHERE ORDER_ID = '%@' ORDER BY ORDER_DATE DESC", [dictDetailOrder objectForKey:@"ORDER_ID"]];
            }else{
                sqlSelect = [NSString stringWithFormat:@"SELECT PRODUCT_ID, PRODUCT_NAME, PRODUCT_QUANTITY_ORDERED FROM ORDERSLOG WHERE ORDER_ID = '%@' ORDER BY ORDER_DATE DESC", [dictDetailOrder objectForKey:@"ORDER_ID"]];
            }
            const char *select_stmt = [sqlSelect UTF8String];
            sqlite3_prepare_v2(appDB, select_stmt, -1, &statement, nil);
            while (sqlite3_step(statement) != SQLITE_DONE) {
                NSMutableDictionary *dictDetail = [[NSMutableDictionary alloc] init];
                [dictDetail setObject:[NSString stringWithFormat:@"%d",sqlite3_column_int(statement, 0)] forKey:@"PRODUCT_ID"];
                [dictDetail setObject:[NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 1)] forKey:@"PRODUCT_NAME"];
                [dictDetail setObject:[NSString stringWithFormat:@"%d",sqlite3_column_int(statement, 2)] forKey:@"PRODUCT_QUANTITY_ORDERED"];
                [arrOrderDetail addObject:dictDetail];
            }
            [dictDetailOrder setObject:arrOrderDetail forKey:@"ORDER_DETAIL"];
            [arrToReturn addObject:dictDetailOrder];
        }
        [DBManager finalizeStatements:statement withDB:appDB];
    }
    return arrToReturn;
}

+(void)deleteOrderLog:(NSString *)orderId
{
    sqlite3 *appDB = nil;
    sqlite3_stmt *statement;
    const char *dbPath = [[DBManager getDBPath] UTF8String];
    NSString *sqlDelete = @"";
    const char *deleteSQL = [sqlDelete UTF8String];

    if (sqlite3_open(dbPath, &appDB) == SQLITE_OK) {
        sqlDelete = [NSString stringWithFormat:@"DELETE FROM ORDERSLOG WHERE ORDER_ID = \"%@\" ",orderId];
        deleteSQL = [sqlDelete UTF8String];
        sqlite3_prepare_v2(appDB, deleteSQL, -1, &statement, nil);
        if (sqlite3_step(statement) != SQLITE_DONE) {
            NSLog(@"Fail error %s", sqlite3_errmsg(appDB));
        }
        [DBManager finalizeStatements:statement withDB:appDB];
    }
}

#pragma mark -- Delete table content
+(void)deleteTableContent:(NSArray*)tables
{
    sqlite3 *appDB = nil;
    sqlite3_stmt *statement;
    const char *dbPath = [[DBManager getDBPath] UTF8String];
    NSString *sqlDelete = @"";
    const char *deleteSQL = [sqlDelete UTF8String];
    for (NSString * strTable in tables) {
        if (sqlite3_open(dbPath, &appDB) == SQLITE_OK) {
            sqlDelete = [NSString stringWithFormat:@"DELETE FROM %@",strTable];
            deleteSQL = [sqlDelete UTF8String];
            sqlite3_prepare_v2(appDB, deleteSQL, -1, &statement, nil);
            if (sqlite3_step(statement) != SQLITE_DONE) {
                NSLog(@"Fail error %s", sqlite3_errmsg(appDB));
            }
            [DBManager finalizeStatements:statement withDB:appDB];
        }
    }
}

#pragma mark -- Update product stock
+(void)updateProductStock:(int)productId withStock:(int)stock;
{
    sqlite3 *appDB = nil;
    sqlite3_stmt *statement;
    const char *dbPath = [[DBManager getDBPath] UTF8String];
    NSString *sqlUpdate = @"";
    const char *updateSQL = [sqlUpdate UTF8String];
        if (sqlite3_open(dbPath, &appDB) == SQLITE_OK) {
            sqlUpdate = [NSString stringWithFormat:@"UPDATE PRODUCTS SET PRODUCT_TOTAL_ON_HAND = %d WHERE PRODUCT_MASTER_MASTEROBJECT_ID = %d",stock,productId];
            updateSQL = [sqlUpdate UTF8String];
            sqlite3_prepare_v2(appDB, updateSQL, -1, &statement, nil);
            if (sqlite3_step(statement) != SQLITE_DONE) {
                NSLog(@"Fail error %s", sqlite3_errmsg(appDB));
            }
            [DBManager finalizeStatements:statement withDB:appDB];
        }
}


@end
