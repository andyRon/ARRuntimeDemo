# ARRuntimeDemo


学习iOS开发，runtime这个知识点是绕不过去的，但对于我这种学习OC不是太久，写OC的量不够多的人来说，抽象理解runtime的概念或者是看源代码有点枯燥，效果也不好，以例子的方法学习可能会更好，随着代码量的上升，对runtime的理解会越来越深入。
详细代码[ARRuntimeDemo](https://github.com/andyRon/ARRuntimeDemo),开发环境Xcode9.4

 Person.h为：
```
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
```
Person.m为：
```
#import "Person.h"

@implementation Person
{
    NSString *lastname;  
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
```


### 1 获取类的所有变量(包括成员变量和属性变量)
```
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
```
结果输出(其中firstName、lastname、weight为成员变量，_age为属性变量)：
```
2018-06-01 17:04:56.275194+0800 ARRuntimeDemo[60670:5448260] Name: firstName  Type: @"NSString"
2018-06-01 17:04:56.276120+0800 ARRuntimeDemo[60670:5448260] Name: lastname  Type: @"NSString"
2018-06-01 17:04:56.276503+0800 ARRuntimeDemo[60670:5448260] Name: weight  Type: f
2018-06-01 17:04:56.276614+0800 ARRuntimeDemo[60670:5448260] Name: _age  Type: i
```
解释：
- `Iva`，一个指向objc_ivar结构体指针,包含了变量名、变量类型等信息
- 像lastname、weight这种定义在`@implementation`所谓的私有变量也可获取
- 对应`class_copyIvarList `还有一个`class_copyPropertyList`只能获得属性变量的方法

### 2 获取所有方法（不包括类方法）
```
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
```
结果输出:
```
2018-06-01 16:54:50.433232+0800 ARRuntimeDemo[60482:5418318] (Method:f1)
2018-06-01 16:54:50.433465+0800 ARRuntimeDemo[60482:5418318] (Method:f2)
2018-06-01 16:54:50.433930+0800 ARRuntimeDemo[60482:5418318] (Method:.cxx_destruct)
2018-06-01 16:54:50.434335+0800 ARRuntimeDemo[60482:5418318] (Method:init)
2018-06-01 16:54:50.435163+0800 ARRuntimeDemo[60482:5418318] (Method:height)
2018-06-01 16:54:50.435788+0800 ARRuntimeDemo[60482:5418318] (Method:setHeight:)
2018-06-01 16:54:50.435990+0800 ARRuntimeDemo[60482:5418318] (Method:setAge:)
2018-06-01 16:54:50.436482+0800 ARRuntimeDemo[60482:5418318] (Method:age)
```
解释：
- 获得了像`height`,`setHeight`这种隐藏的**setter**、**getter**方法
- `Method`是一个指向objc_method结构体指针，表示对类中的某个方法的描述。
- `.cxx_destruct`是关于系统自动内存释放的隐藏方法


### 3 为类添加新属性
category只能为类添加新方法，不能添加新属性，但通过runtime配合category就可以达到添加属性效果。
首先新建一个类`Person`的category：
`.h`文件
```
//  Person+Category.h

#import "Person.h"

@interface Person (Category)

@property (nonatomic, assign)float height;

@end
```
`.m`文件
```
//  Person+Category.m

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

```
然后就能访问新属性`height`了：
```
- (IBAction)addVar:(UIButton *)sender {
    per = [[Person alloc] init];
    
    per.height = 123;
    NSLog(@"%f", [per height]);
}
```
此时虽然通过上面的获取所有变量方法不能获取`height`,但通过上面的额获取所有方法可以获取`height`和`setHeight`方法了:
```
2018-06-01 17:14:36.945742+0800 ARRuntimeDemo[60892:5482950] Name: firstName  Type: @"NSString"
2018-06-01 17:14:36.948330+0800 ARRuntimeDemo[60892:5482950] Name: lastname  Type: @"NSString"
2018-06-01 17:14:36.948771+0800 ARRuntimeDemo[60892:5482950] Name: weight  Type: f
2018-06-01 17:14:36.949166+0800 ARRuntimeDemo[60892:5482950] Name: _age  Type: i

2018-06-01 17:15:02.198444+0800 ARRuntimeDemo[60892:5482950] (Method:f1)
2018-06-01 17:15:02.198620+0800 ARRuntimeDemo[60892:5482950] (Method:f2)
2018-06-01 17:15:02.198800+0800 ARRuntimeDemo[60892:5482950] (Method:.cxx_destruct)
2018-06-01 17:15:02.198917+0800 ARRuntimeDemo[60892:5482950] (Method:init)
2018-06-01 17:15:02.199048+0800 ARRuntimeDemo[60892:5482950] (Method:height)
2018-06-01 17:15:02.199150+0800 ARRuntimeDemo[60892:5482950] (Method:setHeight:)
2018-06-01 17:15:02.199239+0800 ARRuntimeDemo[60892:5482950] (Method:setAge:)
2018-06-01 17:15:02.199356+0800 ARRuntimeDemo[60892:5482950] (Method:age)
```


### 4 添加新方法
```
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
```
输出：
```
2018-06-01 17:31:56.113168+0800 ARRuntimeDemo[61295:5543319] 已新增方法:NewMethod
```

### 5 交换两个方法
```
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
```
输出：
```
2018-06-01 17:39:00.497375+0800 ARRuntimeDemo[61448:5566239] 跑
2018-06-01 17:39:00.497841+0800 ARRuntimeDemo[61448:5566239] 学习
2018-06-01 17:39:00.499255+0800 ARRuntimeDemo[61448:5566239] 学习
2018-06-01 17:39:00.499449+0800 ARRuntimeDemo[61448:5566239] 跑

```

这篇文章我只是做了runtime一些简单使用，并没有相关的使用场景，算是入门了，文末参考提到的文章都是不错，值得以后深入。


> 参考：
[iOS开发 -- Runtime 的几个小例子](https://www.jianshu.com/p/ed65518ec8db)  
[OC最实用的runtime总结，面试、工作你看我就足够了！](https://www.jianshu.com/p/ab966e8a82e2)  
[iOS-RunTime，不再只是听说](http://www.jianshu.com/p/8acdedf9c1af)  
[Runtime全方位装逼指南](http://www.jianshu.com/p/efeb33712445#)  
 [Objective-C Runtime](http://yulingtianxia.com/blog/2014/11/05/objective-c-runtime/ "Objective-C Runtime")

