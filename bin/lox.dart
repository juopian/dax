import 'dart:io';
import 'package:dax/error.dart';
import 'package:dax/parser.dart';
import 'package:dax/resolver.dart';
import 'package:dax/scanner.dart';
import 'package:dax/stmt.dart';
import 'package:dax/token.dart';
import 'package:dax/lox_callable.dart';
import 'package:dax/interpreter.dart';
import 'ast_printer.dart';

late Interpreter interpreter;
bool showTokens = false;
bool showAst = false;
void main(List<String> arguments) async {
  interpreter = Interpreter(); 
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
  run('', sourceFile: path);
  if (hadError) {
    exitCode = 65;
  }
  if (hadRuntimeError) {
    exitCode = 70;
  }
}

void runPrompt() async {
  final List<String> history = [];
  int historyIndex = 0;
  stdin.echoMode = false;
  stdin.lineMode = false;

  for (;;) {
    stdout.write('> ');
    StringBuffer inputBuffer = StringBuffer();
    bool enterPressed = false;
    while (!enterPressed) {
      int byte = stdin.readByteSync();
      if (byte == 10) {
        enterPressed = true;
        stdout.write('\n');
      } else if (byte == 127) {
        String line = inputBuffer.toString();
        if (line.isNotEmpty) {
          stdout.write('\b \b');
          inputBuffer.clear();
          inputBuffer.write(line.substring(0, line.length - 1));
        }
      } else if (byte == 27) {
        stdin.readByteSync();
        int arrowkey = stdin.readByteSync();
        if (arrowkey == 65) {
          // uparrow
          if (historyIndex > 0) {
            historyIndex--;
            stdout.write('\x1B[2K\r> ${history[historyIndex]}');
            inputBuffer.clear();
            inputBuffer.write(history[historyIndex]);
          }
        } else if (arrowkey == 66) {
          // downarrow
          if (historyIndex < history.length - 1) {
            historyIndex++;
            stdout.write('\x1B[2K\r> ${history[historyIndex]}');
            inputBuffer.clear();
            inputBuffer.write(history[historyIndex]);
          } else {
            historyIndex = history.length;
            stdout.write('\x1B[2K\r> ');
            inputBuffer.clear();
          }
        }
      } else {
        stdout.write(String.fromCharCode(byte));
        inputBuffer.writeCharCode(byte);
      }
    }

    String line = inputBuffer.toString();
    if (line.toLowerCase() == 'exit') {
      break;
    }
    if (line.isNotEmpty) {
      history.add(line);
      historyIndex = history.length;
      await run(line);
      hadError = false;
    }
  }
  stdin.echoMode = true;
  stdin.lineMode = true;
}

Future<void> run(String source, {String sourceFile = ''}) async {
  LoxReader? reader;
  if (sourceFile.isNotEmpty) {
    reader = LoxReader(sourceFile);
  }
  Scanner scanner = Scanner(source, reader: reader, loadedFiles: []);
  List<Token> tokens = await scanner.scanTokens();
  for (var token in tokens) {
    if (showTokens) {
      stdout.writeln(token.toString());
    }
  }
  Parser parser = Parser(tokens);
  try {
    List<Stmt> statements = parser.parse();
    for (Stmt stmt in statements) {
      if (showAst) {
        print("ast:" + AstPrinter().printStmt(stmt));
      }
    }
    Resolver resolver = Resolver(interpreter);
    resolver.resolve(statements);
    interpreter.interpret(statements);
  } catch (e) {
    return;
  }
}
