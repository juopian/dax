import 'package:dax/token.dart';
import 'package:dax/expr.dart';

abstract class Stmt {
  T accept<T>(Visitor<T> visitor);
}

class Block extends Stmt {
  final List<Stmt> statements;
  Block(this.statements, );
  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitBlockStmt(this);
}

class Expression extends Stmt {
  final Expr expression;
  Expression(this.expression, );
  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitExpressionStmt(this);
}

class If extends Stmt {
  final Expr condition;
  final Stmt thenBranch;
  final Stmt? elseBranch;
  If(this.condition, this.thenBranch, this.elseBranch, );
  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitIfStmt(this);
}

class Print extends Stmt {
  final Expr expression;
  Print(this.expression, );
  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitPrintStmt(this);
}

class Var extends Stmt {
  final Token name;
  final Expr? initializer;
  Var(this.name, this.initializer, );
  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitVarStmt(this);
}

class While extends Stmt {
  final Expr condition;
  final Stmt body;
  While(this.condition, this.body, );
  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitWhileStmt(this);
}

abstract class Visitor<T> {
  T visitBlockStmt(Block stmt);
  T visitExpressionStmt(Expression stmt);
  T visitIfStmt(If stmt);
  T visitPrintStmt(Print stmt);
  T visitVarStmt(Var stmt);
  T visitWhileStmt(While stmt);
}
