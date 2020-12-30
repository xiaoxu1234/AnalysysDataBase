//
//  AnalysysDataBase.m
//  AnalysysDataBase
//
//  Created by xiao xu on 2020/12/29.
//

#import "AnalysysDataBase.h"
#import "AnalysysSqlite3.h"
// 数据库中常见的几种类型
#define SQL_TEXT     @"TEXT" //文本
#define SQL_INTEGER  @"INTEGER" //int long integer ...
#define SQL_REAL     @"REAL" //浮点
#define SQL_BLOB     @"BLOB" //data

@interface AnalysysDataBase()

@property (nonatomic,strong) AnalysysSqlite3 *dataBase;

@end

@implementation AnalysysDataBase

+ (instancetype)sharedManager {
    static id singleInstance = nil;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        if (!singleInstance) {
            singleInstance = [[self alloc] init] ;
        }
    });
    return singleInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.dataBase = [[AnalysysSqlite3 alloc] init];
        NSString *sql = @"CREATE TABLE 'AnalysysLog' (id INTEGER PRIMARY KEY, 'log' TEXT,'time' TEXT)";
        BOOL b = [self.dataBase createTableWithSql:sql];
        if (b) {
            NSLog(@"AnalysysLog表创建成功");
        } else {
            NSLog(@"AnalysysLog表创建失败");
        }
    }
    return self;;
}

- (BOOL)insertLog:(NSString *)log {
    NSString *sql = @"insert into AnalysysLog(log,time) values(?,?)";
    NSString *time = [NSString stringWithFormat:@"%lf",[[NSDate date] timeIntervalSince1970] * 1000];
    BOOL b = [self.dataBase execTableWithSql:sql params:@[log,time]];
    if (b) {
        NSLog(@"插入数据成功");
    } else {
        NSLog(@"插入数据失败");
    }
    return b;
}

- (NSArray *)selectLog {
    NSString *sql = @"select * from AnalysysLog";
    return [self.dataBase selectTableWithSql:sql params:nil];
}

- (void)selectLogFinshBlock:(void(^)(NSArray *arr))block {
    NSString *sql = @"select * from AnalysysLog";
    [self.dataBase selectTableWithSql:sql params:nil finshBlock:^(NSArray *arr) {
        block(arr);
    }];
}

@end
