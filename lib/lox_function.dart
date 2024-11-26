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
    Environment environment = Environment(closure);
    for (int i = 0; i < declaration.params.length; i++) {
      environment.define(declaration.params[i].lexeme, arguments[i]);
    }
    for (var key in declaration.namedParams.keys) {
      if (namedArguments[Symbol(key.lexeme)] != null) {
        environment.define(key.lexeme, namedArguments[Symbol(key.lexeme)]);
      } else {
        environment.define(key.lexeme, declaration.namedParams[key]);
      }
    }
    try {
      interpreter.executeBlock(declaration.body, environment);
    } on ReturnException catch (returnValue) {
      if (isInitializer) {
        return closure.getAt(0, "this");
      }
      return returnValue.value;
    } on RuntimeError catch (error) {
      runtimeError(error);
      rethrow;
    }
    if (isInitializer) {
      return closure.getAt(0, "this");
    }
    return null;
  }

  @override
  String toString() => "<fn ${declaration.name.lexeme}>";
}
