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
    Matrix4? transform;
    var transformParsed = namedArguments[const Symbol('transform')];
    if (transformParsed != null) {
      transform = transformParsed as Matrix4;
    }
    return Container(
        margin: margin,
        padding: padding,
        decoration: decoration,
        transform: transform,
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

class IPadding implements LoxCallable {
  @override
  Object? call(Interpreter interpreter, List<Object?> arguments,
      Map<Symbol, Object?> namedArguments) {
    var padding = namedArguments[const Symbol('padding')];
    if (padding == null) {
      throw "padding required in Padding";
    }
    Widget? child;
    var childParsed = namedArguments[const Symbol('child')];
    if (childParsed != null) {
      child = childParsed as Widget;
    }
    return Padding(
      padding: padding as EdgeInsetsGeometry,
      child: child,
    );
  }

  @override
  int arity() {
    return 1;
  }
}

class IClipOval implements LoxCallable {
  @override
  Object? call(Interpreter interpreter, List<Object?> arguments,
      Map<Symbol, Object?> namedArguments) {
    Widget? child;
    var childParsed = namedArguments[const Symbol('child')];
    if (childParsed != null) {
      child = childParsed as Widget;
    }
    return ClipOval(
      child: child,
    );
  }

  @override
  int arity() {
    return 1;
  }
}

class IClipRRect implements LoxCallable {
  @override
  Object? call(Interpreter interpreter, List<Object?> arguments,
      Map<Symbol, Object?> namedArguments) {
    Widget? child;
    var childParsed = namedArguments[const Symbol('child')];
    if (childParsed != null) {
      child = childParsed as Widget;
    }
    BorderRadius? borderRadius;
    var borderRadiusParsed = namedArguments[const Symbol('borderRadius')];
    if (borderRadiusParsed != null) {
      borderRadius = borderRadiusParsed as BorderRadius;
    }
    return ClipRRect(
      child: child,
      borderRadius: borderRadius,
    );
  }

  @override
  int arity() {
    return 1;
  }
}

class IClipRect implements LoxCallable {
  @override
  Object? call(Interpreter interpreter, List<Object?> arguments,
      Map<Symbol, Object?> namedArguments) {
    Widget? child;
    var childParsed = namedArguments[const Symbol('child')];
    if (childParsed != null) {
      child = childParsed as Widget;
    }
    return ClipRect(
      child: child,
    );
  }

  @override
  int arity() {
    return 1;
  }
}

class IListTile implements LoxCallable {
  @override
  Object? call(Interpreter interpreter, List<Object?> arguments,
      Map<Symbol, Object?> namedArguments) {
    Widget? leading;
    var leadingParsed = namedArguments[const Symbol('leading')];
    if (leadingParsed != null) {
      leading = leadingParsed as Widget;
    }
    Widget? title;
    var titleParsed = namedArguments[const Symbol('title')];
    if (titleParsed != null) {
      title = titleParsed as Widget;
    }
    Widget? subtitle;
    var subtitleParsed = namedArguments[const Symbol('subtitle')];
    if (subtitleParsed != null) {
      subtitle = subtitleParsed as Widget;
    }
    Widget? trailing;
    var trailingParsed = namedArguments[const Symbol('trailing')];
    if (trailingParsed != null) {
      trailing = trailingParsed as Widget;
    }
    bool? dense;
    var denseParsed = namedArguments[const Symbol('dense')];
    if (denseParsed != null) {
      dense = denseParsed as bool;
    }
    bool selected = false;
    var selectedParsed = namedArguments[const Symbol('selected')];
    if (selectedParsed != null) {
      selected = selectedParsed as bool;
    }
    Function()? onTap;
    var onTapParsed = namedArguments[const Symbol('onTap')];
    if (onTapParsed != null) {
      onTap = () {
        (onTapParsed as LoxFunction).call(interpreter, [], {});
      };
    }
    Function()? onLongPress;
    var onLongPressParsed = namedArguments[const Symbol('onLongPress')];
    if (onLongPressParsed != null) {
      onLongPress = () {
        (onLongPressParsed as LoxFunction).call(interpreter, [], {});
      };
    }
    EdgeInsetsGeometry? contentPadding;
    var contentPaddingParsed = namedArguments[const Symbol('contentPadding')];
    if (contentPaddingParsed != null) {
      contentPadding = contentPaddingParsed as EdgeInsetsGeometry;
    }
    return ListTile(
      leading: leading,
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      dense: dense,
      selected: selected,
      onTap: onTap,
      onLongPress: onLongPress,
      contentPadding: contentPadding
    );
  }

  @override
  int arity() {
    return 1;
  }
}
