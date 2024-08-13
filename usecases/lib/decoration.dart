import 'package:dax/dax.dart';
import 'package:flutter/material.dart';
import 'package:usecases/utils.dart';

class IBoxDecoration implements LoxCallable {
  @override
  Object? call(Interpreter interpreter, List<Object?> arguments,
      Map<Symbol, Object?> namedArguments) {
    Color? color;
    var colorParsed = namedArguments[const Symbol('color')];
    if (colorParsed != null) {
      color = colorParsed as Color;
    }
    BoxBorder? border;
    var borderParsed = namedArguments[const Symbol('border')];
    if (borderParsed != null) {
      border = borderParsed as BoxBorder;
    }
    BorderRadiusGeometry? borderRadius;
    var borderRadiusParsed = namedArguments[const Symbol('borderRadius')];
    if (borderRadiusParsed != null) {
      borderRadius = borderRadiusParsed as BorderRadiusGeometry;
    }
    List<BoxShadow>? boxShadow;
    var boxShadowParsed = namedArguments[const Symbol('boxShadow')];
    if (boxShadowParsed != null) {
      boxShadow = (boxShadowParsed as List).cast<BoxShadow>();
    }
    Gradient? gradient;
    var gradientParsed = namedArguments[const Symbol('gradient')];
    if (gradientParsed != null) {
      gradient = gradientParsed as Gradient;
    }
    return BoxDecoration(
        color: color,
        border: border,
        gradient: gradient,
        borderRadius: borderRadius,
        boxShadow: boxShadow);
  }

  @override
  int arity() => 0;
}

class ITextStyle implements LoxCallable {
  @override
  Object? call(Interpreter interpreter, List<Object?> arguments,
      Map<Symbol, Object?> namedArguments) {
    double? fontSize;
    var sizeParsed = namedArguments[const Symbol('fontSize')];
    fontSize = parseDouble(sizeParsed);
    Color? color;
    var colorParsed = namedArguments[const Symbol('color')];
    if (colorParsed != null) {
      color = colorParsed as Color;
    }

    FontWeight? fontWeight;
    var fontWeightParsed = namedArguments[const Symbol('fontWeight')];
    if (fontWeightParsed != null) {
      fontWeight = fontWeightParsed as FontWeight;
    }
    return TextStyle(fontWeight: fontWeight, fontSize: fontSize, color: color);
  }

  @override
  int arity() {
    return 3;
  }
}

class IBoxShadow implements LoxCallable {
  @override
  Object? call(Interpreter interpreter, List<Object?> arguments,
      Map<Symbol, Object?> namedArguments) {
    Color color = Colors.black;
    if (namedArguments[const Symbol('color')] != null) {
      color = namedArguments[const Symbol('color')] as Color;
    }
    Offset offset = Offset.zero;
    if (namedArguments[const Symbol('offset')] != null) {
      offset = namedArguments[const Symbol('offset')] as Offset;
    }
    double blurRadius =
        parseDouble(namedArguments[const Symbol('blurRadius')]) ?? 0.0;
    double spreadRadius =
        parseDouble(namedArguments[const Symbol('spreadRadius')]) ?? 0.0;
    return BoxShadow(
        color: color,
        offset: offset,
        blurRadius: blurRadius,
        spreadRadius: spreadRadius);
  }

  @override
  int arity() => 0;
}
