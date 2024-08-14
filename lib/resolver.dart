import 'error.dart';
import 'expr.dart' as Expr;
import 'interpreter.dart';
import 'stack.dart';
import 'stmt.dart' as Stmt;
import 'token.dart';

enum FunctionType { NONE, FUNCTION, INITIALIZER, METHOD }

enum ClassType { NONE, CLASS, SUBCLASS }

class Resolver implements Expr.Visitor<void>, Stmt.Visitor<void> {
  late final Interpreter interpreter;
  final Stack<Map<String, bool>> scopes = Stack();
  FunctionType currentFunctionType = FunctionType.NONE;
  ClassType currentClassType = ClassType.NONE;
  Resolver(this.interpreter);

  void resolve(List<Stmt.Stmt> statements) {
    for (Stmt.Stmt statement in statements) {
      resolveStmt(statement);
    }
  }

  void beginScope() {
    scopes.push({});
  }

  void endScope() {
    scopes.pop();
  }

  void resolveStmt(Stmt.Stmt stmt) {
    stmt.accept(this);
  }

  void resolveExpr(Expr.Expr expr) {
    expr.accept(this);
  }

  void resolveFunction(Stmt.Functional function, FunctionType type) {
    FunctionType enclosingFunctionType = currentFunctionType;
    currentFunctionType = type;

    beginScope();
    for (Token param in function.params) {
      declare(param);
      define(param);
    }
    resolve(function.body);
    endScope();
    currentFunctionType = enclosingFunctionType;
  }

  @override
  void visitClassStmt(Stmt.Class stmt) {
    ClassType enclosingClassType = currentClassType;
    currentClassType = ClassType.CLASS;
    declare(stmt.name);
    define(stmt.name);

    if (stmt.superclass != null &&
        stmt.name.lexeme == stmt.superclass!.name.lexeme) {
      error1(stmt.superclass!.name, 'A class can not inherit from itself.');
    }

    if (stmt.superclass != null) {
      currentClassType = ClassType.SUBCLASS;
      resolveExpr(stmt.superclass as Expr.Expr);
    }
    if (stmt.superclass != null) {
      beginScope();
      scopes.peek()["super"] = true;
    }
    beginScope();
    scopes.peek()["this"] = true;
    for (Stmt.Functional method in stmt.methods) {
      FunctionType declaration = FunctionType.METHOD;
      if (method.name.lexeme == "init") {
        declaration = FunctionType.INITIALIZER;
      }
      resolveFunction(method, declaration);
    }

    endScope();
    if (stmt.superclass != null) endScope();
    currentClassType = enclosingClassType;
    return;
    // if (stmt.superclass != null) {
    //   if (stmt.name.lexeme == stmt.superclass!.name.lexeme) {
    //     error1(stmt.superclass!.name, 'A class can not inherit from itself.');
    //   }
    // }
  }

  @override
  void visitBlockStmt(Stmt.Block stmt) {
    beginScope();
    resolve(stmt.statements);
    endScope();
  }

  @override
  void visitExpressionStmt(Stmt.Expression stmt) {
    resolveExpr(stmt.expression);
    return;
  }

  @override
  void visitVarStmt(Stmt.Var stmt) {
    declare(stmt.name);
    if (stmt.initializer != null) {
      resolveExpr(stmt.initializer!);
    }
    define(stmt.name);
    return;
  }

  @override
  void visitFunctionalStmt(Stmt.Functional stmt) {
    declare(stmt.name);
    define(stmt.name);
    resolveFunction(stmt, FunctionType.FUNCTION);
    return;
  }

  @override
  void visitIfStmt(Stmt.If stmt) {
    resolveExpr(stmt.condition);
    resolveStmt(stmt.thenBranch);
    if (stmt.elseBranch != null) {
      resolveStmt(stmt.elseBranch!);
    }
    return;
  }

  @override
  void visitPrintStmt(Stmt.Print stmt) {
    resolveExpr(stmt.expression);
    return;
  }

  @override
  void visitReturnStmt(Stmt.Return stmt) {
    if (currentFunctionType == FunctionType.NONE) {
      error1(stmt.keyword, 'Can not return from top-level code.');
    }
    if (stmt.value != null) {
      if (currentFunctionType == FunctionType.INITIALIZER) {
        error1(stmt.keyword, 'Can not return a value from an initializer.');
      }
      resolveExpr(stmt.value!);
    }

    return;
  }

  @override
  void visitWhileStmt(Stmt.While stmt) {
    resolveExpr(stmt.condition);
    resolveStmt(stmt.body);
    return;
  }

  @override
  void visitAnonymousExpr(Expr.Anonymous expr) {
    declare(expr.name);
    define(expr.name);
    FunctionType enclosingFunctionType = currentFunctionType;
    currentFunctionType = FunctionType.FUNCTION;
    beginScope();
    for (Token param in expr.params) {
      declare(param);
      define(param);
    }
    resolve(expr.body);
    endScope();
    currentFunctionType = enclosingFunctionType;
  }

  @override
  void visitVariableExpr(Expr.Variable expr) {
    if (!scopes.isEmpty && scopes.peek()[expr.name.lexeme] == false) {
      error1(expr.name, 'Can not read local variable in its own initializer.');
    }
    resolveLocal(expr, expr.name);
    return;
  }

  @override
  void visitAssignExpr(Expr.Assign expr) {
    resolveExpr(expr.value);
    resolveLocal(expr, expr.name);
    return;
  }

  @override
  void visitBinaryExpr(Expr.Binary expr) {
    resolveExpr(expr.left);
    resolveExpr(expr.right);
    return;
  }

  @override
  void visitArrayExpr(Expr.Array expr) {
    for (Expr.Expr element in expr.elements) {
      resolveExpr(element);
    }
    return;
  }

  @override
  void visitDictExpr(Expr.Dict expr) {
    for (MapEntry<String, Expr.Expr> entry in expr.entries.entries) {
      resolveExpr(entry.value);
    }
    return;
  }

  @override
  void visitMappingExpr(Expr.Mapping expr) {
    resolveExpr(expr.callee);
    if (expr.lambda is Stmt.Functional) {
      resolveFunction(expr.lambda as Stmt.Functional, FunctionType.FUNCTION);
    } else {
      resolveExpr(expr.lambda as Expr.Expr);
    }
    return;
  }

  @override
  void visitIndexingExpr(Expr.Indexing expr) {
    resolveExpr(expr.callee);
    resolveExpr(expr.key);
    return;
  }

  @override
  void visitCallExpr(Expr.Call expr) {
    resolveExpr(expr.callee);

    for (Expr.Expr argument in expr.arguments) {
      resolveExpr(argument);
    }

    return;
  }

  @override
  void visitGetExpr(Expr.Get expr) {
    resolveExpr(expr.object);
    return;
  }

  @override
  void visitSetExpr(Expr.Set expr) {
    resolveExpr(expr.value);
    resolveExpr(expr.object);
    return;
  }

  @override
  void visitSuperExpr(Expr.Super expr) {
    if (currentClassType == ClassType.NONE) {
      error1(expr.keyword, 'Can not use \'super\' outside of a class.');
    } else if (currentClassType != ClassType.SUBCLASS) {
      error1(
          expr.keyword, 'Can not use \'super\' in a class with no superclass.');
    }
    resolveLocal(expr, expr.keyword);
    return;
  }

  @override
  void visitThisExpr(Expr.This expr) {
    if (currentClassType == ClassType.NONE) {
      error1(expr.keyword, 'Can not use \'this\' outside of a class.');
      return;
    }
    resolveLocal(expr, expr.keyword);
    return;
  }

  @override
  void visitGroupingExpr(Expr.Grouping expr) {
    resolveExpr(expr.expression);
    return;
  }

  @override
  void visitLiteralExpr(Expr.Literal expr) {
    return;
  }

  @override
  void visitLogicalExpr(Expr.Logical expr) {
    resolveExpr(expr.left);
    resolveExpr(expr.right);
    return;
  }

  @override
  void visitUnaryExpr(Expr.Unary expr) {
    resolveExpr(expr.right);
    return;
  }

  void declare(Token name) {
    if (scopes.isEmpty) return;
    Map<String, bool> scope = scopes.peek();
    if (scope.containsKey(name.lexeme)) {
      error1(name, 'Variable with this name already declared in this scope.');
    }
    scope[name.lexeme] = false;
  }

  void define(Token name) {
    if (scopes.isEmpty) return;
    scopes.peek()[name.lexeme] = true;
  }

  void resolveLocal(Expr.Expr expr, Token name) {
    for (int i = scopes.length - 1; i >= 0; i--) {
      if (scopes.get(i).containsKey(name.lexeme)) {
        interpreter.resolve(expr, scopes.length - 1 - i);
        return;
      }
    }
  }
}
