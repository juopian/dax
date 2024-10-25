import 'runtime_error.dart';
import 'token.dart';

class Environment {
  final Environment? enclosing;
  final Map<String, Object?> values = {};

  Environment(this.enclosing);

  Object? get(Token name) {
    if (values.containsKey(name.lexeme)) {
      return values[name.lexeme];
    }
    if (enclosing != null) {
      return enclosing!.get(name);
    }

    throw RuntimeError(name, "Undefined variable '${name.lexeme}'.");
  }

  Object? getAt(int distance, String name) {
    Map<String, Object?> values = ancestor(distance).values;
    if (values.containsKey(name)) {
      return values[name];
    }
  }

  void assignAt(int distance, Token name, Object? value) {
    ancestor(distance).values[name.lexeme] = value;
  }

  void assign(Token name, Object? value) {
    if (values.containsKey(name.lexeme)) {
      values[name.lexeme] = value;
      return;
    }
    if (enclosing != null) {
      enclosing!.assign(name, value);
      return;
    }
    throw RuntimeError(name, "Undefined variable '" + name.lexeme + "'.");
  }

  void define(String name, Object? value) {
    values[name] = value;
  }

  int length(){
    var i = 0;
    Environment environment = this;
    while(environment.enclosing != null) {
      environment = environment.enclosing!; 
      i++;
    }
    return i;
  }

  Environment ancestor(int distance) {
    Environment environment = this;
    for (int i = 0; i < distance; i++) {
      environment = environment.enclosing!;
    }
    return environment;
  }
}
