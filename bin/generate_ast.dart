import 'dart:io';

void main(List<String> args) {
  exitCode = 0;
  if (args.length != 1) {
    print("Usage: generate_ast <outout directory>");
    exitCode = 2;
    return;
  }
  String outputDir = args[0];
  defineAst(outputDir, "Expr", [
    "Assign   : Token name, Expr value",
    "Binary   : Expr left, Token operator, Expr right",
    "Call     : Expr callee, Token paren, List<Expr> arguments",
    "Array    : List<Expr> elements",
    "Dict     : Map<String,Expr> entries",
    "Then     : Expr future, Token name, Object then",
    "Conditional: Expr condition, Expr thenBranch, Expr elseBranch",
    "Arrayif  : Expr condition, Expr thenBranch, Expr? elseBranch",
    "Anonymous: Token name, List<Token> params, List<Stmt> body",
    "Mapping  : Expr callee, Token name, Object lambda",
    "Indexing : Expr callee, Token name, Expr key",
    "Await    : Token name, Expr future",
    "Get      : Expr object, Token name",
    "Grouping : Expr expression",
    "Literal  : Object? value",
    "Logical  : Expr left, Token operator, Expr right",
    "Set      : Expr object, Token name, Expr value",
    "Super    : Token keyword, Token method",
    "This     : Token keyword",
    "Unary    : Token operator, Expr right",
    "Variable : Token name"
  ]);

  defineAst(outputDir, "Stmt", [
    "Block      : List<Stmt> statements",
    "Class      : Token name, Variable? superclass, List<Functional> methods",
    "Expression : Expr expression",
    "Functional : Token name, bool isAsync, List<Token> params, List<Stmt> body",
    "If         : Expr condition, Stmt thenBranch, Stmt? elseBranch",
    "Print      : Expr expression",
    "Return     : Token keyword, Expr? value",
    "Var        : Token name, Expr? initializer",
    "While      : Expr condition, Stmt body"
  ]);
}

void defineAst(String outputDir, String baseName, List<String> types) {
  String path = "$outputDir/${baseName.toLowerCase()}.dart";
  var file = File(path);
  var sink = file.openWrite();
  sink.writeln("import 'package:dax/token.dart';");
  if (baseName == 'Stmt') {
    sink.writeln("import 'package:dax/expr.dart';");
  } else {
    sink.writeln("import 'package:dax/stmt.dart';");
  }
  sink.writeln('''

abstract class $baseName {
  T accept<T>(Visitor<T> visitor);
}
''');
  for (String type in types) {
    String className = type.split(':')[0].trim();
    String fields = type.split(':')[1].trim();
    defineType(sink, baseName, className, fields);
  }

  defineVisitor(sink, baseName, types);
  sink.close();
}

void defineType(IOSink sink, String baseName, String className, String fields) {
  sink.writeln("class $className extends $baseName {");
  var fieldsSplit = fields.split(", ");
  for (var field in fieldsSplit) {
    sink.writeln("  final $field;");
  }
  sink.write("  $className(");
  for (var field in fieldsSplit) {
    var name = field.split(" ")[1];
    sink.write("this.$name, ");
  }
  sink.writeln(");");
  sink.writeln("  @override");
  sink.writeln(
      "  T accept<T>(Visitor<T> visitor) => visitor.visit$className$baseName(this);");
  sink.writeln("}\n");
}

void defineVisitor(IOSink sink, String baseName, List<String> types) {
  sink.writeln("abstract class Visitor<T> {");
  for (String type in types) {
    var className = type.split(':')[0].trim();
    sink.writeln(
        "  T visit$className$baseName($className ${baseName.toLowerCase()});");
  }
  sink.writeln("}");
}
