import 'dart:io';

bool hadError = false;

void error(int line, String message) {
  report(line, "", message);
}

void report(int line, String where, String message) {
  stdout.writeln("[line $line] Error $where: $message");
  hadError = true;
}
