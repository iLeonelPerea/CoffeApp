//
//  DBManager.h
//
//

/** @name DBManager
 
    Class with all the methods to make operations into the local database. The database is a SQLite DB.
 */

#import <Foundation/Foundation.h>
#import "ProductObject.h"
#import <sqlite3.h>

@interface DBManager : NSObject

/** Check if the database already exists.
 
    This method is used every time the app is launched. If the database doesn't exists, is created.
    The tables of the structure are:
        - PRODUCTS. Store all the products of the current menu.
        - PRODUCT_CATEGORIES. Store the categories for the products of the current menu.
        - ORDERSLOG. Log of the orders. The data of this table is used in the "My Orders" option of the app and to calculate the virtual stock of the products.
 */
+(BOOL)checkOrCreateDataBase;

/** Return the Path of the database on the device directory. */
+(NSString*)getDBPath;

/** Finalize a SQLite statement.
 
    Is used to finalize a statement after an operation on the database.
 
    @param stm  Statement variable used.
    @param DB The Sqlite database variable.
 */
+(void)finalizeStatements:(sqlite3_stmt*)stm withDB:(sqlite3*)DB;

/** Inserts a product into the PRODUCTS table.
 
 This method is used when the app send a request to the Spree store to get the current menu.
 
 To see which values are inserted, check the ProductObject section.
 
 @param product A ProductObject object.
 */
+(void)insertProduct:(ProductObject *)product;

/** Return all the products of a specific category.
 
    @param category It's a the category which contains the products to get from Products table.
 */
+(NSMutableArray *)getProductsCategory:(CategoryObject *)category;

/** Get all the products for the current from the PRODUCTS table.
 
    Is used to get all the prodcuts for the current menu.
 */
+(NSMutableArray*)getProducts;

/** Delete the content of the PRODUCTS table.
 
    Is used before the app ask to the Spree store for the current menu.
 */
+(void)deleteProducts;

/** Insert a category into PRODUCT_CATEGORIES table.
 
    @param product The ProducObject contains the data of the category to be inserted.
 */
+(void)insertProductCategory:(ProductObject *)product;

/** Insert a category into PRODUCT_CATEGORIES table based on an array received.
 
    @param category Dictionary with the values for ID and CATEGORY_NAME.
 */
+(void)insertCategory:(NSDictionary *)category;

/** Returns the categories into an array from PRODUCT_CATEGORIES table.
 */
+(NSMutableArray *)getCategories;

/** Insert into ORDERSLOG the information from the orders maded.
 
    The data of this table is used in the "My Orders" option of the app and to calculate the virtual stock of the products.
 
    @param dictDataOrder A dictionary with the next information: ORDER_ID, ORDER_STATUS, ORDER_DATE, PRODUCT_ID, PRODUCT_NAME and PRODUCT_QUANTITY_ORDERED.
 */
+(void)insertOrdersLog:(NSDictionary*)dictDataOrder;

/** Update the state of an order from ORDERSLOG table.
    
    Is used to update the state of an order when is attended or completed.
 
    @param orderId The ORDER_ID of the order to be updated.
    @param orderState The ORDER_STATUS of the order to be updated.
 */
+(void)updateStateOrderLog:(NSString*)orderId withState:(NSString*)orderState;

/** Return the orders from the ORDERSLOG table.
 
    The information is returned into an array with two levels:
    - ORDER_ID.
    - ORDER_DATE.
    - ORDER_STATUS.
    - ORDER_DETAIL. Dictionary with an array that contains:
        - PRODUCT_ID.
        - PRODUCT_NAME.
        - PRODUCT_QUANTITY_ORDERED.
 
    @param withPastOrders If the value of this param is YES, the method will return the orders with ORDER_STATUS in "complete". On the other hand, will return the orders with ORDER_STATUS in "confirm" or "attending".
 */
+(NSMutableArray*)getOrdersHistory:(BOOL)withPastOrders;

/** Delete a specific order from ORDERSLOG table.
    
    This method is used to delete a order that is cancelled by the user. To delete an order it must to be in ORDER_STATUS equal to "confirm".
 
    @param orderId The ORDER_ID of the order to be deleted.
 */
+(void)deleteOrderLog:(NSString *)orderId;

/** Delete the content of a table.
    
    Receives an array with the names of the table, which their content will be deleted. Is used when the user do Log Out from the app.
 
    @param tables Array with the tables which content will be deleted.
 */
+(void)deleteTableContent:(NSArray*)tables;

/** Update the stock of a specific product from the PRODUCTS table.
 
    When the app receives a push notification, because an order was served. This method is called to update the stock of a product.
 
    @param productId The PRODUCT_MASTER_MASTEROBJECT_ID of the product to be updated.
    @param stock The value of stock to be updated.
 */
+(void)updateProductStock:(int)productId withStock:(int)stock;

/** Return the quantity of each product registered in ORDERSLOG.
 
    This method sum the quantity of each product that is in orders with ORDER_STATUS equal to "confirm" or "attending".
    The information is used to set the update the total_on_hand value of each product of the current menu.
    The array that is returned contains:
        - PRODUCT_ID.
        - TOTAL.
 */
+(NSMutableArray *)getProductsInConfirm;

@end
