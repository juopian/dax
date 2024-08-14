import 'package:dax/dax.dart';
import 'package:flutter/material.dart';
import 'package:usecases/utils.dart';

class IExpanded implements LoxCallable {
  @override
  Object? call(Interpreter interpreter, List<Object?> arguments,
      Map<Symbol, Object?> namedArguments) {
    var child = namedArguments[const Symbol('child')];
    if (child == null) {
      throw "child required in Expanded";
    }
    int flex = 1;
    var flexParsed = namedArguments[const Symbol('flex')];
    if (flexParsed != null) {
      flex = flexParsed as int;
    }
    return Expanded(
      flex: flex,
      child: child as Widget,
    );
  }

  @override
  int arity() {
    return 1;
  }
}

class IRow implements LoxCallable {
  @override
  Object? call(Interpreter interpreter, List<Object?> arguments,
      Map<Symbol, Object?> namedArguments) {
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start;
    var mainAxisAlignmentParsed =
        namedArguments[const Symbol('mainAxisAlignment')];
    if (mainAxisAlignmentParsed != null) {
      mainAxisAlignment = mainAxisAlignmentParsed as MainAxisAlignment;
    }
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center;
    var crossAxisAlignmentParsed =
        namedArguments[const Symbol('crossAxisAlignment')];
    if (crossAxisAlignmentParsed != null) {
      crossAxisAlignment = crossAxisAlignmentParsed as CrossAxisAlignment;
    }
    var childrenParsed = namedArguments[const Symbol('children')];
    if (childrenParsed == null) {
      throw "children required in Row";
    }
    List<Widget> children = (childrenParsed as List).cast<Widget>();
    return Row(
        children: children,
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment);
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
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start;
    var mainAxisAlignmentParsed =
        namedArguments[const Symbol('mainAxisAlignment')];
    if (mainAxisAlignmentParsed != null) {
      mainAxisAlignment = mainAxisAlignmentParsed as MainAxisAlignment;
    }
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center;
    var crossAxisAlignmentParsed =
        namedArguments[const Symbol('crossAxisAlignment')];
    if (crossAxisAlignmentParsed != null) {
      crossAxisAlignment = crossAxisAlignmentParsed as CrossAxisAlignment;
    }
    var childrenParsed = namedArguments[const Symbol('children')];
    if (childrenParsed == null) {
      throw "children required in Column";
    }
    List<Widget> children = (childrenParsed as List).cast<Widget>();
    return Column(
      children: children,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
    );
  }

  @override
  int arity() {
    return 1;
  }
}


class ICenter implements LoxCallable {
  @override
  Object? call(Interpreter interpreter, List<Object?> arguments,
      Map<Symbol, Object?> namedArguments) {
    var child = namedArguments[const Symbol('child')];
    if (child == null) {
      throw "child required in Center";
    }
    double? heightFactor =
        parseDouble(namedArguments[const Symbol('heightFactor')]);
    double? widthFactor =
        parseDouble(namedArguments[const Symbol('widthFactor')]);
    return Center(
      child: child as Widget,
      heightFactor: heightFactor,
      widthFactor: widthFactor,
    );
  }

  @override
  int arity() {
    return 1;
  }
}


class IWrap implements LoxCallable {
  @override
  Object? call(Interpreter interpreter, List<Object?> arguments,
      Map<Symbol, Object?> namedArguments) {
    var childrenParsed = namedArguments[const Symbol('children')];
    if (childrenParsed == null) {
      throw "children required in Wrap";
    }
    List<Widget> children = (childrenParsed as List).cast<Widget>();
    return Wrap(
      children: children,
    );
  }

  @override
  int arity() {
    return 1;
  }
}