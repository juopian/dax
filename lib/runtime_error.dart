
import 'token.dart';

class RuntimeError implements Exception {
  final Token token;
  final String message_;
  RuntimeError(this.token, this.message_);

  String get message => '"${token.sourceFile}" [line ${token.line}] ' + message_;
}