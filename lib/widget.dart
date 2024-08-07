import 'lox_function.dart';
// import 'package:flutter/material.dart';

import 'interpreter.dart';
import 'lox_callable.dart';

class StringFunction implements LoxCallable {
  @override
  int arity() {
    return 1;
  }

  @override
  Object? call(Interpreter interpreter, List<Object?> arguments) {
    return '${arguments.first}';
  }
}

// class TextFunction implements LoxCallable {
//   @override
//   int arity() {
//     return 1;
//   }

//   @override
//   Object? call(Interpreter interpreter, List<Object?> arguments) {
//     return Text('${arguments.first}');
//   }
// }

// class ColumnFunction implements LoxCallable {
//   @override
//   int arity() {
//     return 2;
//   }

//   @override
//   Object? call(Interpreter interpreter, List<Object?> arguments) {
//     return Column(children: arguments.cast<Widget>());}
// }

// class TextButtonFunction implements LoxCallable {
//   @override
//   int arity() {
//     return 2;
//   }

//   @override
//   Object? call(Interpreter interpreter, List<Object?> arguments) {
//     return TextButton(
//         child: arguments.first as Widget,
//         onPressed: () {
//           (arguments.last as LoxFunction).call(interpreter, arguments);
//           // setState(() { });
//         });
//   }
// }

class GenericLoxCallable implements LoxCallable {
  final int Function() _arity;
  final Object? Function(Interpreter, List<Object?>) _call;

  GenericLoxCallable(this._arity, this._call);

  @override
  int arity() => _arity();

  @override
  Object? call(Interpreter interpreter, List<Object?> arguments) =>
      _call(interpreter, arguments);
}
