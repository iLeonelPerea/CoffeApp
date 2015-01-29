//
//  DBManager.m
//  testTableView
//
//

#import "DBManager.h"

@implementation DBManager

#pragma mark -- DB base methods
+(BOOL)checkOrCreateDataBase{
    /// Boolean flag.
    BOOL isDbOk;
    sqlite3 *inventoryDB;
    /// Create a file manager object.
    NSFileManager *filemgr = [NSFileManager defaultManager];
    //NSLog(@"%@",[DBManager getDBPath]);
    /// Check for the databse file in the file path.
    if([filemgr fileExistsAtPath:[DBManager getDBPath]] == NO){
        /// Get the DBPath
        const char *dbpath = [[DBManager getDBPath] UTF8String];
        if (sqlite3_open(dbpath, &inventoryDB) == SQLITE_OK) {
            char *errMsg;
            /// Define the entire database structure.
            const char *sql_stmt = " CREATE TABLE IF NOT EXISTS PRODUCTS (ID INTEGER PRIMARY KEY AUTOINCREMENT, PRODUCT_PRODUCT_ID INTEGER, PRODUCT_MASTER_MASTEROBJECT_ID INTEGER, PRODUCT_MASTER_IN_STOCK INTEGER, PRODUCT_MASTER_IMAGE_ATTACHMENT_FILE_NAME TEXT, PRODUCT_MASTER_IMAGE_IMAGE_ID INTEGER, PRODUCT_MASTER_IMAGE_PRODUCT_URL TEXT, PRODUCT_CATEGORY_ID INTEGER, PRODUCT_NAME TEXT, PRODUCT_TOTAL_ON_HAND INTEGER, DATE_AVAILABLE INTEGER, START_HOUR TEXT, END_HOUR TEXT);  CREATE TABLE IF NOT EXISTS PRODUCT_CATEGORIES (ID INTEGER, CATEGORY_NAME TEXT, INTERNAL_ID INTEGER PRIMARY KEY AUTOINCREMENT); CREATE TABLE IF NOT EXISTS ORDERSLOG(ID INTEGER PRIMARY KEY AUTOINCREMENT, ORDER_ID TEXT, ORDER_STATUS TEXT, ORDER_DATE INTEGER, PRODUCT_ID INTEGER, PRODUCT_NAME TEXT, PRODUCT_QUANTITY_ORDERED INTEGER); ";
            if (sqlite3_exec(inventoryDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK){
                isDbOk = NO;
                //NSLog(@"table fail...");
            }else{
                isDbOk = YES;
            }
            [DBManager finalizeStatements:nil withDB:inventoryDB];
        }else{
            //NSLog(@"db fail...");
            isDbOk = NO;
        }
    }else{
        /// Set the flag isDbOK to inform that the DB already exists.
        isDbOk = YES;
    }
    return isDbOk;
}

+(NSString*)getDBPath
{
    /// Define the required variables.
    NSString *docsDir;
    NSArray *dirPaths;
    NSString *databasePath;
    /// Define the path for the directories on the device.
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    /// Get the first directory in the dirPaths array.
    docsDir = [dirPaths objectAtIndex:0];
    /// Define the database path.
    databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:@"CoffeDB.sqlite3"]];
    return databasePath;
}

+(void)finalizeStatements:(sqlite3_stmt*)stm withDB:(sqlite3*)DB
{
    /// Finalize a statement object.
    sqlite3_finalize(stm);
    sqlite3_close(DB);
}

#pragma mark -- Product methods
+(void)insertProduct:(ProductObject *)product{
    sqlite3 *inventoryDB = nil;
    sqlite3_stmt *statement;
    const char *dbpath = [[DBManager getDBPath] UTF8String];
    if (sqlite3_open(dbpath, &inventoryDB) == SQLITE_OK) {
        /// Set the Insert statement.
        NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO PRODUCTS (PRODUCT_PRODUCT_ID,PRODUCT_MASTER_MASTEROBJECT_ID, PRODUCT_MASTER_IN_STOCK, PRODUCT_MASTER_IMAGE_ATTACHMENT_FILE_NAME, PRODUCT_MASTER_IMAGE_IMAGE_ID, PRODUCT_MASTER_IMAGE_PRODUCT_URL, PRODUCT_CATEGORY_ID, PRODUCT_NAME, PRODUCT_TOTAL_ON_HAND, DATE_AVAILABLE, START_HOUR, END_HOUR) VALUES (\"%d\", \"%d\", \"%d\", \"%@\", \"%d\",\"%@\",\"%d\",\"%@\",\"%d\",\"%2f\",\"%@\",\"%@\")", product.product_id, product.masterObject.masterObject_id, product.masterObject.in_stock, product.masterObject.imageObject.attachment_file_name, product.masterObject.imageObject.image_id, product.masterObject.imageObject.product_url, product.categoryObject.category_id, product.name, product.total_on_hand, product.date_available, product.startHour, product.endHour];
        const char *insert_stmt = [insertSQL UTF8String];
        /// Execute the insert statement.
        sqlite3_prepare_v2(inventoryDB, insert_stmt, -1, &statement, NULL);
        /// Check for errors in the insert.
        if (sqlite3_step(statement) != SQLITE_DONE) {
            //NSLog(@"fiel error... %s - %d", sqlite3_errmsg(inventoryDB),product.product_id);
        }
    }
    /// Finalize the statement.
    [DBManager finalizeStatements:statement withDB:inventoryDB];
}

+(NSMutableArray *)getProductsCategory:(CategoryObject *)category{
    sqlite3 * inventoryDB;
    sqlite3_stmt * statement;
    const char * dbpath = [[DBManager getDBPath] UTF8String];
    /// Create a dictionary to store all the data from the query results.
    NSMutableDictionary * dictToReturn;
    /// Create an array to store the dictionary of the query results.
    NSMutableArray * arrToReturn = [NSMutableArray new];
    /// Set the Select statement.
    NSString * selectFoodSQL = [NSString stringWithFormat: @"SELECT * FROM PRODUCTS WHERE PRODUCT_CATEGORY_ID =%d",category.category_id];
    const char * select_stmt = [selectFoodSQL UTF8String];
    if (sqlite3_open(dbpath, &inventoryDB) == SQLITE_OK) {
        if(sqlite3_prepare_v2(inventoryDB, select_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            /// Loop to extract all the data from the query result.
            while (sqlite3_step(statement) == SQLITE_ROW) {
                ProductObject *productObject = [[ProductObject alloc] init];
                dictToReturn = [NSMutableDictionary new];
                [dictToReturn setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)] forKey:@"product_id"];
                [dictToReturn setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)] forKey:@"masterObject_id"];
                [dictToReturn setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)] forKey:@"in_stock"];
                [dictToReturn setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)] forKey:@"attachment_file_name"];
                [dictToReturn setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 5)] forKey:@"image_id"];
                [dictToReturn setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 6)] forKey:@"product_url"];
                [dictToReturn setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 7)] forKey:@"category_id"];
                [dictToReturn setObject:category.category_name forKey:@"category_name"];
                [dictToReturn setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 8)] forKey:@"name"];
                [dictToReturn setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 9)] forKey:@"total_on_hand"];
                [dictToReturn setObject:[NSString stringWithFormat:@"%.2f", sqlite3_column_double(statement, 10)] forKey:@"date_available"];
                [dictToReturn setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 11)] forKey:@"available_from"];
                [dictToReturn setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 11)] forKey:@"available_to"];
                productObject = [productObject assignProductObjectDB:dictToReturn];
                [arrToReturn addObject:productObject];
            }
            /// Finalize the statement.
            [DBManager finalizeStatements:statement withDB:inventoryDB];
            /// Return an array with all the prodcust from a category.
            return arrToReturn;
        }
        else
            return nil;
    }
    else
        return nil;
}

+(NSMutableArray *)getProducts{
    /// Create the DB variables.
    sqlite3 * inventoryDB;
    sqlite3_stmt * statement;
    /// Get the path of the DB.
    const char * dbpath = [[DBManager getDBPath] UTF8String];
    /// Create the array to return.
    NSMutableArray * arrToReturn = [NSMutableArray new];
    /// Set the Select statement.
    NSString * selectFoodSQL = [NSString stringWithFormat: @"SELECT * FROM PRODUCT_CATEGORIES"];
    const char * select_stmt = [selectFoodSQL UTF8String];
    /// Check for the status of DB.
    if (sqlite3_open(dbpath, &inventoryDB) == SQLITE_OK) {
        /// Execute and check the select statement.
        if(sqlite3_prepare_v2(inventoryDB, select_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            /// Loop to extrat the products from the query result.
            while (sqlite3_step(statement) == SQLITE_ROW) {
                /// Create a category object.
                CategoryObject *newProductCategoryObject = [[CategoryObject alloc] init];
                [newProductCategoryObject setCategory_id:sqlite3_column_int(statement, 0)];
                [newProductCategoryObject setCategory_name:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)]];
                /// Get the products of the category.
                [arrToReturn addObject:[self getProductsCategory:newProductCategoryObject]];
            }
            /// Finalize the statement.
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
    /// Set DB variables.
    sqlite3 *inventoryDB = nil;
    sqlite3_stmt *statement;
    /// Get the path of the DB.
    const char *dbpath = [[DBManager getDBPath] UTF8String];
    if (sqlite3_open(dbpath, &inventoryDB) == SQLITE_OK) {
        /// Set the Delete statement.
        NSString *insertSQL = [NSString stringWithFormat:@"DELETE FROM PRODUCTS"];
        const char *insert_stmt = [insertSQL UTF8String];
        /// Execute the statement.
        sqlite3_prepare_v2(inventoryDB, insert_stmt, -1, &statement, NULL);
        /// Check for errors.
        if (sqlite3_step(statement) != SQLITE_DONE) {
            //NSLog(@"fiel error... %s", sqlite3_errmsg(inventoryDB));
        }
    }
    /// Finalize the statement.
    [DBManager finalizeStatements:statement withDB:inventoryDB];
}

#pragma mark -- Prducts Category methods
+(void)insertProductCategory:(ProductObject *)product{
    /// Set the DB variables.
    sqlite3 *inventoryDB = nil;
    sqlite3_stmt *statement;
    /// Get the path of the DB.
    const char *dbpath = [[DBManager getDBPath] UTF8String];
    if (sqlite3_open(dbpath, &inventoryDB) == SQLITE_OK) {
        /// Set the Insert statement.
        NSString *insertSQL = [NSString stringWithFormat:@"INSERT OR REPLACE INTO PRODUCT_CATEGORIES (ID, CATEGORY_NAME) VALUES (\"%d\", \"%@\")", product.categoryObject.category_id, product.categoryObject.category_name];
        const char *insert_stmt = [insertSQL UTF8String];
        /// Execute the Insert statement.
        sqlite3_prepare_v2(inventoryDB, insert_stmt, -1, &statement, NULL);
        /// Check for errors.
        if (sqlite3_step(statement) != SQLITE_DONE) {
            //NSLog(@"fiel error... %s - %d", sqlite3_errmsg(inventoryDB),product.product_id);
        }
    }
    /// Finalize the statement.
    [DBManager finalizeStatements:statement withDB:inventoryDB];
}

+(void)insertCategory:(NSDictionary *)category
{
    /// Set the DB variables.
    sqlite3 *inventoryDB = nil;
    sqlite3_stmt *statement;
    /// Get the path of the DB.
    const char *dbpath = [[DBManager getDBPath] UTF8String];
    if (sqlite3_open(dbpath, &inventoryDB) == SQLITE_OK) {
        /// Set the Insert statement.
        NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO PRODUCT_CATEGORIES (ID, CATEGORY_NAME) VALUES (\"%d\", \"%@\")", [[category objectForKey:@"id"] intValue], [category objectForKey:@"name"]];
        const char *insert_stmt = [insertSQL UTF8String];
        /// Execute the Insert statement.
        sqlite3_prepare_v2(inventoryDB, insert_stmt, -1, &statement, NULL);
        /// Check for errors.
        if (sqlite3_step(statement) != SQLITE_DONE) {
            //NSLog(@"fiel error... %s - %@", sqlite3_errmsg(inventoryDB),[category objectForKey:@"name"]);
        }
    }
    /// Finalize the statement.
    [DBManager finalizeStatements:statement withDB:inventoryDB];
}

+(NSMutableArray *)getCategories{
    /// Set the DB variables.
    sqlite3 * inventoryDB;
    sqlite3_stmt * statement;
    /// Get the path of the DB.
    const char * dbpath = [[DBManager getDBPath] UTF8String];
    /// Create the array to return.
    NSMutableArray * arrToReturn = [NSMutableArray new];
    /// Set the Select statement.
    NSString * selectFoodSQL = [NSString stringWithFormat: @"SELECT * FROM PRODUCT_CATEGORIES"];
    const char * select_stmt = [selectFoodSQL UTF8String];
    if (sqlite3_open(dbpath, &inventoryDB) == SQLITE_OK) {
        /// Execute and check the Select statement.
        if(sqlite3_prepare_v2(inventoryDB, select_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            /// Loop to extract the data from the query result.
            while (sqlite3_step(statement) == SQLITE_ROW) {
                /// Create an instance of CategoryObject.
                CategoryObject *newProductCategoryObject = [[CategoryObject alloc] init];
                [newProductCategoryObject setCategory_id:sqlite3_column_int(statement, 0)];
                [newProductCategoryObject setCategory_name:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)]];
                [arrToReturn addObject:newProductCategoryObject];
            }
            /// Finalize the statement.
            [DBManager finalizeStatements:statement withDB:inventoryDB];
            /// Return the array with the data.
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
    /// Set the DB variables.
    sqlite3 * appDB;
    sqlite3_stmt * statement;
    /// Get the path of the DB.
    const char * dbPath = [[DBManager getDBPath] UTF8String];
    /// Create and set a date fomatter.
    NSDateFormatter * dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd-MM-yyyy HH:mm"];
    
    if (sqlite3_open(dbPath, &appDB) == SQLITE_OK) {
        /// Set the Insert statement.
        NSString * sqlInsert = [NSString stringWithFormat:@"INSERT INTO ORDERSLOG (ORDER_ID, ORDER_STATUS, ORDER_DATE, PRODUCT_ID, PRODUCT_NAME, PRODUCT_QUANTITY_ORDERED) VALUES(\"%@\", \"%@\", \"%f\", \"%d\", \"%@\", \"%d\")", [dictDataOrder objectForKey:@"orderId"],[dictDataOrder objectForKey:@"orderStatus"],(double)[[dateFormat dateFromString:[dictDataOrder objectForKey:@"orderDate"]] timeIntervalSince1970],[[dictDataOrder objectForKey:@"productId"] intValue],[dictDataOrder objectForKey:@"productName"],[[dictDataOrder objectForKey:@"productQuantityOrdered"] intValue]];
        const char * insertSQL = [sqlInsert UTF8String];
        /// Execute the Insert statement.
        sqlite3_prepare_v2(appDB, insertSQL, -1, &statement, NULL);
        /// Check for errors.
        if (sqlite3_step(statement) != SQLITE_DONE) {
            //NSLog(@"%s",sqlite3_errmsg(appDB));
        }
    }
    /// Finalize the statement.
    [DBManager finalizeStatements:statement withDB:appDB];
}

+(void)updateStateOrderLog:(NSString*)orderId withState:(NSString*)orderState;
{
    /// Set the DB variables.
    sqlite3 * appDB;
    sqlite3_stmt * statement;
    /// Get the path of the DB.
    const char * dbPath = [[DBManager getDBPath] UTF8String];
    if (sqlite3_open(dbPath, &appDB) == SQLITE_OK) {
        /// Set the Update statement.
        NSString * sqlUpdate = [NSString stringWithFormat:@"UPDATE ORDERSLOG SET ORDER_STATUS = '%@' WHERE ORDER_ID = '%@' ",orderState, orderId];
        const char * updateSQL = [sqlUpdate UTF8String];
        /// Execute the Update statement.
        sqlite3_prepare_v2(appDB, updateSQL, -1, &statement, NULL);
        /// Check for errors.
        if (sqlite3_step(statement) != SQLITE_DONE) {
            //NSLog(@"%s", sqlite3_errmsg(appDB));
        }
    }
    /// Finalize the statement.
    [DBManager finalizeStatements:statement withDB:appDB];
}

+(NSMutableArray *)getOrdersHistory:(BOOL)withPastOrders
{
    /// Set the DB variables.
    sqlite3 * appDB;
    sqlite3_stmt * statement;
    /// Get the path of the DB.
    const char * dbPath = [[DBManager getDBPath] UTF8String];
    /// Create the array to return.
    NSMutableArray * arrToReturn = [[NSMutableArray alloc] init];
    /// Create a temporal array to store information about the orders.
    NSMutableArray * arrTotalOrders = [[NSMutableArray alloc] init];
    NSString * sqlSelect = @"";

    /// Get the distincts orders (incoming/past)
    if (sqlite3_open(dbPath, &appDB) ==  SQLITE_OK) {
        /// Create a date formatter.
        NSDateFormatter *dtFormat =[[NSDateFormatter alloc] init];
        [dtFormat setDateFormat:@"EEEE, LLLL d, yyyy, HH:mm"];
        
        /// Check which kind of orders will be selected.
        if (withPastOrders) {
            /// Set the Select statement.
            sqlSelect = [NSString stringWithFormat:@"SELECT DISTINCT ORDER_ID, ORDER_DATE, ORDER_STATUS FROM ORDERSLOG WHERE ORDER_STATUS = \"complete\"  ORDER BY ORDER_DATE DESC"];
        }else{
            /// Set the Select statement.
            sqlSelect = [NSString stringWithFormat:@"SELECT DISTINCT ORDER_ID, ORDER_DATE, ORDER_STATUS FROM ORDERSLOG WHERE ORDER_STATUS = \"confirm\" OR ORDER_STATUS = \"attending\" ORDER BY ORDER_DATE DESC"];
        }
        const char *select_stmt = [sqlSelect UTF8String];
        /// Execute the Select statement
        sqlite3_prepare_v2(appDB, select_stmt, -1, &statement, nil);
        while (sqlite3_step(statement) != SQLITE_DONE) {
            NSMutableDictionary *dictOrderHistory = [[NSMutableDictionary alloc] init];
            [dictOrderHistory setObject:[NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 0)] forKey:@"ORDER_ID"];
            [dictOrderHistory setObject:[dtFormat stringFromDate:[NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(statement, 1)]] forKey:@"ORDER_DATE"];
            [dictOrderHistory setObject:[NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 2)] forKey:@"ORDER_STATUS"];
            [arrTotalOrders addObject:dictOrderHistory];
        }
    }
    /// Finalize the statement
    [DBManager finalizeStatements:statement withDB:appDB];

    /// Get the detail of each order previously selected
    for (NSMutableDictionary * dictDetailOrder in arrTotalOrders) {
        NSMutableArray * arrOrderDetail = [[NSMutableArray alloc] init];
        if (sqlite3_open(dbPath, &appDB) ==  SQLITE_OK) {
            /// Create a date formatter.
            NSDateFormatter *dtFormat =[[NSDateFormatter alloc] init];
            [dtFormat setDateFormat:@"dd-MM-yyyy HH:mm"];
            
            /// Check which kind of orders will be selected.
            if (withPastOrders) {
                /// Set the Select statement.
                sqlSelect = [NSString stringWithFormat:@"SELECT PRODUCT_ID, PRODUCT_NAME, PRODUCT_QUANTITY_ORDERED FROM ORDERSLOG WHERE ORDER_ID = '%@' ORDER BY ORDER_DATE DESC", [dictDetailOrder objectForKey:@"ORDER_ID"]];
            }else{
                /// Set the Select statement.
                sqlSelect = [NSString stringWithFormat:@"SELECT PRODUCT_ID, PRODUCT_NAME, PRODUCT_QUANTITY_ORDERED FROM ORDERSLOG WHERE ORDER_ID = '%@' ORDER BY ORDER_DATE DESC", [dictDetailOrder objectForKey:@"ORDER_ID"]];
            }
            const char *select_stmt = [sqlSelect UTF8String];
            /// Execute the Select statement.
            sqlite3_prepare_v2(appDB, select_stmt, -1, &statement, nil);
            /// Extract the data from the query result.
            while (sqlite3_step(statement) != SQLITE_DONE) {
                /// Create a dictionary.
                NSMutableDictionary *dictDetail = [[NSMutableDictionary alloc] init];
                [dictDetail setObject:[NSString stringWithFormat:@"%d",sqlite3_column_int(statement, 0)] forKey:@"PRODUCT_ID"];
                [dictDetail setObject:[NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 1)] forKey:@"PRODUCT_NAME"];
                [dictDetail setObject:[NSString stringWithFormat:@"%d",sqlite3_column_int(statement, 2)] forKey:@"PRODUCT_QUANTITY_ORDERED"];
                [arrOrderDetail addObject:dictDetail];
            }
            [dictDetailOrder setObject:arrOrderDetail forKey:@"ORDER_DETAIL"];
            [arrToReturn addObject:dictDetailOrder];
        }
        /// Finalize the statement.
        [DBManager finalizeStatements:statement withDB:appDB];
    }
    return arrToReturn;
}

+(void)deleteOrderLog:(NSString *)orderId
{
    /// Set DB variables.
    sqlite3 *appDB = nil;
    sqlite3_stmt *statement;
    /// Get the path of the DB.
    const char *dbPath = [[DBManager getDBPath] UTF8String];
    NSString *sqlDelete = @"";
    const char *deleteSQL = [sqlDelete UTF8String];
    if (sqlite3_open(dbPath, &appDB) == SQLITE_OK) {
        /// Set the Delete Statement.
        sqlDelete = [NSString stringWithFormat:@"DELETE FROM ORDERSLOG WHERE ORDER_ID = \"%@\" ",orderId];
        deleteSQL = [sqlDelete UTF8String];
        /// Execute the Delete statement.
        sqlite3_prepare_v2(appDB, deleteSQL, -1, &statement, nil);
        /// Check for errors.
        if (sqlite3_step(statement) != SQLITE_DONE) {
            //NSLog(@"delete order log Fail error %s", sqlite3_errmsg(appDB));
        }
        /// Finalize the statement.
        [DBManager finalizeStatements:statement withDB:appDB];
    }
}

#pragma mark -- Delete table content
+(void)deleteTableContent:(NSArray*)tables
{
    /// Set DB variables.
    sqlite3 *appDB = nil;
    sqlite3_stmt *statement;
    /// Get the path of the DB.
    const char *dbPath = [[DBManager getDBPath] UTF8String];
    NSString *sqlDelete = @"";
    const char *deleteSQL = [sqlDelete UTF8String];
    /// Loop to delete the content of each table from the array tables.
    for (NSString * strTable in tables) {
        if (sqlite3_open(dbPath, &appDB) == SQLITE_OK) {
            /// Set the Delete statement.
            sqlDelete = [NSString stringWithFormat:@"DELETE FROM %@",strTable];
            deleteSQL = [sqlDelete UTF8String];
            /// Execute the Delete statement.
            sqlite3_prepare_v2(appDB, deleteSQL, -1, &statement, nil);
            /// Check for errors.
            if (sqlite3_step(statement) != SQLITE_DONE) {
                //NSLog(@"delete table content Fail error %s", sqlite3_errmsg(appDB));
            }
            /// Finalize the statement.
            [DBManager finalizeStatements:statement withDB:appDB];
        }
    }
}

#pragma mark -- Update product stock
+(void)updateProductStock:(int)productId withStock:(int)stock;
{
    /// Set the DB variables.
    sqlite3 *appDB = nil;
    sqlite3_stmt *statement;
    /// Get the path of the DB.
    const char *dbPath = [[DBManager getDBPath] UTF8String];
    NSString *sqlUpdate = @"";
    const char *updateSQL = [sqlUpdate UTF8String];
        if (sqlite3_open(dbPath, &appDB) == SQLITE_OK) {
            /// Set the Update statement.
            sqlUpdate = [NSString stringWithFormat:@"UPDATE PRODUCTS SET PRODUCT_TOTAL_ON_HAND = %d WHERE PRODUCT_MASTER_MASTEROBJECT_ID = %d",stock,productId];
            updateSQL = [sqlUpdate UTF8String];
            /// Execute the Update statement.
            sqlite3_prepare_v2(appDB, updateSQL, -1, &statement, nil);
            /// Check for errors.
            if (sqlite3_step(statement) == SQLITE_DONE) {
                //NSLog(@"update product stock Fail error %s", sqlite3_errmsg(appDB));
            }
            /// Finalize the statement.
            [DBManager finalizeStatements:statement withDB:appDB];
        }
}

#pragma mark -- Get products from orders in confirm status
+(NSMutableArray *)getProductsInConfirm
{
    /// Set the DB variables.
    sqlite3 * appDB;
    sqlite3_stmt * statement;
    /// Get the path of the DB.
    const char * dbpath = [[DBManager getDBPath] UTF8String];
    NSMutableArray * arrToReturn = [[NSMutableArray alloc] init];
    /// Set the Select statement.
    NSString * selectSQL = [NSString stringWithFormat: @"SELECT A.PRODUCT_ID, A.TOTAL FROM (SELECT PRODUCT_ID, SUM(PRODUCT_QUANTITY_ORDERED)AS TOTAL FROM ORDERSLOG WHERE ORDER_STATUS = 'confirm' OR ORDER_STATUS = 'attending' GROUP BY PRODUCT_ID) AS A WHERE A.TOTAL > 0"];
    const char * select_stmt = [selectSQL UTF8String];
    if (sqlite3_open(dbpath, &appDB) == SQLITE_OK) {
        /// Execute the Select statement.
        sqlite3_prepare_v2(appDB, select_stmt, -1, &statement, nil);
        /// Loop to extract the data from the query result.
        while (sqlite3_step(statement) != SQLITE_DONE) {
            NSMutableDictionary * dictProduct = [[NSMutableDictionary alloc] init];
            [dictProduct setObject:[NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 0)] forKey:@"PRODUCT_ID"];
            [dictProduct setObject:[NSString stringWithFormat:@"%d",sqlite3_column_int(statement, 1)] forKey:@"TOTAL"];
            [arrToReturn addObject:dictProduct];
        }
    }
    /// Finalize the statement.
    [DBManager finalizeStatements:statement withDB:appDB];
    
    return arrToReturn;
}


#pragma mark -- Delete orders in confirm o attending status of past days
+(void)deleteUnattendedOrders
{
    sqlite3 * appDB;
    sqlite3_stmt * statement;
    const char * dbPath = [[DBManager getDBPath] UTF8String];
    
    NSDateFormatter * dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd-MM-yyyy 00:00"];
    NSString * currentDate = [dateFormat stringFromDate:[NSDate dateWithTimeIntervalSince1970:[[NSDate date] timeIntervalSince1970]]];
    
    NSString * deleteSQL = [NSString stringWithFormat:@"DELETE FROM ORDERSLOG WHERE ORDER_DATE < %f  AND (ORDER_STATUS = 'confirm' OR ORDER_STATUS = 'attending') ", (double)[[dateFormat dateFromString:currentDate] timeIntervalSince1970]];
    const char * deleteStmt = [deleteSQL UTF8String];
    if (sqlite3_open(dbPath, &appDB) == SQLITE_OK) {
        sqlite3_prepare_v2(appDB, deleteStmt, -1, &statement, nil);
        if (sqlite3_step(statement) != SQLITE_DONE) {
            //NSLog(@"delete unattended orders Fail error %s", sqlite3_errmsg(appDB));
        }
    }
    [DBManager finalizeStatements:statement withDB:appDB];
}


@end
