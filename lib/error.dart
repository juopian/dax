import 'dart:io';

import 'runtime_error.dart';
import 'token.dart';
import 'token_type.dart';

bool hadError = false;
bool hadRuntimeError = false; 

void error(int line, String message) {
  report(line, "", message);
}

void runtimeError(RuntimeError error) {
  print('${error.message}\n[line ${error.token.line}]');
  hadRuntimeError = true;
}

void report(int line, String where, String message) {
  stdout.writeln("[line $line] Error $where: $message");
  hadError = true;
}

void error1(Token token, String message) {
  if (token.type == TokenType.EOF) {
    report(token.line, " at end", message);
  } else {
    report(token.line, " at '${token.lexeme}'", message);
  }
}
