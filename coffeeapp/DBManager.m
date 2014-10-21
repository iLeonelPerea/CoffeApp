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
    if([filemgr fileExistsAtPath:[DBManager getDBPath]] == NO){
        const char *dbpath = [[DBManager getDBPath] UTF8String];
        if (sqlite3_open(dbpath, &inventoryDB) == SQLITE_OK) {
            char *errMsg;
            const char *sql_stmt = "CREATE TABLE IF NOT EXISTS SHOPPINGCART (ID INTEGER PRIMARY KEY AUTOINCREMENT, PRODUCT_DESCRIPTION TEXT, PRODUCT_DISPLAY_PRICE TEXT, PRODUCT_PRODUCT_ID INTEGER, PRODUCT_MASTER_COST_PRICE TEXT, PRODUCT_MASTER_DESCRIPTION TEXT, PRODUCT_MASTER_DISPLAY_PRICE TEXT, PRODUCT_MASTER_MASTEROBJECT_ID INTEGER, PRODUCT_MASTER_IN_STOCK INTEGER, PRODUCT_MASTER_NAME TEXT, PRODUCT_MASTER_PRICE TEXT, PRODUCT_MASTER_SKU TEXT, PRODUCT_MASTER_IMAGE_ATTACHMENT_FILE_NAME TEXT, PRODUCT_MASTER_IMAGE_IMAGE_ID INTEGER, PRODUCT_MASTER_IMAGE_LARGE_URL TEXT, PRODUCT_MASTER_IMAGE_MINI_URL TEXT, PRODUCT_MASTER_IMAGE_PRODUCT_URL TEXT, PRODUCT_MASTER_IMAGE_SMALL_URL TEXT, PRODUCT_NAME TEXT, PRODUCT_PRICE TEXT, PRODUCT_SLUG TEXT, PRODUCT_TOTAL_ON_HAND INTEGER, PRODUCT_QUANTITY INTEGER); CREATE TABLE IF NOT EXISTS PRODUCTS (ID INTEGER PRIMARY KEY AUTOINCREMENT, PRODUCT_DESCRIPTION TEXT, PRODUCT_DISPLAY_PRICE TEXT, PRODUCT_PRODUCT_ID INTEGER, PRODUCT_MASTER_COST_PRICE TEXT, PRODUCT_MASTER_DESCRIPTION TEXT, PRODUCT_MASTER_DISPLAY_PRICE TEXT, PRODUCT_MASTER_MASTEROBJECT_ID INTEGER, PRODUCT_MASTER_IN_STOCK INTEGER, PRODUCT_MASTER_NAME TEXT, PRODUCT_MASTER_PRICE TEXT, PRODUCT_MASTER_SKU TEXT, PRODUCT_MASTER_IMAGE_ATTACHMENT_FILE_NAME TEXT, PRODUCT_MASTER_IMAGE_IMAGE_ID INTEGER, PRODUCT_MASTER_IMAGE_LARGE_URL TEXT, PRODUCT_MASTER_IMAGE_MINI_URL TEXT, PRODUCT_MASTER_IMAGE_PRODUCT_URL TEXT, PRODUCT_MASTER_IMAGE_SMALL_URL TEXT, PRODUCT_NAME TEXT, PRODUCT_PRICE TEXT, PRODUCT_SLUG TEXT, PRODUCT_TOTAL_ON_HAND INTEGER, PRODUCT_SHOW_DAYS INTEGER, DATE_AVAILABLE INTEGER); CREATE TABLE IF NOT EXISTS ORDER_PRODUCT (ID INTEGER PRIMARY KEY AUTOINCREMENT, ORDER_ID TEXT, PRODUCT_MASTEROBJECT_ID INTEGER, PRODUCT_QUANTITY INTEGER, PRODUCT_DELIVERY_TYPE INTEGER, PRODUCT_DELIVERY_DATE DOUBLE); CREATE TABLE IF NOT EXISTS CREDITCARDMANAGER (ID INTEGER PRIMARY KEY AUTOINCREMENT, CREDIT_CARD_NUMBER TEXT, OWNER_NAME TEXT, MONTH_DUE_DATE INT, YEAR_DUE_DATE INT, CURRENT_CARD INT, CC_TYPE TEXT, CC_KIND TEXT);CREATE TABLE IF NOT EXISTS COUNTRY(ID INTEGER PRIMARY KEY AUTOINCREMENT, COUNTRY_ID INT, ISO_NAME TEXT, ISO TEXT, ISO3 TEXT, NAME TEXT, NUM_CODE INT); CREATE TABLE IF NOT EXISTS STATE(ID INTEGER PRIMARY KEY AUTOINCREMENT, ABBR TEXT, COUNTRY_ID INT, STATE_ID INT, NAME TEXT); CREATE TABLE IF NOT EXISTS ORDERSLOG(ID INTEGER PRIMARY KEY AUTOINCREMENT, ORDER_ID TEXT, TOTAL_AMOUNT TEXT, STATE TEXT, MESSAGE TEXT); CREATE TABLE IF NOT EXISTS USERADDRESS(ID INTEGER PRIMARY KEY AUTOINCREMENT, ID_USER INTEGER, ADDRESS_FIRSTNAME TEXT, ADDRESS_LASTNAME TEXT, ADDRESS_ADDRESS1 TEXT, ADDRESS_CITY TEXT, ADDRESS_PHONE TEXT, ADDRESS_ZIPCODE TEXT, ADDRESS_STATE_ID TEXT, ADDRESS_COUNTRY_ID TEXT, BILLING_ADDRESS_FIRSTNAME TEXT, BILLING_ADDRESS_LASTNAME TEXT, BILLING_ADDRESS_ADDRESS1 TEXT, BILLING_ADDRESS_CITY TEXT, BILLING_ADDRESS_PHONE TEXT, BILLING_ADDRESS_ZIPCODE TEXT, BILLING_ADDRESS_STATE_ID TEXT, BILLING_ADDRESS_COUNTRY_ID TEXT);";
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
    databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:@"GastronautDB.sqlite3"]];
    
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
        NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO PRODUCTS (PRODUCT_DESCRIPTION, PRODUCT_DISPLAY_PRICE, PRODUCT_PRODUCT_ID, PRODUCT_MASTER_COST_PRICE, PRODUCT_MASTER_DESCRIPTION, PRODUCT_MASTER_DISPLAY_PRICE, PRODUCT_MASTER_MASTEROBJECT_ID, PRODUCT_MASTER_IN_STOCK, PRODUCT_MASTER_NAME, PRODUCT_MASTER_PRICE, PRODUCT_MASTER_SKU, PRODUCT_MASTER_IMAGE_ATTACHMENT_FILE_NAME, PRODUCT_MASTER_IMAGE_IMAGE_ID, PRODUCT_MASTER_IMAGE_LARGE_URL, PRODUCT_MASTER_IMAGE_MINI_URL, PRODUCT_MASTER_IMAGE_PRODUCT_URL, PRODUCT_MASTER_IMAGE_SMALL_URL, PRODUCT_NAME, PRODUCT_PRICE, PRODUCT_SLUG, PRODUCT_TOTAL_ON_HAND, PRODUCT_SHOW_DAYS, DATE_AVAILABLE) VALUES (\"%@\", \"%@\", \"%d\", \"%@\", \"%@\", \"%@\", \"%d\", \"%d\", \"%@\", \"%@\", \"%@\", \"%@\", \"%d\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%d\",\"%d\",\"%2f\")", product.description, product.display_price, product.product_id, product.masterObject.cost_price, product.masterObject.description, product.masterObject.display_price, product.masterObject.masterObject_id, product.masterObject.in_stock, product.masterObject.name, product.masterObject.price, product.masterObject.sku, product.masterObject.imageObject.attachment_file_name, product.masterObject.imageObject.image_id, product.masterObject.imageObject.large_url, product.masterObject.imageObject.mini_url, product.masterObject.imageObject.product_url, product.masterObject.imageObject.small_url, product.name, product.price, product.slug, product.total_on_hand, product.showDays, product.date_available];
        const char *insert_stmt = [insertSQL UTF8String];
        
        sqlite3_prepare_v2(inventoryDB, insert_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) != SQLITE_DONE) {
            NSLog(@"fiel error... %s - %d", sqlite3_errmsg(inventoryDB),product.product_id);
        }
    }
    [DBManager finalizeStatements:statement withDB:inventoryDB];
}

+(NSMutableArray *)getProducts
{
    sqlite3 * inventoryDB;
    sqlite3_stmt * statement;
    const char * dbpath = [[DBManager getDBPath] UTF8String];
    NSMutableDictionary * dictToReturn;
    NSMutableArray * arrToReturn = [NSMutableArray new];
    NSString * selectFoodSQL = [NSString stringWithFormat: @"SELECT * FROM PRODUCTS"];
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
                [dictToReturn setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 18)] forKey:@"name"];
                [dictToReturn setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 19)] forKey:@"price"];
                [dictToReturn setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 20)] forKey:@"slug"];
                [dictToReturn setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 21)] forKey:@"total_on_hand"];
                [dictToReturn setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 22)] forKey:@"showDays"];
                [dictToReturn setObject:[NSString stringWithFormat:@"%.2f", sqlite3_column_double(statement, 23)] forKey:@"date_available"];
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

@end
