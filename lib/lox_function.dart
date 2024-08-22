import 'error.dart';
import 'lox_instance.dart';

import 'environment.dart';
import 'interpreter.dart';
import 'lox_callable.dart';
import 'return.dart';
import 'runtime_error.dart';
import 'stmt.dart';

class LoxFunction implements LoxCallable {
  final Functional declaration;
  final Environment closure;
  final bool isInitializer;
  LoxFunction(this.declaration, this.closure, this.isInitializer);

  LoxFunction bind(LoxInstance instance) {
    Environment environment = Environment(closure);
    environment.define("this", instance);
    return LoxFunction(declaration, environment, isInitializer);
  }

  @override
  int arity() => declaration.params.length;

  @override
  Object? call(Interpreter interpreter, List<Object?> arguments,
      Map<Symbol, Object?> namedArguments) {
    /*
      fun add(x, y) {
        return x + y;
      }
      add(1,2);
      add(x:1, y:2);
      add(y:1, x:2);
    */
    Environment environment = Environment(closure);
    for (int i = 0; i < declaration.params.length; i++) {
      environment.define(declaration.params[i].lexeme, arguments[i]);
    }

    try {
      interpreter.executeBlock(declaration.body, environment);
    } on ReturnException catch (returnValue) {
      if (isInitializer) {
        return closure.getAt(0, "this");
      }
      return returnValue.value;
    }
    if (isInitializer) {
      return closure.getAt(0, "this");
    }
    return null;
  }

  @override
  String toString() => "<fn ${declaration.name.lexeme}>";
}
