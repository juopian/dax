import 'dart:math';

import 'environment.dart';
import 'error.dart';
import 'expr.dart' as Expr;
import 'lox_callable.dart';
import 'lox_class.dart';
import 'lox_function.dart';
import 'lox_instance.dart';
import 'return.dart';
import 'stmt.dart' as Stmt;
import 'runtime_error.dart';
import 'token.dart';
import 'token_type.dart';
import 'global_function.dart';

Environment top = Environment(null);

class Interpreter implements Expr.Visitor<Object?>, Stmt.Visitor<void> {
  Environment globals = Environment(top);
  Map<Expr.Expr, int> locals = {};
  late Environment environment = globals;
  static bool hadError = false;
  static bool hadRuntimeError = false;

  Interpreter() {
    top.define("str", StringFunction());
  }

  void registerGlobal(String name, Object obj) {
    top.define(name, obj);
  }

  void registerLocal(String name, Object obj) {
    globals.define(name, obj);
  }

  dynamic invokeFunction(String name) {
    final callable = globals.getAt(0, name);
    if (callable != null && callable is LoxCallable) {
      return callable.call(this, [], {});
    }
  }

  void interpret(List<Stmt.Stmt> statements) {
    try {
      for (Stmt.Stmt statement in statements) {
        execute(statement);
      }
    } on RuntimeError catch (error) {
      runtimeError(error);
      rethrow;
    }
  }

  void execute(Stmt.Stmt stmt) {
    stmt.accept(this);
  }

  void resolve(Expr.Expr expr, int depth) {
    locals[expr] = depth;
  }

  String stringify(Object? object) {
    if (object == null) return "null";

    if (object is num) {
      String text = object.toString();
      if (text.endsWith(".0")) {
        text = text.substring(0, text.length - 2);
      }
      return text;
    }

    return object.toString();
  }

  @override
  Object? visitBinaryExpr(Expr.Binary expr) {
    Object? left = evaluate(expr.left);
    Object? right = evaluate(expr.right);
    switch (expr.operator.type) {
      case TokenType.GREATER:
        checkNumberOperands(expr.operator, left, right);
        return (left as num) > (right as num);
      case TokenType.GREATER_EQUAL:
        checkNumberOperands(expr.operator, left, right);
        return (left as num) >= (right as num);
      case TokenType.LESS:
        checkNumberOperands(expr.operator, left, right);
        return (left as num) < (right as num);
      case TokenType.LESS_EQUAL:
        checkNumberOperands(expr.operator, left, right);
        return (left as num) <= (right as num);
      case TokenType.BANG_EQUAL:
        return !isEqual(left, right);
      case TokenType.EQUAL_EQUAL:
        return isEqual(left, right);
      case TokenType.MINUS:
        checkNumberOperands(expr.operator, right, left);
        return (left as num) - (right as num);
      case TokenType.SLASH:
        checkNumberOperands(expr.operator, right, left);
        return (left as num) / (right as num);
      case TokenType.STAR:
        checkNumberOperands(expr.operator, right, left);
        return (left as num) * (right as num);
      case TokenType.MOD:
        checkNumberOperands(expr.operator, right, left);
        return (left as num) % (right as num);
      case TokenType.PLUS:
        if (left is num && right is num) {
          return left + right;
        }
        if (left is String && right is String) {
          return left + right;
        }
        throw RuntimeError(
            expr.operator, "Operands must be two numbers or two strings.");
    }
    return null;
  }

  @override
  Object? visitLiteralExpr(Expr.Literal expr) {
    return expr.value;
  }

  @override
  Object? visitCallExpr(Expr.Call expr) {
    Object? callee = evaluate(expr.callee);
    List<Object?> arguments = [];
    Map<Symbol, Object?> namedArguments = {};
    for (Expr.Expr argument in expr.arguments) {
      var arg = evaluate(argument);
      if (argument is Expr.NamedArgs) {
        Map args = arg as Map;
        namedArguments.addAll({Symbol(args.keys.first): args.values.first});
      } else {
        arguments.add(arg);
      }
    }
    if (callee is Function) {
      return Function.apply(callee, arguments, namedArguments);
    }
    if (callee is DaxCallable) {
      return callee.call(this, arguments, namedArguments);
    }
    if (callee is! LoxCallable) {
      throw RuntimeError(expr.paren, "Can only call functions and classes.");
    }
    LoxCallable function = callee;
    if (arguments.length != function.arity()) {
      throw RuntimeError(expr.paren,
          "Expected ${function.arity()} arguments but got ${arguments.length}.");
    }
    if (function is LoxClass &&
        function.superclass != null &&
        (function.superclass!.name == "StatefulWidget" ||
            function.superclass!.name == "StatelessWidget")) {
      namedArguments[Symbol('_klass_')] = function;
      return (top.getAt(0, "Dax${function.superclass!.name}") as DaxCallable)
          .call(this, arguments, namedArguments);
    }
    return function.call(this, arguments, namedArguments);
  }

  @override
  Object? visitAwaitExpr(Expr.Await expr) {
    Object? object = evaluate(expr.future);
    if (object is Future) {
      return object.then((value) => value);
    }
    throw RuntimeError(expr.name, "Only future can be used in await.");
  }

  @override
  Object? visitIndexingExpr(Expr.Indexing expr) {
    Object? object = evaluate(expr.callee);
    if (object is List) {
      return object[evaluate(expr.key) as int];
    }
    if (object is Map) {
      return object[evaluate(expr.key) as String];
    }
    if (object is RegExpMatch) {
      return object[evaluate(expr.key) as int];
    }
    throw RuntimeError(expr.name, "Only list or map can be used in indexing.");
  }

  @override
  Object visitNamedArgsExpr(Expr.NamedArgs expr) {
    Map<String, Object?> entries = {};
    expr.entries.forEach((key, value) {
      entries[key] = evaluate(value);
    });
    return entries;
  }

  @override
  Object visitDictExpr(Expr.Dict expr) {
    Map<Object, Object?> entries = {};
    expr.entries.forEach((key, value) {
      entries[evaluate(key)!] = evaluate(value);
    });
    return entries;
  }

  @override
  Object visitArrayExpr(Expr.Array expr) {
    List<Object?> elements = [];
    for (Expr.Expr element in expr.elements) {
      var result = evaluate(element);
      if (result != null) {
        elements.add(result);
      }
    }
    return elements;
  }

  @override
  Object? visitArrayifExpr(Expr.Arrayif expr) {
    if (isTruthy(evaluate(expr.condition))) {
      return evaluate(expr.thenBranch);
    } else if (expr.elseBranch != null) {
      return evaluate(expr.elseBranch!);
    }
    return null;
  }

  @override
  Object? visitGetExpr(Expr.Get expr) {
    Object? object = evaluate(expr.object);
    if (expr.name.lexeme == "toString") {
      return object.toString();
    }
    if (object is num) {
      switch (expr.name.lexeme) {
        case 'abs':
          return object.abs;
        case 'round':
          return object.round;
        case 'ceil':
          return object.ceil;
        case 'compareTo':
          return object.compareTo;
        case 'floor':
          return object.floor;
        case 'truncate':
          return object.truncate;
        case 'roundToDouble':
          return object.roundToDouble;
        case 'ceilToDouble':
          return object.ceilToDouble;
        case 'floorToDouble':
          return object.floorToDouble;
        case 'truncateToDouble':
          return object.truncateToDouble;
        case 'toInt':
          return object.toInt;
        case 'toDouble':
          return object.toDouble;
        case 'toStringAsFixed':
          return object.toStringAsFixed;
        case 'toStringAsExponential':
          return object.toStringAsExponential;
        case 'toStringAsPrecision':
          return object.toStringAsPrecision;
      }
    }
    if (object is DateTime) {
      switch (expr.name.lexeme) {
        case 'year':
          return object.year;
        case 'month':
          return object.month;
        case 'day':
          return object.day;
        case 'hour':
          return object.hour;
        case 'minute':
          return object.minute;
        case 'second':
          return object.second;
        case 'millisecond':
          return object.millisecond;
        case 'microsecond':
          return object.microsecond;
      }
    }
    if (object is Map) {
      switch (expr.name.lexeme) {
        case 'keys':
          return object.keys;
        case 'values':
          return object.values;
        case 'entries':
          return object.entries;
        case 'length':
          return object.length;
        case 'isEmpty':
          return object.isEmpty;
        case 'isNotEmpty':
          return object.isNotEmpty;
        case 'containsKey':
          return object.containsKey;
        case 'containsValue':
          return object.containsValue;
        case 'remove':
          return object.remove;
        case 'clear':
          return object.clear;
      }
      return object[expr.name.lexeme];
    }

    if (object is String) {
      switch (expr.name.lexeme) {
        case 'substring':
          return object.substring;
        case 'indexOf':
          return object.indexOf;
        case 'lastIndexOf':
          return object.lastIndexOf;
        case 'codeUnitAt':
          return object.codeUnitAt;
        case 'length':
          return object.length;
        case 'isEmpty':
          return object.isEmpty;
        case 'isNotEmpty':
          return object.isNotEmpty;
        case 'compareTo':
          return object.compareTo;
        case 'contains':
          return object.contains;
        case 'startsWith':
          return object.startsWith;
        case 'endsWith':
          return object.endsWith;
        case 'trim':
          return object.trim;
        case 'toLowerCase':
          return object.toLowerCase;
        case 'toUpperCase':
          return object.toUpperCase;
        case 'padLeft':
          return object.padLeft;
        case 'padRight':
          return object.padRight;
        case 'replaceAll':
          return object.replaceAll;
        case 'replaceFirst':
          return object.replaceFirst;
        case 'codeUnits':
          return object.codeUnits;
        case 'runes':
          return object.runes;
        case 'split':
          return object.split;
        case 'trimLeft':
          return object.trimLeft;
        case 'trimRight':
          return object.trimRight;
        case 'replaceAllMapped':
          return object.replaceAllMapped;
      }
      throw RuntimeError(expr.name, "Unknown property ${expr.name.lexeme}.");
    }
    if (object is List) {
      switch (expr.name.lexeme) {
        case 'first':
          return object.first;
        case 'last':
          return object.last;
        case 'single':
          return object.single;
        case 'length':
          return object.length;
        case 'isEmpty':
          return object.isEmpty;
        case 'isNotEmpty':
          return object.isNotEmpty;
        case 'add':
          return object.add;
        case 'removeLast':
          return object.removeLast;
        case 'clear':
          return object.clear;
        case 'insert':
          return object.insert;
        case 'insertAll':
          return object.insertAll;
        case 'setAll':
          return object.setAll;
        case 'removeAt':
          return object.removeAt;
        case 'remove':
          return object.remove;
        case 'indexOf':
          return object.indexOf;
        case 'lastIndexOf':
          return object.lastIndexOf;
        case 'join':
          return object.join;
        case 'any':
          return object.any;
        case 'shuffle':
          return object.shuffle;
        case 'sublist':
          return object.sublist;
        case 'getRange':
          return object.getRange;
        case 'setRange':
          return object.setRange;
        case 'fillRange':
          return object.fillRange;
      }
      throw RuntimeError(expr.name, "Unknown property ${expr.name.lexeme}.");
    } else if (object is Iterable) {
      switch (expr.name.lexeme) {
        case 'first':
          return object.first;
        case 'last':
          return object.last;
        case 'length':
          return object.length;
        case 'isEmpty':
          return object.isEmpty;
        case 'isNotEmpty':
          return object.isNotEmpty;
      }
      throw RuntimeError(expr.name, "Unknown property ${expr.name.lexeme}.");
    }
    if (object is LoxInstance) {
      return object.get(expr.name); // get方法绑定了实例
    }
    if (object is LoxGetCallable) {
      return object.get(expr.name);
    }
    throw RuntimeError(expr.name, "Only instances have properties.");
  }

  @override
  Object? visitLogicalExpr(Expr.Logical expr) {
    Object? left = evaluate(expr.left);
    if (expr.operator.type == TokenType.OR) {
      if (isTruthy(left)) {
        return left;
      }
    } else {
      if (!isTruthy(left)) {
        return left;
      }
    }
    return evaluate(expr.right);
  }

  @override
  Object? visitIndexSetExpr(Expr.IndexSet expr) {
    Object? object = evaluate(expr.object);
    Object? index = evaluate(expr.name);
    Object? value = evaluate(expr.value);
    if (object is Map) {
      object[index] = value;
      return value;
    }
    return null;
  }

  @override
  Object? visitSetExpr(Expr.Set expr) {
    Object? object = evaluate(expr.object);
    Object? value = evaluate(expr.value);
    if (object is LoxInstance) {
      object.set(expr.name, value);
      return value;
    }
    if (object is LoxSetCallable) {
      object.set(expr.name, value);
      return value;
    }
    throw RuntimeError(expr.name, "Only instances have set properties.");
  }

  @override
  Object? visitSuperExpr(Expr.Super expr) {
    int distance = locals[expr]!;
    LoxClass superclass = environment.getAt(distance, "super") as LoxClass;
    LoxInstance object = environment.getAt(distance - 1, "this") as LoxInstance;
    LoxFunction? method = superclass.findMethod(expr.method.lexeme);
    if (method == null) {
      throw RuntimeError(
          expr.method, "Undefined property '${expr.method.lexeme}'.");
    }
    return method.bind(object);
  }

  @override
  Object? visitThisExpr(Expr.This expr) {
    return lookUpVariable(expr.keyword, expr);
  }

  @override
  Object? visitMappingExpr(Expr.Mapping expr) {
    Stmt.Functional mp;
    var func = evaluate(expr.lambda);
    if (func is! LoxFunction) {
      throw RuntimeError(
          expr.name, "Only func can be used as Mapping function");
    } else {
      mp = func.declaration;
    }
    Object? objects = evaluate(expr.callee);
    LoxFunction iterableFun = LoxFunction(mp, environment, false);
    switch (expr.name.lexeme) {
      case 'map':
        if (objects is! Iterable) {
          throw RuntimeError(expr.name, "Only iterable can map function");
        }
        return objects.map((i) {
          return iterableFun.call(this, [i], {});
        }).toList();
      case 'where':
        if (objects is! Iterable) {
          throw RuntimeError(expr.name, "Only iterable can use where function");
        }
        return objects.where((i) {
          return iterableFun.call(this, [i], {}) == true;
        }).toList();
      case 'sort':
        if (objects is! List) {
          throw RuntimeError(expr.name, "Only List can be sorted");
        }
        objects.sort((a, b) {
          return iterableFun.call(this, [a, b], {}) as int;
        });
        return null;
      case 'forEach':
        if (objects is! Iterable) {
          throw RuntimeError(
              expr.name, "Only iterable can use forEach function");
        }
        for (var i in objects) {
          iterableFun.call(this, [i], {});
        }
        return null;
    }
    // if (objects is List<Object?>) {
    //   List<Object?> results = [];
    //   for (var i in objects) {
    //     var result = mapFun.call(this, [i], {});
    //     results.add(result);
    //   }
    //   return results;
    // } else if (objects is Iterable) {
    //   List<Object?> results = [];
    //   for (var i in objects) {
    //     var result = mapFun.call(this, [i], {});
    //     results.add(result);
    //   }
    //   return results;
    // }
    throw RuntimeError(expr.name, "Only Array have mapping.");
  }

  @override
  Object? visitConditionalExpr(Expr.Conditional expr) {
    if (isTruthy(evaluate(expr.condition))) {
      return evaluate(expr.thenBranch);
    } else {
      return evaluate(expr.elseBranch);
    }
  }

  @override
  Object? visitThenExpr(Expr.Then expr) {
    Object? object = evaluate(expr.future);
    if (object is Future) {
      Stmt.Functional then;
      var func = evaluate(expr.then);
      if (func is! LoxFunction) {
        throw RuntimeError(
            expr.name, "Only func can be used as Mapping function");
      } else {
        then = func.declaration;
      }
      Environment previous = environment;
      return object.then((value) {
        if (expr.then is! Expr.Anonymous) {
          previous = environment;
        }
        LoxFunction thenFun = LoxFunction(then, previous, false);
        return thenFun.call(this, [value], {});
      });
    }
    throw RuntimeError(expr.name, "Only future can be used in then.");
  }

  @override
  Object? visitUnaryExpr(Expr.Unary expr) {
    Object? right = evaluate(expr.right);

    switch (expr.operator.type) {
      case TokenType.BANG:
        return !isTruthy(right);
      case TokenType.MINUS:
        checkNumberOperand(expr.operator, right);
        return -(right as num);
    }

    // Unreachable
    return null;
  }

  @override
  Object? visitAnonymousExpr(Expr.Anonymous expr) {
    var fun = Stmt.Functional(expr.name, expr.params, {}, expr.body);
    return LoxFunction(fun, environment, false);
  }

  @override
  Object? visitVariableExpr(Expr.Variable expr) {
    // return environment.get(expr.name);
    return lookUpVariable(expr.name, expr);
  }

  Object? lookUpVariable(Token name, Expr.Expr expr) {
    if (locals.containsKey(expr)) {
      int distance = locals[expr]!;
      return environment.getAt(distance, name.lexeme);
    } else {
      return globals.get(name);
    }
  }

  void checkNumberOperand(Token operator, Object? operand) {
    if (operand is double) return;
    throw RuntimeError(operator, "Operand must be a number.");
  }

  void checkNumberOperands(Token operator, Object? left, Object? right) {
    if (left is num && right is num) return;

    throw RuntimeError(operator, "Operands must be numbers.");
  }

  bool isTruthy(Object? object) {
    if (object == null) return false;
    if (object is bool) return object;
    return true;
  }

  bool isEqual(Object? a, Object? b) {
    if (a == null && b == null) return true;
    if (a == null) return false;
    return a == b;
  }

  @override
  Object? visitGroupingExpr(Expr.Grouping expr) {
    return evaluate(expr.expression);
  }

  @override
  Object? visitAssignExpr(Expr.Assign expr) {
    Object? value = evaluate(expr.value);
    // environment.assign(expr.name, value);
    int? distance = locals[expr];
    if (distance != null) {
      environment.assignAt(distance, expr.name, value);
    } else {
      globals.assign(expr.name, value);
    }

    return value;
  }

  Object? evaluate(Expr.Expr expr) {
    return expr.accept(this);
  }

  // @override
  // void visitForEachStmt(Stmt.ForEach stmt) {
  //   Stmt.Functional mp;
  //   var func = evaluate(stmt.lambda);
  //   if (func is! LoxFunction) {
  //     throw RuntimeError(
  //         stmt.name, "Only func can be used as forEach function");
  //   } else {
  //     mp = func.declaration;
  //   }
  //   LoxFunction iterableFun = LoxFunction(mp, environment, false);
  //   Object? object = evaluate(stmt.iterable);
  //   if (object is Iterable) {
  //     for (var i in object) {
  //       iterableFun.call(this, [i], {});
  //     }
  //   } else if (object is Map) {
  //     object.forEach((k, v) {
  //       iterableFun.call(this, [k, v], {});
  //     });
  //   } else if (object is List) {
  //     for (var i in object) {
  //       iterableFun.call(this, [i], {});
  //     }
  //   } else {
  //     throw RuntimeError(
  //         stmt.name, "Only Iterable or List or Map have forEach.");
  //   }
  // }

  @override
  void visitIfStmt(Stmt.If stmt) {
    if (isTruthy(evaluate(stmt.condition))) {
      execute(stmt.thenBranch);
    } else if (stmt.elseBranch != null) {
      execute(stmt.elseBranch!);
    }
    return;
  }

  @override
  void visitExpressionStmt(Stmt.Expression stmt) {
    evaluate(stmt.expression);
    return;
  }

  @override
  void visitPrintStmt(Stmt.Print stmt) {
    Object? value = evaluate(stmt.expression);
    print(stringify(value));
    return;
  }

  @override
  void visitVarStmt(Stmt.Var stmt) {
    Object? value;
    if (stmt.initializer != null) {
      value = evaluate(stmt.initializer!);
    }
    // 如果初始化用到了自身，很明显environment 找不到这个值
    environment.define(stmt.name.lexeme, value);
    return;
  }

  @override
  void visitWhileStmt(Stmt.While stmt) {
    while (isTruthy(evaluate(stmt.condition))) {
      execute(stmt.body);
    }
    return;
  }

  @override
  void visitReturnStmt(Stmt.Return stmt) {
    Object? value;
    if (stmt.value != null) {
      value = evaluate(stmt.value!);
    }
    throw ReturnException(value);
  }

  @override
  void visitBlockStmt(Stmt.Block stmt) {
    executeBlock(stmt.statements, Environment(environment));
    return;
  }

  @override
  void visitFunctionalStmt(Stmt.Functional stmt) {
    LoxFunction function = LoxFunction(stmt, environment, false);
    for (var key in function.declaration.namedParams.keys) {
      if (function.declaration.namedParams[key] != null) {
        function.declaration.namedParams[key] =
            evaluate(function.declaration.namedParams[key] as Expr.Expr);
      }
    }
    environment.define(stmt.name.lexeme, function);
    return;
  }

  @override
  void visitClassStmt(Stmt.Class stmt) {
    Object? superclass;
    if (stmt.superclass != null) {
      superclass = evaluate(stmt.superclass!);
      if (superclass is! LoxClass) {
        throw RuntimeError(
            stmt.superclass!.name, "Superclass must be a class.");
      }
    }

    environment.define(stmt.name.lexeme, null);

    if (stmt.superclass != null) {
      environment = Environment(environment);
      environment.define("super", superclass);
    }

    Map<String, LoxFunction> methods = {};
    for (Stmt.Functional method in stmt.methods) {
      LoxFunction function = LoxFunction(
          method, environment, method.name.lexeme == stmt.name.lexeme); // init
      for (var key in function.declaration.namedParams.keys) {
        if (function.declaration.namedParams[key] != null) {
          function.declaration.namedParams[key] =
              evaluate(function.declaration.namedParams[key] as Expr.Expr);
        }
      }
      methods[method.name.lexeme] = function;
    }
    LoxClass klass = LoxClass(stmt.name.lexeme,
        superclass == null ? null : superclass as LoxClass, methods);

    if (superclass != null) {
      environment = environment.enclosing!;
    }
    environment.assign(stmt.name, klass);
    return;
  }

  void executeBlock(List<Stmt.Stmt> statements, Environment environment) {
    Environment previous = this.environment;
    try {
      this.environment = environment;
      for (Stmt.Stmt statement in statements) {
        execute(statement);
      }
    } finally {
      this.environment = previous;
    }
  }
}
