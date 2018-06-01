//
//  ViewController.m
//  ARRuntimeDemo
//
//  Created by andyron<http://andyron.com> on 2018/5/31.
//  Copyright © 2018年 andyron. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"
#import <objc/runtime.h>
#import "Person+Category.h"

@interface ViewController ()

@end

@implementation ViewController {
    Person *per;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
     per = [[Person alloc]init];
    
}
// 1. 获取所有变量，包括成员变量和属性变量
- (IBAction)getAllVar:(UIButton *)sender {
    unsigned int count = 0;
    Ivar *allVariables = class_copyIvarList([Person class], &count);
    
    for (int i=0; i<count; i++) {
        Ivar ivar = allVariables[i];
        const char *Variablename = ivar_getName(ivar);
        const char *VariableType = ivar_getTypeEncoding(ivar);
        
        NSLog(@"Name: %s  Type: %s", Variablename, VariableType);
    }
}
// 2. 获取所有方法，不包括类方法
- (IBAction)getAllMethod:(UIButton *)sender {
    unsigned int count;
    //获取方法列表，所有在.m文件显式实现的方法都会被找到，包括setter+getter方法；
    Method *allMethods = class_copyMethodList([Person class], &count);
    for(int i =0;i<count;i++) {
        //Method，为runtime声明的一个宏，表示对一个方法的描述
        Method md = allMethods[i];
        //获取SEL：SEL类型,即获取方法选择器@selector()
        SEL sel = method_getName(md);
        //得到sel的方法名：以字符串格式获取sel的name，也即@selector()中的方法名称
        const char *methodname = sel_getName(sel);
        
        NSLog(@"(Method:%s)",methodname);
    }
}

//- (IBAction)changeVar:(UIButton *)sender {
//    per = [[Person alloc] init];
//    per.age = 12;
//
//    NSLog(@"改变前的person：%s",per);
//
//    unsigned int count = 0;
//    Ivar *allList = class_copyIvarList([Person class], &count);
//    Ivar ivv = allList[0]; //从第一个例子getAllVariable中输出的控制台信息，我们可以看到name为第一个实例属性。
//    object_setIvar(per, ivv, @"Mike"); //name属性Tom被强制改为Mike。
//    NSLog(@"改变之后的person：%@",per);
//}

// 3. 添加新属性
- (IBAction)addVar:(UIButton *)sender {
    per = [[Person alloc] init];
    
    per.height = 123;
    NSLog(@"%f", [per height]);
}

// 4. 添加新方法
- (IBAction)addMethod:(UIButton *)sender {
    /* 动态添加方法：
     第一个参数表示Class cls 类型；
     第二个参数表示待调用的方法名称；
     第三个参数(IMP)myAddingFunction，IMP一个函数指针，这里表示指定具体实现方法myAddingFunction；
     第四个参数表方法的参数，0代表没有参数；
     */
    class_addMethod([per class], @selector(NewMethod), (IMP)myAddingFunction, 0);
    //调用方法 【如果使用[per NewMethod]调用方法，在ARC下会报“no visible @interface"错误】
    [per performSelector:@selector(NewMethod)];
}
//具体的实现（方法的内部都默认包含两个参数Class类和SEL方法，被称为隐式参数。）
int myAddingFunction(id self, SEL _cmd){
    NSLog(@"已新增方法:NewMethod");
    return 1;
}

// 5. 交换两个方法
- (IBAction)swapMethod:(UIButton *)sender {
    [Person run];
    [Person study];
    
    Method m1 = class_getClassMethod([Person class], @selector(run));
    Method m2 = class_getClassMethod([Person class], @selector(study));
    
    method_exchangeImplementations(m1, m2);
    
    [Person run];
    [Person study];
}






@end
