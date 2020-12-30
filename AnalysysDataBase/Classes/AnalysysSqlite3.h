//
//  AnalysysSqlite3.h
//  AnalysysDataBase
//
//  Created by xiao xu on 2020/12/29.
//

#import <Foundation/Foundation.h>

@interface AnalysysSqlite3 : NSObject

- (BOOL)createTableWithSql:(NSString *)sql;

- (BOOL)execTableWithSql:(NSString *)sql params:(NSArray *)params;

- (NSArray *)selectTableWithSql:(NSString *)sql params:(NSArray *)params;
- (void)selectTableWithSql:(NSString *)sql params:(NSArray *)params finshBlock:(void(^)(NSArray *arr))block;
@end

