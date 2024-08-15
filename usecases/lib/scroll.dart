import 'package:dax/dax.dart';
import 'package:flutter/material.dart';
import 'package:usecases/utils.dart';

class IListView implements LoxCallable, LoxNamedCallable {
  final builder = ListViewBuilder();
  final separated = ListViewSeparated();
  @override
  Object? get(Token name) {
    if (name.lexeme == "builder") {
      return builder;
    } else if (name.lexeme == "separated") {
      return separated;
    }
    throw "Unknown property: ${name.lexeme}";
  }

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

class ListViewBuilder implements LoxCallable {
  @override
  Object? call(Interpreter interpreter, List<Object?> arguments,
      Map<Symbol, Object?> namedArguments) {
    double? itemExtent =
        parseDouble(namedArguments[const Symbol('itemExtent')]);
    bool reverse = false;
    var reverseParsed = namedArguments[const Symbol('reverse')];
    if (reverseParsed != null) {
      reverse = reverseParsed as bool;
    }
    int? itemCount;
    var itemCountParsed = namedArguments[const Symbol('itemCount')];
    if (itemCountParsed != null) {
      itemCount = itemCountParsed as int;
    }
    Widget? prototypeItem;
    var prototypeItemParsed = namedArguments[const Symbol('prototypeItem')];
    if (prototypeItemParsed != null) {
      prototypeItem = prototypeItemParsed as Widget;
    }
    bool shrinkWrap = false;
    var shrinkWrapParsed = namedArguments[const Symbol('shrinkWrap')];
    if (shrinkWrapParsed != null) {
      shrinkWrap = shrinkWrapParsed as bool;
    }
    bool? primary;
    var primaryParsed = namedArguments[const Symbol('primary')];
    if (primaryParsed != null) {
      primary = primaryParsed as bool;
    }
    EdgeInsetsGeometry? padding;
    var paddingParsed = namedArguments[const Symbol('padding')];
    if (paddingParsed != null) {
      padding = paddingParsed as EdgeInsetsGeometry;
    }
    var itemBuilder = namedArguments[const Symbol('itemBuilder')];
    if (itemBuilder == null) {
      throw "itemBuilder required in ListView.builder";
    }
    return ListView.builder(
      itemExtent: itemExtent,
      prototypeItem: prototypeItem,
      reverse: reverse,
      primary: primary,
      shrinkWrap: shrinkWrap,
      itemCount: itemCount,
      padding: padding,
      itemBuilder: (BuildContext context, int index) {
        return (itemBuilder as LoxCallable)
            .call(interpreter, [context, index], {}) as Widget;
      },
    );
  }

  @override
  int arity() {
    return 1;
  }
}

class ListViewSeparated implements LoxCallable {
  @override
  Object? call(Interpreter interpreter, List<Object?> arguments,
      Map<Symbol, Object?> namedArguments) {
    bool reverse = false;
    var reverseParsed = namedArguments[const Symbol('reverse')];
    if (reverseParsed != null) {
      reverse = reverseParsed as bool;
    }
    var itemCount = namedArguments[const Symbol('itemCount')];
    if (itemCount == null) {
      throw "itemCount required in ListView.separated";
    }
    bool shrinkWrap = false;
    var shrinkWrapParsed = namedArguments[const Symbol('shrinkWrap')];
    if (shrinkWrapParsed != null) {
      shrinkWrap = shrinkWrapParsed as bool;
    }
    bool? primary;
    var primaryParsed = namedArguments[const Symbol('primary')];
    if (primaryParsed != null) {
      primary = primaryParsed as bool;
    }
    EdgeInsetsGeometry? padding;
    var paddingParsed = namedArguments[const Symbol('padding')];
    if (paddingParsed != null) {
      padding = paddingParsed as EdgeInsetsGeometry;
    }
    var itemBuilder = namedArguments[const Symbol('itemBuilder')];
    if (itemBuilder == null) {
      throw "itemBuilder required in ListView.builder";
    }
    var separatorBuilder = namedArguments[const Symbol('separatorBuilder')];
    if (separatorBuilder == null) {
      throw "separatorBuilder required in ListView.separated";
    }
    return ListView.separated(
        reverse: reverse,
        primary: primary,
        padding: padding,
        shrinkWrap: shrinkWrap,
        itemCount: itemCount as int,
        itemBuilder: (BuildContext context, int index) {
          return (itemBuilder as LoxCallable)
              .call(interpreter, [context, index], {}) as Widget;
        },
        separatorBuilder: (BuildContext context, int index) {
          return (separatorBuilder as LoxCallable)
              .call(interpreter, [context, index], {}) as Widget;
        });
  }

  @override
  int arity() {
    return 1;
  }
}
