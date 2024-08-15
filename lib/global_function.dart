import 'interpreter.dart';
import 'lox_callable.dart';

class ClockFunction implements LoxCallable {
  @override
  int arity() {
    return 0;
  }

  @override
  Object? call(Interpreter interpreter, List<Object?> arguments,
      Map<Symbol, Object?> namedArguments) {
    return DateTime.now().millisecondsSinceEpoch / 1000.0;
  }

  @override
  String toString() {
    return "<native fn>";
  }
}

class StringFunction implements LoxCallable {
  @override
  int arity() {
    return 1;
  }

  @override
  Object? call(Interpreter interpreter, List<Object?> arguments,
      Map<Symbol, Object?> namedArguments) {
    return '${arguments.first}';
  }
}

class GenericLoxCallable implements LoxCallable {
  final int Function() _arity;
  final Object? Function(
      Interpreter, List<Object?>, Map<Symbol, Object?> namedArguments) _call;

  GenericLoxCallable(this._arity, this._call);

  @override
  int arity() => _arity();

  @override
  Object? call(Interpreter interpreter, List<Object?> arguments,
          Map<Symbol, Object?> namedArguments) =>
      _call(interpreter, arguments, namedArguments);
}
