//
//  AnalysysSqlite3.m
//  AnalysysDataBase
//
//  Created by xiao xu on 2020/12/29.
//

#import "AnalysysSqlite3.h"
#import <sqlite3.h>

@interface AnalysysSqlite3()
{
    sqlite3 *_db;
    NSString *_dbPath;
}
@end

@implementation AnalysysSqlite3

- (instancetype)init {
    return [self initWithPath:nil];
}

- (instancetype)initWithPath:(NSString*)aPath {
    self = [super init];
    if (self) {
        _dbPath = aPath ? [aPath copy] : @"AnalysysDB.sqlite";
        _db = nil;
    }
    return self;
}

- (NSString *)getDatabaseFilePath {
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *dataBaseFilePath = [docPath stringByAppendingPathComponent:_dbPath];
    return dataBaseFilePath;
}

- (BOOL)openDataBase {
    NSString *filePath = [self getDatabaseFilePath];
    int result = sqlite3_open(filePath.UTF8String, &_db);
    if (result == SQLITE_OK) {
        NSLog(@"%@",[NSString stringWithFormat:@"数据库打开成功:%@",filePath]);
        return YES;
    }else{
        NSLog(@"数据库打开失败");
        return NO;
    }
}

- (BOOL)createTableWithSql:(NSString *)sql {
    
    BOOL result = [self openDataBase];
    
    if (result == YES) {
        
        //定义编译sql语句的变量（数据句柄）
        sqlite3_stmt *stmt = NULL;
        //开始编译sql语句
        sqlite3_prepare_v2(_db, sql.UTF8String, -1, &stmt, NULL);
        //执行sql语句
        result = sqlite3_step(stmt);
        
        if (result == SQLITE_ERROR) {
            const char *errorMsg = sqlite3_errmsg(_db);
            NSString *error = [NSString stringWithCString:errorMsg encoding:NSUTF8StringEncoding];
            NSLog(@"%@",error);
            return NO;
        }
        
        //关闭数据句柄和数据库
        sqlite3_finalize(stmt);
        sqlite3_close(_db);
        return  YES;
        
    } else {
        return result;
    }
}


- (BOOL)execTableWithSql:(NSString *)sql params:(NSArray *)params {
    
    BOOL result = [self openDataBase];
    if (result == YES) {
        
        //定义编译sql语句的变量（数据句柄）
        sqlite3_stmt *stmt = NULL;
        //开始编译sql语句
        sqlite3_prepare_v2(_db, sql.UTF8String, -1, &stmt, NULL);
        
        //绑定参数
        for (int i = 0; i < params.count; i++) {
            // 获取参数内容
            id param = params[i];
            if ([param isKindOfClass:[NSString class]] )
                sqlite3_bind_text(stmt, i+1, [param UTF8String], -1, SQLITE_TRANSIENT);
            if ([param isKindOfClass:[NSNumber class]] ) {
                if (!strcmp([param objCType], @encode(float)))
                    sqlite3_bind_double(stmt, i+1, [param doubleValue]);
                else if (!strcmp([param objCType], @encode(int)))
                    sqlite3_bind_int(stmt, i+1, [param intValue]);
                else if (!strcmp([param objCType], @encode(BOOL)))
                    sqlite3_bind_int(stmt, i+1, [param intValue]);
                else
                    NSLog(@"unknown NSNumber");
            }
            if ([param isKindOfClass:[NSDate class]]) {
                sqlite3_bind_double(stmt, i+1, [param timeIntervalSince1970]);
            }
            if ([param isKindOfClass:[NSData class]] ) {
                sqlite3_bind_blob(stmt, i+1, [param bytes], (int)[param length], SQLITE_STATIC);
            }
        }
        
        //执行sql语句
        if (sqlite3_step(stmt) == SQLITE_DONE) {
            //关闭数据句柄和数据库
            sqlite3_finalize(stmt);
            sqlite3_close(_db);
            return YES;
        } else {
            const char *errorMsg = sqlite3_errmsg(_db);
            NSString *error = [NSString stringWithCString:errorMsg encoding:NSUTF8StringEncoding];
            NSLog(@"%@",error);
            return NO;
        }
        
    }else{
        return result;
    }
}

- (NSArray *)selectTableWithSql:(NSString *)sql params:(NSArray *)params {
    
    BOOL result = [self openDataBase];
    if (result == YES) {
        //定义编译sql语句的变量（数据句柄）
        sqlite3_stmt *stmt = NULL;
        //开始编译sql语句
       BOOL prepareResult = sqlite3_prepare_v2(_db, sql.UTF8String, -1, &stmt, NULL);
        if (prepareResult == SQLITE_ERROR) {
            const char *errorMsg = sqlite3_errmsg(_db);
            NSString *error = [NSString stringWithCString:errorMsg encoding:NSUTF8StringEncoding];
            NSLog(@"%@",error);
        }
        
        //绑定参数
        for (int i = 0; i < params.count; i++) {
            // 获取参数内容
            id param = params[i];
            if ([param isKindOfClass:[NSString class]] )
                sqlite3_bind_text(stmt, i+1, [param UTF8String], -1, SQLITE_TRANSIENT);
            if ([param isKindOfClass:[NSNumber class]] ) {
                if (!strcmp([param objCType], @encode(float)))
                    sqlite3_bind_double(stmt, i+1, [param doubleValue]);
                else if (!strcmp([param objCType], @encode(int)))
                    sqlite3_bind_int(stmt, i+1, [param intValue]);
                else if (!strcmp([param objCType], @encode(BOOL)))
                    sqlite3_bind_int(stmt, i+1, [param intValue]);
                else
                    NSLog(@"unknown NSNumber");
            }
            if ([param isKindOfClass:[NSDate class]]) {
                sqlite3_bind_double(stmt, i+1, [param timeIntervalSince1970]);
            }
            if ([param isKindOfClass:[NSData class]] ) {
                sqlite3_bind_blob(stmt, i+1, [param bytes], (int)[param length], SQLITE_STATIC);
            }
        }
                    
        NSMutableArray *resultsArray = [NSMutableArray array];
        while (sqlite3_step(stmt) == SQLITE_ROW) {
                int columns = sqlite3_column_count(stmt);
                NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:columns];
                
                for (int i = 0; i<columns; i++) {
                    const char *name = sqlite3_column_name(stmt, i);
                    
                    NSString *columnName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
                    
                    int type = sqlite3_column_type(stmt, i);
                    
                    switch (type) {
                        case SQLITE_INTEGER:
                        {
                            int value = sqlite3_column_int(stmt, i);
                            [result setObject:[NSNumber numberWithInt:value] forKey:columnName];
                            break;
                        }
                        case SQLITE_FLOAT:
                        {
                            float value = sqlite3_column_double(stmt, i);
                            [result setObject:[NSNumber numberWithFloat:value] forKey:columnName];
                            break;
                        }
                        case SQLITE_TEXT:
                        {
                            const char *value = (const char*)sqlite3_column_text(stmt, i);
                            [result setObject:[NSString stringWithCString:value encoding:NSUTF8StringEncoding] forKey:columnName];
                            break;
                        }
                            
                        case SQLITE_BLOB:
                        {
                            int bytes = sqlite3_column_bytes(stmt, i);
                            if (bytes > 0) {
                                const void *blob = sqlite3_column_blob(stmt, i);
                                if (blob != NULL) {
                                    [result setObject:[NSData dataWithBytes:blob length:bytes] forKey:columnName];
                                }
                            }
                            break;
                        }
                                                
                        case SQLITE_NULL:
                            [result setObject:[NSNull null] forKey:columnName];
                            break;
                            
                        default:
                        {
                            const char *value = (const char *)sqlite3_column_text(stmt, i);
                            [result setObject:[NSString stringWithCString:value encoding:NSUTF8StringEncoding] forKey:columnName];
                            break;
                        }
                            
                    }
                }
        
                [resultsArray addObject:result];
            }
        
        //关闭数据句柄和数据库
        sqlite3_finalize(stmt);
        sqlite3_close(_db);
        return  resultsArray;
            
        }else{
            return nil;
        }
}

- (void)selectTableWithSql:(NSString *)sql params:(NSArray *)params finshBlock:(void(^)(NSArray *arr))block {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray *array =[self selectTableWithSql:sql params:params];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                block(array);
            }
        });
    });
}

@end
