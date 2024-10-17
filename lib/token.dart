import 'token_type.dart';

class Token {
  final TokenType type;
  final String lexeme;
  final Object? literal;
  final int line;
  final String sourceFile;

  Token(this.type, this.lexeme, this.literal, this.line,
      {this.sourceFile = ''});

  @override
  String toString() {
    return "$type $lexeme $literal";
  }
}
