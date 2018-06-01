//
//  Person+Category.m
//  ARRuntimeDemo
//
//  Created by andyron<http://andyron.com> on 2018/6/1.
//  Copyright © 2018年 andyron. All rights reserved.
//

#import "Person+Category.h"
#import <objc/runtime.h>

const char *key = "myKey";

@implementation Person (Category)

-(void)setHeight:(float)height {
    NSNumber *num = [NSNumber numberWithFloat:height];
    /*
     objc_setAssociatedObject(id object, const void *key, id value, objc_AssociationPolicy policy);
     第一个参数是需要添加属性的对象；
     第二个参数是属性的key，是C字符串就可以;
     第三个参数是属性的值,类型必须为id，所以此处height先转为NSNumber类型；
     第四个参数是使用策略，是一个枚举值，类似@property属性创建时设置属性修饰符，可从命名看出各枚举的意义；
     */
    objc_setAssociatedObject(self, key, num, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(float)height {
    NSNumber *number = objc_getAssociatedObject(self, key);
    return [number floatValue];
}
@end
