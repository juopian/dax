import 'error.dart';
import 'expr.dart';
import 'stmt.dart';
import 'token.dart';
import 'token_type.dart';

class ParseError implements Exception {
  final String message;
  ParseError(this.message);
}

class Parser {
  final List<Token> tokens;
  int current = 0;

  Parser(this.tokens);

  Expr? parseExpression() {
    try {
      return expression();
    } on ParseError {
      return null;
    }
  }

  List<Stmt> parse() {
    List<Stmt> statements = [];
    while (!isAtEnd()) {
      Stmt? decl = declaration();
      if (decl != null) {
        statements.add(decl);
      }
    }
    return statements;
  }

  Stmt? declaration({bool rethrowError = true}) {
    try {
      if (match([TokenType.CLASS])) return classDeclaration();
      if (match([TokenType.FUN])) return function("function");
      if (match([TokenType.VAR])) return varDeclaration();
      return statement();
    } on ParseError {
      synchronize();
      if (rethrowError) {
        rethrow;
      } else {
        return null;
      }
    }
  }

  Stmt classDeclaration() {
    Token name = consume(TokenType.IDENTIFIER, "Expect class name.");

    Variable? superclass;
    if (match([TokenType.EXTENDS])) {
      consume(TokenType.IDENTIFIER, "Expect superclass name.");
      superclass = Variable(previous());
    }

    consume(TokenType.LEFT_BRACE, "Expect '{' before class body.");

    List<Functional> methods = [];
    while (!check(TokenType.RIGHT_BRACE) && !isAtEnd()) {
      methods.add(function("method"));
    }

    consume(TokenType.RIGHT_BRACE, "Expect '}' after class body.");

    return Class(name, superclass, methods);
  }

  Functional function(String kind) {
    Token name = consume(TokenType.IDENTIFIER, "Expect $kind name.");
    consume(TokenType.LEFT_PAREN, "Expect '(' after $kind name.");
    List<Token> parameters = [];
    if (!check(TokenType.RIGHT_PAREN)) {
      do {
        if (check(TokenType.RIGHT_PAREN)) break;
        if (parameters.length >= 255) {
          error(peek(), "Can't have more than 255 parameters.");
        }
        parameters.add(
          consume(TokenType.IDENTIFIER, "Expect parameter name."),
        );
      } while (match([TokenType.COMMA]));
    }
    consume(TokenType.RIGHT_PAREN, "Expect ')' after parameters.");
    match([TokenType.ASYNC]);
    consume(TokenType.LEFT_BRACE, "Expect '{' before $kind body.");
    List<Stmt> body = block();
    return Functional(name, parameters, body);
  }

  Stmt varDeclaration() {
    Token name = consume(TokenType.IDENTIFIER, "Expect variable name.");
    Expr? initializer;
    if (match([TokenType.EQUAL])) {
      initializer = expression();
    } else {
      initializer = null;
    }
    consume(TokenType.SEMICOLON, "Expect ';' after variable declaration.");
    return Var(name, initializer);
  }

  // Stmt classDeclaration() {

  Stmt statement() {
    if (match([TokenType.FOR])) return forStatement();
    if (match([TokenType.IF])) return ifStatement();
    if (match([TokenType.PRINT])) return printStatement();
    if (match([TokenType.RETURN])) return returnStatement();
    if (match([TokenType.WHILE])) return whileStatement();
    if (match([TokenType.LEFT_BRACE])) return Block(block());
    if (matchforEach()) return foreachStatement();
    return expressionStatement();
  }

  bool matchforEach() {
    var currentSnap = current;
    bool isMatch = false;
    arrayOrMap();
    if (match([TokenType.DOT])) {
      if (check(TokenType.FOREACH)) {
        isMatch = true;
      }
    }
    current = currentSnap;
    return isMatch;
  }

  Stmt forStatement() {
    consume(TokenType.LEFT_PAREN, "Expect '(' after 'for'.");
    Stmt? initializer;
    if (match([TokenType.SEMICOLON])) {
      initializer = null;
    } else if (match([TokenType.VAR])) {
      initializer = varDeclaration();
    } else {
      initializer = expressionStatement();
    }
    Expr? condition;
    if (!check(TokenType.SEMICOLON)) {
      condition = expression();
    }
    consume(TokenType.SEMICOLON, "Expect ';' after loop condition.");
    Expr? increment;
    if (!check(TokenType.RIGHT_PAREN)) {
      increment = expression();
    }
    consume(TokenType.RIGHT_PAREN, "Expect ')' after for clause.");

    Stmt body = statement();

    if (increment != null) {
      body = Block([body, Expression(increment)]);
    }
    condition ??= Literal(true);
    body = While(condition, body);
    if (initializer != null) {
      body = Block([initializer, body]);
    }
    return body;
  }

  Stmt ifStatement() {
    consume(TokenType.LEFT_PAREN, "Expect '(' after 'if'.");
    Expr condition = expression();
    consume(TokenType.RIGHT_PAREN, "Expect ')' after if condition.");
    Stmt thenBranch = statement();
    Stmt? elseBranch;
    if (match([TokenType.ELSE])) {
      elseBranch = statement();
    }
    return If(condition, thenBranch, elseBranch);
  }

  Stmt returnStatement() {
    Token keyword = previous();
    Expr? value;
    if (!check(TokenType.SEMICOLON)) {
      value = expression();
    }
    consume(TokenType.SEMICOLON, "Expect ';' after return value.");
    return Return(keyword, value);
  }

  Stmt whileStatement() {
    consume(TokenType.LEFT_PAREN, "Expect '(' after 'while'.");
    Expr condition = expression();
    consume(TokenType.RIGHT_PAREN, "Expect ')' after condition.");
    Stmt body = statement();

    return While(condition, body);
  }

  Stmt printStatement() {
    Expr value = expression();
    consume(TokenType.SEMICOLON, "Expect ';' after value.");
    return Print(value);
  }

  List<Stmt> block() {
    List<Stmt> statements = [];
    while (!check(TokenType.RIGHT_BRACE) && !isAtEnd()) {
      statements.add(declaration()!);
    }
    consume(TokenType.RIGHT_BRACE, "Expect '}' after block.");
    return statements;
  }

  Stmt foreachStatement() {
    Expr callee = arrayOrMap();
    consume(TokenType.DOT, "Expect '.' before 'foreach'.");
    Token name = consume(TokenType.FOREACH, "Expect 'foreach'.");
    consume(TokenType.LEFT_PAREN, "Expect '(' after 'map'.");
    Expr expr = expression();
    consume(TokenType.RIGHT_PAREN, "Expect ')' after parameters.");
    consume(TokenType.SEMICOLON, "Expect ';' after expression.");
    return ForEach(callee, name, expr);
  }

  Stmt expressionStatement() {
    Expr expr = expression();
    consume(TokenType.SEMICOLON, "Expect ';' after expression.");
    return Expression(expr);
  }

  Expr expression() {
    return assignment();
    // return equality();
  }

  Expr assignment() {
    // Expr expr = equality();
    Expr expr = conditional();
    if (match([TokenType.EQUAL])) {
      Token equals = previous();
      Expr value = assignment();
      if (expr is Variable) {
        Token name = expr.name;
        return Assign(name, value);
      } else if (expr is Get) {
        Get _get = expr;
        return Set(_get.object, _get.name, value);
      }
      throw error(equals, "Invalid assignment target.");
    }
    return expr;
  }

  Expr conditional() {
    Expr expr = or();
    Expr? thenExpr;
    Expr? elseExpr;
    while (match([TokenType.QUESTION, TokenType.COLON])) {
      if (previous().type == TokenType.QUESTION) {
        thenExpr = or();
      } else if (previous().type == TokenType.COLON) {
        elseExpr = or();
      }
    }
    if (thenExpr != null && elseExpr != null) {
      return Conditional(expr, thenExpr, elseExpr);
    }
    return expr;
  }

  Expr or() {
    Expr expr = and();
    while (match([TokenType.OR])) {
      Token operator = previous();
      Expr right = and();
      expr = Logical(expr, operator, right);
    }
    return expr;
  }

  Expr and() {
    Expr expr = equality();
    while (match([TokenType.AND])) {
      Token operator = previous();
      Expr right = equality();
      expr = Logical(expr, operator, right);
    }
    return expr;
  }

  Expr equality() {
    Expr expr = comparison();
    while (match([TokenType.BANG_EQUAL, TokenType.EQUAL_EQUAL])) {
      Token operator = previous();
      Expr right = comparison();
      expr = Binary(expr, operator, right);
    }
    return expr;
  }

  Expr comparison() {
    Expr expr = term();
    while (match([
      TokenType.GREATER,
      TokenType.GREATER_EQUAL,
      TokenType.LESS,
      TokenType.LESS_EQUAL
    ])) {
      Token operator = previous();
      Expr right = term();
      expr = Binary(expr, operator, right);
    }
    return expr;
  }

  Expr term() {
    Expr expr = factor();
    while (match([TokenType.MINUS, TokenType.PLUS])) {
      Token operator = previous();
      Expr right = factor();
      expr = Binary(expr, operator, right);
    }
    return expr;
  }

  Expr factor() {
    Expr expr = unary();
    while (match([TokenType.SLASH, TokenType.STAR, TokenType.MOD])) {
      Token operator = previous();
      Expr right = unary();
      expr = Binary(expr, operator, right);
    }
    return expr;
  }

  Expr unary() {
    if (match([TokenType.BANG, TokenType.MINUS])) {
      Token operator = previous();
      Expr right = unary();
      return Unary(operator, right);
    }
    // return call();
    return wait();
  }

  Expr wait() {
    if (match([TokenType.AWAIT])) {
      Token operator = previous();
      Expr right = call();
      return Await(operator, right);
    }
    return call();
  }

  Expr call() {
    Expr expr = arrayOrMap();
    while (true) {
      if (match([TokenType.LEFT_PAREN])) {
        expr = finishCall(expr);
      } else if (match([TokenType.DOT])) {
        Token name =
            consume(TokenType.IDENTIFIER, "Expect property name after '.'.");
        if (name.lexeme == 'map') {
          expr = mappingExpr(expr, name);
        } else if (name.lexeme == 'then') {
          expr = thenExpr(expr, name);
        } else {
          expr = Get(expr, name);
        }
      } else if (match([TokenType.LEFT_BRACKET])) {
        expr = indexingExpr(expr);
      } else {
        break;
      }
    }
    return expr;
  }

  Expr indexingExpr(Expr callee) {
    Expr index = expression();
    Token paren = consume(TokenType.RIGHT_BRACKET, "Expect ']' after key.");
    return Indexing(callee, paren, index);
  }

  Expr mappingExpr(Expr callee, Token name) {
    consume(TokenType.LEFT_PAREN, "Expect '(' after 'map'.");
    Expr expr = expression();
    consume(TokenType.RIGHT_PAREN, "Expect ')' after parameters.");
    return Mapping(callee, name, expr);
  }

  Expr thenExpr(Expr callee, Token name) {
    consume(TokenType.LEFT_PAREN, "Expect '(' after 'then'.");
    Expr expr = expression();
    consume(TokenType.RIGHT_PAREN, "Expect ')' after parameters.");
    return Then(callee, name, expr);
  }

  Expr finishCall(Expr callee) {
    List<Expr> arguments = [];
    if (!check(TokenType.RIGHT_PAREN)) {
      do {
        if (check(TokenType.RIGHT_PAREN)) break;
        if (arguments.length >= 255) {
          error(peek(), "Can't have more than 255 arguments.");
        }
        // 检测是否名称参数
        if (peekNext().type == TokenType.COLON) {
          Token name =
              consume(TokenType.IDENTIFIER, "Expect argument name before :.");
          consume(TokenType.COLON, "Expect : after $name.");
          Expr expr = expression();
          arguments.add(Dict({name.lexeme: expr}, true));
        } else {
          arguments.add(expression());
        }
      } while (match([TokenType.COMMA]));
    }

    Token paren = consume(TokenType.RIGHT_PAREN, "Expect ')' after arguments.");

    return Call(callee, paren, arguments);
  }

  Expr arrayOrMap() {
    if (match([TokenType.LEFT_BRACKET])) {
      List<Expr> elements = [];
      if (!check(TokenType.RIGHT_BRACKET)) {
        do {
          if (check(TokenType.RIGHT_BRACKET)) break;
          elements.add(expression());
        } while (match([TokenType.COMMA]));
      }
      consume(TokenType.RIGHT_BRACKET, "Expect ']' after array elements.");
      return Array(elements);
    } else if (match([TokenType.LEFT_BRACE])) {
      Map<String, Expr> entries = {};
      if (!check(TokenType.RIGHT_BRACE)) {
        do {
          if (check(TokenType.RIGHT_BRACE)) break;
          Token key = consume(TokenType.STRING, 'Expect key.');
          consume(TokenType.COLON, "Expect ':' after dictionary key.");
          entries['${key.literal}'] = expression();
        } while (match([TokenType.COMMA]));
      }
      consume(TokenType.RIGHT_BRACE, "Expect '}' after array elements.");
      return Dict(entries, false);
    }
    return primary();
  }

  Expr primary() {
    if (match([TokenType.FALSE])) return Literal(false);
    if (match([TokenType.TRUE])) return Literal(true);
    if (match([TokenType.NIL])) return Literal(null);
    if (match([TokenType.NUMBER, TokenType.STRING])) {
      return Literal(previous().literal);
    }
    if (match([TokenType.IF])) {
      consume(TokenType.LEFT_PAREN, "Expect '(' after 'if'.");
      Expr condition = expression();
      consume(TokenType.RIGHT_PAREN, "Expect ')' after if condition.");
      Expr thenBranch = expression();
      Expr? elseBranch;
      if (match([TokenType.ELSE])) {
        elseBranch = expression();
      }
      return Arrayif(condition, thenBranch, elseBranch);
    }

    if (match([TokenType.SUPER])) {
      Token keyword = previous();
      consume(TokenType.DOT, "Expect '.' after 'SUPER'.");
      Token method =
          consume(TokenType.IDENTIFIER, "Expect superclass method name.");
      return Super(keyword, method);
    }
    if (match([TokenType.THIS])) return This(previous());

    if (match([TokenType.IDENTIFIER])) {
      return Variable(previous());
    }
    var currentSnap = current;
    bool isAnonymous = false;
    if (match([TokenType.LEFT_PAREN])) {
      if (!check(TokenType.RIGHT_PAREN)) {
        do {
          if (check(TokenType.RIGHT_PAREN)) break;
          expression();
        } while (match([TokenType.COMMA]));
      }
      consume(TokenType.RIGHT_PAREN, "Expect ')' after parameters.");
      if (check(TokenType.LEFT_BRACE)) {
        isAnonymous = true;
      }
      current = currentSnap;
    }

    if (isAnonymous) {
      consume(TokenType.LEFT_PAREN, "Expect '(' after map.");
      List<Token> parameters = [];
      if (!check(TokenType.RIGHT_PAREN)) {
        do {
          if (check(TokenType.RIGHT_PAREN)) break;
          parameters.add(
            consume(TokenType.IDENTIFIER, "Expect parameter name."),
          );
        } while (match([TokenType.COMMA]));
      }
      Token paren =
          consume(TokenType.RIGHT_PAREN, "Expect ')' after parameters.");
      consume(TokenType.LEFT_BRACE, "Expect '{' before map body.");
      List<Stmt> body = block();
      Expr anony = Anonymous(paren, parameters, body);
      return anony;
    }
    if (match([TokenType.LEFT_PAREN])) {
      Expr expr = expression();
      consume(TokenType.RIGHT_PAREN, "Expect ')' after expression.");
      return Grouping(expr);
    }
    throw error(peek(), "Expect expression.");
  }

  Token consume(TokenType type, String message) {
    if (!check(type)) {
      throw error(peek(), message);
    }
    return advance();
  }

  bool match(List<TokenType> types) {
    for (TokenType type in types) {
      if (check(type)) {
        advance();
        return true;
      }
    }
    return false;
  }

  bool check(TokenType type) {
    if (isAtEnd()) return false;
    return peek().type == type;
  }

  Token advance() {
    if (!isAtEnd()) current++;
    return previous();
  }

  bool isAtEnd() {
    return peek().type == TokenType.EOF;
  }

  Token peek() {
    return tokens[current];
  }

  Token peekNext() {
    if (current + 1 >= tokens.length) return tokens.last;
    return tokens[current + 1];
  }

  Token previous() {
    return tokens[current - 1];
  }

  ParseError error(Token token, String message) {
    error1(token, message);
    return ParseError(message);
  }

  void synchronize() {
    advance();
    while (!isAtEnd()) {
      if (previous().type == TokenType.SEMICOLON) return;
      switch (peek().type) {
        case TokenType.CLASS:
        case TokenType.FUN:
        case TokenType.VAR:
        case TokenType.FOR:
        case TokenType.IF:
        case TokenType.WHILE:
        case TokenType.PRINT:
        case TokenType.RETURN:
          return;
      }
      advance();
    }
  }
}
