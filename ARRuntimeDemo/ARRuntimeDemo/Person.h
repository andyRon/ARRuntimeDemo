//
//  Person.h
//  ARRuntimeDemo
//
//  Created by andyron<http://andyron.com> on 2018/5/31.
//  Copyright © 2018年 andyron. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject
{
    NSString * firstName;
}
@property (nonatomic, assign) int age;

+(void)run;
+(void)study;

-(void)f1;
-(void)f2;

@end
