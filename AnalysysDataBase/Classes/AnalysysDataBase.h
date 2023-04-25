//
//  AnalysysDataBase.h
//  AnalysysDataBase
//
//  Created by xiao xu on 2020/12/29.
//

#import <Foundation/Foundation.h>

@interface AnalysysDataBase : NSObject
+ (instancetype)sharedManager;
- (void)insertLog:(NSString *)log success:(void(^)(BOOL isSuccess))block;
- (void)selectLogFinshBlock:(void(^)(NSArray *arr))block;
- (void)deleteLogWithCount:(NSUInteger)count finishBlock:(void(^)(BOOL isSuccess))block;
- (void)deleteAllLogFinishBlock:(void(^)(BOOL isSuccess))block;
@end

