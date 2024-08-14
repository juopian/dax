import 'package:flutter/material.dart';
import 'package:dax/dax.dart';
import 'package:flutter/services.dart';
import 'package:usecases/base.dart';
import 'package:usecases/icon.dart';
import 'package:usecases/common.dart';
import 'package:usecases/basic.dart';
import 'package:usecases/decoration.dart';
import 'package:usecases/edgeinsets.dart';
import 'package:usecases/layout.dart';
import 'package:usecases/scroll.dart';
import 'package:usecases/container.dart';

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
  var isChecked = true;
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
    return Scaffold(
      appBar: AppBar(
        title: Text("title"),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.cyan),
            onPressed: switchRadius
          ),
          IconButton(
            icon: Icon(Icons.history),
            onPressed: (){} 
          )
        ]
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Hello world!", 
            style: TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold)
          ),
          Column(
            children: arr.map(item)
          ),
          Text("You are my hero: " + str(i)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
              child:Text("click me"), 
              onPressed: increase
            ),
            OutlinedButton(
              child:Text("click me"), 
              onPressed: increase
            ), 
            ElevatedButton(
              child:Text("click me"), 
              onPressed: increase
            )]
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
          Image(
            height: 60,
            image: NetworkImage("https://avatars2.githubusercontent.com/u/20411648?s=460&v=4")
          ),
          Row(
            children: [
              CircularProgressIndicator(),
              Checkbox(
                value: isChecked,
                onChanged: (value) {
                  isChecked = value;
                  update();
                }
              )
            ]
          ),
          TextField(
            maxLines: 1,
            style: TextStyle(fontSize: 20),
            onChanged: (value) {
              print value;
            },
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(10),
              prefixIcon: Icon(Icons.star),
              enabledBorder: OutlineInputBorder(
                 borderRadius: BorderRadius.circular(1),
                 borderSide: BorderSide(
                    color: Colors.blue
                 )
              ),
              focusedBorder: OutlineInputBorder(
                 borderRadius: BorderRadius.circular(10),
                 borderSide: BorderSide(
                    color: Colors.red
                 )
              )
            )),
          Row(
            children: [
              Expanded(
                child: Container(height: 20, color: Colors.red)
              ),
              Expanded(
                flex:2,
                child: Container(height: 20, color: Colors.green)
              )
            ]
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
    interpreter.registerGlobal("MainAxisAlignment", mainAxisAlignmentMap);
    interpreter.registerGlobal("CrossAxisAlignment", crossAxisAlignmentMap);
    interpreter.registerGlobal("TextAlign", textAlignMap);
    interpreter.registerGlobal("BoxFit", boxFitMap);
    interpreter.registerGlobal("Radius", radiusMap);
    interpreter.registerGlobal("TextInputType", textInputTypeMap);
    interpreter.registerGlobal("BorderStyle", borderStyleMap);
    interpreter.registerGlobal("Offset", IOffset());
    interpreter.registerGlobal("Image", IImage());
    interpreter.registerGlobal("AssetImage", IAssetImage());
    interpreter.registerGlobal("NetworkImage", INetworkImage());
    interpreter.registerGlobal("Alignment", IAlignment());
    interpreter.registerGlobal("Color", IColor());
    interpreter.registerGlobal("Expanded", IExpanded());
    interpreter.registerGlobal("TextStyle", ITextStyle());
    interpreter.registerGlobal("Text", IText());
    interpreter.registerGlobal("Row", IRow());
    interpreter.registerGlobal("Column", IColumn());
    interpreter.registerGlobal("ListView", IListView());
    interpreter.registerGlobal("TextButton", ITextButton());
    interpreter.registerGlobal("BorderSide", IBorderSide());
    interpreter.registerGlobal("ElevatedButton", IElevatedButton());
    interpreter.registerGlobal("OutlinedButton", IOutlinedButton());
    interpreter.registerGlobal("LinearGradient", ILinearGradient());
    interpreter.registerGlobal("CircularProgressIndicator", ICircularProgressIndicator());
    interpreter.registerGlobal("Container", IContainer());
    interpreter.registerGlobal("BoxShadow", IBoxShadow());
    interpreter.registerGlobal("InputDecoration", IInputDecoration());
    interpreter.registerGlobal("UnderlineInputBorder", IUnderlineInputBorder());
    interpreter.registerGlobal("OutlineInputBorder", IOutlineInputBorder());
    interpreter.registerGlobal("Icon", IIcon());
    interpreter.registerGlobal("IconButton", IIconButton());
    interpreter.registerGlobal("Checkbox", ICheckbox());
    interpreter.registerGlobal("TextField", ITextField());
    interpreter.registerGlobal("AppBar", IAppBar());
    interpreter.registerGlobal("Scaffold", IScaffold());
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
    return renderedWidget;
    // return Scaffold(
    //   appBar: AppBar(
    //     title: Text(widget.title),
    //   ),
    //   body: Center(
    //     child: Column(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: <Widget>[
    //         renderedWidget,
    //       ],
    //     ),
    //   ),
    // );
  }
}
