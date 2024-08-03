import 'package:dax/expr.dart';
import 'package:dax/token.dart';
import 'package:dax/token_type.dart';


class AstPrinter implements Visitor<String> {
  String print(Expr expr) {
    return expr.accept(this);
  }

  @override
  String visitBinaryExpr(Binary expr) {
    return parenthesize(expr.operator.lexeme, [expr.left, expr.right]);
  }

  @override
  String visitGroupingExpr(Grouping expr) {
    return parenthesize("group", [expr.expression]);
  }

  @override
  String visitLiteralExpr(Literal expr) {
    if (expr.value == null) {
      return "nil";
    }
    return expr.value.toString();
  }

  @override
  String visitUnaryExpr(Unary expr) {
    return parenthesize(expr.operator.lexeme, [expr.right]);
  }

  String parenthesize(String name, List<Expr> exprs) {
    StringBuffer sb = StringBuffer();
    sb.write("($name");
    for (Expr expr in exprs) {
      sb.write(" ");
      sb.write(expr.accept(this));
    }
    sb.write(")");
    return sb.toString();
  }
}

void main(List<String> args) {
  Expr expression = Binary(
      Unary(Token(TokenType.MINUS, "-", null, 1), Literal(123)),
      Token(TokenType.STAR, "*", null, 1),
      Grouping(Literal(45.67)));
  print(AstPrinter().print(expression));
}
