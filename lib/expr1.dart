import 'package:dax/token.dart';


abstract class Expr {
  T accept<T>(ExprVisitor<T> visitor);
}

class Binary extends Expr {
  final Expr left;
  final Token operator;
  final Expr right;
  Binary(this.left, this.operator, this.right);
  @override
  T accept<T>(ExprVisitor<T> visitor) => visitor.visitBinaryExpr(this);
}

class Grouping extends Expr {
  final Expr expression;
  Grouping(this.expression);
  @override
  T accept<T>(ExprVisitor<T> visitor) => visitor.visitGroupingExpr(this);
}

class Literal extends Expr {
  final Object? value;
  Literal(this.value);
  @override
  T accept<T>(ExprVisitor<T> visitor) => visitor.visitLiteralExpr(this);
}

class Unary extends Expr {
  final Token operator;
  final Expr right;
  Unary(this.operator, this.right);
  @override
  T accept<T>(ExprVisitor<T> visitor) => visitor.visitUnaryExpr(this);
}

abstract class ExprVisitor<T> {
  T visitBinaryExpr(Binary expr);
  T visitGroupingExpr(Grouping expr);
  T visitLiteralExpr(Literal expr);
  T visitUnaryExpr(Unary expr);
}
