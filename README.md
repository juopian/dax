这是一个基于AST语法树的解析器，名字暂时叫dax，运行以下语句进入控制台体验语法特性：

`dart run bin/lox.dart`


也可以指定某个文件作为解析内容：
`dart run bin/lox.dart demo/fun.dax`

目前支持基本数据类型：

* 整数
* 浮点
* 布尔
* 字符串
* 数组
* 字典 
* 空


基本使用场景：

```
var n = nil;  // 空
var i = 1; 
var b = true; 
i = 2; // 赋值
print 2 * (3+2) ;  // 括号表达式
var s = "this is string";  // 采用双引号
var s1 = 'this is string'; // 采用单引号
var s2 = "1+2 = ${1+2}" ; // 字符串解析
var arr = [1,2,3];
print arr[1] ;  // 根据数组下标获取内容
var dict = {"x": 1};
print dict["x"];  // 获取字典某个key对应的内容
print dict.x; // 效果同上
var arrDict = [{"x": 1}, {"x": 2}];
fun add(x, y) { // 定义函数
	return x+y;
}
add(1,2);  //调用函数

var anony = (i) { return i*i; };  // 定义匿名函数
print anony(2); // 打印出4

var mp = arr.map((i) {return i*i}) ;  // map 运算
var mp1 = arr.map(anony); // 使用匿名函数变量

if (!(2<1)) {
	print "2>1";   // 条件判断
}

if ( 2>1 && 2<3) { // 逻辑运算
	print "2 between 1 and 3";
}

var loaded = false;
var text = loaded ? "loading": "loaded";  // 三目运算

var n = 1;
while( n < 10) { // while 循环
	print n;
	n = n+1;
}

for (var i = 0; i< 10 ; i=i+1){ // for 循环
	print i;
}

Api.get(url).then((value){ print value; }) // 发起网络请求

或采用匿名函数
var doSomething1 = (value){ ... };
var doSomething2 = (value){ ... };
Api.get(url, {debug: true}).then(doSomething1).then(doSomething2);

```


