import 'package:dax/runtime_error.dart';
import 'package:flutter/material.dart';
import 'package:dax/dax.dart';
import 'package:usecases/color_map.dart';
import 'package:usecases/fontweight_map.dart';

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
        primarySwatch: Colors.blue,
      ),
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

  fun increase(){
     i = i + 1;
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
    // interpreter.registerFunction("TextStyle", function);
    interpreter.registerGlobal("Colors", colorMap);
    interpreter.registerGlobal("FontWeight", fontWeightMap);
    interpreter.registerGlobal(
      "Expanded",
      GenericLoxCallable(() => 1,
          (Interpreter interpreter, List<Object?> arguments) {
        return Expanded(
          child: parseArguments(arguments, 'child') as Widget,
        );
      }),
    );
    interpreter.registerGlobal(
      "TextStyle",
      GenericLoxCallable(() => 1,
          (Interpreter interpreter, List<Object?> arguments) {
        double? fontSize;
        var sizeParsed = parseArguments(arguments, 'fontSize');
        if (sizeParsed != null) {
          if (sizeParsed is int) {
            fontSize = sizeParsed.toDouble();
          } else if (sizeParsed is double) {
            fontSize = sizeParsed;
          }
        }
        Color? color;
        var colorParsed = parseArguments(arguments, 'color');
        if (colorParsed != null) {
          color = colorParsed as Color;
        }
        FontWeight? fontWeight;
        var fontWeightParsed = parseArguments(arguments, 'fontWeight');
        if (fontWeightParsed != null) {
          fontWeight = fontWeightParsed as FontWeight;
        }
        return TextStyle(
            fontWeight: fontWeight, fontSize: fontSize, color: color);
      }),
    );
    interpreter.registerGlobal(
      "Text",
      GenericLoxCallable(() => 1,
          (Interpreter interpreter, List<Object?> arguments) {
        TextStyle? style;
        var styleParsed = parseArguments(arguments, 'style');
        if (styleParsed != null) {
          style = styleParsed as TextStyle;
        }
        return Text(
          arguments.first as String,
          style: style,
        );
      }),
    );
    interpreter.registerGlobal(
      "Column",
      GenericLoxCallable(() => 1,
          (Interpreter interpreter, List<Object?> arguments) {
        var childrenParsed = parseArguments(arguments, 'children');
        if (childrenParsed == null) {
          throw "Argument not found: children";
        }
        List<Widget> children = (childrenParsed as List).cast<Widget>();
        return Column(children: children);
      }),
    );
    interpreter.registerGlobal(
      "ListView",
      GenericLoxCallable(() => 1,
          (Interpreter interpreter, List<Object?> arguments) {
        var childrenParsed = parseArguments(arguments, 'children');
        if (childrenParsed == null) {
          throw "Argument not found: children";
        }
        List<Widget> children = (childrenParsed as List).cast<Widget>();
        return ListView(children: children);
      }),
    );
    interpreter.registerGlobal(
        "TextButton",
        GenericLoxCallable(() => 2,
            (Interpreter interpreter, List<Object?> arguments) {
          return TextButton(
              child: parseArguments(arguments, 'child') as Widget,
              onPressed: () {
                (parseArguments(arguments, 'onPressed') as LoxFunction)
                    .call(interpreter, arguments);
              });
        }));
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
