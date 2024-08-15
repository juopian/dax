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

class IAlignment implements LoxCallable, LoxGetCallable {

  @override
  Object? get(Token name) {
    switch (name.lexeme) {
      case 'topLeft':
        return Alignment.topLeft;
      case 'topCenter':
        return Alignment.topCenter;
      case 'topRight':
        return Alignment.topRight;
      case 'centerLeft':
        return Alignment.centerLeft;
      case 'center':
        return Alignment.center;
      case 'centerRight':
        return Alignment.centerRight;
      case 'bottomLeft':
        return Alignment.bottomLeft;
      case 'bottomCenter':
        return Alignment.bottomCenter;
      case 'bottomRight':
        return Alignment.bottomRight;
      default:
        return null;
    }
  }

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

class ITextEditingController implements LoxCallable{
  @override
  int arity() {
    return 0;
  }

  @override
  Object call(Interpreter interpreter, List<Object?> arguments,
      Map<Symbol, Object?> namedArguments) {
    return TextEditingControllerIns();
  }
}


class TextEditingControllerIns extends TextEditingController implements LoxSetCallable {
  @override
  Object? set(Token name, Object? value) {
    switch (name.lexeme) {
      case 'text':
        text = value as String;
        break;
    }
  }
}