import 'package:dax/lox_instance.dart';

import 'environment.dart';
import 'interpreter.dart';
import 'lox_callable.dart';
import 'return.dart';
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
  Object? call(Interpreter interpreter, List<Object?> arguments) {
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
