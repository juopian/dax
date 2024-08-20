import "token_type.dart";
import 'token.dart';
import 'error.dart';

class Scanner {
  final String source;
  final List<Token> tokens = [];
  int start = 0;
  int current = 0;
  int line = 1;

  final Map<String, TokenType> keywords = {
    "and": TokenType.AND,
    "class": TokenType.CLASS,
    "else": TokenType.ELSE,
    "false": TokenType.FALSE,
    "for": TokenType.FOR,
    "fun": TokenType.FUN,
    "if": TokenType.IF,
    "nil": TokenType.NIL,
    "or": TokenType.OR,
    "print": TokenType.PRINT,
    "return": TokenType.RETURN,
    "super": TokenType.SUPER,
    "this": TokenType.THIS,
    "true": TokenType.TRUE,
    "var": TokenType.VAR,
    "while": TokenType.WHILE,
    "await": TokenType.AWAIT,
    "async": TokenType.ASYNC,
  };

  Scanner(this.source);

  List<Token> scanTokens() {
    while (!isAtEnd()) {
      start = current;
      scanToken();
    }

    tokens.add(Token(TokenType.EOF, "", null, line));
    return tokens;
  }

  void scanToken() {
    String c = advance();
    switch (c) {
      case '[':
        addToken(TokenType.LEFT_BRACKET);
        break;
      case ']':
        addToken(TokenType.RIGHT_BRACKET);
        break;
      case '(':
        addToken(TokenType.LEFT_PAREN);
        break;
      case ')':
        addToken(TokenType.RIGHT_PAREN);
        break;
      case '{':
        addToken(TokenType.LEFT_BRACE);
        break;
      case '}':
        addToken(TokenType.RIGHT_BRACE);
        break;
      case '?':
        addToken(TokenType.QUESTION);
        break;
      case ':':
        addToken(TokenType.COLON);
        break;
      case ',':
        addToken(TokenType.COMMA);
        break;
      case '.':
        addToken(TokenType.DOT);
        break;
      case '-':
        if (allow()) {
          number(c);
        } else {
          addToken(TokenType.MINUS);
        }
        break;
      case '+':
        addToken(TokenType.PLUS);
        break;
      case ';':
        addToken(TokenType.SEMICOLON);
        break;
      case '*':
        addToken(TokenType.STAR);
        break;
      case '%':
        addToken(TokenType.MOD);
        break;
      case '!':
        if (match('=')) {
          addToken(TokenType.BANG_EQUAL);
        } else {
          addToken(TokenType.BANG);
        }
        break;
      case '=':
        if (match('=')) {
          addToken(TokenType.EQUAL_EQUAL);
        } else {
          addToken(TokenType.EQUAL);
        }
        break;
      case '<':
        if (match('=')) {
          addToken(TokenType.LESS_EQUAL);
        } else {
          addToken(TokenType.LESS);
        }
        break;
      case '>':
        if (match('=')) {
          addToken(TokenType.GREATER_EQUAL);
        } else {
          addToken(TokenType.GREATER);
        }
        break;
      case '/':
        if (match('/')) {
          while (peek() != '\n' && !isAtEnd()) {
            advance();
          }
        } else {
          addToken(TokenType.SLASH);
        }
        break;
      case ' ':
      case '\r':
      case '\t':
        break;
      case '\n':
        line++;
        break;
      case '"':
        string();
        break;
      default:
        if (isDigit(c, false)) {
          number(c);
        } else if (isAlpha(c)) {
          identifier();
        } else {
          error(line, "Unexpected character.");
        }
        break;
    }
  }

  bool allow() {
    if (tokens.isEmpty) return true;
    Token previous = tokens.last;
    return (previous.type == TokenType.EQUAL ||
            previous.type == TokenType.LEFT_PAREN) ||
        previous.type == TokenType.COMMA ||
        previous.type == TokenType.COLON ||
        previous.type == TokenType.MINUS ||
        previous.type == TokenType.PLUS ||
        previous.type == TokenType.STAR ||
        previous.type == TokenType.SLASH ||
        previous.type == TokenType.PRINT;
  }

  void identifier() {
    while (isAlphaNumeric(peek())) {
      advance();
    }
    String text = source.substring(start, current);
    TokenType type = TokenType.IDENTIFIER;
    if (keywords.containsKey(text)) {
      type = keywords[text]!;
    }
    addToken(type);
  }

  void string() {
    bool interplote = false;
    while (peek() != '"' && !isAtEnd()) {
      if (peek() == '\n') line++;
      if (peek() == '\$') {
        advance();
        if (peek() == '{') {
          // print("start : $start, current: $current");
          if (current - start > 2) {
            if (interplote == true) {
              addToken(TokenType.PLUS);
            }
            addToken1(
                TokenType.STRING, source.substring(start + 1, current - 1));
            addToken(TokenType.PLUS);
          }
          interplote = true;
          addToken(TokenType.LEFT_PAREN);
          advance();
          while (peek() != '}' && !isAtEnd()) {
            start = current;
            scanToken();
          }
          if (peek() == '}') {
            addToken(TokenType.RIGHT_PAREN);
            addToken(TokenType.DOT);
            addToken2(TokenType.IDENTIFIER, "toString");
            start = current;
            advance();
          } else {
            error(line, "Unterminated expression in string interpolation.");
          }
        }
      } else {
        advance();
      }
    }

    if (isAtEnd()) {
      error(line, "Unterminated string.");
      return;
    }

    advance();

    if (interplote) {
      addToken(TokenType.PLUS);
    }
    addToken1(TokenType.STRING, source.substring(start + 1, current - 1));
  }

  void number(String c) {
    bool isHex = false;
    if (c == '0' && peek() == 'x') {
      isHex = true;
      advance();
    }
    while (isDigit(peek(), isHex)) {
      advance();
    }
    bool isDouble = false;
    if (peek() == '.' && isDigit(peekNext(), false)) {
      isDouble = true;
      advance();
      while (isDigit(peek(), false)) {
        advance();
      }
    }

    String numberStr = source.substring(start, current);
    if (isDouble) {
      addToken1(TokenType.NUMBER, double.parse(numberStr));
    } else {
      addToken1(TokenType.NUMBER, int.parse(numberStr));
    }
  }

  String peekNext() {
    if (current + 1 >= source.length) return '\u0000';
    return source[current + 1];
  }

  bool isAlpha(String c) {
    return (c.codeUnitAt(0) >= 'a'.codeUnitAt(0) &&
            c.codeUnitAt(0) <= 'z'.codeUnitAt(0)) ||
        (c.codeUnitAt(0) >= 'A'.codeUnitAt(0) &&
            c.codeUnitAt(0) <= 'Z'.codeUnitAt(0)) ||
        c == '_';
  }

  bool isAlphaNumeric(String c) {
    return isAlpha(c) || isDigit(c, false);
  }

  String peek() {
    if (isAtEnd()) return '\u0000';
    return source[current];
  }

  bool isDigit(String c, bool isHex) =>
      (c.codeUnitAt(0) >= '0'.codeUnitAt(0) &&
          c.codeUnitAt(0) <= '9'.codeUnitAt(0) &&
          !isHex) |
      ((((c.codeUnitAt(0) >= 'a'.codeUnitAt(0) &&
                  c.codeUnitAt(0) <= 'f'.codeUnitAt(0)) |
              (c.codeUnitAt(0) >= '0'.codeUnitAt(0) &&
                  c.codeUnitAt(0) <= '9'.codeUnitAt(0))) &&
          isHex));

  bool isAtEnd() {
    bool atEnd = current >= source.length;
    return atEnd;
  }

  String advance() {
    current++;
    return source[current - 1];
  }

  void addToken(TokenType type) {
    addToken1(type, null);
  }

  void addToken1(TokenType type, Object? literal) {
    String text = source.substring(start, current);
    tokens.add(Token(type, text, literal, line));
  }

  void addToken2(TokenType type, String lexeme) {
    tokens.add(Token(type, lexeme, null, line));
  }

  bool match(String expected) {
    if (isAtEnd()) return false;
    if (source[current] != expected) return false;
    current++;
    return true;
  }
}
