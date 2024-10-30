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

class Class extends Stmt {
  final Token name;
  final Variable? superclass;
  final List<Functional> methods;
  Class(this.name, this.superclass, this.methods, );
  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitClassStmt(this);
}

class Expression extends Stmt {
  final Expr expression;
  Expression(this.expression, );
  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitExpressionStmt(this);
}

class Functional extends Stmt {
  final Token name;
  final List<Token> params;
  final Map<Token,Object?> namedParams;
  final List<Stmt> body;
  Functional(this.name, this.params, this.namedParams, this.body, );
  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitFunctionalStmt(this);
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

class Return extends Stmt {
  final Token keyword;
  final Expr? value;
  Return(this.keyword, this.value, );
  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitReturnStmt(this);
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
  T visitClassStmt(Class stmt);
  T visitExpressionStmt(Expression stmt);
  T visitFunctionalStmt(Functional stmt);
  T visitIfStmt(If stmt);
  T visitPrintStmt(Print stmt);
  T visitReturnStmt(Return stmt);
  T visitVarStmt(Var stmt);
  T visitWhileStmt(While stmt);
}
