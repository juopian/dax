import 'interpreter.dart';
import 'token.dart';

abstract class LoxCallable {
  int arity();
  Object? call(Interpreter interpreter, List<Object?> arguments, Map<Symbol, Object?> namedArguments);
}


abstract class LoxNamedCallable {
  Object? get(Token name);
}