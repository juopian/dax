import 'interpreter.dart';

abstract class LoxCallable {
  int arity();
  Object? call(Interpreter interpreter, List<Object?> arguments, Map<Symbol, Object?> namedArguments);
}
