import 'interpreter.dart';
import 'token.dart';

abstract class LoxCallable {
  int arity();
  Object? call(Interpreter interpreter, List<Object?> arguments, Map<Symbol, Object?> namedArguments);
}


abstract class LoxGetCallable {
  Object? get(Token name);
}

abstract class LoxSetCallable {
  void set(Token name, Object? value);
}