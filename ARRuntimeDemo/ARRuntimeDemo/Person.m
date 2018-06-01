//
//  Person.m
//  ARRuntimeDemo
//
//  Created by andyron<http://andyron.com> on 2018/5/31.
//  Copyright © 2018年 andyron. All rights reserved.
//

#import "Person.h"

@implementation Person
{
    NSString *lastname;  //实例变量（私有，实际是可以访问）
    float weight;
}

-(instancetype)init {
    self = [super init];
    if (self) {
        firstName = @"Andy";
        
    }
    return self;
}

-(void)f1 {
    NSLog(@"执行f1");
}

-(void)f2 {
    NSLog(@"执行f2");
}

+ (void)run {
    NSLog(@"跑");
}

+ (void)study {
    NSLog(@"学习");
}

@end
