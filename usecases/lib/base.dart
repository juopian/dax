import 'package:dax/dax.dart';
import 'package:dax/lox_callable.dart';
import 'package:flutter/material.dart';
import 'package:usecases/utils.dart';

class IOffset implements LoxCallable {
  @override
  int arity() {
    return 0;
  }

  @override
  Object call(Interpreter interpreter, List<Object?> arguments,
      Map<Symbol, Object?> namedArguments) {
    double dx = 0;
    double dy = 0;
    if (arguments.length == 2) {
      dx = parseDouble(arguments[0]) ?? 0;
      dy = parseDouble(arguments[1]) ?? 0;
    }
    return Offset(dx, dy);
  }
}

class IAlignment implements LoxCallable {


  @override
  int arity() {
    return 0;
  }
  
  @override
  Object call(Interpreter interpreter, List<Object?> arguments,
      Map<Symbol, Object?> namedArguments) {
    double x = 0;
    double y = 0;
    if (arguments.length == 2) {
      x = parseDouble(arguments[0]) ?? 0;
      y = parseDouble(arguments[1]) ?? 0;
    }
    return Alignment(x, y);
  }
}

class IColor implements LoxCallable {
  @override
  int arity() {
    return 0;
  }

  @override
  Object call(Interpreter interpreter, List<Object?> arguments,
      Map<Symbol, Object?> namedArguments) {
    return Color(arguments[0] as int);
  }
}

class IAssetImage implements LoxCallable {
  @override
  int arity() {
    return 0;
  }

  @override
  Object call(Interpreter interpreter, List<Object?> arguments,
      Map<Symbol, Object?> namedArguments) {
    return AssetImage(arguments[0] as String);
  }
}


class INetworkImage implements LoxCallable {
  @override
  int arity() {
    return 0;
  }

  @override
  Object call(Interpreter interpreter, List<Object?> arguments,
      Map<Symbol, Object?> namedArguments) {
    return NetworkImage(arguments[0] as String);
  }
}