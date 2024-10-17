import 'dart:io';
import 'package:http/http.dart' as http;
import 'interpreter.dart';
import 'token.dart';

class LoxReader {
  String pathOrUrl;
  String? jwt;
  LoxReader(this.pathOrUrl, {this.jwt});

  set path(String path) => pathOrUrl = path;

  Future<String> read() {
    if (pathOrUrl.startsWith("http")) {
      Map<String, String>? headers;
      if (jwt != null) {
        headers = {'Authorization': 'Bearer $jwt'};
      }
      return http.get(Uri.parse(pathOrUrl), headers: headers).then((s) {
        return s.body;
      });
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
