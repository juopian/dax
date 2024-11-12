import 'lox_callable.dart';
import "token_type.dart";
import 'token.dart';
// import 'interpreter.dart';
import 'error.dart';

class Scanner {
  String source;
  String sourceFile = '';
  LoxReader? reader;
  final List<Token> tokens = [];
  List<String> loadedFiles;
  int start = 0;
  int current = 0;
  int line = 1;

  final Map<String, TokenType> keywords = {
    "and": TokenType.AND,
    "&&": TokenType.AND,
    "class": TokenType.CLASS,
    "else": TokenType.ELSE,
    "false": TokenType.FALSE,
    "for": TokenType.FOR,
    "fun": TokenType.FUN,
    "if": TokenType.IF,
    "null": TokenType.NIL,
    "or": TokenType.OR,
    "||": TokenType.OR,
    "print": TokenType.PRINT,
    "return": TokenType.RETURN,
    "super": TokenType.SUPER,
    "this": TokenType.THIS,
    "true": TokenType.TRUE,
    "var": TokenType.VAR,
    "while": TokenType.WHILE,
    "await": TokenType.AWAIT,
    "async": TokenType.ASYNC,
    "extends": TokenType.EXTENDS,
  };

  Scanner(this.source, {this.reader, required this.loadedFiles});

  Future<List<Token>> scanTokens({bool isBase = true}) async {
    if (reader != null) {
      Uri u = Uri.parse(reader!.pathOrUrl);
      source = await reader!.read();
      sourceFile = u.pathSegments.last;
    }
    while (!isAtEnd()) {
      start = current;
      await scanToken();
    }
    if (isBase) {
      tokens.add(Token(TokenType.EOF, "", null, line, sourceFile: sourceFile));
    }
    return tokens;
  }

  Future<void> scanToken() async {
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
      case "'":
        string("'");
        break;
      case '"':
        string('"');
        break;
      default:
        if (isDigit(c, false)) {
          number(c);
        } else if (isAlpha(c)) {
          await identifier();
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


  Future<void> identifier() async {
    while (isAlphaNumeric(peek())) {
      advance();
    }
    String text = source.substring(start, current);
    if (text == 'import') {
      while (peek() == ' ' || peek() == '\t') {
        advance();
      }
      if (peek() != '"' && peek() != "'") {
        throw Exception("Expect '\"' after import.");
      }
      advance();

      String filePath = "";
      while ((peek() != '"' && peek() != "'") && !isAtEnd()) {
        filePath += advance();
      }

      if (isAtEnd()) throw Exception("Unterminated string in import.");

      advance(); // pass double quote
      advance(); // pass semicolon
      var oldFilePath = reader!.pathOrUrl;
      final currentDirectory = Uri.parse(oldFilePath).resolve(filePath);
      reader!.path = currentDirectory.toString();
      if (loadedFiles.contains(currentDirectory.path)) {
        return;
      }
      loadedFiles.add(currentDirectory.path);
      Scanner scanner = Scanner('', reader: reader, loadedFiles: loadedFiles);
      List<Token> tks = await scanner.scanTokens(isBase: false);
      reader!.path = oldFilePath;
      tokens.addAll(tks);
      return;
    }
    TokenType type = TokenType.IDENTIFIER;
    if (keywords.containsKey(text)) {
      type = keywords[text]!;
    }
    addToken(type);
  }

  void string(String c) {
    bool interplote = false;
    while (peek() != c && !isAtEnd()) {
      if (peek() == '\n') line++;
      if (peek() == '\$') {
        advance();
        if (peek() == '{') {
          if (interplote == true) {
            addToken(TokenType.PLUS);
          }
          if (current - start > 2) {
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
        c == '_'|| c == '&' || c == '|';
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
                  c.codeUnitAt(0) <= '9'.codeUnitAt(0)) |
              (c.codeUnitAt(0) >= 'A'.codeUnitAt(0) &&
                  c.codeUnitAt(0) <= 'F'.codeUnitAt(0))) &&
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
    tokens.add(Token(type, text, literal, line, sourceFile: sourceFile));
  }

  void addToken2(TokenType type, String lexeme) {
    tokens.add(Token(type, lexeme, null, line, sourceFile: sourceFile));
  }

  bool match(String expected) {
    if (isAtEnd()) return false;
    if (source[current] != expected) return false;
    current++;
    return true;
  }
}
