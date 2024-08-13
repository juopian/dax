import 'package:dax/dax.dart';
import 'package:flutter/material.dart';

Object? parseArguments(List<Object?> arguments, String name) {
  for (Object? argument in arguments) {
    if (argument is Map && argument.containsKey(name)) {
      return argument[name];
    }
  }
  return null;
}

class IExpanded implements LoxCallable {
  @override
  Object? call(Interpreter interpreter, List<Object?> arguments,
      Map<Symbol, Object?> namedArguments) {
    var child = namedArguments[const Symbol('child')];
    if (child == null) {
      throw "child required in Expanded";
    }
    return Expanded(
      child: child as Widget,
    );
  }

  @override
  int arity() {
    return 1;
  }
}



class IText implements LoxCallable {
  @override
  Object? call(Interpreter interpreter, List<Object?> arguments,
      Map<Symbol, Object?> namedArguments) {
    TextStyle? style;
    var styleParsed = namedArguments[const Symbol('style')];
    if (styleParsed != null) {
      style = styleParsed as TextStyle;
    }
    return Text(
      arguments.first as String,
      style: style,
    );
  }

  @override
  int arity() {
    return 1;
  }
}

class IColumn implements LoxCallable {
  @override
  Object? call(Interpreter interpreter, List<Object?> arguments,
      Map<Symbol, Object?> namedArguments) {
    var childrenParsed = namedArguments[const Symbol('children')];
    if (childrenParsed == null) {
      throw "children required in Column";
    }
    List<Widget> children = (childrenParsed as List).cast<Widget>();
    return Column(children: children);
  }

  @override
  int arity() {
    return 1;
  }
}

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

class ITextButton implements LoxCallable {
  @override
  Object? call(Interpreter interpreter, List<Object?> arguments,
      Map<Symbol, Object?> namedArguments) {
    var child = namedArguments[const Symbol('child')];
    if (child == null) {
      throw "child required in TextButton";
    }
    var onPressed = namedArguments[const Symbol('onPressed')];
    if (onPressed == null) {
      throw "onPressed required in TextButton";
    }
    return TextButton(
        child: child as Widget,
        onPressed: () {
          (onPressed as LoxFunction)
              .call(interpreter, arguments, namedArguments);
        });
  }

  @override
  int arity() {
    return 2;
  }
}

class IContainer implements LoxCallable {
  @override
  Object? call(Interpreter interpreter, List<Object?> arguments,
      Map<Symbol, Object?> namedArguments) {
    EdgeInsetsGeometry? margin;
    EdgeInsetsGeometry? padding;
    Decoration? decoration;
    Widget? child;
    var marginParsed = namedArguments[const Symbol('margin')];
    if (marginParsed != null) {
      margin = marginParsed as EdgeInsetsGeometry;
    }
    var paddingParsed = namedArguments[const Symbol('padding')];
    if (paddingParsed != null) {
      padding = paddingParsed as EdgeInsetsGeometry;
    }
    var decorationParsed = namedArguments[const Symbol('decoration')];
    if (decorationParsed != null) {
      decoration = decorationParsed as Decoration;
    }
    var childParsed = namedArguments[const Symbol('child')];
    if (childParsed != null) {
      child = childParsed as Widget;
    }
    return Container(
      margin: margin,
      padding: padding,
      decoration: decoration,
      child: child,
    );
  }

  @override
  int arity() {
    return 1;
  }
}
