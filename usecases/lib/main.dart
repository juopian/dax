import 'package:flutter/material.dart';
import 'package:dax/dax.dart';
import 'package:flutter/services.dart';
import 'package:usecases/base.dart';
import 'package:usecases/icon.dart';
import 'package:usecases/api.dart';
import 'package:usecases/common.dart';
import 'package:usecases/basic.dart';
import 'package:usecases/decoration.dart';
import 'package:usecases/edgeinsets.dart';
import 'package:usecases/layout.dart';
import 'package:usecases/scroll.dart';
import 'package:usecases/container.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
              backgroundColor: Colors.white,
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
  
  void loadData()async {
    var result = await Api.get('https://i-lambda.gzuni.com/sbox/com.test/fn/fn');
  }

  @override
  void initState() {
    super.initState();
    registerGlobalFunctions();
    Scanner scanner = Scanner('''
  var i = 0;
  var arr = [{"x":1}, {"x":2}];
  var radius = 5;
  var isChecked = true;
  var selectedIndex = 0;
  var textEditingController = TextEditingController();
  var textEditingController1 = TextEditingController();
  fun increase(){
     i = i + 1;
     update();
  }

  fun switchRadius() {
    radius = radius + 3;
    update();
  }

  fun item(i,) {
    return Text("位置: \${i["x"]}", 
      style: TextStyle(
        color: Colors.blue, 
        fontSize: 20
      )
    );
  }

  fun getData() {
    var result = [];
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

  fun loadData() async {
    var result = await Api.get("https://i-lambda.gzuni.com/sbox/com.test/fn/fn");
    print "result is \${result}";
  }

  fun initState() {
    loadData();
  }

  fun build() {
    return DefaultTabController(
    length: 3,
    child: Scaffold(
      appBar: AppBar(
        title: Text("title"),
        bottom: TabBar(
          labelColor: Colors.black,
          indicatorSize: TabBarIndicatorSize.label,
          indicatorColor: Colors.red,
          tabs: [
            Tab(text: "Home"),
            Tab(text: "User"),
            Tab(text: "More"),
          ] 
        ),
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
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(backgroundColor: Colors.red, icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(backgroundColor: Colors.red, icon: Icon(Icons.business), label: "Business"),
          BottomNavigationBarItem(backgroundColor: Colors.red, icon: Icon(Icons.school), label: "School"),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: Colors.green,
        onTap: (i){
          print "click \${i}";
          selectedIndex = i;
          update();
        },
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          mini: true,
          onPressed: (){
            print "click";
          }
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
              child:Text("btn1"), 
              onPressed: (){
                print getDeviceWidth();
              } 
            ),
            OutlinedButton(
              child:Text("btn2"), 
              onPressed: (){
                showSnackBar(SnackBar(
                  width: 100,
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  content: Text("snackbar")));
              } 
            ), 
            OutlinedButton(
              child:Text("btn3"), 
              onPressed: (){
                showModalBottomSheet(
                  context: context, 
                  isDismissible: false,
                  builder: (context){
                  return Container(
                    child: Column(
                      children: [
                        Text("Sheet"),
                        TextButton(
                          child: Text("Close"),
                          onPressed: () {
                            Navigator.pop(context);
                          }
                        ) 
                      ]
                    ),
                    height: 100,
                  );
                });
              } 
            ), 
             OutlinedButton(
              child:Text("btn4"), 
              onPressed: (){
                showDialog(
                  context: context, 
                  barrierDismissible: false,
                  builder: (context){
                  return AlertDialog(
                    title:  Text("Basic dialog title"),
                    content: Text("This is my content"),
                    actions: [
                      TextButton(
                        child: Text("Close"),
                        onPressed: () {
                          Navigator.pop(context);
                        }
                      )
                    ] 
                  );
                });
              } 
            ), 
            ElevatedButton(
              child:Text("btn5"), 
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
            margin: EdgeInsets.all(2.0),
            decoration: BoxDecoration(
              color: Colors.blue,
              border: Border.all(
                width: 2,
                color: Colors.blue
              ),
              gradient: LinearGradient(
                colors: [Color(0xff66bb6a), Color(0xff43a047)],
                begin: Alignment.centerLeft,
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
            transform: Matrix4.rotationZ(0.2),
            child: Text("This is a container", 
              style: TextStyle(
                fontSize: 20, 
                color: Color(0xff66bb6a)
              )
            )
          ),
          Wrap(
            spacing: 10,
            children: [
              Align(child: Text("Hello world!")),
              Image(
                height: 60,
                image: NetworkImage("https://pics6.baidu.com/feed/a8ec8a13632762d0a458dd54b4ab71f4503dc648.jpeg@f_auto?token=4246c989393b6ad6b32441a482158ae8")
              ),
              Image(
                height: 60,
                image: NetworkImage("https://pics6.baidu.com/feed/a8ec8a13632762d0a458dd54b4ab71f4503dc648.jpeg@f_auto?token=4246c989393b6ad6b32441a482158ae8")
              ),
              Image(
                height: 60,
                image: NetworkImage("https://pics6.baidu.com/feed/a8ec8a13632762d0a458dd54b4ab71f4503dc648.jpeg@f_auto?token=4246c989393b6ad6b32441a482158ae8")
              ),
            ]
          ),
          Container(
            width: 200,
            height: 50,
            decoration: BoxDecoration(
              border: Border.all(
                width: 2,
                color: Colors.blue
              ) 
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Transform.rotate(
                      angle: 1.2,
                      child: Text("Hello world!")
                    )
                  )
                )
              ] 
            ),
          ),
          Row(
            children: [
              CircularProgressIndicator(color: Colors.red),
              CupertinoActivityIndicator(),
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
            controller: textEditingController,
            style: TextStyle(fontSize: 20),
            onChanged: (value) {
              print value;
            },
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(1),
              prefixIcon: Icon(Icons.star),
              suffixIcon: IconButton(
                icon: Icon(Icons.close, color: Colors.cyan),
                onPressed: (){
                  textEditingController.text = "";
                } 
              ),
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
            child: ListView.separated(
              itemCount: 10,
              separatorBuilder: (context, index) {
                if(index % 2 == 0) 
                  return Divider(color: Colors.red);
                 else 
                  return Divider(color: Colors.green);
              },
              itemBuilder: (context, index) {
                return Text("item \${index}");
              }
            )
          )
          // Expanded( 
          //   child: ListView(
          //     children: getItems().map((i){ 
          //       return Text("位置: \${i}", 
          //         style: TextStyle(fontSize: 20, color: Colors.cyan)
          //       ); 
          //     })
          //   ) 
          // )
        ]
      )
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
    interpreter.invokeFunction('initState');
    renderedWidget = interpreter.getRenderedWidget() as Widget;
  }

  void updateUI() {
    final renderResult = interpreter.invokeFunction('build');
    setState(() {
      renderedWidget = renderResult as Widget;
    });
  }

  void registerGlobalFunctions() {
    interpreter.registerGlobal("context", context);
    interpreter.registerGlobal("Colors", colorMap);
    interpreter.registerGlobal("FontWeight", fontWeightMap);
    interpreter.registerGlobal("EdgeInsets", edgeInsetsMap);
    interpreter.registerGlobal("Icons", iconMap);
    interpreter.registerGlobal("Border", borderMap);
    interpreter.registerGlobal("Navigator", navigatorMap);
    interpreter.registerGlobal("BorderRadius", borderRadiusMap);
    interpreter.registerGlobal("SnackBarBehavior", snackBarBehaviorMap);
    interpreter.registerGlobal("Transform", transformMap);
    interpreter.registerGlobal("Matrix4", matrix4Map);
    interpreter.registerGlobal("MainAxisAlignment", mainAxisAlignmentMap);
    interpreter.registerGlobal("CrossAxisAlignment", crossAxisAlignmentMap);
    interpreter.registerGlobal("TextAlign", textAlignMap);
    interpreter.registerGlobal("BoxFit", boxFitMap);
    interpreter.registerGlobal("Radius", radiusMap);
    interpreter.registerGlobal("Api", apiMap);
    interpreter.registerGlobal("TextInputType", textInputTypeMap);
    interpreter.registerGlobal("BorderStyle", borderStyleMap);
    interpreter.registerGlobal("AxisDirection", axisDirectionMap);
    interpreter.registerGlobal("WrapAlignment", wrapAlignmentMap);
    interpreter.registerGlobal("TextDirection", textDirectionMap);
    interpreter.registerGlobal("TabBarIndicatorSize", tabBarIndicatorSizeMap);
    interpreter.registerGlobal("StackFix", stackFitMap);
    interpreter.registerGlobal("Offset", IOffset());
    interpreter.registerGlobal("Image", IImage());
    interpreter.registerGlobal("AssetImage", IAssetImage());
    interpreter.registerGlobal("NetworkImage", INetworkImage());
    interpreter.registerGlobal("Alignment", IAlignment());
    interpreter.registerGlobal("Color", IColor());
    interpreter.registerGlobal("Expanded", IExpanded());
    interpreter.registerGlobal("Stack", IStack());
    interpreter.registerGlobal("Positioned", IPositioned());
    interpreter.registerGlobal("ClipOval", IClipOval());
    interpreter.registerGlobal("ClipRRect", IClipRRect());
    interpreter.registerGlobal("ClipRect", IClipRect());
    interpreter.registerGlobal("Align", IAlign());
    interpreter.registerGlobal("Wrap", IWrap());
    interpreter.registerGlobal("TextStyle", ITextStyle());
    interpreter.registerGlobal("Text", IText());
    interpreter.registerGlobal("Divider", IDivider());
    interpreter.registerGlobal("SnackBar", ISnackBar());
    interpreter.registerGlobal("Row", IRow());
    interpreter.registerGlobal("Column", IColumn());
    interpreter.registerGlobal("ListView", IListView());
    interpreter.registerGlobal(
        "SingleChildScrollView", ISingleChildScrollView());
    interpreter.registerGlobal("TextButton", ITextButton());
    interpreter.registerGlobal("BorderSide", IBorderSide());
    interpreter.registerGlobal("ElevatedButton", IElevatedButton());
    interpreter.registerGlobal("OutlinedButton", IOutlinedButton());
    interpreter.registerGlobal("LinearGradient", ILinearGradient());
    interpreter.registerGlobal("GestureDetector", IGestureDetector());
    interpreter.registerGlobal("AlertDialog", IAlertDialog());
    interpreter.registerGlobal(
        "TextEditingController", ITextEditingController());
    interpreter.registerGlobal(
        "CupertinoActivityIndicator", ICupertinoActivityIndicator());
    interpreter.registerGlobal(
        "CircularProgressIndicator", ICircularProgressIndicator());
    interpreter.registerGlobal("Container", IContainer());
    interpreter.registerGlobal("Padding", IPadding());
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
    interpreter.registerGlobal("TabBar", ITabBar());
    interpreter.registerGlobal("TabBarView", ITabBarView());
    interpreter.registerGlobal("DefaultTabController", IDefaultTabController());
    interpreter.registerGlobal("Tab", ITab());
    interpreter.registerGlobal("FloatingActionButton", IFloatingActionButton());
    interpreter.registerGlobal(
        "BottomNavigationBarItem", IBottomNavigationBarItem());
    interpreter.registerGlobal("BottomNavigationBar", IBottomNavigationBar());
    interpreter.registerGlobal("ListTile", IListTile());
    interpreter.registerGlobal("BoxDecoration", IBoxDecoration());
    interpreter.registerGlobal("showDialog", IShowDialog());
    interpreter.registerGlobal("showModalBottomSheet", IShowModalBottomSheet());
    interpreter.registerGlobal(
        "getDeviceWidth",
        GenericLoxCallable(() => 0, (Interpreter interpreter,
            List<Object?> arguments, Map<Symbol, Object?> namedArguments) {
          return MediaQuery.of(context).size.width;
        }));
    interpreter.registerGlobal(
        "showSnackBar",
        GenericLoxCallable(() => 1, (Interpreter interpreter,
            List<Object?> arguments, Map<Symbol, Object?> namedArguments) {
          ScaffoldMessenger.of(context).showSnackBar(arguments.first as SnackBar);
        }));
    interpreter.registerGlobal(
        "update",
        GenericLoxCallable(() => 0, (Interpreter interpreter,
            List<Object?> arguments, Map<Symbol, Object?> namedArguments) {
          updateUI();
        }));
    WidgetsBinding.instance!.addPostFrameCallback((_) {});
  }

  @override
  Widget build(BuildContext context) {
    return renderedWidget;
  }
}
