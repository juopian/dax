import 'dart:io';

void main(List<String> args) {
  exitCode = 0;
  if (args.length != 1) {
    print("Usage: generate_ast <outout directory>");
    exitCode = 64;
  }
  String outputDir = args[0];
  defineAst(outputDir, "Expr", [
    "Binary   : Expr left, Token operator, Expr right",
    "Grouping : Expr expression",
    "Literal  : Object value",
    "Unary    : Token operator, Expr right"
  ]);
}

void defineAst(String outputDir, String baseName, List<String> types) {
  String path = "$outputDir/${baseName.toLowerCase()}.dart";
  var file = File(path);
  var sink = file.openWrite();
  sink.writeln('''
import 'package:dax/token.dart';

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
  for (String type in types){
    var className = type.split(':')[0].trim();
    sink.writeln("  T visit$className$baseName($className ${baseName.toLowerCase()});");
  }
  sink.writeln("}");
}
