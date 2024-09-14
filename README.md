这是一个基于AST语法树的解析器，名字暂时叫dax，运行以下语句进入控制台体验语法特性：
`dart run bin/lox.dart`


也可以指定某个文件作为解析内容：
`dart run bin/lox.dart demo/fun.dax`

### 1.基本数据类型：

* 整数
```
var i = 1; 
```
* 浮点
```
var d = 1.0;
```
* 布尔
```
var b = true; 
```
* 字符串
```
var s = "this is string";  // 采用双引号
var s1 = 'this is string'; // 采用单引号
```
* 数组
```
var arr = [1,2,3];
var arr1 = [1, if(2>1) 2 ,3];
var arrDict = [{"x": 1}, {"x": 2}];
```
* 字典
```
var dict = {"x": 1};
```
* 空
```
var n = null;  // 空
```
### 2.基本表达式
* 赋值运算符
```
var x = 1;
x = 2;
```
* and/or 运算符
```
var x = 2>1 and 2<3;
```

* 三目运算符
```
var x = 2 > 1 ? 2 : 3;
```

* 比较运算符
```
var x = 2>1;
```

* 算术运算符
```
var x = 1+2;
var y = 1*2 + 3/6;
```

* 单目运算符
```
var x = -1;
var b = !true;
```

* map 运算符
```
var arr = [1,2,3];
var arr1 = arr.map((i) {return i*i});
```

* then 运算符
```
http.get(url).then(...)
```

* . 运算符
```
var dict = {"x": 1};
var x = dict.x;
```

* 下标运算符
```
var arr = [1,2,3];
var x = arr[1];
var dict = {"y":1};
var y = dict["y"];
```

* 括号表达式
```
var x = (1+2)*3;
```

* 匿名表达式
```
var arr = [1,2,3];
var x = (i){ return i*2; };
var y = arr.map(x);
print x(2);
```

* 字符串解析
```
var s = "1+2 = ${1+2}";
print s; // 输出 "1+2 = 3"
```

### 3.基本语句
* if-else 语句
```
if (2>1) {
	print "2>1";
} else {
	print "2<=1";
}
```

* while 循环语句
```
var i = 0;
while (i<10) {
	print i;
	i = i+1;
}
```
* for 循环语句
```
for (var i = 0; i< 10 ; i=i+1){
	print i;
}
```

* forEach 语句
```
var arr = [1,2,3];
arr.forEach((i) {
	print i;
});
```

* return 语句
```
fun add(x, y) {
	return x+y;
}
```

* 块级语句 
```
{
	var x = 1;
	var y = 2;
	print x+y;
}
```

### 4. 函数
```
fun sayHello(name) {
	print "Hello, My name is ${name}"
}
sayHello("Tom");
```

### 5. 类定义
```
class Person {
	sayHello() {
		print "hello, my name is ${name} and age is ${age}";
	}
}

class Student extends Person {
	study() {
		print "studying...";
	}
}
var p = Student();
p.name = "Tom";
p.age = 20;
p.sayHello();
p.study();
```