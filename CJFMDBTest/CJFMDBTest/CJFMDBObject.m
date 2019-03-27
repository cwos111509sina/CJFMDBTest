//
//  BCFMDBObject.m
//  boche
//
//  Created by jsmnzn on 2019/3/21.
//  Copyright © 2019年 jsmnzn. All rights reserved.
//

#import "CJFMDBObject.h"


@interface CJFMDBObject ()

@property (nonatomic,strong)FMDatabase *db;
@property (nonatomic,strong)FMDatabaseQueue *queue;

@end

@implementation CJFMDBObject

static CJFMDBObject *manager;
+(instancetype)shareManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!manager) {
            manager = [[CJFMDBObject alloc]init];
            manager.queue = [FMDatabaseQueue databaseQueueWithPath:[NSString stringWithFormat:@"%@/park.sqlite",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]]];
            manager.db = [FMDatabase databaseWithPath:[NSString stringWithFormat:@"%@/park.sqlite",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]]];
            NSLog(@"filePath = %@",[NSString stringWithFormat:@"%@/park.sqlite",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]]);
        }
    });
    
    return manager;
}


+(instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!manager) {
            manager = [super allocWithZone:zone];
        }
    });
    return manager;
}


//插入数据、没有表时创建
-(void)fmdbInsertTable:(NSString *)table primaryKey:(NSString *)priKey vlaues:(NSArray *)values{
    if (![self isCreateTable:table]) {
        NSDictionary * dict = values[0];
        NSMutableArray * arr = [dict allKeys].mutableCopy;
        [arr removeObject:priKey];
        NSString * keys = [arr componentsJoinedByString:@" text,"];
        [self.queue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
            [db executeUpdate:[NSString stringWithFormat:@"create table if not exists %@ (%@ text primary key,%@ text);",table,priKey,keys]];
        }];
    }
    [self.queue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        for (NSDictionary * dict in values) {
            [db executeUpdate:[NSString stringWithFormat:@"insert or replace into %@ (%@) values (:%@)",table,[[dict allKeys] componentsJoinedByString:@","],[[dict allKeys] componentsJoinedByString:@",:"]] withParameterDictionary:dict];
            
        }
        
    }];
    
}
//更新数据
-(void)fmdbUpdateTable:(NSString *)table name:(NSString *)name values:(NSArray *)values{
    
    if (![self isCreateTable:table]) {
        return;
    }
    [self.queue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        for (NSDictionary * dict in values) {
            NSMutableArray * arr = [[NSMutableArray alloc]init];
            for (NSString * key in [dict allKeys]) {
                if (![key isEqualToString:name]) {
                    [arr addObject:[NSString stringWithFormat:@"%@ = '%@'",key,dict[key]]];
                }
            }
            
            [db executeUpdate:[NSString stringWithFormat:@"update %@ set %@ where %@ = '%@'",table,[arr componentsJoinedByString:@" ' "],name,dict[name]]];
        }
    }];
}

//删除数据
-(void)fmdbDeleteTable:(NSString *)table{
    if ([_db open]) {
        [_db executeUpdate:[NSString stringWithFormat:@"delete from %@;",table]];
    }
}
-(void)fmdbDeleteTable:(NSString *)table name:(NSString *)name values:(NSArray *)values{
    if (![self isCreateTable:table]) {
        return;
    }
    
    [self.queue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        
        NSString *sql = [NSString stringWithFormat:@"delete from %@ where %@ in ('%@')",table,name,[values componentsJoinedByString:[NSString stringWithFormat:@"','"]]];
        
        [db executeUpdate:sql];
    }];
    
}


//获取表中数据

-(NSArray *)fmdbSelectFromTable:(NSString *)table limit:(NSInteger)limit offset:(NSInteger)offset{
    NSMutableArray * array = [[NSMutableArray alloc]init];
    
    if ([_db open]) {
        
        FMResultSet *result = [_db executeQuery:[NSString stringWithFormat:@"select * from %@ limit %ld offset %ld;",table,limit,offset]];
        
        
        while ([result next]) {
            NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
            //        [dict removeObjectForKey:@"id"];
            
            NSMutableArray * keyArray = [[NSMutableArray alloc]init];
            
            for (NSString *key in result.columnNameToIndexMap.allKeys) {
                [keyArray addObject:[result columnNameForIndex:[result.columnNameToIndexMap[key] intValue]]];
            }
            
            for (NSString *key in keyArray) {
                [dict setObject:[NSString stringWithFormat:@"%@",[result stringForColumn:key]] forKey:key];
            }
            [array addObject:dict];
        }
    }
    return array.copy;
}


-(NSArray *)fmdbSelectFromTable:(NSString *)table{
    NSMutableArray * array = [[NSMutableArray alloc]init];
    
    if ([_db open]) {
        
        FMResultSet *result = [_db executeQuery:[NSString stringWithFormat:@"select * from %@",table]];
        
        
        while ([result next]) {
            NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
            //        [dict removeObjectForKey:@"id"];
            
            NSMutableArray * keyArray = [[NSMutableArray alloc]init];
            
            for (NSString *key in result.columnNameToIndexMap.allKeys) {
                [keyArray addObject:[result columnNameForIndex:[result.columnNameToIndexMap[key] intValue]]];
            }
            
            for (NSString *key in keyArray) {
                [dict setObject:[NSString stringWithFormat:@"%@",[result stringForColumn:key]] forKey:key];
            }
            [array addObject:dict];
        }
    }
    return array.copy;
}



-(BOOL)isCreateTable:(NSString *)table{
    
    __block BOOL isCreat;
    
    [self.queue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        
        FMResultSet *result = [db executeQuery:@"select count(*) as 'count' from sqlite_master where type = 'table' and name = ?",table];
        
        if ([result next]) {
            NSInteger count = [result intForColumn:@"count"];
            if (count == 0) {
                isCreat = NO;
            }else{
                isCreat = YES;
            }
        }else{
            isCreat = NO;
        }
    }];
    
    
    return isCreat;
}

-(void)fmdbDelete{
    
    NSString *filePath = [NSString stringWithFormat:@"%@/park.sqlite",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    if ([manager fileExistsAtPath:filePath]) {
        [manager removeItemAtPath:filePath error:nil];
    }
}



@end
