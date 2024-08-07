import 'package:flutter/material.dart';
import 'package:dax/dax.dart';

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
  int _counter = 0;

  bool loaded = false;
  final Interpreter interpreter = Interpreter();
  late Widget renderedWidget;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  void initState() {
    super.initState();
    registerGlobalFunctions();
    Scanner scanner = Scanner('''
  print("Hello, World!");
  var i = 0;

  fun increase(){
     i = i + 1;
     update();
  }

  fun build() {
    return Column(Text("you are hero:" + String(i)),TextButton(Text("click me"), increase));
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

  void registerGlobalFunctions() {
    interpreter.registerFunction(
      "Text",
      GenericLoxCallable(() => 1,
          (Interpreter interpreter, List<Object?> arguments) {
        return Text(arguments.first as String);
      }),
    );
    interpreter.registerFunction(
      "Column",
      GenericLoxCallable(() => 2,
          (Interpreter interpreter, List<Object?> arguments) {
        return Column(children: arguments.cast<Widget>());
      }),
    );
    interpreter.registerFunction(
        "TextButton",
        GenericLoxCallable(() => 2,
            (Interpreter interpreter, List<Object?> arguments) {
          return TextButton(
              child: arguments.first as Widget,
              onPressed: () {
                (arguments.last as LoxFunction).call(interpreter, arguments);
              });
        }));
    interpreter.registerFunction(
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
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
