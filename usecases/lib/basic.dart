import 'package:dax/dax.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:usecases/utils.dart';

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

class IElevatedButton implements LoxCallable {
  @override
  Object? call(Interpreter interpreter, List<Object?> arguments,
      Map<Symbol, Object?> namedArguments) {
    var child = namedArguments[const Symbol('child')];
    if (child == null) {
      throw "child required in ElevatedButton";
    }
    var onPressed = namedArguments[const Symbol('onPressed')];
    if (onPressed == null) {
      throw "onPressed required in ElevatedButton";
    }
    return ElevatedButton(
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

class IOutlinedButton implements LoxCallable {
  @override
  Object? call(Interpreter interpreter, List<Object?> arguments,
      Map<Symbol, Object?> namedArguments) {
    var child = namedArguments[const Symbol('child')];
    if (child == null) {
      throw "child required in OutlinedButton";
    }
    var onPressed = namedArguments[const Symbol('onPressed')];
    if (onPressed == null) {
      throw "onPressed required in OutlinedButton";
    }
    return OutlinedButton(
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

class IIcon implements LoxCallable {
  @override
  Object? call(Interpreter interpreter, List<Object?> arguments,
      Map<Symbol, Object?> namedArguments) {
    if (arguments.isEmpty) {
      throw "icon required in Icon";
    }
    var icon = arguments[0];
    double? size;
    size = parseDouble(namedArguments[const Symbol('size')]);
    Color? color;
    var colorParsed = namedArguments[const Symbol('color')];
    if (colorParsed != null) {
      color = colorParsed as Color;
    }
    return Icon(icon as IconData, size: size, color: color);
  }

  @override
  int arity() {
    return 1;
  }
}

class IIconButton implements LoxCallable {
  @override
  Object? call(Interpreter interpreter, List<Object?> arguments,
      Map<Symbol, Object?> namedArguments) {
    var icon = namedArguments[const Symbol('icon')];
    if (icon == null) {
      throw "icon required in IconButton";
    }
    var onPressed = namedArguments[const Symbol('onPressed')];
    if (onPressed == null) {
      throw "onPressed required in IconButton";
    }
    return IconButton(
        icon: icon as Widget,
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

class IImage implements LoxCallable {
  @override
  Object? call(Interpreter interpreter, List<Object?> arguments,
      Map<Symbol, Object?> namedArguments) {
    var imageParsed = namedArguments[const Symbol('image')];
    if (imageParsed == null) {
      throw "image required in Image";
    }
    ImageProvider image = imageParsed as ImageProvider;
    double? height = parseDouble(namedArguments[const Symbol('height')]);
    double? width = parseDouble(namedArguments[const Symbol('width')]);
    BoxFit? fit;
    var fitParsed = namedArguments[const Symbol('fit')];
    if (fitParsed != null) {
      fit = fitParsed as BoxFit;
    }
    return Image(
      image: image,
      height: height,
      width: width,
      fit: fit,
    );
  }

  @override
  int arity() {
    return 1;
  }
}

class ICupertinoActivityIndicator implements LoxCallable {
  @override
  Object? call(Interpreter interpreter, List<Object?> arguments,
      Map<Symbol, Object?> namedArguments) {
    return const CupertinoActivityIndicator();
  }

  @override
  int arity() {
    return 0;
  }
}

class ICircularProgressIndicator implements LoxCallable {
  @override
  Object? call(Interpreter interpreter, List<Object?> arguments,
      Map<Symbol, Object?> namedArguments) {
    double? strokeWidth =
        parseDouble(namedArguments[const Symbol('strokeWidth')]);
    double? value = parseDouble(namedArguments[const Symbol('value')]);
    Color? color;
    Color? backgroundColor;
    var colorParsed = namedArguments[const Symbol('color')];
    if (colorParsed != null) {
      color = colorParsed as Color;
    }
    var backgroundColorParsed = namedArguments[const Symbol('backgroundColor')];
    if (backgroundColorParsed != null) {
      backgroundColor = backgroundColorParsed as Color;
    }
    return CircularProgressIndicator(
      strokeWidth: strokeWidth ?? 4.0,
      value: value,
      color: color,
      backgroundColor: backgroundColor,
    );
  }

  @override
  int arity() {
    return 0;
  }
}

class ICheckbox implements LoxCallable {
  @override
  Object? call(Interpreter interpreter, List<Object?> arguments,
      Map<Symbol, Object?> namedArguments) {
    var value = namedArguments[const Symbol('value')];
    if (value == null) {
      throw "value required in Checkbox";
    }
    var onChanged = namedArguments[const Symbol('onChanged')];
    if (onChanged == null) {
      throw "onChanged required in Checkbox";
    }
    return Checkbox(
      value: value as bool,
      onChanged: (bool? value) {
        (onChanged as LoxFunction).call(interpreter, [value], {});
      },
    );
  }

  @override
  int arity() {
    return 2;
  }
}

class ITextField implements LoxCallable {
  @override
  Object? call(Interpreter interpreter, List<Object?> arguments,
      Map<Symbol, Object?> namedArguments) {
    TextEditingController? controller;
    var controllerParsed = namedArguments[const Symbol('controller')];
    if (controllerParsed != null) {
      controller = controllerParsed as TextEditingController;
    }
    Function(String)? onChanged;
    var onChangedParsed = namedArguments[const Symbol('onChanged')];
    if (onChangedParsed != null) {
      onChanged = (String value) {
        (onChangedParsed as LoxFunction).call(interpreter, [value], {});
      };
    }
    InputDecoration? decoration;
    var decorationParsed = namedArguments[const Symbol('decoration')];
    if (decorationParsed != null) {
      decoration = decorationParsed as InputDecoration;
    }
    int maxLines = 1;
    var maxLinesParsed = namedArguments[const Symbol('maxLines')];
    if (maxLinesParsed != null) {
      maxLines = maxLinesParsed as int;
    }
    TextStyle? style;
    var styleParsed = namedArguments[const Symbol('style')];
    if (styleParsed != null) {
      style = styleParsed as TextStyle;
    }
    return TextField(
      controller: controller,
      decoration: decoration,
      onChanged: onChanged,
      maxLines: maxLines,
      style: style,
    );
  }

  @override
  int arity() {
    return 2;
  }
}

class IDivider implements LoxCallable {
  @override
  Object? call(Interpreter interpreter, List<Object?> arguments,
      Map<Symbol, Object?> namedArguments) {
    double? height = parseDouble(namedArguments[const Symbol('height')]);
    double? thickness = parseDouble(namedArguments[const Symbol('thickness')]);
    double? indent = parseDouble(namedArguments[const Symbol('indent')]);
    double? endIndent = parseDouble(namedArguments[const Symbol('endIndent')]);
    Color? color;
    var colorParsed = namedArguments[const Symbol('color')];
    if (colorParsed != null) {
      color = colorParsed as Color;
    }
    return Divider(
      height: height,
      thickness: thickness,
      indent: indent,
      endIndent: endIndent,
      color: color,
    );
  }

  @override
  int arity() {
    return 0;
  }
}
