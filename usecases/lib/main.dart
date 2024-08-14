import 'package:flutter/material.dart';
import 'package:dax/dax.dart';
import 'package:usecases/base.dart';
import 'package:usecases/icon.dart';
import 'package:usecases/common.dart';
import 'package:usecases/decoration.dart';
import 'package:usecases/edgeinsets.dart';
import 'package:usecases/widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
              elevation: 3,
              centerTitle: true,
              color: Colors.white,
              foregroundColor: Colors.black87)),
      home: const MyHomePage(title: 'Dax Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool loaded = false;
  final Interpreter interpreter = Interpreter();
  late Widget renderedWidget;

  @override
  void initState() {
    super.initState();
    registerGlobalFunctions();
    Scanner scanner = Scanner('''
  var i = 0;
  var arr = [{"x":1}, {"x":2}, {"x":3}];
  var radius = 5;
  fun increase(){
     i = i + 1;
     update();
  }

  fun switchRadius() {
    radius = radius + 3;
    update();
  }

  fun item(i) {
    return Text("位置: \${i["x"]}", 
      style: TextStyle(
        color: Colors.blue, 
        fontSize: 20
      )
    );
  }

  fun mp(i) {
    return i.x;
  }

  fun getItems() {
    var i = 0;
    var items = [];
    while(i < 20) {
      items.add(i) ;
      i = i + 1;
    }
    return items; 
  }


  fun build() {
    return Expanded(
      child: Column(
        children: [
          Column(children: [
            Text("Hello, world!", 
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30.0
              )
            ) 
          ]),
          Column(children : []),
          Column(
            children: arr.map(item)
          ),
          Text("You are my hero: " + str(i)),
          TextButton(
            child:Text("click me"), 
            onPressed: increase
          ),
          TextButton(
            child:Text("switch radius"), 
            onPressed: () {
              radius = radius + 3;
              update();
            } 
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            margin: EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.blue,
              border: Border.all(
                width: 2,
                color: Colors.blue
              ),
              gradient: LinearGradient(
                colors: [Color(0xff66bb6a), Color(0xff43a047)],
                begin: Alignment(-1, -1),
                end: Alignment(1,1)
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0xff66bb6a),
                  offset: Offset(2, 2),
                  blurRadius: 5.0,
                  spreadRadius: 1.0
                )
              ],
              borderRadius: BorderRadius.vertical(top: Radius.circular(radius))
            ),
            child: Text("This is a container", 
              style: TextStyle(
                fontSize: 20, 
                color: Color(0xff66bb6a)
              )
            )
          ),
          Expanded( 
            child: ListView(
              children: getItems().map((i){ 
                return Text("位置: \${i}", 
                  style: TextStyle(fontSize: 20, color: Colors.cyan)
                ); 
              })
            ) 
          )
        ]
      )
    );
  }

  // fun build() {
  //   return Expanded(
  //     child: Text("Hello world", style: TextStyle(fontSize: 20))
  //   );
  // }

  build();
''');

    List<Token> tokens = scanner.scanTokens();
    Parser parser = Parser(tokens);
    List<Stmt> statements = parser.parse();
    Resolver resolver = Resolver(interpreter);
    resolver.resolve(statements);
    interpreter.interpret(statements);
    renderedWidget = interpreter.getRenderedWidget() as Widget;
  }

  void updateUI() {
    final renderResult = interpreter.invokeFunction('build');
    setState(() {
      renderedWidget = renderResult as Widget;
    });
  }

  Object? parseArguments(List<Object?> arguments, String name) {
    for (Object? argument in arguments) {
      if (argument is Map && argument.containsKey(name)) {
        return argument[name];
      }
    }
    // throw "Argument not found: $name";
    return null;
  }

  void registerGlobalFunctions() {
    interpreter.registerGlobal("Colors", colorMap);
    interpreter.registerGlobal("FontWeight", fontWeightMap);
    interpreter.registerGlobal("EdgeInsets", edgeInsetsMap);
    interpreter.registerGlobal("Icons", iconMap);
    interpreter.registerGlobal("Border", borderMap);
    interpreter.registerGlobal("BorderRadius", borderRadiusMap);
    interpreter.registerGlobal("Radius", radiusMap);
    interpreter.registerGlobal("Offset", IOffset());
    interpreter.registerGlobal("Alignment", IAlignment());
    interpreter.registerGlobal("Color", IColor());
    interpreter.registerGlobal("Expanded", IExpanded());
    interpreter.registerGlobal("TextStyle", ITextStyle());
    interpreter.registerGlobal("Text", IText());
    interpreter.registerGlobal("Column", IColumn());
    interpreter.registerGlobal("ListView", IListView());
    interpreter.registerGlobal("TextButton", ITextButton());
    interpreter.registerGlobal("LinearGradient", ILinearGradient());
    interpreter.registerGlobal("Container", IContainer());
    interpreter.registerGlobal("BoxShadow", IBoxShadow());
    interpreter.registerGlobal("BoxDecoration", IBoxDecoration());
    interpreter.registerGlobal(
        "update",
        GenericLoxCallable(() => 0,
            (Interpreter interpreter, List<Object?> arguments) {
          updateUI();
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            renderedWidget,
          ],
        ),
      ),
    );
  }
}
