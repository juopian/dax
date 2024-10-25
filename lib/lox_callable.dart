import 'dart:io';
import 'package:http/http.dart' as http;
import 'interpreter.dart';
import 'token.dart';

class LoxReader {
  String pathOrUrl;
  LoxReader(this.pathOrUrl);

  set path(String path) => pathOrUrl = path;

  Future<String> read() async {
    if (pathOrUrl.startsWith("http")) {
      var response = await http.get(Uri.parse(pathOrUrl));
      return response.body;
    }
    return File(pathOrUrl).readAsString();
  }
}

abstract class LoxCallable {
  int arity();
  Object? call(Interpreter interpreter, List<Object?> arguments,
      Map<Symbol, Object?> namedArguments);
}

abstract class LoxGetCallable {
  Object? get(Token name);
}

abstract class LoxSetCallable {
  void set(Token name, Object? value);
}

abstract class DaxCallable {
  Object? call(Interpreter interpreter, List<Object?> arguments,
      Map<Symbol, Object?> namedArguments);
}
