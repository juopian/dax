import 'package:dax/environment.dart';
import 'package:dax/error.dart';
import 'package:dax/expr.dart' as Expr;
import 'package:dax/stmt.dart' as Stmt;
import 'package:dax/runtime_error.dart';
import 'package:dax/token.dart';
import 'package:dax/token_type.dart';

class Interpreter implements Expr.Visitor<Object?>, Stmt.Visitor<void> {
  Environment environment = Environment(null);

  // void interpret(Expr expression) {
  //   try {
  //     Object? value = evaluate(expression);
  //     print(stringify(value));
  //   } on RuntimeError catch (error) {
  //     runtimeError(error);
  //   }
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
    return environment.get(expr.name);
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
    environment.assign(expr.name, value);
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
  void visitBlockStmt(Stmt.Block stmt) {
    executeBlock(stmt.statements, Environment(environment));
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
