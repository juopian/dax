import 'package:dax/expr.dart' as Expr;
import 'package:dax/stmt.dart' as Stmt;
import 'package:dax/token.dart';
import 'package:dax/token_type.dart';

class AstPrinter implements Expr.Visitor<String>, Stmt.Visitor<String> {
  String print(Expr.Expr expr) {
    return expr.accept(this);
  }

  String printStmt(Stmt.Stmt stmt) {
    return stmt.accept(this);
  }

  @override
  String visitAnonymousExpr(Expr.Anonymous expr) {
    return parenthesize2("anonymous", expr.body);
  }

  @override
  String visitMappingExpr(Expr.Mapping expr) {
    return parenthesize2("map", [expr.callee, expr.name, expr.lambda]);
  }

  @override
  String visitIndexingExpr(Expr.Indexing expr) {
    return parenthesize2("[]", [expr.callee, expr.key]);
  }

  @override
  String visitSuperExpr(Expr.Super expr) {
    return parenthesize2("super", [expr.method]);
  }

  @override
  String visitThisExpr(Expr.This expr) {
    return "this";
  }

  @override
  String visitGetExpr(Expr.Get expr) {
    return parenthesize2(".", [expr.object, expr.name.lexeme]);
  }

  @override
  String visitSetExpr(Expr.Set expr) {
    return parenthesize2("=", [expr.object, expr.name.lexeme, expr.value]);
  }

  @override
  String visitCallExpr(Expr.Call expr) {
    return parenthesize2("call", [expr.callee, expr.arguments]);
  }

  @override
  String visitWhileStmt(Stmt.While stmt) {
    return parenthesize2("while", [stmt.condition, stmt.body]);
  }

  @override
  String visitLogicalExpr(Expr.Logical expr) {
    return parenthesize(expr.operator.lexeme, [expr.left, expr.right]);
  }

  @override
  String visitAssignExpr(Expr.Assign expr) {
    return parenthesize2("=", [expr.name, expr.value]);
  }

  @override
  String visitBinaryExpr(Expr.Binary expr) {
    return parenthesize(expr.operator.lexeme, [expr.left, expr.right]);
  }

  @override
  String visitDictExpr(Expr.Dict expr) {
    StringBuffer sb = StringBuffer();
    sb.write("{");
    int i = 0;
    for (var entry in expr.entries.entries) {
      if (i > 0) {
        sb.write(", ");
      }
      sb.write(entry.key);
      sb.write(": ");
      sb.write(entry.value.accept(this));
      i++;
    }
    sb.write("}");
    return sb.toString(); 
  }

  @override
  String visitArrayExpr(Expr.Array expr) {
    StringBuffer sb = StringBuffer();
    sb.write("[");
    for (int i = 0; i < expr.elements.length; i++) {
      if (i > 0) {
        sb.write(", ");
      }
      sb.write(expr.elements[i].accept(this));
    }
    sb.write("]");
    return sb.toString();
  }

  @override
  String visitGroupingExpr(Expr.Grouping expr) {
    return parenthesize("group", [expr.expression]);
  }

  @override
  String visitLiteralExpr(Expr.Literal expr) {
    if (expr.value == null) {
      return "nil";
    }
    return expr.value.toString();
  }

  @override
  String visitUnaryExpr(Expr.Unary expr) {
    return parenthesize(expr.operator.lexeme, [expr.right]);
  }

  @override
  String visitVariableExpr(Expr.Variable expr) {
    return expr.name.lexeme;
  }

  @override
  String visitIfStmt(Stmt.If stmt) {
    if (stmt.elseBranch == null) {
      return parenthesize2("if", [stmt.condition, stmt.thenBranch]);
    }
    return parenthesize2(
        "if", [stmt.condition, stmt.thenBranch, stmt.elseBranch]);
  }

  @override
  String visitBlockStmt(Stmt.Block stmt) {
    StringBuffer sb = StringBuffer();
    sb.write("(block");
    for (Stmt.Stmt statement in stmt.statements) {
      sb.write(statement.accept(this));
    }
    sb.write(")");
    return sb.toString();
  }

  @override
  String visitExpressionStmt(Stmt.Expression stmt) {
    return parenthesize(";", [stmt.expression]);
  }

  @override
  String visitPrintStmt(Stmt.Print stmt) {
    return parenthesize("print", [stmt.expression]);
  }

  @override
  String visitVarStmt(Stmt.Var stmt) {
    if (stmt.initializer == null) {
      return parenthesize2("var", [stmt.name]);
    }
    return parenthesize2("var", [stmt.name, "=", stmt.initializer!]);
  }

  @override
  String visitFunctionalStmt(Stmt.Functional stmt) {
    StringBuffer sb = StringBuffer();
    sb.write("(fun ");
    sb.write(stmt.name.lexeme);
    sb.write(")");
    return sb.toString();
  }

  @override
  String visitClassStmt(Stmt.Class stmt) {
    StringBuffer sb = StringBuffer();
    sb.write("(class ");
    sb.write(stmt.name.lexeme);
    sb.write(")");
    return sb.toString();
  }


  @override
  String visitReturnStmt(Stmt.Return stmt) {
    if (stmt.value == null) {
      return "(return))";
    }
    return parenthesize("return", [stmt.value!]);
  }


  String parenthesize(String name, List<Expr.Expr> exprs) {
    StringBuffer sb = StringBuffer();
    sb.write("($name");
    for (Expr.Expr expr in exprs) {
      sb.write(" ");
      sb.write(expr.accept(this));
    }
    sb.write(")");
    return sb.toString();
  }

  String parenthesize2(String name, List<Object?> parts) {
    StringBuffer sb = StringBuffer();
    sb.write("($name");
    transform(sb, parts);
    sb.write(")");
    return sb.toString();
  }

  void transform(StringBuffer sb, List<Object?> parts) {
    for (Object? part in parts) {
      sb.write(" ");
      if (part is Expr.Expr) {
        sb.write(part.accept(this));
      } else if (part is Stmt.Stmt) {
        sb.write(part.accept(this));
      } else if (part is Token) {
        sb.write(part.lexeme);
      } else if (part is List) {
        transform(sb, part as List<Object>);
      } else {
        sb.write(part.toString());
      }
    }
  }
}

void main(List<String> args) {
  Expr.Expr expression = Expr.Binary(
      Expr.Unary(Token(TokenType.MINUS, "-", null, 1), Expr.Literal(123)),
      Token(TokenType.STAR, "*", null, 1),
      Expr.Grouping(Expr.Literal(45.67)));
  print(AstPrinter().print(expression));
}
