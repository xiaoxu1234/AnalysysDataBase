//
//  AnalysysDataBase.h
//  AnalysysDataBase
//
//  Created by xiao xu on 2020/12/29.
//

#import <Foundation/Foundation.h>

@interface AnalysysDataBase : NSObject
+ (instancetype)sharedManager;
- (BOOL)insertLog:(NSString *)log;
- (NSArray *)selectLog;
- (void)selectLogFinshBlock:(void(^)(NSArray *arr))block;
@end

