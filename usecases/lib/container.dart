
import 'package:dax/dax.dart';
import 'package:flutter/material.dart';
import 'package:usecases/utils.dart';


class IScaffold implements LoxCallable {
  @override
  Object? call(Interpreter interpreter, List<Object?> arguments,
      Map<Symbol, Object?> namedArguments) {
    Widget? body;
    var bodyParsed = namedArguments[const Symbol('body')];
    if (bodyParsed != null) {
      body = bodyParsed as Widget;
    }
    PreferredSizeWidget? appBar;
    var appBarParsed = namedArguments[const Symbol('appBar')];
    if (appBarParsed != null) {
      appBar = appBarParsed as PreferredSizeWidget;
    }
    return Scaffold(
      appBar: appBar,
      body: body,
    );
  }

  @override
  int arity() {
    return 1;
  }
}

class IAppBar implements LoxCallable {
  @override
  Object? call(Interpreter interpreter, List<Object?> arguments,
      Map<Symbol, Object?> namedArguments) {
    var title = namedArguments[const Symbol('title')];
    if (title == null) {
      throw "title required in AppBar";
    }
    List<Widget> actions = [];
    var actionsParsed = namedArguments[const Symbol('actions')];
    if (actionsParsed != null) {
      actions = (actionsParsed as List).cast<Widget>();
    }
    return AppBar(
      title: title as Widget,
      actions: actions,
    );
  }

  @override
  int arity() {
    return 1;
  }
}



class IContainer implements LoxCallable {
  @override
  Object? call(Interpreter interpreter, List<Object?> arguments,
      Map<Symbol, Object?> namedArguments) {
    EdgeInsetsGeometry? margin;
    EdgeInsetsGeometry? padding;
    Decoration? decoration;
    Color? color;
    Widget? child;
    var marginParsed = namedArguments[const Symbol('margin')];
    if (marginParsed != null) {
      margin = marginParsed as EdgeInsetsGeometry;
    }
    var colorParsed = namedArguments[const Symbol('color')];
    if (colorParsed != null) {
      color = colorParsed as Color;
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
    double? width = parseDouble(namedArguments[const Symbol('width')]);
    double? height = parseDouble(namedArguments[const Symbol('height')]);
    return Container(
        margin: margin,
        padding: padding,
        decoration: decoration,
        child: child,
        color: color,
        height: height,
        width: width);
  }

  @override
  int arity() {
    return 1;
  }
}
