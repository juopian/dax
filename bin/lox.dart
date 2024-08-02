import 'package:cli/cli.dart' as cli;

void main(List<String> arguments) {
  if (arguments.length > 1) {
    print('Too many arguments.');
  } else if(arguments.length == 1) {
    print("runFile");
  } else {
    print("runPrompt") ; 
  }
}
