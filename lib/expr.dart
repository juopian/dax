import 'package:dax/token.dart';
import 'package:dax/stmt.dart';

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

class Call extends Expr {
  final Expr callee;
  final Token paren;
  final List<Expr> arguments;
  Call(this.callee, this.paren, this.arguments, );
  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitCallExpr(this);
}

class Array extends Expr {
  final List<Expr> elements;
  Array(this.elements, );
  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitArrayExpr(this);
}

class Dict extends Expr {
  final Map<String,Expr> entries;
  Dict(this.entries, );
  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitDictExpr(this);
}

class Then extends Expr {
  final Expr future;
  final Token name;
  final Object then;
  Then(this.future, this.name, this.then, );
  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitThenExpr(this);
}

class Conditional extends Expr {
  final Expr condition;
  final Expr thenBranch;
  final Expr elseBranch;
  Conditional(this.condition, this.thenBranch, this.elseBranch, );
  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitConditionalExpr(this);
}

class Arrayif extends Expr {
  final Expr condition;
  final Expr thenBranch;
  final Expr? elseBranch;
  Arrayif(this.condition, this.thenBranch, this.elseBranch, );
  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitArrayifExpr(this);
}

class Anonymous extends Expr {
  final Token name;
  final List<Token> params;
  final List<Stmt> body;
  Anonymous(this.name, this.params, this.body, );
  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitAnonymousExpr(this);
}

class Mapping extends Expr {
  final Expr callee;
  final Token name;
  final Object lambda;
  Mapping(this.callee, this.name, this.lambda, );
  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitMappingExpr(this);
}

class Indexing extends Expr {
  final Expr callee;
  final Token name;
  final Expr key;
  Indexing(this.callee, this.name, this.key, );
  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitIndexingExpr(this);
}

class Await extends Expr {
  final Token name;
  final Expr future;
  Await(this.name, this.future, );
  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitAwaitExpr(this);
}

class Get extends Expr {
  final Expr object;
  final Token name;
  Get(this.object, this.name, );
  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitGetExpr(this);
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

class Set extends Expr {
  final Expr object;
  final Token name;
  final Expr value;
  Set(this.object, this.name, this.value, );
  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitSetExpr(this);
}

class Super extends Expr {
  final Token keyword;
  final Token method;
  Super(this.keyword, this.method, );
  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitSuperExpr(this);
}

class This extends Expr {
  final Token keyword;
  This(this.keyword, );
  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitThisExpr(this);
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
  T visitCallExpr(Call expr);
  T visitArrayExpr(Array expr);
  T visitDictExpr(Dict expr);
  T visitThenExpr(Then expr);
  T visitConditionalExpr(Conditional expr);
  T visitArrayifExpr(Arrayif expr);
  T visitAnonymousExpr(Anonymous expr);
  T visitMappingExpr(Mapping expr);
  T visitIndexingExpr(Indexing expr);
  T visitAwaitExpr(Await expr);
  T visitGetExpr(Get expr);
  T visitGroupingExpr(Grouping expr);
  T visitLiteralExpr(Literal expr);
  T visitLogicalExpr(Logical expr);
  T visitSetExpr(Set expr);
  T visitSuperExpr(Super expr);
  T visitThisExpr(This expr);
  T visitUnaryExpr(Unary expr);
  T visitVariableExpr(Variable expr);
}
