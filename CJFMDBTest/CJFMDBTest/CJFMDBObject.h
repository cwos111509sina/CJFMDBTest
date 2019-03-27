//
//  BCFMDBObject.h
//  boche
//
//  Created by jsmnzn on 2019/3/21.
//  Copyright © 2019年 jsmnzn. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FMDB.h"

NS_ASSUME_NONNULL_BEGIN


@interface CJFMDBObject : NSObject

+(instancetype)shareManager;

//插入数据、没有表时创建
-(void)fmdbInsertTable:(NSString *)table primaryKey:(NSString *)priKey vlaues:(NSArray *)values;

/**
 更新数据
 
 table:表名字 t_xxxx
 name :主键
 values : 包含改动字典的数组 字典内包含主键、修改内容键值对
 
 */
-(void)fmdbUpdateTable:(NSString *)table name:(NSString *)name values:(NSArray *)values;

/**
 删除表中数据
 
 table:表名字 t_xxxx
 name :主键
 values : 包含删除主键对应的值
 
 */
-(void)fmdbDeleteTable:(NSString *)table;
-(void)fmdbDeleteTable:(NSString *)table name:(NSString *)name values:(NSArray *)values;

/**
 获取表中数据
 table:表名字 t_xxxx
 limit:返回行数
 offset:从数据库取数据时条数的起点
 
 */

-(NSArray *)fmdbSelectFromTable:(NSString *)table;
-(NSArray *)fmdbSelectFromTable:(NSString *)table limit:(NSInteger)limit offset:(NSInteger)offset;


//删除数据库
-(void)fmdbDelete;




@end

NS_ASSUME_NONNULL_END
