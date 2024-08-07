import 'interpreter.dart';

import 'lox_callable.dart';
import 'lox_function.dart';
import 'lox_instance.dart';

class LoxClass implements LoxCallable {
  final String name;
  final LoxClass? superclass;
  final Map<String, LoxFunction> methods;
  LoxClass(this.name, this.superclass, this.methods);

  LoxFunction? findMethod(String name) {
    if (methods.containsKey(name)) {
      return methods[name];
    }
    if (superclass != null) {
      return superclass!.findMethod(name);
    }
    return null;
  }

  @override
  String toString() {
    return name;
  }

  @override
  int arity() {
    LoxFunction? initializer = findMethod('init');
    if (initializer != null) {
      return initializer.arity();
    }
    return 0;
  }

  @override
  Object? call(Interpreter interpreter, List<Object?> arguments) {
    LoxInstance instance = LoxInstance(this);
    LoxFunction? initializer = findMethod('init');
    if (initializer != null) {
      initializer.bind(instance).call(interpreter, arguments);
    }
    return instance;
  }
}
