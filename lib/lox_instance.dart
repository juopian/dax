import 'lox_class.dart';
import 'lox_function.dart';
import 'runtime_error.dart';
import 'token.dart';

class LoxInstance {
  final LoxClass klass;
  final Map<String, Object?> fields = {};
  LoxInstance(this.klass);

  Object? get(Token name) {
    if (fields.containsKey(name.lexeme)) {
      return fields[name.lexeme];
    }
    LoxFunction? method = klass.findMethod(name.lexeme);
    if (method != null) {
      return method.bind(this);
    }
    throw RuntimeError(name, "Undefined property '" + name.lexeme + "'.");
  }

  void set(Token name, Object? value) {
    fields[name.lexeme] = value;
  }

  @override
  String toString() {
    return klass.name + " instance";
  }
}
