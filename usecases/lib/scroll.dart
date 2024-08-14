import 'package:dax/dax.dart';
import 'package:flutter/material.dart';
import 'package:usecases/utils.dart';


class IListView implements LoxCallable {
  @override
  Object? call(Interpreter interpreter, List<Object?> arguments,
      Map<Symbol, Object?> namedArguments) {
    var childrenParsed = namedArguments[const Symbol('children')];
    if (childrenParsed == null) {
      throw "children required in ListView";
    }
    List<Widget> children = (childrenParsed as List).cast<Widget>();
    return ListView(children: children);
  }

  @override
  int arity() {
    return 1;
  }
}
