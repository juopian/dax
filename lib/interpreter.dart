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
import 'widget.dart';
// import 'package:flutter/material.dart';

class ClockFunction implements LoxCallable {
  @override
  int arity() {
    return 0;
  }

  @override
  Object? call(Interpreter interpreter, List<Object?> arguments) {
    return DateTime.now().millisecondsSinceEpoch / 1000.0;
  }

  @override
  String toString() {
    return "<native fn>";
  }
}

class Interpreter implements Expr.Visitor<Object?>, Stmt.Visitor<void> {
  final Environment globals = Environment(null);
  final Map<Expr.Expr, int> locals = {};
  late Environment environment;
  // late Widget renderWidget;

  Interpreter() {
    print("init Interpreter");
    environment = globals;
    globals.define("clock", ClockFunction());
    globals.define("String", StringFunction());
    // globals.define("Text", TextFunction());
    // globals.define("Column", ColumnFunction());
    // globals.define("TextButton", TextButtonFunction());
  }

  void registerFunction(String name, LoxCallable function) {
    globals.define(name, function);
  }

  dynamic invokeFunction(String name) {
    final callable = globals.getAt(0, name);
    if (callable != null && callable is LoxCallable) {
      return callable.call(this, []);
    }
    throw RuntimeError((callable as LoxFunction).declaration.name,
        'Function not found: $name');
  }

  // void interpret(Expr expression) {
  //   try {
  //     Object? value = evaluate(expression);
  //     print(stringify(value));
  //   } on RuntimeError catch (error) {
  //     runtimeError(error);
  //   }
  // }

  // Widget getRenderedWidget() {
  //   return renderWidget;
  // }

  void interpret(List<Stmt.Stmt> statements) {
    try {
      for (Stmt.Stmt statement in statements) {
        execute(statement);
      }
    } on RuntimeError catch (error) {
      runtimeError(error);
    }
  }

  void execute(Stmt.Stmt stmt) {
    stmt.accept(this);
  }

  void resolve(Expr.Expr expr, int depth) {
    locals[expr] = depth;
  }

  String stringify(Object? object) {
    if (object == null) return "nil";

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
    for (Expr.Expr argument in expr.arguments) {
      arguments.add(evaluate(argument));
    }
    if (callee is! LoxCallable) {
      throw RuntimeError(expr.paren, "Can only call functions and classes.");
    }
    LoxCallable function = callee;
    if (arguments.length != function.arity()) {
      throw RuntimeError(expr.paren,
          "Expected ${function.arity()} arguments but got ${arguments.length}.");
    }
    var result = function.call(this, arguments);
    if (function is LoxFunction) {
      // if (function.declaration.name.lexeme == "build" && result is Widget) {
      //   renderWidget = result;
      // }
    }
    return result;
  }

  @override
  Object? visitGetExpr(Expr.Get expr) {
    Object? object = evaluate(expr.object);
    if (object is LoxInstance) {
      return object.get(expr.name); // get方法绑定了实例
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
  Object? visitSetExpr(Expr.Set expr) {
    Object? object = evaluate(expr.object);
    if (object is LoxInstance) {
      Object? value = evaluate(expr.value);
      object.set(expr.name, value);
      return value;
    }
    throw RuntimeError(expr.name, "Only instances have properties.");
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
  Object? visitUnaryExpr(Expr.Unary expr) {
    Object? right = evaluate(expr.right);

    switch (expr.operator.type) {
      case TokenType.BANG:
        return !isTruthy(right);
      case TokenType.MINUS:
        checkNumberOperand(expr.operator, right);
        return -(right as num);
    }

    // Unreachable.
    return null;
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
    // LoxClass klass = LoxClass(stmt.name.lexeme);

    if (stmt.superclass != null) {
      environment = Environment(environment);
      environment.define("super", superclass);
    }

    Map<String, LoxFunction> methods = {};
    for (Stmt.Functional method in stmt.methods) {
      LoxFunction function =
          LoxFunction(method, environment, method.name.lexeme == "init");
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
