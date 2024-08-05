import 'dart:io';

import 'package:dax/runtime_error.dart';
import 'package:dax/token.dart';
import 'package:dax/token_type.dart';

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
