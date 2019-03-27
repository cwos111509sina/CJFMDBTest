//
//  ViewController.m
//  CJFMDBTest
//
//  Created by jsmnzn on 2019/3/27.
//  Copyright © 2019年 Mingneng. All rights reserved.
//

#import "ViewController.h"
#import "CJFMDBObject.h"

#define WIDTH [UIScreen mainScreen].bounds.size.width

@interface ViewController ()
@property (nonatomic,strong)CJFMDBObject *db;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    _db = [CJFMDBObject shareManager];

    NSArray *itemArr = @[@"插入数据",@"更新数据",@"查询前两行数据",@"查询结果",@"删除数据",@"删除所有数据"];
    
    CGFloat frameX = 30.0;
    CGFloat frameY = 100.0;
    
    for ( int i = 0; i<itemArr.count; i++) {
        
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(frameX, frameY, WIDTH, 50);
        [button setTitle:itemArr[i] forState:UIControlStateNormal];
        [button sizeToFit];
        
        if ((frameX+CGRectGetMaxX(button.frame)+20+30) >= WIDTH) {
            frameX = 30.0;
            frameY += 50.0;
        }
        
        button.frame = CGRectMake(frameX, frameY, button.frame.size.width+20, 30);
        button.tag = 100+i;
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        
        
        frameX += button.frame.size.width+30;
        
    }
    
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)buttonClick:(UIButton *)button{
    
    switch (button.tag) {
            
        case 100:{//插入数据
            static int i = 0;
            [_db fmdbInsertTable:@"student" primaryKey:@"testID" vlaues:@[@{@"testID":[NSString stringWithFormat:@"%d",i],@"name":@"testName0",@"age":[NSString stringWithFormat:@"age%d",i]}]];
            i++;
    }
            break;
        case 101:{//更新数据
            [_db fmdbUpdateTable:@"student" name:@"name" values:@[@{@"name":@"testName2",@"age":@"changeAge2"}]];
        }
            break;
        case 102:{//查询前两行数据
            NSArray *resultArray = [_db fmdbSelectFromTable:@"student" limit:2 offset:0];
            NSLog(@"前两行数据 resultArray = %@",resultArray);
        }
            break;
        case 103:{//查询所有数据
            NSArray * resultArr = [_db fmdbSelectFromTable:@"student"];
            NSLog(@"查询所有结果 resultArr = %@",resultArr);
        }
            break;
        case 104://删除数据
            [_db fmdbDeleteTable:@"student" name:@"testID" values:@[@"0"]];
            break;
        case 105://删除表中所有数据
            [_db fmdbDeleteTable:@"student"];
            break;
            
        default:
            break;
    }
    
    NSArray * resultArr = [_db fmdbSelectFromTable:@"student"];
    NSLog(@"操作结果 resultArr = %@",resultArr);
}




@end
