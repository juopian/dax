import 'package:dax/token.dart';

abstract class Expr {
  T accept<T>(Visitor<T> visitor);
}

class Assign extends Expr {
  final Token name;
  final Expr value;
  Assign(this.name, this.value, );
  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitAssignExpr(this);
}

class Binary extends Expr {
  final Expr left;
  final Token operator;
  final Expr right;
  Binary(this.left, this.operator, this.right, );
  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitBinaryExpr(this);
}

class Grouping extends Expr {
  final Expr expression;
  Grouping(this.expression, );
  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitGroupingExpr(this);
}

class Literal extends Expr {
  final Object? value;
  Literal(this.value, );
  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitLiteralExpr(this);
}

class Logical extends Expr {
  final Expr left;
  final Token operator;
  final Expr right;
  Logical(this.left, this.operator, this.right, );
  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitLogicalExpr(this);
}

class Unary extends Expr {
  final Token operator;
  final Expr right;
  Unary(this.operator, this.right, );
  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitUnaryExpr(this);
}

class Variable extends Expr {
  final Token name;
  Variable(this.name, );
  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitVariableExpr(this);
}

abstract class Visitor<T> {
  T visitAssignExpr(Assign expr);
  T visitBinaryExpr(Binary expr);
  T visitGroupingExpr(Grouping expr);
  T visitLiteralExpr(Literal expr);
  T visitLogicalExpr(Logical expr);
  T visitUnaryExpr(Unary expr);
  T visitVariableExpr(Variable expr);
}
