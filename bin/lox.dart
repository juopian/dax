import 'dart:io';
// import 'dart:math';
import "package:dax/error.dart";
// import 'package:dax/cli.dart' as cli;
import 'package:dax/scanner.dart';
import 'package:dax/token.dart';
// import 'package:path/path.dart';

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
        stdout.write('\b \b');
        String line = inputBuffer.toString();
        inputBuffer.clear();
        inputBuffer.write(line.substring(0, line.length - 1));
      } else if (byte == 27) {
        stdin.readByteSync();
        int arrowkey = stdin.readByteSync();
        if (arrowkey == 65) {
          // up arrow
          if (historyIndex > 0) {
            historyIndex--;
            stdout.write('\x1B[2K\r> ${history[historyIndex]}');
            inputBuffer.clear();
            inputBuffer.write(history[historyIndex]);
          }
        } else if (arrowkey == 66) {
          // down arrow
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
    // var line = stdin.readByteSync();
    // if (line == null) break;
    // run(line);
    // hadError = false;

    String line = inputBuffer.toString();
    if (line.toLowerCase() == 'exit') {
      break;
    }
    if (line.isNotEmpty) {
      history.add(line);
      historyIndex = history.length;
      run(line);
      hadError = false;
    }
  }
  stdin.echoMode = true;
  stdin.lineMode = true;
}

void run(String source) {
  Scanner scanner = Scanner(source);

  List<Token> tokens = scanner.scanTokens();
  for (var token in tokens) {
    stdout.writeln(token.toString());
  }
}
