import 'dart:io';
import "package:dax/error.dart";
import 'package:dax/cli.dart' as cli;
import 'package:dax/scanner.dart';
import 'package:dax/token.dart';
import 'package:path/path.dart';

void main(List<String> arguments) {
  exitCode = 0;
  if (arguments.length > 1) {
    print('Usage: dlox [script].\n');
    exitCode = 2;
  } else if (arguments.length == 1) {
    runFile(arguments[0]);
  } else {
    runPrompt();
  }
}

void runFile(String path) {
  // read file from path
  var fileString = File(path).readAsStringSync();
  run(fileString);
  if (hadError) {
    exitCode = 65;
  }
}

void runPrompt() {
  for (;;) {
    stdout.write('> ');
    var line = stdin.readLineSync();
    if (line == null) break;
    run(line);
    hadError = false;
  }
}

void run(String source) {
  Scanner scanner = Scanner(source);

  List<Token> tokens = scanner.scanTokens();
  for (var token in tokens) {
    stdout.writeln(token.toString());
  }
}
